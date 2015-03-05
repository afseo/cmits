#!/bin/bash
# --- BEGIN DISCLAIMER ---
# Those who use this do so at their own risk;
# AFSEO does not provide maintenance nor support.
# --- END DISCLAIMER ---
# --- BEGIN AFSEO_DATA_RIGHTS ---
# This is a work of the U.S. Government and is placed
# into the public domain in accordance with 17 USC Sec.
# 105. Those who redistribute or derive from this work
# are requested to include a reference to the original,
# at <https://github.com/afseo/cmits>, for example by
# including this notice in its entirety in derived works.
# --- END AFSEO_DATA_RIGHTS ---

run_test () {
    local test=$1
    pushd tests >& /dev/null
    PREAMBLE=${PREAMBLE:-../preamble}
    if [ ! -d $test\-expected ]; then
        echo test $test FAILED: no expected values to compare with >&2
        return 1
    fi
    rm -rf $test\-actual
    cp -R pristine $test\-actual
    set -e
    test_$test
    set +e
    local retval=0
    local outfile=$(mktemp)
    if ! diff -ru -x .svn $test\-actual $test\-expected > $outfile; then
        echo FAILED: differences found >&2
        cat $outfile
        retval=1
    fi
    rm -f $outfile
    popd >& /dev/null
    return $retval
}

test_lorem () {
    $PREAMBLE apply LOREM lorem-actual
}

test_lorem_remove () {
    $PREAMBLE apply LOREM lorem_remove-actual
    $PREAMBLE remove LOREM lorem_remove-actual
}

test_atsign () {
    $PREAMBLE apply ATSIGN atsign-actual
}

test_lorem_blank_lines () {
    $PREAMBLE apply LOREM_BLANK_LINES lorem_blank_lines-actual
}

# Grab all functions whose name starts with test_.
TESTS=( $(declare -F -p | cut -d' ' -f3 | grep '^test_' | sed 's/^test_//g') )

# We want to execute all the tests, but still return an error value if any of
# them fail.
aggregate_retval=0
for test in ${TESTS[*]}; do
    echo -n "$test ... "
    if run_test $test; then
        echo "ok"
    else
        # run_test already echoed FAILED for us, above.
        aggregate_retval=1
    fi
done

if [ $aggregate_retval = 0 ]; then
    echo All tests succeeded.
fi

exit $aggregate_retval

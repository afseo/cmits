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
def lines_to_file(file_handle):
    """Write lines to a file.

    Input: strings. (No Unicode handling.)
    Output: nothing.
    Side effects: writes to file_handle.

    Closes the file_handle given when the input ends.
    """
    def coro(target):
        try:
            while True:
                x = (yield)
                file_handle.write(x)
        except GeneratorExit:
            file_handle.close()
    return coro

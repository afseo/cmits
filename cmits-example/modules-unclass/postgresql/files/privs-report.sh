#!/bin/bash

# e.g. _times 30 echo hello
_times () { local n=$1 i; shift; for (( i=0; $i < $n; i++ )); do "$@"; done; }

# e.g. hdecoration 70 1
_habove () {
    local width="$1" level="$2"
    case $level in
        1) echo; _times $width echo -n '*'; echo;;
        2)       _times $width echo -n '.'; echo;;
    esac
}

# future expansion
_hbelow () {
    local width="$1" level="$2"
    case $level in
        1) _times $width echo -n '*'; echo;;
        2) _times $width echo -n '.'; echo;;
    esac
}

# e.g. header 1 This is some text
header () {
    local width=70 level="$1"
    shift
    local message="$*"
    echo
    _habove $width $level
    # if the message is narrower than width, center it
    if [ ${#message} -lt $width ]; then
        _times $(( ( $width - ${#message} ) / 2 )) echo -n " "
    fi
    echo "$message"
    _hbelow $width $level
    echo
}


# parameters: database, piece of sql
AS_PG_IN () {
    db="$1"; shift; runuser postgres -c "psql -d '$db' <<<'$*'"
}
# same, but no text alignment, column headers, or row count
RAW_AS_PG_IN () {
    db="$1"; shift; runuser postgres -c "psql -Atq -d '$db' <<<'$*'"
}

# no parameters; lists connectable databases
databases () {
    # template0 does not allow connections; do not list it
    RAW_AS_PG_IN postgres 'select datname from pg_database where datallowconn'
}

header 1 "Roles:"
AS_PG_IN postgres '\du'
header 1 "Databases and database-level privileges:"
# do not show encodings, which \l does
AS_PG_IN postgres 'select datname, datacl from pg_database'
header 1 "Privileges inside each database:"
for db in $(databases); do
    header 2 "$db"
    AS_PG_IN "$db" '\dp'
done

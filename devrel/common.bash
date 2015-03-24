set -o errexit
set -o nounset

declare -r debug='false'

function make_temp_file
{
    local template="$1"
    if [[ $template != *XXXXXX ]]
    then
        template="$template.XXXXXX"
    fi
    mktemp -t "$template"
}

function now
{
    date '+%Y-%m-%d %H:%M:%S'
}

function pwarn
{
    echo "$(now) [warning]: $@" 1>&2
}

function perr
{
    echo "$(now) [error]: $@" 1>&2
}

function pinfo
{
    echo "$(now) [info]: $@"
}

function pdebug
{
    if [[ $debug == 'true' ]]
    then
        echo "$(now) [debug]: $@"
    fi
}

function errexit
{
    perr "$@"
    exit 1
}

function onexit
{
    echo Exiting!
    (( ${#DIRSTACK[*]} > 1 )) && popd
}

trap onexit EXIT


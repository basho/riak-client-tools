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

function pinfo_n
{
    echo -n "$(now) [info]: $@"
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

function transfers_in_progress
{
    local retval='in_progress'
    local transfers_out="$(make_temp_file riak-admin-transfers)"

    $riak_admin transfers > $transfers_out 2>&1
    if grep -iqF 'Node is not running' $transfers_out
    then
        perr 'Riak transfers did not complete. Error!'
        retval='error' # Return error
    elif grep -iqF 'No transfers active' $transfers_out
    then
        retval='done' # No longer in progress
    else
        retval='in_progress' # Still in progress
    fi
    rm -f $transfers_out
    echo $retval
}

function wait_for_transfers
{
    local transfer_status="$(transfers_in_progress)"
    while [[ $transfer_status == 'in_progress' ]]
    do
        pinfo 'Transfers in progress.'
        sleep 5
        transfer_status="$(transfers_in_progress)"
    done
    pinfo "Transfer status: $transfer_status"

    if [[ $transfer_status == 'error' ]]
    then
        perr 'Transfers errored!'
        return 1
    fi
    return 0
}

function get_dev_node_count
{
    declare -i dev_node_count="$(ls -1 . | grep '^dev[0-9]\+$' | wc -l)"
    if (( dev_node_count == 0 ))
    then
        perr "No dev nodes found in $dev_cluster_path"
        return 1
    fi
    return 0
}

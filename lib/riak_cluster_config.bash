function riak_cluster_config
{
    # NB: using rcc_ prefix to prevent name clashes
    local -r rcc_riak_admin="$1"
    local -ir rcc_http_port="$2"
    local -r rcc_strong_consistency="${3:-false}" # NB: not used anymore, keep as placeholder
    local -r rcc_use_security="${4:-false}"
    local -r rcc_bucket_type_file_path="${5:-nopath}"

    local rcc_btf=''
    local rcc_bucket_type_def=''
    set +o errexit
    for rcc_bucket_type_file in "$rcc_bucket_type_file_path"/*
    do
        rcc_bucket_type_def="$(< $rcc_bucket_type_file)"
        rcc_bucket_type_name="$(basename $rcc_bucket_type_file)"
        $rcc_riak_admin bucket-type create "$rcc_bucket_type_name" "$rcc_bucket_type_def"
        $rcc_riak_admin bucket-type activate "$rcc_bucket_type_name"
    done
    set -o errexit

    set +o errexit
    echo -n 'Setting properties on test_multi_bucket HTTP CODE:'
    curl -4so /dev/null -w "%{http_code}" -XPUT -H 'Content-type: application/json' localhost:$rcc_http_port/buckets/test_multi_bucket/props -d '{"props":{"allow_mult":true,"last_write_wins":false}}'
    echo ' ...DONE'
    set -o errexit

    if [[ $rcc_use_security == 'true' ]]
    then
        # NB: don't exit on error due to 2.0.7
        # TODO: set -o errexit when all Riak versions >= 2.1.4
        set +o errexit
        $rcc_riak_admin security enable
        $rcc_riak_admin security add-group test

        # cert auth users
        $rcc_riak_admin security add-user riakuser 'groups=test'
        $rcc_riak_admin security add-source riakuser 0.0.0.0/0 certificate
        $rcc_riak_admin security add-user certuser 'groups=test'
        $rcc_riak_admin security add-source certuser 0.0.0.0/0 certificate

        # password auth users
        $rcc_riak_admin security add-user riakpass 'password=Test1234' 'groups=test'
        $rcc_riak_admin security add-user user 'password=password' 'groups=test'
        $rcc_riak_admin security add-source riakpass 0.0.0.0/0 password
        $rcc_riak_admin security add-source user 0.0.0.0/0 password

        # trust auth users
        $rcc_riak_admin security add-user riak_trust_user password=riak_trust_user
        $rcc_riak_admin security add-source riak_trust_user 0.0.0.0/0 trust

        # NB: Riak 2.0.7 does not support chaining grants via commas
        $rcc_riak_admin security grant riak_kv.get on any to all
        $rcc_riak_admin security grant riak_kv.get_preflist on any to all
        $rcc_riak_admin security grant riak_kv.put on any to all
        $rcc_riak_admin security grant riak_kv.delete on any to all
        $rcc_riak_admin security grant riak_kv.index on any to all
        $rcc_riak_admin security grant riak_kv.list_keys on any to all
        $rcc_riak_admin security grant riak_kv.list_buckets on any to all
        $rcc_riak_admin security grant riak_kv.mapreduce on any to all

        $rcc_riak_admin security grant riak_core.get_bucket on any to all
        $rcc_riak_admin security grant riak_core.set_bucket on any to all
        $rcc_riak_admin security grant riak_core.get_bucket_type on any to all
        $rcc_riak_admin security grant riak_core.set_bucket_type on any to all

        $rcc_riak_admin security grant search.admin on any to all
        $rcc_riak_admin security grant search.query on any to all

        $rcc_riak_admin security grant riak_ts.get on any to all
        $rcc_riak_admin security grant riak_ts.put on any to all
        $rcc_riak_admin security grant riak_ts.delete on any to all
        $rcc_riak_admin security grant riak_ts.list_keys on any to all
        $rcc_riak_admin security grant riak_ts.coverage on any to all
        $rcc_riak_admin security grant riak_ts.create_table on any to all
        $rcc_riak_admin security grant riak_ts.query_select on any to all
        $rcc_riak_admin security grant riak_ts.describe_table on any to all
        $rcc_riak_admin security grant riak_ts.show_tables on any to all
        set -o errexit
    fi

    return 0
}

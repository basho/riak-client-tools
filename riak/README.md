Riak Devrel Tools
=================

These scripts can be used to configure and start a Riak devrel for use in integration testing your Riak client library.

## Usage

* First, a correctly built `devrel` must be available. Here is the general sequence of commands to do so:

    ```
    mkdir -p Projects/basho
    cd Projects/basho
    git clone git://github.com/basho/riak.git
    cd riak
    make locked-deps
    make devrel DEVNODES=4
    ```

    More info can be found in [the documentation](http://docs.basho.com/riak/latest/ops/building/installing/from-source/)

* Then, use the `devrel/setup-dev-cluster` script to configure and start your devrel. The script assumes that the devrel is available at `$HOME/Projects/basho/riak/dev` but can be changed via the `-p` argument:

    ```
    lbakken@brahms ~/Projects/basho/riak-client-tools (master=)
    $ ./devrel/setup-dev-cluster -h

    setup-dev-cluster: Quickly setup a dev Riak cluster.

    Usage: setup-dev-cluster [-p <riak dev path>] [-n <node count>] [-l] [-c]

    -p      Riak dev path (Default: "/home/lbakken/Projects/basho/riak/dev")
    -n      Node count (Default: 4)
    -l      Set up cluster to use Legacy Search instead of Yokozuna Search
    -c      Set up cluster for Strong Consistency
            Note: overrides -n setting and requires at least 4 nodes
    -s      Set up cluster to use Riak Security
    -b      Default backend to use (Default: "bitcask", can be "leveldb")

    Exiting!
    ```

## Examples

The [Riak .NET Client](https://github.com/basho/riak-dotnet-client) integration test suite requires a devrel configured with security and strong consistency:

```
./devrel/setup-dev-cluster -sc
```

The [Riak .NET Client examples project](https://github.com/basho/riak-dotnet-client/tree/develop/src/RiakClientExamples) requires that `leveldb` be the default backend:

```
./devrel/setup-dev-cluster -b leveldb
```

If your devrel is located in `$HOME/src/riak/dev`, use this `-p` argument:

```
./devrel/setup-dev-cluster -p "$HOME/src/riak/dev"
```


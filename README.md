
# meta-codechecker

A Layer to support CodeChecker as a frontend to clang static analysis

## usage

This layer exposes a bbclass and the recipes needed to support inclusion of the tooling.
Note that meta-clang is a requirement.

### enable codechecker feature:

    In e.g. conf/local.conf
    DISTRO_FEATURES_append += " codechecker"

To enable the layer within a single recipe, add to the bitbake recipe

    inherit codechecker

### globally enable codechecker for all packages

    In e.g. conf/local.conf
    INHERIT += "codechecker"

### options

To generate a static HTML site as report do add:

    In e.g. conf/local.conf
    CODECHECKER_REPORT_HTML = "1"

To upload the results to the CodeScanner webserver (e.g. docker container) add:

    CODECHECKER_REPORT_STORE = "1" 
    CODECHECKER_REPORT_HOST = "http[s]://]host:port/Endpoint" 

Note:  The URL of the product to store the results for, in the format of
'http[s]://]host:port/Endpoint'. (default: localhost:8001/Default)

To add arguments to the CodeChecker analyze command (see CodeChecker man), e.g.:

    CODECHECKER_ANALYZE_ARGS = "-e sensitive"

### output location

The output will be in:

    check tmp/deploy/CodeChecker/*


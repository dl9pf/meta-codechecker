
# meta-codechecker

A Layer to support CodeChecker as a frontent to clang static analysis


## usage

This layer exposes a bbclass and the recipes needed to support inclusion of the tooling.
Note that meta-clang is a requirement.

### In a recipe enable:

To enable the layer within a single recipe, do add

    inherit codechecker
    CODECHECKER_ENABLED = "1"
 
 ### In conf/local.conf
    INHERIT += "codechecker"
    CODECHECKER_ENABLED = "1"

### options:

To generate a static HTML site as report do add:

    CODECHECKER_REPORT_HTML = "1"

To upload the results to the CodeScanner webserver (e.g. docker container) add:

    CODECHECKER_REPORT_STORE = "1" 
    CODECHECKER_REPORT_HOST = "http[s]://]host:port/Endpoint" 

Note:  The URL of the product to store the results for, in the format of
'http[s]://]host:port/Endpoint'. (default: localhost:8001/Default)

Note: this was tested against the docker container
  docker pull codechecker/codechecker-web:6.13.0

### output location

The output will be in:

    check tmp/deploy/CodeChecker/*


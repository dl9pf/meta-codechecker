
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

To generate a TXT report compatible with warning-ng do add:

    CODECHECKER_REPORT_TXT = "1"

To generate a static HTML site as report do add:

    CODECHECKER_REPORT_HTML = "1"

To generate a codeclimate compatible report do add:

    CODECHECKER_REPORT_CODECLIMATE = "1"

The output will be in tmp/deploy/CodeChecker/*

To upload the results to the CodeChecker webserver (e.g. docker container) add:

    CODECHECKER_REPORT_STORE = "1"
    CODECHECKER_REPORT_HOST = "http://yourcodecheckerhost:8001/"
    CODECHECKER_REPORT_ENDPOINT = "myproductname"
    # ENDPOINT cannot have '.' or '+' or ' '  in the name !
    #
    # optionally have the endpoint created
    #CODECHECKER_REPORT_ENDPOINT_CREATE = "1"

Note:  The URL of the product to store the results for, in the format of
'http[s]://]host:port/'. (default: localhost:8001/Default)

Note: this was tested against the docker container
  docker pull codechecker/codechecker-web:6.15.2

To select different analyzer you can use:

    CODECHECKER_ANALYZER = "clangsa clang-tidy"

The default is only run clang-tidy

To add arguments to the CodeChecker analyze command (see CodeChecker man), e.g.:

    CODECHECKER_ANALYZE_ARGS = "-e sensitive"

### output location

The output will be in:

    check tmp/deploy/CodeChecker/*


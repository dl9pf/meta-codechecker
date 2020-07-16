# meta-codechecker
Layer to support CodeChecker as a frontent to clang static analysis


# usage
# - in a recipe enable:
inherit codechecker
CODECHECKER_ENABLED = "1"

options:
CODECHECKER_REPORT_HTML = "1"
# web not working, yet.
#CODECHECKER_REPORT_STORE = "1"
#CODECHECKER_REPORT_HOST = "http[s]://]host:port/Endpoint"
# The URL of the product to store the results for, in
# the format of 'http[s]://]host:port/Endpoint'.
# (default: localhost:8001/Default)

# output
check tmp/deploy/images/CodeChecker/*

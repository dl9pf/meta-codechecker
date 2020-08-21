# existing upstream recipe does not have a native version
SUMMARY = "Recipie to embedded the Python PiP Package thrift"
HOMEPAGE ="https://pypi.org/project/thrift"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://LICENSE;md5=2ba8bcf874551cc47b1c430e18ec4163"

inherit pypi setuptools3 native
PYPI_PACKAGE = "thrift"
SRC_URI[md5sum] = "c3bc8d9a910d2c9ce26f2ad1f7c96762"
SRC_URI[sha256sum] = "9af1c86bf73433afc6010ed376a6c6aca2b54099cc0d61895f640870a9ae7d89"

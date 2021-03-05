SUMMARY = "Recipe to embedded the Python PiP Package codechecker_api"
HOMEPAGE ="https://pypi.org/project/codechecker_api"
LICENSE = "Apache-2.0-with-LLVM-exception"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/Apache-2.0-with-LLVM-exception;md5=0bcd48c3bdfef0c9d9fd17726e4b7dab"

inherit native pypi setuptools3
PYPI_PACKAGE = "codechecker_api"

SRC_URI[sha256sum] = "19ddeee1edc0863e50f8a812887c22bafcfafe7367b7981e04f1a6ed74a3c092"

SUMMARY = "Recipe to embedded the Python PiP Package codechecker_api_shared"
HOMEPAGE ="https://pypi.org/project/codechecker_api_shared"
LICENSE = "Apache-2.0-with-LLVM-exception"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/Apache-2.0-with-LLVM-exception;md5=0bcd48c3bdfef0c9d9fd17726e4b7dab"

inherit native pypi setuptools3
PYPI_PACKAGE = "codechecker_api_shared"

SRC_URI[sha256sum] = "65bee7da8fbffba61174cc4ccef76babcc9e6585ebdd4866da4a13d85834de25"

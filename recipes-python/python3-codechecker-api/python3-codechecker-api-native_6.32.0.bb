SUMMARY = "Recipie to embedded the Python PiP Package codechecker_api"
HOMEPAGE ="https://pypi.org/project/codechecker_api"
LICENSE = "Apache-2.0-with-LLVM-exception"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/Apache-2.0-with-LLVM-exception;md5=0bcd48c3bdfef0c9d9fd17726e4b7dab"

inherit pypi setuptools3 native
PYPI_PACKAGE = "codechecker_api"

# 6.31
#SRC_URI[sha256sum] = "7805aa650fd36cfa5567575720e7057cdb4a19748f331b049a6cd8b7d337f36f"

#6.33
#SRC_URI[sha256sum] = "39cd6b01b47ed9a0b8690d149a0c6bba6b7350df36c9a55bc78ddf459686c851"

#6.32
SRC_URI[sha256sum] = "8d7f7cf5d6c5b971e424135cc2967bf3b5451befa5be84dca54487b0c27032af"

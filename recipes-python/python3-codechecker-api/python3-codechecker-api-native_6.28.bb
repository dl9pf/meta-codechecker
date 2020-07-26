SUMMARY = "Codechecker web api"
HOMEPAGE = "http://codechecker.org"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/Apache-2.0;md5=89aea4e17d99a7cacdbeed46a0096b10"

DEPENDS += "${PYTHON_PN}-native python3-pip-native"

# should it work through pypi ??
#PYPI_PACKAGE = "codechecker_api"
#SRC_URI[md5sum] = "6fad9772e75421969ddb41975483abdf"
#SRC_URI[sha256sum] = "1aac2ae2d0d8ea368fa90906567f5c08463d98ade155c0c4bfedd6a0f7160e38"
#inherit pypi
#inherit setuptools3

inherit native

# until I find the better method ...
# use wheel
SRC_URI = " https://files.pythonhosted.org/packages/d6/f4/c29c7664621018a2c026d9a34435874e04b0fc596a110e09e901a83e2694/codechecker_api-6.28.0-py3-none-any.whl"
SRC_URI[sha256sum] = "ff8e8cf4607b252d1cd4e9a786ec87b15467ff700b260700dab93eaa443aee9b"

do_configure[noexec] = "1"
do_compile[noexec] = "1"

# This is ugly, but works
# TODO: split into separate packages
do_install() {
        pip3 install --verbose --no-cache-dir --prefix ${D}${prefix} ${WORKDIR}/codechecker_api-6.28.0-py3-none-any.whl
}
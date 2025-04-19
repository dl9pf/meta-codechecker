LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://LICENSE;md5=b9e5c5521f21a2e6301f5ce9591f5f18"

SRC_URI[sha256sum] = "e814d8249f6751f174d012c240b02601b877b78e5c4fe5dd00b30dc796f01ee4"

SRC_URI = "git://github.com/uqfoundation/multiprocess;protocol=https;branch=master"

SRCREV = "2255a2837e08f30f4ab07b3cb73f0c7ed2973d5f"

S = "${WORKDIR}/git"

inherit setuptools3

BBCLASSEXTEND = "native nativesdk"

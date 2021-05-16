SUMMARY = "Portalocker"
HOMEPAGE = "https://github.com/WoLpH/portalocker.git"
LICENSE = "PSF"

LIC_FILES_CHKSUM = "file://LICENSE;md5=f9273424c73af966635d66eb53487e14"

SRC_URI = "git://github.com/WoLpH/portalocker.git;protocol=https"
SRCREV = "ec9f5da208b7c90cd1f36f4ae085269e60359190"

S = "${WORKDIR}/git"

inherit setuptools3
inherit native
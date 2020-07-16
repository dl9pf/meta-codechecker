SUMMARY = "Portalocker"
HOMEPAGE = "https://github.com/WoLpH/portalocker.git"
LICENSE = "PSF"

LIC_FILES_CHKSUM = "file://LICENSE;md5="

SRC_URI = "git://github.com/WoLpH/portalocker.git;protocol=https"
SRCREV = "c34a48e5724b3874b7f5722a0192d213c81cf6c0"

S = "${WORKDIR}/git"

inherit setuptools3
inherit native
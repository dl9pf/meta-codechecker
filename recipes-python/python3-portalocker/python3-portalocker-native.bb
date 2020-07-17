SUMMARY = "Portalocker"
HOMEPAGE = "https://github.com/WoLpH/portalocker.git"
LICENSE = "PSF"

LIC_FILES_CHKSUM = "file://LICENSE;md5=f9273424c73af966635d66eb53487e14"

SRC_URI = "git://github.com/WoLpH/portalocker.git;protocol=https"
SRCREV = "56d7aeb36c80b4f063b24706217342b10d146469"

S = "${WORKDIR}/git"

inherit setuptools3
inherit native
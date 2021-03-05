SUMMARY = "CodeChecker static analysis tool"
HOMEPAGE = "https://codechecker.readthedocs.io/en/latest/"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://LICENSE.TXT;md5=2e982d844baa4df1c80de75470e0c5cb"

DEPENDS = "doxygen-native curl-native git-native nodejs-native python3-native"

SRC_URI = "git://github.com/Ericsson/CodeChecker.git;branch=release-v6.15.1"

#SRCREV = "${AUTOREV}"
#6.15.1
SRCREV = "692e51ba4be08e97c4b07cc344edca082dc50f63"

S = "${WORKDIR}/git"

inherit autotools python3native setuptools3

do_compile() {
    alias python=python3
    cd ${S}
    BUILD_LOGGER_64_BIT_ONLY=YES make package
}

do_install(){
    mkdir -p ${D}/${exec_prefix}/local

    # cp is not perfect but works for this pile of files
    cp -ard ${S}/build/CodeChecker ${D}/${exec_prefix}/local/

    # fix user
    chown -R root:root ${D}/${exec_prefix}/local/
}

FILES_${PN} += " ${exec_prefix}/local*"
SYSROOT_DIRS += " ${exec_prefix}/local"
SYSROOT_DIRS_NATIVE += " ${exec_prefix}/local"

RDEPENDS_${PN}_class-native += "clang-native python3-native"

BBCLASSEXTEND += "native"

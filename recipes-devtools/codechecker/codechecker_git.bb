SUMMARY = "CodeChecker static analysis tool"
HOMEPAGE = "https://codechecker.readthedocs.io/en/latest/"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://LICENSE.TXT;md5=2e982d844baa4df1c80de75470e0c5cb"

DEPENDS = "doxygen-native curl-native git-native nodejs-native python3-native"

SRC_URI = " git://github.com/Ericsson/codechecker.git;protocol=https \
            file://0001-Use-python3-for-setuptool-calls.patch "
SRCREV = "${AUTOREV}"

S = "${WORKDIR}/git"

inherit autotools python3native setuptools3

do_compile() {
    alias python=python3
    cd ${S}
    BUILD_LOGGER_64_BIT_ONLY=YES make package
}

do_install(){
    mkdir -p ${D}/${exec_prefix}/local
    cp -ard ${S}/build/CodeChecker ${D}/${exec_prefix}/local/
    chown -R root:root ${D}/${exec_prefix}/local/
    ls -alhR ${D}/${exec_prefix}

#    # TODO: yes, copying is ugly
#    mkdir -p ${D}/${bindir}
#    cp -ard ${S}/build/CodeChecker/bin/* ${D}/${bindir}/
#    
#    mkdir ${D}/${exec_prefix}/cc_bin
#    cp -ard ${S}/build/CodeChecker/cc_bin/* ${D}/${exec_prefix}/cc_bin/
#
#    mkdir ${D}/${exec_prefix}/config
#    cp -ard ${S}/build/CodeChecker/config/* ${D}/${exec_prefix}/config/
#
#    mkdir ${D}/${exec_prefix}/ld_logger
#    cp -ard ${S}/build/CodeChecker/ld_logger/* ${D}/${exec_prefix}/ld_logger/
#
#    ls -alhR ${D}/${exec_prefix}/ld_logger/
#
#    mkdir -p ${D}/${libdir}
#    cp -ard ${S}/build/CodeChecker/lib/* ${D}/${libdir}
#    
#    ls -alhR ${D}
}

FILES_${PN} += " ${exec_prefix}/local*"
SYSROOT_DIRS += " ${exec_prefix}/local"
SYSROOT_DIRS_NATIVE += " ${exec_prefix}/local"

#RDEPENDS_${PN} += "clang-native python3-native"
RDEPENDS_${PN}_class-native += "clang-native python3-native"

BBCLASSEXTEND += "native"

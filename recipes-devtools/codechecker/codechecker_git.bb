SUMMARY = "CodeChecker static analysis tool"
HOMEPAGE = "https://codechecker.readthedocs.io/en/latest/"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://LICENSE.TXT;md5=2e982d844baa4df1c80de75470e0c5cb"

DEPENDS = "doxygen-native curl-native git-native nodejs-native python3-native"

SRC_URI = " git://github.com/Ericsson/codechecker.git;protocol=https \
            file://0001-Use-python3-for-setuptool-calls.patch "

#SRCREV = "${AUTOREV}"
# last 6.32 api
SRCREV = "f5defa9cb06c8ffdd68160bafa0d130c4b0f3951"

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
RDEPENDS_${PN}_class-nativesdk += "nativesdk-clang nativesdk-python3"

BBCLASSEXTEND += "native nativesdk"

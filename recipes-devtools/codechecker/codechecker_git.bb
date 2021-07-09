SUMMARY = "CodeChecker static analysis tool"
HOMEPAGE = "https://codechecker.readthedocs.io/en/latest/"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://LICENSE.TXT;md5=2e982d844baa4df1c80de75470e0c5cb"

DEPENDS = "doxygen-native curl-native git-native nodejs-native python3-native"

# Codemirror is normaly download by codechecker's build system in codechecker/tools/plist_to_html/Makefile
# but that doesn't works well with offline build.
CODEMIRROR_VERSION = "5.30.0"
CODEMIRROR_BASE_URL = "https://cdnjs.cloudflare.com/ajax/libs/codemirror/${CODEMIRROR_VERSION}"


SRC_URI = " git://github.com/Ericsson/codechecker.git;protocol=https;branch=release-v6.15.2 \
            file://0002-Add-severity-to-CodeClimate-export.patch \
            ${CODEMIRROR_BASE_URL}/codemirror.min.js;name=codemirror.min.js;downloadfilename=codemirror.min.js.${CODEMIRROR_VERSION} \
            ${CODEMIRROR_BASE_URL}/codemirror.min.css;name=codemirror.min.css;downloadfilename=codemirror.min.css.${CODEMIRROR_VERSION} \
            https://raw.githubusercontent.com/codemirror/CodeMirror/${CODEMIRROR_VERSION}/LICENSE;name=codemirror.LICENSE;downloadfilename=codemirror.LICENSE.${CODEMIRROR_VERSION} \
            ${CODEMIRROR_BASE_URL}/mode/clike/clike.min.js;name=clike.min.js;downloadfilename=codemirror.clike.min.js.${CODEMIRROR_VERSION}"

# \
#            file://0001-Use-python3-for-setuptool-calls.patch "

SRC_URI[codemirror.min.js.md5sum] = "6f1c7c549c8ed350268aad9332ffcba1"
SRC_URI[codemirror.min.js.sha256sum] = "02a9ccc1cf4a93ab094a10e8e501b0bb611af4ccd247e8925b2e27255fa04515"

SRC_URI[codemirror.min.css.md5sum] = "f161643660c93c30cf8ba701079ed1c3"
SRC_URI[codemirror.min.css.sha256sum] = "c25b8eff0e1c9e8ac9a52d0999c753498cf075be44eaed38e6a6b812bbdf6f59"

SRC_URI[codemirror.LICENSE.md5sum] = "8554e1ee437cc3fb3cfee9ad4a11b8ab"
SRC_URI[codemirror.LICENSE.sha256sum] = "a3f2fe2ac6b471aa80c737c5d283dd049bdc903a73835ee6d4d2cac02fdd53bf"

SRC_URI[clike.min.js.md5sum] = "f6ea81338366ce679c731b3013ca7848"
SRC_URI[clike.min.js.sha256sum] = "9496e66bbb82bbad38b281a98f92c93b84710cc5948a07b569f179bdea19c73e"

# By default, the makefile call npm install to build the webserver ui
# For offline build, the build_ui_dist feature must be disabled.
PACKAGECONFIG ??= ""
PACKAGECONFIG[build_ui_dist] = "BUILD_UI_DIST=YES,BUILD_UI_DIST=NO"

#SRCREV = "${AUTOREV}"
# v6.15.2 & api 6.39
SRCREV = "63740679d61ff715175b9f31858d2fe9767efa41"

S = "${WORKDIR}/git"

# Code Mirror files must be placed in this directory before running `make package`
CODEMIRROR_DIR = "${S}/tools/plist_to_html/plist_to_html/static/vendor/codemirror"

inherit autotools python3native setuptools3

do_compile() {
    # Link codemirror files in the right folder
    mkdir -p ${CODEMIRROR_DIR}
    ln -sf ${WORKDIR}/codemirror.min.js.${CODEMIRROR_VERSION} ${CODEMIRROR_DIR}/codemirror.min.js
    ln -sf ${WORKDIR}/codemirror.min.css.${CODEMIRROR_VERSION} ${CODEMIRROR_DIR}/codemirror.min.css
    ln -sf ${WORKDIR}/codemirror.LICENSE.${CODEMIRROR_VERSION} ${CODEMIRROR_DIR}/codemirror.LICENSE
    ln -sf ${WORKDIR}/codemirror.clike.min.js.${CODEMIRROR_VERSION} ${CODEMIRROR_DIR}/clike.min.js
    
    alias python=python3
    cd ${S}
    BUILD_LOGGER_64_BIT_ONLY=YES ${PACKAGECONFIG_CONFARGS} make package
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

SUMMARY = "Simple helloworld application"
SECTION = "examples"
LICENSE = "BSD-2-Clause"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/BSD-2-Clause;md5=cb641bc04cda31daea161b1bc15da69f"

SRC_URI = "file://simple-hello-world.c;subdir=sources"

S = "${WORKDIR}/sources"

DEPENDS += "codechecker-native"

EXTRANATIVEPATH += "python3-native"

inherit codechecker
CODECHECKER_ENABLED ?= "1"
CODECHECKER_REPORT_HTML ?= "1"
#CODECHECKER_REPORT_STORE ?= "1"
#CODECHECKER_REPORT_HOST ?= "http://localhost:8001/Default"

do_compile() {
    ${CC} -w simple-hello-world.c ${CFLAGS} ${LDFLAGS} -o simple-hello-world
}

do_install() {
    install -d ${D}${bindir}
    install -m 0755 simple-hello-world ${D}${bindir}
}
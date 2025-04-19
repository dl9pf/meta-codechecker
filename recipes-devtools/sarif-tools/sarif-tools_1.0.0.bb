LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://LICENSE;md5=d4a904ca135bb7bc912156fee12726f0"

SRC_URI[sha256sum] = "e814d8249f6751f174d012c240b02601b877b78e5c4fe5dd00b30dc796f01ee4"

SRC_URI = "git://github.com/microsoft/sarif-tools;protocol=https;branch=main"

SRCREV = "c76ebfed17565d7197011430b14fba13232d6108"

S = "${WORKDIR}/git"

RDEPENDS:${PN} += "python3-jinja2"

inherit python_poetry_core

BBCLASSEXTEND = "native nativesdk"

SUMMARY = "CodeChecker static analysis tool"
HOMEPAGE = "https://codechecker.readthedocs.io/en/latest/"
LICENSE = "Apache-2.0"

# The pypi package doesn't include a license file
LIC_FILES_CHKSUM = "file://LICENSE.TXT;md5=2e982d844baa4df1c80de75470e0c5cb"

SRC_URI[md5sum] = "edd6a862af82a573f924ef14b40dd4db"
SRC_URI[sha256sum] = "1affc5fc6b21749050e36530868583c672852a448fd07bc7a221eb1d7d05b663"

PYPI_PACKAGE = "codechecker"

inherit pypi setuptools3-base

SRC_URI += " file://0001-Don-t-require-fix-version-of-dependancies.patch"

DEPENDS += "\
    ${PYTHON_PN}-pip-native \
"

RDEPENDS_${PN} += "python3 python3-modules"

# Requirements from web/requirements.txt
RDEPENDS_${PN} += "python3-lxml python3-sqlalchemy python3-alembic python3-portalocker python3-psutil python3-mypy-extensions"

# Requirements from analyzers/requirements.txt
RDEPENDS_${PN} += "python3-pyyaml python3-git"

RDEPENDS_${PN}_class-native += " clang-native"
RDEPENDS_${PN}_class-nativesdk += " nativesdk-clang"

do_install() {
    # CodeChecker use a native namespace package and can't be installed using
    # setup.py install, so we can't simply ihnerit from setuptools3
    # Instead, we must install using pip install .
    # This code is inspired by the distutils3.bbclass
    install -d ${D}${PYTHON_SITEPACKAGES_DIR}


    PYTHONPATH=${D}${PYTHON_SITEPACKAGES_DIR} \
    ${STAGING_BINDIR_NATIVE}/${PYTHON_PN}-native/${PYTHON_PN} -m pip install . \
      --no-index --no-deps \
      --prefix=${prefix} \
      --root=${D}

    for i in ${D}${bindir}/* ${D}${sbindir}/*; do
        if [ -f "$i" ]; then
            sed -i -e s:${PYTHON}:${USRBINPATH}/env\ python3:g $i
            sed -i -e s:${STAGING_BINDIR_NATIVE}:${bindir}:g $i
        fi
    done
}

BBCLASSEXTEND += "native nativesdk"

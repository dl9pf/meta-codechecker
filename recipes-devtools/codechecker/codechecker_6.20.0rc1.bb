SUMMARY = "CodeChecker static analysis tool"
HOMEPAGE = "https://codechecker.readthedocs.io/en/latest/"
LICENSE = "Apache-2.0"

# The pypi package doesn't include a license file
LIC_FILES_CHKSUM = "file://LICENSE.TXT;md5=2e982d844baa4df1c80de75470e0c5cb"

SRC_URI += "file://0001-Replace-Binary-with-LargeBinary.patch"

SRC_URI[sha256sum] = "9781fdd49c47f8f00a78152ff0648a409290a6f296a6d1620677c853fba598aa"

PYPI_PACKAGE = "codechecker"

inherit pypi setuptools3

DEPENDS += "\
    ${PYTHON_PN}-pip-native \
"


do_patch:append() {
    bb.build.exec_func('do_relax_version_requirements', d)
}

do_relax_version_requirements () {
    sed -i -e "s/==/>=/g" ${S}/analyzer/requirements.txt
    sed -i -e "s/==/>=/g" ${S}/web/requirements.txt
    sed -i -e "s/==/>=/g" ${S}/build_dist/CodeChecker/lib/python3/codechecker.egg-info/requires.txt
}

RDEPENDS:${PN} += "python3 python3-modules"

# Requirements from web/requirements.txt
RDEPENDS:${PN} += "python3-lxml python3-sqlalchemy python3-alembic python3-portalocker python3-psutil python3-mypy-extensions python3-thrift"

# Requirements from analyzers/requirements.txt
RDEPENDS:${PN} += "python3-pyyaml python3-git"

RDEPENDS_${PN}:class-native += " clang-native"
RDEPENDS_${PN}:class-nativesdk += " nativesdk-clang"

BBCLASSEXTEND += "native nativesdk"

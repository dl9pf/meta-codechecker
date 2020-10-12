SUMMARY = "Recipie to embedded the Python PiP Package codechecker_api_shared"
HOMEPAGE ="https://pypi.org/project/codechecker_api_shared"
LICENSE = "Apache-2.0-with-LLVM-exception"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/Apache-2.0-with-LLVM-exception;md5=0bcd48c3bdfef0c9d9fd17726e4b7dab"

inherit pypi setuptools3 native
PYPI_PACKAGE = "codechecker_api_shared"

#6.31
#SRC_URI[sha256sum] = "364ad9ddcf90a8b93b9d8c304f5ff7de644c0e6835e3629701132621d698d3bf"

# 6.33
#SRC_URI[sha256sum] = "1d196b7e7088e7ca656cceced4dba8add97eb6cd1be8c7a8eb637441d4b6818c"

# 6.32
SRC_URI[sha256sum] = "51e526a155e9a6fa765dd5eb6683e0b77ac0ef4caf098be27633e63070995d01"

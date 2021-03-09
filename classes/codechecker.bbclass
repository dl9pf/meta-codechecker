inherit python3-dir

CODECHECKER_ENABLED ?= "${@bb.utils.contains('DISTRO_FEATURES', 'codechecker', '1', '0', d)}"
CODECHECKER_ENABLED_class-native = ""
CODECHECKER_ENABLED_class-nativesdk = ""
CODECHECKER_ENABLED_class-cross-canadian = ""

CODECHECKER_REPORT_HTML ?= "1"

python do_csprecompile () {
    os.environ["LD_PRELOAD"] = "" + d.getVar('RECIPE_SYSROOT_NATIVE') + "/usr/local/CodeChecker/ld_logger/lib/x86_64/ldlogger.so"
    os.environ["CC_LOGGER_GCC_LIKE"] = "gcc:g++:clang:clang++:cc:c++:ccache"
    os.environ["CC_LOGGER_FILE"] = "" + d.getVar("B") + "/codechecker-log.json"
    os.makedirs("" + d.getVar("DEPLOY_DIR") + "/codechecker/" + d.getVar("PN") , exist_ok=True)
}

python do_cspostcompile () {
    os.environ["LD_PRELOAD"] = ""
}

###############################################

do_codechecker_analyze() {
    bbnote "codechecker_analyze"
    if test -f ${CC_LOGGER_FILE} ; then
        CodeChecker analyze ${PARALLEL_MAKE} ${CODECHECKER_ANALYZE_ARGS} -o ${CC_ANALYZE_OUT} --report-hash context-free-v2 ${CC_LOGGER_FILE} || status=$?
        if [ ${status} -eq 0 ]; then
            bbnote "codechecker analyze ok"
        else
            bbwarn "codechecker analyze issues found, status=${status}"
	    status=0
        fi
	mkdir -p ${CC_DIR}
        ln -sfn ${CC_DIR}/${TS} ${CC_DIR}/latest
        cp ${CC_LOGGER_FILE} ${CC_DIR}/${TS}/
    fi
}

do_codechecker_parse() {
    bbnote "codechecker_parse"
    if test x"${CODECHECKER_REPORT_HTML}" = x"1"; then
        mkdir -p ${CC_REPORT_OUT}
        CodeChecker parse ${CODECHECKER_PARSE_ARGS} -e html --trim-path-prefix=${S} ${CC_ANALYZE_OUT} -o ${CC_REPORT_OUT} || status=$?
        if [ ${status} -eq 0 ]; then
            bbdebug 1 "codechecker parse ok"
	else
	    bbwarn "codechecker parse failed, status=${status}"
	    status=0
        fi
    fi
}

do_codechecker_store() {
    bbnote "codechecker_store"
    if test x"${CODECHECKER_REPORT_STORE}" = x"1"; then
        if test ! x"${CODECHECKER_REPORT_HOST}" = x""; then
            CodeChecker store ${CODECHECKER_STORE_ARGS} -n ${PF} --trim-path-prefix=${S} --url ${CODECHECKER_REPORT_HOST} ${CC_ANALYZE_OUT} || status=$?
            if [ ${status} -eq 0 ]; then
            	bbdebug 1 "codechecker store ok"
            else
                bbwarn "codechecker store failed, status=${status}"
		status=0
            fi
        fi
    fi
}

do_codechecker() {
    if test x"${CODECHECKER_ENABLED}" = x"1"; then
       bbnote "codechecker enabled"

       # need to teach proper PATHs for this run
       export PYTHON="${STAGING_BINDIR_NATIVE}/python3-native/python3"
       export PYTHONNOUSERSITE="1"
       export PYTHONPATH="${RECIPE_SYSROOT_NATIVE}/usr/lib/python${PYTHON_BASEVERSION}/site-packages/"
       export PATH="${RECIPE_SYSROOT_NATIVE}/usr/bin:${RECIPE_SYSROOT_NATIVE}/usr/bin/python3-native/:${RECIPE_SYSROOT_NATIVE}/usr/local/CodeChecker/bin:$PATH"

       # expose variable for codechecker
       export TS=$(date +%4Y%2m%2d%2H%2M%2S)
       export CC_DIR="${DEPLOY_DIR}/codechecker/${PN}"
       export CC_ANALYZE_OUT="${CC_DIR}/${TS}/results/"
       export CC_REPORT_OUT="${CC_DIR}/${TS}/report-html/"
       export CC_LOGGER_FILE="${B}/codechecker-log.json"
       export status=0

       do_codechecker_analyze
       if test -d ${CC_ANALYZE_OUT} ; then
	   do_codechecker_parse
	   do_codechecker_store
       fi
    fi
}
addtask codechecker after do_compile before do_install

python () {
    if d.getVar("CODECHECKER_ENABLED") == "1":
        if not bb.data.inherits_class('nativesdk', d) \
            and not bb.data.inherits_class('native', d) \
            and not bb.data.inherits_class('cross', d) \
            and not bb.data.inherits_class('crosssdk', d) \
            and not bb.data.inherits_class('allarch', d):
            d.prependVarFlag("do_compile", "prefuncs", "do_csprecompile ")
            d.appendVarFlag("do_compile", "postfuncs", " do_cspostcompile")
            d.appendVarFlag("do_compile", "depends", " codechecker-native:do_populate_sysroot python3-six-native:do_populate_sysroot python3-thrift-native:do_populate_sysroot python3-codechecker-api-native:do_populate_sysroot python3-codechecker-api-shared-native:do_populate_sysroot clang-native:do_populate_sysroot python3-native:do_populate_sysroot python3-psutil-native:do_populate_sysroot python3-portalocker-native:do_populate_sysroot python3-pyyaml-native:do_populate_sysroot")
}

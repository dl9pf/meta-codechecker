inherit python3-dir

CODECHECKER_ENABLED ?= "${@bb.utils.contains('DISTRO_FEATURES', 'codechecker', '1', '0', d)}"
CODECHECKER_ENABLED_class-native = ""
CODECHECKER_ENABLED_class-nativesdk = ""
CODECHECKER_ENABLED_class-cross-canadian = ""
CODECHECKER_REPORT_HTML ?= "1"

python do_csprecompile () {
    os.environ["LD_PRELOAD"] = "" + d.getVar('RECIPE_SYSROOT_NATIVE') + "/usr/local/CodeChecker/ld_logger/lib/x86_64/ldlogger.so"
    os.environ["CC_LOGGER_GCC_LIKE"] = "gcc:g++:clang:clang++:cc:c++:ccache"
    os.environ["CC_LOGGER_FILE"] = "" + d.getVar("DEPLOY_DIR") + "/CodeChecker/" + d.getVar("PN") + "/codechecker-log.json"
    os.makedirs("" + d.getVar("DEPLOY_DIR") + "/CodeChecker/" + d.getVar("PN") , exist_ok=True)
}

python do_cspostcompile () {
    if d.getVar("CODECHECKER_ENABLED") == "1":
        os.environ["LD_PRELOAD"] = ""
}

###############################################

do_codechecker_analyse() {
    if test x"${CODECHECKER_ENABLED}" = x"1"; then
        # need to teach proper PATHs for this run
        export PYTHON="${STAGING_BINDIR_NATIVE}/python3-native/python3"
        export PYTHONNOUSERSITE="1"
        export PYTHONPATH="${RECIPE_SYSROOT_NATIVE}/usr/lib/python${PYTHON_BASEVERSION}/site-packages/"
        export PATH="${RECIPE_SYSROOT_NATIVE}/usr/bin:${RECIPE_SYSROOT_NATIVE}/usr/bin/python3-native/:${RECIPE_SYSROOT_NATIVE}/usr/local/CodeChecker/bin:$PATH"
        # expose Variable for CodeChecker
        TS=$(date +%4Y%2m%2d%2H%2M%2S)
        export CC_LOGGER_FILE="${DEPLOY_DIR}/CodeChecker/${PN}/codechecker-log.json"
        export CC_ANALYSE_OUT="${DEPLOY_DIR}/CodeChecker/${PN}/${TS}/results/"
        if test -f ${CC_LOGGER_FILE} ; then
            CodeChecker analyze ${PARALLEL_MAKE} ${CODECHECKER_ANALYZE_ARGS} -o ${CC_ANALYSE_OUT} --report-hash context-free-v2 ${CC_LOGGER_FILE} || status=$?
            if [ ${status} -eq 0 ]; then
                bbnote "CodeChecker analyze ok"
            else
                bbwarn "CodeChecker analyze issues found"
            fi
            ln -sfn ${DEPLOY_DIR}/CodeChecker/${PN}/${TS} ${DEPLOY_DIR}/CodeChecker/${PN}/latest
            cp ${CC_LOGGER_FILE} ${DEPLOY_DIR}/CodeChecker/${PN}/${TS}/
        fi
    fi
}
addtask codechecker_analyse

do_codechecker_parse() {
    if test x"${CODECHECKER_ENABLED}" = x"1"; then
       # need to teach proper PATHs for this run
       export PYTHON="${STAGING_BINDIR_NATIVE}/python3-native/python3"
       export PYTHONNOUSERSITE="1"
       export PYTHONPATH="${RECIPE_SYSROOT_NATIVE}/usr/lib/python${PYTHON_BASEVERSION}/site-packages/"
       export PATH="${RECIPE_SYSROOT_NATIVE}/usr/bin:${RECIPE_SYSROOT_NATIVE}/usr/bin/python3-native/:${RECIPE_SYSROOT_NATIVE}/usr/local/CodeChecker/bin:$PATH"

       # expose variables for CodeChecker
       export CC_ANALYSE_OUT="${DEPLOY_DIR}/CodeChecker/${PN}/latest/results/"
       export CC_REPORT_OUT="${DEPLOY_DIR}/CodeChecker/${PN}/latest/report-html/"

       if test -d ${CC_ANALYSE_OUT}/ ; then
           if test x"${CODECHECKER_REPORT_HTML}" = x"1"; then
              mkdir -p ${CC_REPORT_OUT}
              CodeChecker parse -e html --trim-path-prefix=${S} ${CC_ANALYSE_OUT} -o ${CC_REPORT_OUT}
              ln -sfn ${CC_REPORT_OUT} ${DEPLOY_DIR}/CodeChecker/${PN}/report-html
           fi
       fi
    fi
}
addtask codechecker_parse

do_codechecker_store() {
    if test x"${CODECHECKER_ENABLED}" = x"1"; then
        # need to teach proper PATHs for this run
        export PYTHON="${STAGING_BINDIR_NATIVE}/python3-native/python3"
        export PYTHONNOUSERSITE="1"
        export PYTHONPATH="${RECIPE_SYSROOT_NATIVE}/usr/lib/python${PYTHON_BASEVERSION}/site-packages/"
        export PATH="${RECIPE_SYSROOT_NATIVE}/usr/bin:${RECIPE_SYSROOT_NATIVE}/usr/bin/python3-native/:${RECIPE_SYSROOT_NATIVE}/usr/local/CodeChecker/bin:$PATH"

        # expose variables for CodeChecker
        export CC_ANALYSE_OUT="${DEPLOY_DIR}/CodeChecker/${PN}/latest/results/"
        export CC_REPORT_OUT="${DEPLOY_DIR}/CodeChecker/${PN}/latest/report-html/"

        if test -d ${CC_ANALYSE_OUT}/ ; then
            if test x"${CODECHECKER_REPORT_STORE}" = x"1"; then
                if test ! x"${CODECHECKER_REPORT_HOST}" = x""; then
                    CodeChecker store -n ${PF} --trim-path-prefix=${S} --url ${CODECHECKER_REPORT_HOST} ${CC_ANALYSE_OUT} || status=$?
                    if ${status}; then
                        bbdebug 1 "CodeChecker store ok"
                    else
                        bbwarn "CodeChecker store failed"
                    fi
                fi
            fi
        fi
    fi
}
addtask codechecker_store

python () {
    if d.getVar("CODECHECKER_ENABLED") == "1":
        if not bb.data.inherits_class('nativesdk', d) \
            and not bb.data.inherits_class('native', d) \
            and not bb.data.inherits_class('cross', d) \
            and not bb.data.inherits_class('crosssdk', d) \
            and not bb.data.inherits_class('allarch', d):
            d.prependVarFlag("do_compile", "prefuncs", "do_csprecompile ")
            d.appendVarFlag("do_compile", "postfuncs", " do_cspostcompile")
            d.appendVarFlag("do_compile", "postfuncs", " do_codechecker_analyse")
            d.appendVarFlag("do_compile", "postfuncs", " do_codechecker_parse")
            d.appendVarFlag("do_compile", "postfuncs", " do_codechecker_store")
            d.appendVarFlag("do_compile", "depends", " codechecker-native:do_populate_sysroot python3-six-native:do_populate_sysroot python3-thrift-native:do_populate_sysroot python3-codechecker-api-native:do_populate_sysroot python3-codechecker-api-shared-native:do_populate_sysroot clang-native:do_populate_sysroot python3-native:do_populate_sysroot python3-psutil-native:do_populate_sysroot python3-portalocker-native:do_populate_sysroot python3-pyyaml-native:do_populate_sysroot")
}

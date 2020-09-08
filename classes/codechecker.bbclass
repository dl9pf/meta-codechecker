inherit python3-dir

python () {
    if d.getVar("CODECHECKER_ENABLED") == "1":
        if not bb.data.inherits_class('nativesdk', d) \
            and not bb.data.inherits_class('native', d) \
            and not bb.data.inherits_class('cross', d) \
            and not bb.data.inherits_class('crosssdk', d) \
            and not bb.data.inherits_class('allarch', d):
            d.prependVarFlag("do_compile", 'prefuncs', "do_csprecompile ")
            d.appendVarFlag("do_compile", 'postfuncs', " do_cspostcompile")
            d.appendVarFlag("do_compile", "postfuncs", " do_codecheckeranalyse")
            d.appendVarFlag("do_compile", "postfuncs", " do_codecheckerreport")
            d.appendVarFlag("do_compile", 'depends', ' codechecker-native:do_populate_sysroot python3-six-native:do_populate_sysroot python3-thrift-native:do_populate_sysroot python3-codechecker-api-native:do_populate_sysroot python3-codechecker-api-shared-native:do_populate_sysroot clang-native:do_populate_sysroot python3-native:do_populate_sysroot python3-psutil-native:do_populate_sysroot python3-portalocker-native:do_populate_sysroot python3-pyyaml-native:do_populate_sysroot')
}

SAVEDENV = ""
#_environ = dict(os.environ)  # or os.environ.copy()
#    os.environ.update(_environ)

python do_csprecompile () {
    SAVEDENV = os.environ.copy()
    os.environ["LD_PRELOAD"] = "" + d.getVar('RECIPE_SYSROOT_NATIVE') + "/usr/local/CodeChecker/ld_logger/lib/x86_64/ldlogger.so"
    os.environ["CC_LOGGER_GCC_LIKE"] = "gcc:g++:clang:clang++:cc:c++:ccache"
    os.environ["CC_LOGGER_FILE"] = "" + d.getVar("DEPLOY_DIR") + "/CodeChecker/" + d.getVar("PN") + "/codechecker-log.json"
    #os.environ["PARALLEL_MAKE"] = "" + d.getVar("PARALLEL_MAKE")
    os.makedirs("" + d.getVar("DEPLOY_DIR") + "/CodeChecker/" + d.getVar("PN") , exist_ok=True)
    #bb.warn(str(os.environ["LD_PRELOAD"]))
}

python do_cspostcompile () {
    if d.getVar("CODECHECKER_ENABLED") == "1":
        os.environ["LD_PRELOAD"] = ""
        # or restore saved env
        # optimization: remove empty files
}


###############################################

do_codecheckeranalyse() {

if test x"${CODECHECKER_ENABLED}" = x"1"; then
    # optimization - skip empty
    #
    # need to teach proper PATHs for this run
    export PYTHON="${STAGING_BINDIR_NATIVE}/python3-native/python3"
    export PYTHONNOUSERSITE="1"
    export PYTHONPATH="${RECIPE_SYSROOT_NATIVE}/usr/lib/python${PYTHON_BASEVERSION}/site-packages/"
    export PATH="${RECIPE_SYSROOT_NATIVE}/usr/bin:${RECIPE_SYSROOT_NATIVE}/usr/bin/python3-native/:${RECIPE_SYSROOT_NATIVE}/usr/local/CodeChecker/bin:$PATH"

    # expose Variable for CodeChecker
    export CC_LOGGER_FILE="${DEPLOY_DIR}/CodeChecker/${PN}/codechecker-log.json"
    export CC_ANALYSE_OUT="${DEPLOY_DIR}/CodeChecker/${PN}/results/"
    if test -f ${CC_LOGGER_FILE} ; then
        CodeChecker analyze ${PARALLEL_MAKE} -o ${CC_ANALYSE_OUT} --report-hash context-free-v2 ${CC_LOGGER_FILE}
    fi
fi
}

addtask codecheckeranalyse

do_codecheckerreport() {

if test x"${CODECHECKER_ENABLED}" = x"1"; then

    # optimization - skip empty

    # need to teach proper PATHs for this run
    export PYTHON="${STAGING_BINDIR_NATIVE}/python3-native/python3"
    export PYTHONNOUSERSITE="1"
    export PYTHONPATH="${RECIPE_SYSROOT_NATIVE}/usr/lib/python${PYTHON_BASEVERSION}/site-packages/"
    export PATH="${RECIPE_SYSROOT_NATIVE}/usr/bin:${RECIPE_SYSROOT_NATIVE}/usr/bin/python3-native/:${RECIPE_SYSROOT_NATIVE}/usr/local/CodeChecker/bin:$PATH"

    # expose variables for CodeChecker 
    export CC_LOGGER_FILE="${DEPLOY_DIR}/CodeChecker/${PN}/codechecker-log.json"
    export CC_ANALYSE_OUT="${DEPLOY_DIR}/CodeChecker/${PN}/results/"
    export CC_REPORT_OUT="${DEPLOY_DIR}/CodeChecker/${PN}/report-html/"

    if test -d ${CC_ANALYSE_OUT} ; then
        if test x"${CODECHECKER_REPORT_HTML}" = x"1"; then
            mkdir -p ${CC_REPORT_OUT}
            #usage: CodeChecker parse [-h] [-t {plist}] [-e {html,json,codeclimate}]
            #             [-o OUTPUT_PATH] [--suppress SUPPRESS]
            #             [--export-source-suppress] [--print-steps]
            #             [-i SKIPFILE]
            #             [--trim-path-prefix [TRIM_PATH_PREFIX [TRIM_PATH_PREFIX ...]]]
            #             [--review-status [REVIEW_STATUS [REVIEW_STATUS ...]]]
            #             [--verbose {info,debug,debug_analyzer}]
            #             file/folder [file/folder ...]
            CodeChecker parse -e html --trim-path-prefix=${S} ${CC_ANALYSE_OUT} -o ${CC_REPORT_OUT}
        fi
        if test x"${CODECHECKER_REPORT_STORE}" = x"1"; then
            if test ! x"${CODECHECKER_REPORT_HOST}" = x""; then
                #usage: CodeChecker store [-h] [-t {plist}] [-n NAME] [--tag TAG]
                #             [--description DESCRIPTION]
                #             [--trim-path-prefix [TRIM_PATH_PREFIX [TRIM_PATH_PREFIX ...]]]
                #             [--config CONFIG_FILE] [-f] [--url PRODUCT_URL]
                #             [--verbose {info,debug,debug_analyzer}]
                #             [file/folder [file/folder ...]]
                # Todo: credentials
                CodeChecker store -n ${PF} --trim-path-prefix=${S} --url ${CODECHECKER_REPORT_HOST} ${CC_ANALYSE_OUT}
            fi
        fi
    fi
fi
}

addtask codecheckerreport
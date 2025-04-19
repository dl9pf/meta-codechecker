inherit python3-dir

CODECHECKER_EXCLUDED_PACKAGES ??= "libgcc-initial glibc gcc-runtime smack"
CODECHECKER_REPORT_ENDPOINT ??= "Default"
CODECHECKER_ANALYZE_EXTRA_ARGS ??= ""

python () {
    if d.getVar("CODECHECKER_ENABLED") == "1":
        if not bb.data.inherits_class('nativesdk', d) \
            and not bb.data.inherits_class('native', d) \
            and not bb.data.inherits_class('cross', d) \
            and not bb.data.inherits_class('crosssdk', d) \
            and not bb.data.inherits_class('allarch', d) \
            and not d.getVar('PN', True) in d.getVar('CODECHECKER_EXCLUDED_PACKAGES', True):

            # By default we use the compile step to generate compile_commands.json
            codechecker_use_compile_commands_json_from_configure = False

            # For supported build systems the compile_commands.json can be generated during config
            # CMake can generate the compile_commands.json if CMAKE_EXPORT_COMPILE_COMMANDS=ON
            if bb.data.inherits_class('cmake', d):
                d.appendVar("EXTRA_OECMAKE", " -DCMAKE_EXPORT_COMPILE_COMMANDS=ON")
                codechecker_use_compile_commands_json_from_configure = True

            # Meson generates the compile_commands.json by default
            if bb.data.inherits_class('meson', d):
                codechecker_use_compile_commands_json_from_configure = True

            codechecker_deps = ' codechecker-native:do_populate_sysroot python3-six-native:do_populate_sysroot python3-thrift-native:do_populate_sysroot clang-native:do_populate_sysroot python3-native:do_populate_sysroot python3-psutil-native:do_populate_sysroot python3-portalocker-native:do_populate_sysroot python3-pyyaml-native:do_populate_sysroot python3-git-native:do_populate_sysroot python3-alembic-native:do_populate_sysroot python3-sqlalchemy-native:do_populate_sysroot python3-mypy-extensions-native:do_populate_sysroot python3-lxml-native:do_populate_sysroot python3-markupsafe-native:do_populate_sysroot'
            codecheckeranalyse_after = None

            if codechecker_use_compile_commands_json_from_configure:
                codecheckeranalyse_after = "do_configure"
            else:
                d.prependVarFlag("do_compile", "prefuncs", "do_csprecompile ")
                d.appendVarFlag("do_compile", "postfuncs", " do_cspostcompile")
                d.appendVarFlag("do_compile", "depends", codechecker_deps)
                codecheckeranalyse_after = "do_compile"

            bb.build.addtask("codecheckeranalyse", "do_build", codecheckeranalyse_after, d)
            d.appendVarFlag("do_codecheckeranalyse", "depends", codechecker_deps)
            bb.build.addtask("codecheckerreport", "do_build", "do_codecheckeranalyse", d)
            d.appendVarFlag("do_codecheckerreport", "depends", codechecker_deps)
}

SAVEDENV = ""
#_environ = dict(os.environ)  # or os.environ.copy()
#    os.environ.update(_environ)

python do_csprecompile () {
    SAVEDENV = os.environ.copy()
    os.environ["LD_PRELOAD"] = "" + d.getVar('RECIPE_SYSROOT_NATIVE') + "/usr/lib/python" + d.getVar('PYTHON_BASEVERSION') +"/site-packages/codechecker_analyzer/ld_logger/lib/ldlogger.so"
    os.environ["CC_LOGGER_GCC_LIKE"] = "gcc:g++:clang:clang++:cc:c++:ccache"
    os.environ["CC_LOGGER_FILE"] = "" + d.getVar("B") + "/compile_commands.json"
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
    export PATH="${RECIPE_SYSROOT_NATIVE}/usr/bin:${RECIPE_SYSROOT_NATIVE}/usr/bin/python3-native/:$PATH"

    # expose Variable for CodeChecker
    export CC_LOGGER_FILE="${B}/compile_commands.json"
    export CC_ANALYSE_OUT="${DEPLOY_DIR}/CodeChecker/${PN}/results/"
    if test -f ${CC_LOGGER_FILE} ; then
        CodeChecker analyze ${PARALLEL_MAKE} --analyzers clang-tidy ${CODECHECKER_ANALYZE_EXTRA_ARGS} -o ${CC_ANALYSE_OUT} --report-hash context-free-v2 ${CC_LOGGER_FILE} || true
    fi
fi
}

do_codecheckerreport() {

if test x"${CODECHECKER_ENABLED}" = x"1"; then

    # optimization - skip empty

    # need to teach proper PATHs for this run
    export PYTHON="${STAGING_BINDIR_NATIVE}/python3-native/python3"
    export PYTHONNOUSERSITE="1"
    export PYTHONPATH="${RECIPE_SYSROOT_NATIVE}/usr/lib/python${PYTHON_BASEVERSION}/site-packages/"
    export PATH="${RECIPE_SYSROOT_NATIVE}/usr/bin:${RECIPE_SYSROOT_NATIVE}/usr/bin/python3-native/:$PATH"

    # expose variables for CodeChecker
    export CC_LOGGER_FILE="${B}/compile_commands.json"
    export CC_ANALYSE_OUT="${DEPLOY_DIR}/CodeChecker/${PN}/results/"
    export CC_REPORT_HTML_OUT="${DEPLOY_DIR}/CodeChecker/${PN}/report-html/"
    export CC_REPORT_CODECLIMATE_OUT="${DEPLOY_DIR}/CodeChecker/${PN}/report-codeclimate/"
    export CC_REPORT_TXT_OUT="${DEPLOY_DIR}/CodeChecker/${PN}/report-txt/"

    if test -d ${CC_ANALYSE_OUT} ; then
        if test x"${CODECHECKER_REPORT_HTML}" = x"1"; then
            mkdir -p ${CC_REPORT_HTML_OUT}
            #usage: CodeChecker parse [-h] [-t {plist}] [-e {html,json,codeclimate}]
            #             [-o OUTPUT_PATH] [--suppress SUPPRESS]
            #             [--export-source-suppress] [--print-steps]
            #             [-i SKIPFILE]
            #             [--trim-path-prefix [TRIM_PATH_PREFIX [TRIM_PATH_PREFIX ...]]]
            #             [--review-status [REVIEW_STATUS [REVIEW_STATUS ...]]]
            #             [--verbose {info,debug,debug_analyzer}]
            #             file/folder [file/folder ...]
            # Return Code:
            # 0 - No report
            # 1 - CodeChecker error
            # 2 - At least one report emitted by an analyzer
            CodeChecker parse -e html --trim-path-prefix=${S} ${CC_ANALYSE_OUT} -o ${CC_REPORT_HTML_OUT} || test $? -eq 2
        fi

        if test x"${CODECHECKER_REPORT_TXT}" = x"1"; then
            mkdir -p ${CC_REPORT_TXT_OUT}
            CodeChecker parse --trim-path-prefix=${S} ${CC_ANALYSE_OUT} > ${CC_REPORT_TXT_OUT}/reports.txt || test $? -eq 2
        fi

        if test x"${CODECHECKER_REPORT_CODECLIMATE}" = x"1"; then
            mkdir -p ${CC_REPORT_CODECLIMATE_OUT}
            #usage: CodeChecker parse [-h] [-t {plist}] [-e {html,json,codeclimate}]
            #             [-o OUTPUT_PATH] [--suppress SUPPRESS]
            #             [--export-source-suppress] [--print-steps]
            #             [-i SKIPFILE]
            #             [--trim-path-prefix [TRIM_PATH_PREFIX [TRIM_PATH_PREFIX ...]]]
            #             [--review-status [REVIEW_STATUS [REVIEW_STATUS ...]]]
            #             [--verbose {info,debug,debug_analyzer}]
            #             file/folder [file/folder ...]
            # Return Code:
            # 0 - No report
            # 1 - CodeChecker error
            # 2 - At least one report emitted by an analyzer
            CodeChecker parse -e codeclimate --trim-path-prefix=${S} ${CC_ANALYSE_OUT} -o ${CC_REPORT_CODECLIMATE_OUT}/reports.json || test $? -eq 2
        fi

        if test x"${CODECHECKER_REPORT_STORE}" = x"1"; then
            if test ! x"${CODECHECKER_REPORT_HOST}" = x""; then
                echo "xxx ${CODECHECKER_REPORT_ENDPOINT_CREATE} xxxx"
                if test x${CODECHECKER_REPORT_ENDPOINT_CREATE} = x"1" ; then
                    echo 1
                    ENDPOINT_LIST=`mktemp`
                    CodeChecker cmd products list -o plaintext --url ${CODECHECKER_REPORT_HOST} > ${ENDPOINT_LIST}
                    echo 2
                    if ! grep -q ${CODECHECKER_REPORT_ENDPOINT} ${ENDPOINT_LIST} ; then
                        # endpoint not there, create
                        # sqlite only for now
                        CodeChecker cmd products add --verbose debug --url ${CODECHECKER_REPORT_HOST} -n ${CODECHECKER_REPORT_ENDPOINT} ${CODECHECKER_REPORT_ENDPOINT}
                    fi
                    rm -f ${ENDPOINT_LIST}
                fi
                #usage: CodeChecker store [-h] [-t {plist}] [-n NAME] [--tag TAG]
                #             [--description DESCRIPTION]
                #             [--trim-path-prefix [TRIM_PATH_PREFIX [TRIM_PATH_PREFIX ...]]]
                #             [--config CONFIG_FILE] [-f] [--url PRODUCT_URL]
                #             [--verbose {info,debug,debug_analyzer}]
                #             [file/folder [file/folder ...]]
                # Todo: credentials
                CodeChecker store -n ${PF} --trim-path-prefix=${S} --url ${CODECHECKER_REPORT_HOST}${CODECHECKER_REPORT_ENDPOINT} ${CC_ANALYSE_OUT}
            fi
        fi
    fi
fi
}

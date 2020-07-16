
do_compile_prepend_class-target () {
    if test x"${CODECHECKER_ENABLED}" == x"1"; then
        # enabled we are
        export LD_PRELOAD="${RECIPE_SYSROOT_NATIVE}/usr/local/CodeChecker/ld_logger/lib/x86_64/ldlogger.so"
        mkdir -p ${DEPLOY_DIR_IMAGE}/CodeChecker/${BPN}/
        export CC_LOGGER_GCC_LIKE="gcc:g++:clang:clang++:cc:c++:ccache"
        export CC_LOGGER_FILE="${DEPLOY_DIR_IMAGE}/CodeChecker/${BPN}/codechecker-log.json"
    fi
}

do_compile_class-target[depends] += "codechecker-native:do_populate_sysroot"


do_codecheckeranalyse() {

    if test x"${CODECHECKER_ENABLED}" == x"1"; then

    export CC_LOGGER_FILE="${DEPLOY_DIR_IMAGE}/CodeChecker/${BPN}/codechecker-log.json"
    export CC_ANALYSE_OUT="${DEPLOY_DIR_IMAGE}/CodeChecker/${BPN}/results/"

    export PATH="$PATH:${RECIPE_SYSROOT_NATIVE}/usr/local/CodeChecker/bin"
    CodeChecker analyze -o ${CC_ANALYSE_OUT} --report-hash context-free-v2 ${CC_LOGGER_FILE}

    fi

}

addtask codecheckeranalyse before do_build after do_compile
do_codecheckeranalyse[depends] += "codechecker-native:do_populate_sysroot clang-native:do_populate_sysroot python3-native:do_populate_sysroot python3-psutil-native:do_populate_sysroot python3-portalocker-native:do_populate_sysroot python3-pyyaml-native:do_populate_sysroot"

do_codecheckerreport() {

    if test x"${CODECHECKER_ENABLED}" == x"1"; then
	if test x"${CODECHECKER_REPORT_HTML}" == x"1"; then
	    export CC_LOGGER_FILE="${DEPLOY_DIR_IMAGE}/CodeChecker/${BPN}/codechecker-log.json"
	    export CC_ANALYSE_OUT="${DEPLOY_DIR_IMAGE}/CodeChecker/${BPN}/results/"
	    export CC_REPORT_OUT="${DEPLOY_DIR_IMAGE}/CodeChecker/${BPN}/report-html/"
	    export PATH="$PATH:${RECIPE_SYSROOT_NATIVE}/usr/local/CodeChecker/bin"
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
	if test x"${CODECHECKER_REPORT_STORE}" == x"1"; then
	    if test ! x"${CODECHECKER_REPORT_HOST}" == x""; then
		#usage: CodeChecker store [-h] [-t {plist}] [-n NAME] [--tag TAG]
		#             [--description DESCRIPTION]
		#             [--trim-path-prefix [TRIM_PATH_PREFIX [TRIM_PATH_PREFIX ...]]]
		#             [--config CONFIG_FILE] [-f] [--url PRODUCT_URL]
		#             [--verbose {info,debug,debug_analyzer}]
		#             [file/folder [file/folder ...]]
		CodeChecker store -n ${PF} --trim-path-prefix=${S} --url ${CODECHECKER_REPORT_HOST} ${CC_ANALYSE_OUT}
	    fi
	fi
    fi
}

addtask codecheckerreport before do_build after do_codecheckeranalyse
do_codecheckerreport[depends] += "codechecker-native:do_populate_sysroot python3-native:do_populate_sysroot python3-psutil-native:do_populate_sysroot python3-portalocker-native:do_populate_sysroot python3-pyyaml-native:do_populate_sysroot"

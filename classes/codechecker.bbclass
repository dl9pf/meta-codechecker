
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
do_codecheckeranalyse[depends] += "codechecker-native:do_populate_sysroot clang-native:do_populate_sysroot python3-native:do_populate_sysroot python3-psutil-native:do_populate_sysroot"

python __anonymous () {
    if d.getVar('CODESCANNER_ENABLED') == "1":
        # enabled we are
        os.environ["LD_PRELOAD"] = "ldlogger.so"
        os.environ["LD_LIBRARY_PATH"] = "/path/to/codechecker.git/build/CodeChecker/ld_logger/lib"
        os.environ["CC_LOGGER_FILE"] = "" + d.getVar('DEPLOY_DIR_IMAGE') + "/CodeChecker/" + d.getVar('BPN') + "/codechecker-log.json"
}

# not ready ... just a try

export LD_PRELOAD
export LD_LIBRARY_PATH
export CC_LOGGER_FILE

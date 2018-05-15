#!/usr/bin/env bash
#
# Bootstrap the current terminal session by executing scripts under a given bootstrap directory.
#
# @author Aurelien Bourdon

#################################################
# Internal variables                            #
#################################################

# The directory from which bootstrap script files will be executed
bootstrapDirectory=$HOME/.session-bootstrap

# If the discovery of bootstrap script files has to be done in the lexicography order or not
sortedDiscovery=true

# Application name
APP=`basename $0`

# Error codes
HELP_WANTED=10
INVALID_OPTION=11
INVALID_BOOTSTRAP_DIRECTORY=12

#################################################
# Internal functions                            #
#################################################

# Display a message by overriding the current Terminal line
#
# @param $1 message to display
function dynamicEcho {
    local message="$1"
    echo -en "\r\033[K$message"
}

# Display help message
#
# @param nothing
function help {
    echo "usage: ${APP} [OPTIONS]"
    echo 'OPTIONS:'
    echo '      -d | --bootstrap-directory DIRECTORY    The DIRECTORY from which bootstrap script files will be discovered and executed. '
    echo '      -s | --sorted-discovery [true|false]    If the bootstrap script files discovery needs to be lexicographically sorted or not. Default: true.'
    echo '      -h | --help                             Display this helper message.'
}

# Parse user-given options
#
# @param $@ user options
# @return >0 if an error occurred
function parseOptions {
    while [[ $# -gt 0 ]]; do
        local argument="$1"
        case $argument in
            -h|--help)
                help
                return $HELP_WANTED
                ;;
            -d|--bootstrap-directory)
                bootstrapDirectory="$2"
                shift
                ;;
            -s|--sorted-discovery)
                sortedDiscovery="$2"
                if [ ! "$sortedDiscovery" = 'true' ] && [ ! "$sortedDiscovery" = 'false' ]; then
                    echo "Invalid sorted discovery option value '$sortedDiscovery'. Allowed values: true or false"
                    return $INVALID_OPTION
                fi
                shift
                ;;
            *)
                echo "Unknown option '$1'. See '$APP --help'"
                return $INVALID_OPTION
                ;;
        esac
        shift
    done
}

# Run the terminal session bootstrap process
#
# @param nothing
# @return >0 if an error occurred
function bootstrap {
    # Check if the bootstrap directory can be used
    if [ ! -d $bootstrapDirectory ] || [ ! -x $bootstrapDirectory ]; then
       echo "Unable to access to the terminal session bootstrap directory '$bootstrapDirectory'. Skipping terminal session bootstrap process."
       return $INVALID_BOOTSTRAP_DIRECTORY
    fi

    # Create the discovery command based on command options
    local discoveryCommand='find'
    if [ "$sortedDiscovery" = 'true' ]; then
        discoveryCommand="$discoveryCommand -s"
    fi
    discoveryCommand="$discoveryCommand $bootstrapDirectory -type f"

    # Retrieve each bootstrap script and execute it the current terminal session.
    for bootstrapScript in `eval $discoveryCommand`; do
        dynamicEcho "Bootstraping terminal session... ($bootstrapScript)"
        source $bootstrapScript
    done

    # Finally remove any output message
    dynamicEcho ''
}

# Clear environment by removing function and variable declarations
#
# @param nothing
function clearEnvironment {
    # Clear function declarations
    unset -f dynamicEcho
    unset -f help
    unset -f parseOptions
    unset -f bootstrap
    unset -f clearEnvironment
    unset -f main

    # Clear variable declarations
    unset bootstrapDirectory
    unset sortedDiscovery
    unset APP
    unset HELP_WANTED
    unset INVALID_OPTION
    unset INVALID_BOOTSTRAP_DIRECTORY
}

# Main entry point
#
# @param $@ the program arguments
# @return >0 if an error occurred
function main {
    parseOptions "$@" && bootstrap
    local isBootstrapSuccessful=$?
    clearEnvironment
    return $isBootstrapSuccessful
}

#################################################
# Execution                                     #
#################################################

main "$@"

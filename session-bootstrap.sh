#!/usr/bin/env bash
#
# Bootstrap the current terminal session by executing scripts under a given bootstrap directory.
#
# @author Aurelien Bourdon

#################################################
# Internal variables                            #
#################################################

# Application name
APP=`basename $0`

# Log levels
INFO='INFO'
ERROR='ERROR'

# Error codes
HELP_WANTED=10
INVALID_OPTION=11
INVALID_BOOTSTRAP_DIRECTORY=12

# The directory from which bootstrap script files will be executed
bootstrapDirectory=$HOME/.session-bootstrap

# If the discovery of bootstrap script files has to be done in the lexicography order or not
isSortedDiscovery=true

# If informational messages have to be displayed
isInformationMessagesDisplayed=true

#################################################
# Internal functions                            #
#################################################

# Display a message to the terminal
#
# @param $1 the log level to use
# @param $2 the message to display
function log {
    local level="$1"
    if [ $level = $INFO -a $isInformationMessagesDisplayed = false ]; then
        return 0
    fi
    local message="$2"
    echo "$APP: [$level] $message"
}

# Display an informational message to the terminal by overriding the current line
#
# @param $1 message to display
function dynamicLog {
    # Check if informational messages can be displayed
    if [ $isInformationMessagesDisplayed = false ]; then
        return 0
    fi

    # Format message if non-empty
    local message="$1"
    if [ -n "$message" ]; then
        message="$APP: $message"
    fi

    # Dynamically display message
    echo -en "\r\033[K$message"
}

# Display help message
#
# @param nothing
function help {
    echo "usage: ${APP} [OPTIONS]"
    echo 'OPTIONS:'
    echo '      -d | --bootstrap-directory DIRECTORY    The DIRECTORY from which bootstrap script files will be discovered and executed. '
    echo '      -r | --random-discovery                 Do not apply the lexicographically order when discovering script files under the bootstrap directory.'
    echo '      -i | --no-informational-messages        Do not display informational messages.'
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
                if ! [ -d "$bootstrapDirectory" -a -x "$bootstrapDirectory" ]; then
                    log $ERROR "Unable to access to the terminal session bootstrap directory '$bootstrapDirectory'."
                    return $INVALID_BOOTSTRAP_DIRECTORY
                fi
                shift
                ;;
            -r|--random-discovery)
                isSortedDiscovery=false
                ;;
            -i|--no-informational-messages)
                isInformationMessagesDisplayed=false
                ;;
            *)
                log $ERROR "Unknown option '$1'. See '$APP --help'"
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
    # Create the discovery command based on command options
    local discoveryCommand="find $bootstrapDirectory -type f"
    if [ $isSortedDiscovery = true ]; then
        discoveryCommand="$discoveryCommand | sort -df"
    fi

    # Retrieve each bootstrap script and execute it the current terminal session.
    for bootstrapScript in `eval $discoveryCommand`; do
        # End with space to handle potentially bootstrap script's output messages
        dynamicLog "Bootstraping terminal session... ($bootstrapScript): "
        source $bootstrapScript
    done

    # Finally remove any output message
    dynamicLog ''
}

# Clear environment by removing function and variable declarations
#
# @param nothing
function clearEnvironment {
    # Clear function declarations
    unset -f log
    unset -f dynamicLog
    unset -f help
    unset -f parseOptions
    unset -f bootstrap
    unset -f clearEnvironment
    unset -f main

    # Clear variable declarations
    unset bootstrapDirectory
    unset isSortedDiscovery
    unset isInformationMessagesDisplayed
    unset APP
    unset INFO
    unset ERROR
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
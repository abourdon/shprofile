#!/usr/bin/env bash
#
# shprofile: Manage several shell profiles and switch between them, but not only.
#
# @author Aurelien Bourdon

#################################################
# Internal variables                            #
#################################################

# Application name
APP='shprofile'

# Associated files
SHPROFILE_HOME="$HOME/.shprofile"
PROFILES_HOME=$SHPROFILE_HOME/profiles
CURRENT_PROFILE_KEEPER=$SHPROFILE_HOME/current

# Profile execution types
LOADING_PROFILE='LOADING_PROFILE'
UNLOADING_PROFILE='UNLOADING_PROFILE'

# Log levels
INFO='INFO'
ERROR='ERROR'

# Exit status
NO_ERROR=0
HELP_WANTED=10
CURRENT_PROFILE_WANTED=11
AVAILABLE_PROFILES_WANTED=12
PROFILE_UNLOAD_WANTED=13
PROFILE_FORGET_WANTED=14
INVALID_PROFILE=20
INVALID_PROFILES=21
INVALID_PROFILE_EXECUTION_TYPE=22

# Options
isInformationMessagesDisplayed=true
requiredProfile=''

#################################################
# Internal functions                            #
#################################################

# Display a log message to the terminal
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
        return $NO_ERROR
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
function displayHelp {
    echo "usage: ${APP} [OPTIONS] [PROFILE]"
    echo 'PROFILE: the profile name to load. If empty, then load the current enabled profile.'
    echo 'OPTIONS:'
    echo '      -c | --current                      Display the current enabled profile.'
    echo '      -l | --list                         Display the list of available profiles.'
    echo '      -u | --unload                       Unload the current enabled profile, if necessary.'
    echo '      -f | --forget                       Forget the current enabled profile, without unload it.'
    echo '      -I | --no-informational-messages    Do not display informational messages.'
    echo '      -h | --help                         Display this helper message.'
}

# Get the current enabled profile
#
# @param nothing
# @return the name of the current enabled profile or empty if no profile is currently enabled
function getCurrentProfile {
    if [ -f $CURRENT_PROFILE_KEEPER -a -r $CURRENT_PROFILE_KEEPER ]; then
        cat $CURRENT_PROFILE_KEEPER
    fi
}

# Display the current enabled profile
#
# @param nothing
function displayCurrentProfile {
    local currentProfile=$(getCurrentProfile)
    echo ${currentProfile:-No current enabled profile}
}

# Display available profiles, by marking the current enabled one
#
# @param nothing
function displayAvailableProfiles {
    if ! [ -d $PROFILES_HOME -a -x $PROFILES_HOME ]; then
        log $ERROR "Unable to access to profiles directory ($PROFILES_HOME)."
        return $INVALID_PROFILES
    fi
    local currentProfile=$(getCurrentProfile)
    for profile in `ls $PROFILES_HOME`; do
        if [ $profile = "$currentProfile" ]; then
            echo -n '* '
        fi
        echo $profile
    done
}

# Run the terminal session bootstrap process
#
# @param $1 the associated profile name
# @param $2 the associated profile execution type ($LOADING_PROFILE or $UNLOADING_PROFILE)
function executeScripts {
    # Check profile
    local profile="$1"
    if [ -z "$profile" ]; then
        return $INVALID_PROFILE
    fi

    local profileHome=$PROFILES_HOME/$profile
    if ! [ -d $profileHome -a -x $profileHome ]; then
        log $ERROR "Unable to unload profile '$profile' (unable to access to $profileHome). To forget it, use '$APP --forget'."
        return  $INVALID_PROFILE
    fi

    # Construct the list of scripts to execute according to the given profile and execution type
    local executionType="$2"
    local scriptsToExecute=''
    local messagePrefix=''
    case "$executionType" in
        $LOADING_PROFILE)
            scriptsToExecute="find $profileHome -type f | grep -v -E '\-unload(.[^.]+)?$' | sort -df"
            messagePrefix='Loading'
            ;;
        $UNLOADING_PROFILE)
             scriptsToExecute="find $profileHome -type f | grep -E '\-unload(.[^.]+)?$' | sort -df"
             messagePrefix='Unloading'
            ;;
        *)
            return $INVALID_PROFILE_EXECUTION_TYPE
            ;;
    esac
    messagePrefix="$messagePrefix profile '$profile'..."

    # Retrieve each bootstrap script and execute it the current terminal session.
    for scriptToExecute in `eval $scriptsToExecute`; do
        # End with space to handle potentially bootstrap script's output messages
        dynamicLog "$messagePrefix ($scriptToExecute): "
        source $scriptToExecute
    done

    # Finally remove any output message
    dynamicLog ''
}

# Unload the current enabled profile, if necessary, but not forget it.
#
# @param nothing
function unloadCurrentProfile {
    local currentProfile=`getCurrentProfile`
    if [ -z "$currentProfile" ]; then
        return $NO_ERROR
    fi
    executeScripts $currentProfile $UNLOADING_PROFILE
}

# Forget the current enabled profile, if necessary
#
# @param nothing
function forgetCurrentProfile {
    rm -f $CURRENT_PROFILE_KEEPER
}

# Load the required profile
#
# @param nothing
function loadRequiredProfile {
    executeScripts $requiredProfile $LOADING_PROFILE && echo $requiredProfile > $CURRENT_PROFILE_KEEPER
}

# Process the shell profile by unloading the current one if necessary and then apply the required one
#
# @param nothing
function processProfile {
    unloadCurrentProfile && loadRequiredProfile
}

# Clear environment by removing function and variable declarations in this script.
#
# Useful because this script needs to be sourced.
#
# @param nothing
function clearEnvironment {
    # Clear function declarations
    unset -f log
    unset -f dynamicLog
    unset -f displayHelp
    unset -f getCurrentProfile
    unset -f displayCurrentProfile
    unset -f executeScripts
    unset -f unloadCurrentProfile
    unset -f loadRequiredProfile
    unset -f processProfile
    unset -f clearEnvironment
    unset -f parseOptions
    unset -f main

    # Clear variable declarations
    unset APP
    unset SHPROFILE_HOME
    unset PROFILES_HOME
    unset CURRENT_PROFILE_KEEPER
    unset LOADING_PROFILE
    unset UNLOADING_PROFILE
    unset INFO
    unset ERROR
    unset NO_ERROR
    unset HELP_WANTED
    unset CURRENT_PROFILE_WANTED
    unset AVAILABLE_PROFILES_WANTED
    unset UNLOAD_PROFILE_WANTED
    unset INVALID_PROFILE
    unset INVALID_PROFILES
    unset INVALID_PROFILE_EXECUTION_TYPE
    unset isInformationMessagesDisplayed
    unset requiredProfile
}

# Parse user-given options and directly execute "self-contained" options
#
# @param $@ user options
function parseOptions {
    local exitStatus
    while [[ $# -gt 0 ]]; do
        local argument="$1"
        case $argument in
            -c|--current)
                displayCurrentProfile
                exitStatus=$?
                return $([ $exitStatus -ne $NO_ERROR ] && echo $exitStatus || echo $CURRENT_PROFILE_WANTED)
                ;;
            -l|--list)
                displayAvailableProfiles
                exitStatus=$?
                return $([ $exitStatus -ne $NO_ERROR ] && echo $exitStatus || echo $AVAILABLE_PROFILES_WANTED)
                ;;
            -u|--unload)
                unloadCurrentProfile
                exitStatus=$?
                return $([ $exitStatus -ne $NO_ERROR ] && echo $exitStatus || echo $PROFILE_UNLOAD_WANTED)
                ;;
            -f|--forget)
                forgetCurrentProfile
                exitStatus=$?
                return $([ $exitStatus -ne $NO_ERROR ] && echo $exitStatus || echo $PROFILE_FORGET_WANTED)
                ;;
            -I|--no-informational-messages)
                isInformationMessagesDisplayed=false
                ;;
            -h|--help)
                displayHelp
                exitStatus=$?
                return $([ $exitStatus -ne $NO_ERROR ] && echo $exitStatus || echo $HELP_WANTED)
                ;;
            *)
                requiredProfile="$argument"
                local requiredProfileHome="$PROFILES_HOME/$requiredProfile"
                if ! [ -d "$requiredProfileHome" -a -x "$requiredProfileHome" ]; then
                    log $ERROR "Unknown profile '$requiredProfile' (unable to access to '$requiredProfileHome'). Use '$APP --list' to display available profiles."
                    return $INVALID_PROFILE
                fi
                ;;
        esac
        shift
    done
    if [ -z $requiredProfile ]; then
        local currentProfile=`getCurrentProfile`
        if [ -z $currentProfile ]; then
            log $ERROR "Missing profile to load. Use '$APP --list' to display available profiles."
            return $INVALID_PROFILE
        fi
        requiredProfile=$currentProfile
    fi
}

# Main entry point
#
# @param $@ the program arguments
function main {
    # Parse options
    parseOptions "$@"
    local exitStatus=$?

    # Check if user used a "self-contained" option and so no more execution has to be done
    if [ $exitStatus -eq $HELP_WANTED \
        -o $exitStatus -eq $CURRENT_PROFILE_WANTED \
        -o $exitStatus -eq $AVAILABLE_PROFILES_WANTED \
        -o $exitStatus -eq $PROFILE_UNLOAD_WANTED \
        -o $exitStatus -eq $PROFILE_FORGET_WANTED ]; then
        return $NO_ERROR
    fi

    # Check if any error was met during option parsing
    if [ $exitStatus -ne $NO_ERROR ]; then
        return $exitStatus
    fi

    # Process profile
    processProfile
    exitStatus=$?

    # Finally clear the environment
    clearEnvironment
    return $exitStatus
}

#################################################
# Execution                                     #
#################################################

main "$@"
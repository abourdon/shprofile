#!/usr/bin/env bash
#
# shprofile: Manage several shell profiles and switch between them, but not only.
#
# @author Aurelien Bourdon

#####################################################
# Internal variables                                #
#                                                   #
# All prefixed with 'SHP_' or 'shp' to facilitate   #
# their reuse in profile's shell scripts            #
#####################################################

# Application name
SHP_APP='shprofile'

# Associated files
SHP_HOME="$HOME/.shprofile"
SHP_PROFILES_HOME=$SHP_HOME/profiles
SHP_CURRENT_PROFILE_KEEPER=$SHP_HOME/current

# Profile execution types
SHP_LOADING_PROFILE='LOADING_PROFILE'
SHP_UNLOADING_PROFILE='UNLOADING_PROFILE'

# Log levels
SHP_INFO='INFO'
SHP_ERROR='ERROR'

# Exit status
SHP_NO_ERROR=0
SHP_HELP_WANTED=10
SHP_INIT_ENVIRONMENT=11
SHP_CURRENT_PROFILE_WANTED=12
SHP_AVAILABLE_PROFILES_WANTED=13
SHP_PROFILE_UNLOAD_WANTED=14
SHP_PROFILE_FORGET_WANTED=15
SHP_INVALID_PROFILE=20
SHP_INVALID_PROFILES=21
SHP_INVALID_PROFILE_EXECUTION_TYPE=22

# Options
shpIsInformationMessagesDisplayed=true
shpRequiredProfile=''

#####################################################
# Internal functions                                #
#                                                   #
# All prefixed with 'shp' to facilitate their reuse #
# in profile's shell scripts                        #
#####################################################

# Display a log message to the terminal
#
# @param $1 the log level to use
# @param $2 the message to display
function shpLog {
    local level="$1"
    if [ $level = $SHP_INFO -a $shpIsInformationMessagesDisplayed = false ]; then
        return 0
    fi
    local message="$2"
    echo "$SHP_APP: [$level] $message"
}

# Display an informational message to the terminal by overriding the current line
#
# @param $1 message to display
function shpDynamicLog {
    # Check if informational messages can be displayed
    if [ $shpIsInformationMessagesDisplayed = false ]; then
        return $SHP_NO_ERROR
    fi

    # Format message if non-empty
    local message="$1"
    if [ -n "$message" ]; then
        message="$SHP_APP: $message"
    fi

    # Dynamically display message
    echo -en "\r\033[K$message"
}

# Display help message
#
# @param nothing
function shpDisplayHelp {
    echo "usage: ${SHP_APP} [OPTIONS] [PROFILE]"
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
function shpGetCurrentProfile {
    if [ -f $SHP_CURRENT_PROFILE_KEEPER -a -r $SHP_CURRENT_PROFILE_KEEPER ]; then
        cat $SHP_CURRENT_PROFILE_KEEPER
    fi
}

# Display the current enabled profile
#
# @param nothing
function shpDisplayCurrentProfile {
    local currentProfile=$(shpGetCurrentProfile)
    echo ${currentProfile:-No current enabled profile}
}

# Display available profiles, by marking the current enabled one
#
# @param nothing
function shpDisplayAvailableProfiles {
    if ! [ -d $SHP_PROFILES_HOME -a -x $SHP_PROFILES_HOME ]; then
        shpLog $SHP_ERROR "Unable to access to profiles directory ($SHP_PROFILES_HOME)."
        return $SHP_INVALID_PROFILES
    fi
    local currentProfile=$(shpGetCurrentProfile)
    for profile in `ls $SHP_PROFILES_HOME`; do
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
function shpExecuteScripts {
    # Check profile
    local profile="$1"
    if [ -z "$profile" ]; then
        return $SHP_INVALID_PROFILE
    fi

    local profileHome=$SHP_PROFILES_HOME/$profile
    if ! [ -d $profileHome -a -x $profileHome ]; then
        shpLog $SHP_ERROR "Unable to unload profile '$profile' (unable to access to $profileHome). To forget it, use '$SHP_APP --forget'."
        return  $SHP_INVALID_PROFILE
    fi

    # Construct the list of scripts to execute according to the given profile and execution type
    local executionType="$2"
    local scriptsToExecute=''
    local messagePrefix=''
    case "$executionType" in
        $SHP_LOADING_PROFILE)
            scriptsToExecute="find $profileHome -type f | grep -v -E '\-unload(.[^.]+)?$' | sort -df"
            messagePrefix='Loading'
            ;;
        $SHP_UNLOADING_PROFILE)
             scriptsToExecute="find $profileHome -type f | grep -E '\-unload(.[^.]+)?$' | sort -df"
             messagePrefix='Unloading'
            ;;
        *)
            return $SHP_INVALID_PROFILE_EXECUTION_TYPE
            ;;
    esac
    messagePrefix="$messagePrefix profile '$profile'..."

    # Retrieve each bootstrap script and execute it the current terminal session.
    for scriptToExecute in `eval $scriptsToExecute`; do
        # End with space to handle potentially bootstrap script's output messages
        shpDynamicLog "$messagePrefix ($scriptToExecute): "
        source $scriptToExecute
    done

    # Finally remove any output message
    shpDynamicLog ''
}

# Unload the current enabled profile, if necessary, but not forget it.
#
# @param nothing
function shpUnloadCurrentProfile {
    local currentProfile=`shpGetCurrentProfile`
    if [ -z "$currentProfile" ]; then
        return $SHP_NO_ERROR
    fi
    shpExecuteScripts $currentProfile $SHP_UNLOADING_PROFILE
}

# Forget the current enabled profile, if necessary
#
# @param nothing
function shpForgetCurrentProfile {
    rm -f $SHP_CURRENT_PROFILE_KEEPER
}

# Load the required profile
#
# @param nothing
function shpLoadRequiredProfile {
    shpExecuteScripts $shpRequiredProfile $SHP_LOADING_PROFILE && echo $shpRequiredProfile > $SHP_CURRENT_PROFILE_KEEPER
}

# Process the shell profile by unloading the current one if necessary and then apply the required one
#
# @param nothing
function shpProcessProfile {
    shpUnloadCurrentProfile && shpLoadRequiredProfile
}

# Clear environment by removing function and variable declarations in this script.
#
# Useful because this script needs to be sourced.
#
# @param nothing
function shpClearEnvironment {
    # Clear function declarations
    unset -f shpLog
    unset -f shpDynamicLog
    unset -f shpDisplayHelp
    unset -f shpGetCurrentProfile
    unset -f shpDisplayCurrentProfile
    unset -f shpExecuteScripts
    unset -f shpUnloadCurrentProfile
    unset -f shpLoadRequiredProfile
    unset -f shpProcessProfile
    unset -f shpClearEnvironment
    unset -f shpParseOptions
    unset -f shpMain

    # Clear variable declarations
    unset SHP_APP
    unset SHP_SHPROFILE_HOME
    unset SHP_PROFILES_HOME
    unset SHP_CURRENT_PROFILE_KEEPER
    unset SHP_LOADING_PROFILE
    unset SHP_UNLOADING_PROFILE
    unset SHP_INFO
    unset SHP_ERROR
    unset SHP_NO_ERROR
    unset SHP_HELP_WANTED
    unset SHP_CURRENT_PROFILE_WANTED
    unset SHP_AVAILABLE_PROFILES_WANTED
    unset SHP_UNLOAD_PROFILE_WANTED
    unset SHP_INVALID_PROFILE
    unset SHP_INVALID_PROFILES
    unset SHP_INVALID_PROFILE_EXECUTION_TYPE
    unset shpIsInformationMessagesDisplayed
    unset shpRequiredProfile
}

# Parse user-given options and directly execute "self-contained" options
#
# @param $@ user options
function shpParseOptions {
    local exitStatus
    while [[ $# -gt 0 ]]; do
        local argument="$1"
        case $argument in
            -c|--current)
                shpDisplayCurrentProfile
                exitStatus=$?
                return $([ $exitStatus -ne $SHP_NO_ERROR ] && echo $exitStatus || echo $SHP_CURRENT_PROFILE_WANTED)
                ;;
            -l|--list)
                shpDisplayAvailableProfiles
                exitStatus=$?
                return $([ $exitStatus -ne $SHP_NO_ERROR ] && echo $exitStatus || echo $SHP_AVAILABLE_PROFILES_WANTED)
                ;;
            -u|--unload)
                shpUnloadCurrentProfile
                exitStatus=$?
                return $([ $exitStatus -ne $SHP_NO_ERROR ] && echo $exitStatus || echo $SHP_PROFILE_UNLOAD_WANTED)
                ;;
            -f|--forget)
                shpForgetCurrentProfile
                exitStatus=$?
                return $([ $exitStatus -ne $SHP_NO_ERROR ] && echo $exitStatus || echo $SHP_PROFILE_FORGET_WANTED)
                ;;
            -I|--no-informational-messages)
                shpIsInformationMessagesDisplayed=false
                ;;
            -h|--help)
                shpDisplayHelp
                exitStatus=$?
                return $([ $exitStatus -ne $SHP_NO_ERROR ] && echo $exitStatus || echo $SHP_HELP_WANTED)
                ;;
            *)
                shpRequiredProfile="$argument"
                local requiredProfileHome="$SHP_PROFILES_HOME/$shpRequiredProfile"
                if ! [ -d "$requiredProfileHome" -a -x "$requiredProfileHome" ]; then
                    shpLog $SHP_ERROR "Unknown profile '$shpRequiredProfile' (unable to access to '$requiredProfileHome'). Use '$SHP_APP --list' to display available profiles."
                    return $SHP_INVALID_PROFILE
                fi
                ;;
        esac
        shift
    done
    if [ -z $shpRequiredProfile ]; then
        local currentProfile=`shpGetCurrentProfile`
        if [ -z $currentProfile ]; then
            return $SHP_INIT_ENVIRONMENT
        fi
        shpRequiredProfile=$currentProfile
    fi
}

# Main entry point
#
# @param $@ the program arguments
function shpMain {
    # Parse options
    shpParseOptions "$@"
    local exitStatus=$?

    # Check if user used a "self-contained" option and so no more execution has to be done
    if [ $exitStatus -eq $SHP_HELP_WANTED \
        -o $exitStatus -eq $SHP_INIT_ENVIRONMENT \
        -o $exitStatus -eq $SHP_CURRENT_PROFILE_WANTED \
        -o $exitStatus -eq $SHP_AVAILABLE_PROFILES_WANTED \
        -o $exitStatus -eq $SHP_PROFILE_UNLOAD_WANTED \
        -o $exitStatus -eq $SHP_PROFILE_FORGET_WANTED ]; then
        return $SHP_NO_ERROR
    fi

    # Check if any error was met during option parsing
    if [ $exitStatus -ne $SHP_NO_ERROR ]; then
        return $exitStatus
    fi

    # Process profile
    shpProcessProfile
    exitStatus=$?

    # Finally clear the environment
    shpClearEnvironment
    return $exitStatus
}

#####################################################
# Execution                                         #
#####################################################

shpMain "$@"
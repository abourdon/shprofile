#!/bin/bash
#
# Setup the current terminal session by executing scripts under the special $SESSION_STARTUP_DIRECTORY directory.
#
# @author Aurelien Bourdon

# The directory from which startup script files will be executed
SESSION_STARTUP_DIRECTORY=$HOME/.session-startup

# Run the terminal session startup process
function startup {
    # Check if the $SESSION_STARTUP_DIRECTORY can be used
    if [ ! -d $SESSION_STARTUP_DIRECTORY ] || [ ! -x $SESSION_STARTUP_DIRECTORY ]; then
       echo "Unable to access to the terminal session startup directory $SESSION_STARTUP_DIRECTORY. Skipping terminal session startup process."
       return 1
    fi

    # Execute each $SESSION_STARTUP_DIRECTORY files within the current terminal session.
    # Files iteration is done in lexicographical order
    for startupScript in `find -s $SESSION_STARTUP_DIRECTORY -type f`; do
        echo -en "\r\033[KInitialize terminal session... ($startupScript)"
        source $startupScript
    done
    # Then finally remove any output messages
    echo -en "\r\033[K"
}

startup

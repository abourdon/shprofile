#!/usr/bin/env bash
#
# Setup the current terminal session by executing scripts under the special $SESSION_BOOTSTRAP_DIRECTORY directory.
#
# @author Aurelien Bourdon

# The directory from which bootstrap script files will be executed
SESSION_BOOTSTRAP_DIRECTORY=$HOME/.session-bootstrap

# Run the terminal session bootstrap process
function bootstrap {
    # Check if the $SESSION_BOOTSTRAP_DIRECTORY can be used
    if [ ! -d $SESSION_BOOTSTRAP_DIRECTORY ] || [ ! -x $SESSION_BOOTSTRAP_DIRECTORY ]; then
       echo "Unable to access to the terminal session bootstrap directory $SESSION_BOOTSTRAP_DIRECTORY. Skipping terminal session bootstrap process."
       return 1
    fi

    # Execute each $SESSION_BOOTSTRAP_DIRECTORY files within the current terminal session.
    # Files iteration is done in lexicographical order
    for bootstrapScript in `find -s $SESSION_BOOTSTRAP_DIRECTORY -type f`; do
        echo -en "\r\033[KBootstraping terminal session... ($bootstrapScript)"
        source $bootstrapScript
    done
    # Then finally remove any output messages
    echo -en "\r\033[K"
}

bootstrap

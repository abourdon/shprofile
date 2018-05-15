#!/usr/bin/env bash
#
# Example of a simple screen (https://ss64.com/bash/screen.html) initialization process

# Define the .screenrc content (Adapt to your need)
cat > $HOME/.screenrc << EOL
vbell off
startup_message off
termcapinfo xterm* ti@:te@

caption always "%{= dw}%-w%{=b dr}%n %t%{= dw}%+w"
hardstatus alwayslastline "%{g}$LOGNAME@%H %=%{y}%d/%m/%y %c %{b}[%l]"
EOL
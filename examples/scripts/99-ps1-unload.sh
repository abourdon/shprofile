#!/usr/bin/env bash
#
# A simple example of revert of the shprofile's 99-ps1.sh example script

# Use the shprofile's shpGetCurrentProfile function and SHP_NO_ERROR variable
currentProfile=`shpGetCurrentProfile`
if [ -n $currentProfile ]; then
    PS1=`echo $PS1 | sed "s/^($currentProfile) //"`
fi
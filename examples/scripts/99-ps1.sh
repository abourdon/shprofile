#!/usr/bin/env bash
#
# A simple example of PS1 prompt overriding

# Use the shprofile's shpRequiredProfile to access to the new required profile name
PS1="($shpRequiredProfile) $PS1"
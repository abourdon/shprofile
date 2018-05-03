#!/bin/bash
#
# Common jenv (http://www.jenv.be) initialization process

eval "$(jenv init -)"

# Adapt to your need
export JAVA_HOME="$HOME/.jenv/versions/`jenv version-name`"

JAVA_BIN=$JAVA_HOME/bin
export PATH=$JAVA_BIN:$PATH
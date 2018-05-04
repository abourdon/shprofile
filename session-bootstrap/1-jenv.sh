#!/usr/bin/env bash
#
# Example of a simple jenv (http://www.jenv.be) initialization process

eval "$(jenv init -)"

# Adapt to your need
jenv shell 1.8
export JAVA_HOME="$HOME/.jenv/versions/`jenv version-name`"

JAVA_BIN=$JAVA_HOME/bin
export PATH=$JAVA_BIN:$PATH
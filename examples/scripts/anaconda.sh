#!/usr/bin/env bash
#
# Example of a simple anaconda (https://anaconda.org/anaconda/python) initialization process

# Adapt to your need
export ANACONDA_HOME=/usr/local/anaconda3
ANACONDA_BIN=$ANACONDA_HOME/bin

export PATH=$ANACONDA_BIN:$PATH

unset ANACONDA_BIN
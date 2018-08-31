#!/bin/bash

# Store existing env vars and set to this conda env
# so other installs don't pollute the environment.

if [[ -n "PROJ_LIB" ]]; then
    export _CONDA_SET_PROJ_LIB=PROJ_LIB
fi

if [[ -n "PROJ_DIR" ]]; then
    export _CONDA_SET_PROJ_DIR=PROJ_DIR
fi

export PROJ_LIB=$CONDA_PREFIX/share/proj
export PROJ_DIR=$CONDA_PREFIX/share/proj

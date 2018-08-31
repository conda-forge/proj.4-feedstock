#!/bin/bash

# Restore previous env vars if they were set.
unset PROJ_LIB
unset PROJ_DIR

if [[ -n "$_CONDA_SET_PROJ_LIB" ]]; then
    export PROJ_LIB=$_CONDA_SET_PROJ_LIB
    unset _CONDA_SET_PROJ_LIB
fi

if [[ -n "$_CONDA_SET_PROJ_DIR" ]]; then
    export PROJ_DIR=$_CONDA_SET_PROJ_DIR
    unset _CONDA_SET_PROJ_DIR
fi

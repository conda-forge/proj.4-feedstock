:: Store existing env vars and set to this conda env
:: so other installs don't pollute the environment.

@if defined PROJ_LIB (
    set "_CONDA_SET_PROJ_LIB=%PROJ_LIB%"
)

@if defined PROJ_DIR (
    set "_CONDA_SET_PROJ_LIB=%PROJ_DIR%"
)

@set "PROJ_LIB=%CONDA_PREFIX%\Library\share"
@set "PROJ_DIR=%CONDA_PREFIX%\Library\share"

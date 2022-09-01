:: Store existing env vars and set to this conda env
:: so other installs don't pollute the environment.

@if defined PROJ_DATA (
    set "_CONDA_SET_PROJ_DATA=%PROJ_DATA%"
)
@set "PROJ_DATA=%CONDA_PREFIX%\Library\share\proj"

@if exist "%CONDA_PREFIX%\Library\share\proj\copyright_and_licenses.csv" (
    rem proj-data is installed because its license was copied over
    @set "PROJ_NETWORK=OFF"
) else (
    @set "PROJ_NETWORK=ON"
)

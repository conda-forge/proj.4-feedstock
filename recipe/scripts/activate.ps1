# Store existing env vars and set to this conda env
# so other installs don't pollute the environment.

if (Test-Path Env:PROJ_DATA) {
    $Env:_CONDA_SET_PROJ_DATA = $Env:PROJ_DATA
}

$Env:PROJ_DATA = Join-Path $Env:CONDA_PREFIX "Library\share\proj"

if (Test-Path (Join-Path $Env:CONDA_PREFIX "Library\share\proj\copyright_and_licenses.csv")) {
    # proj-data is installed because its license was copied over
    $Env:PROJ_NETWORK = "OFF"
} else {
    $Env:PROJ_NETWORK = "ON"
}

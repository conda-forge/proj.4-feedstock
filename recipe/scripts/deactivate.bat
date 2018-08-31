:: Restore previous GDAL env vars if they were set.

@set "PROJ_LIB="
@set "PROJ_DIR="

@if defined _CONDA_SET_PROJ_LIB (
  set "PROJ_LIB=%_CONDA_SET_PROJ_LIB%"
  set "_CONDA_SET_PROJ_LIB="
)

@if defined _CONDA_SET_PROJ_DIR (
  set "PROJ_DIR=%_CONDA_SET_PROJ_DIR%"
  set "_CONDA_SET_PROJ_DIR="
)

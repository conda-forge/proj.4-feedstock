:: Restore previous PROJ env vars if they were set.

@set "PROJ_DATA="
@set "PROJ_NETWORK="
@if defined _CONDA_SET_PROJ_DATA (
  set "PROJ_DATA=%_CONDA_SET_PROJ_DATA%"
  set "_CONDA_SET_PROJ_DATA="
)

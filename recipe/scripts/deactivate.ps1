Remove-Item ENV:PROJ_DATA -ErrorAction Ignore
Remove-Item ENV:PROJ_NETWORK -ErrorAction Ignore

# Restore previous PROJ env vars if they were set

if ($ENV:_CONDA_SET_PROJ_DATA) {
  $ENV:PROJ_DATA = $ENV:_CONDA_SET_PROJ_DATA
  Remove-Item ENV:_CONDA_SET_PROJ_DATA
}
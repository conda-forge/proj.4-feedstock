cd %SRC_DIR%\nad
curl -fsS -o proj-datumgrid-1.7.zip http://download.osgeo.org/proj/proj-datumgrid-1.7.zip
7z x proj-datumgrid-1.7.zip
del proj-datumgrid-1.7.zip
cd ..

nmake /f makefile.vc

nmake INSTDIR=%LIBRARY_PREFIX% /f makefile.vc install-all
if errorlevel 1 exit 1

set ACTIVATE_DIR=%PREFIX%\etc\conda\activate.d
set DEACTIVATE_DIR=%PREFIX%\etc\conda\deactivate.d
mkdir %ACTIVATE_DIR%
mkdir %DEACTIVATE_DIR%

copy %RECIPE_DIR%\scripts\activate.bat %ACTIVATE_DIR%\proj4-activate.bat
if errorlevel 1 exit 1

copy %RECIPE_DIR%\scripts\deactivate.bat %DEACTIVATE_DIR%\proj4-deactivate.bat
if errorlevel 1 exit 1

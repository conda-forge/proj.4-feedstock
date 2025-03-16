mkdir build && cd build

cmake -G "NMake Makefiles" ^
         -D CMAKE_BUILD_TYPE=Release ^
         -D BUILD_SHARED_LIBS="ON" ^
         -D CMAKE_C_FLAGS="/WX" ^
         -D CMAKE_CXX_FLAGS="/WX" ^
         -D CMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%" ^
         %SRC_DIR%
if errorlevel 1 exit 1

cmake --build . --config Release --target install
if errorlevel 1 exit 1

ctest --output-on-failure
if errorlevel 1 exit 1

cd ..

del /F /Q %LIBRARY_PREFIX%\\share\\proj\\*.cmake
if errorlevel 1 exit 1

set ACTIVATE_DIR=%PREFIX%\etc\conda\activate.d
set DEACTIVATE_DIR=%PREFIX%\etc\conda\deactivate.d
if not exist %ACTIVATE_DIR% mkdir %ACTIVATE_DIR%
if errorlevel 1 exit 1
if not exist %DEACTIVATE_DIR% mkdir %DEACTIVATE_DIR%
if errorlevel 1 exit 1

copy %RECIPE_DIR%\scripts\activate.bat %ACTIVATE_DIR%\proj4-activate.bat
if errorlevel 1 exit 1

copy %RECIPE_DIR%\scripts\deactivate.bat %DEACTIVATE_DIR%\proj4-deactivate.bat
if errorlevel 1 exit 1

:: Copy unix shell activation scripts, needed by Windows Bash users
copy %RECIPE_DIR%\scripts\activate.sh %ACTIVATE_DIR%\proj4-activate.sh
if errorlevel 1 exit 1

copy %RECIPE_DIR%\scripts\deactivate.sh %DEACTIVATE_DIR%\proj4-deactivate.sh
if errorlevel 1 exit 1

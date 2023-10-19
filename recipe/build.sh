#!/bin/bash

mkdir -p build && cd build

if [[ "$CONDA_BUILD_CROSS_COMPILATION" != "1" ]]; then
    EXE_SQLITE3=${PREFIX}/bin/sqlite3
else
    EXE_SQLITE3=${BUILD_PREFIX}/bin/sqlite3
fi

cmake ${CMAKE_ARGS} \
      -D CMAKE_BUILD_TYPE=Release \
      -D BUILD_SHARED_LIBS=ON \
      -D CMAKE_INSTALL_PREFIX=${PREFIX} \
      -D CMAKE_INSTALL_LIBDIR=lib \
      -D EXE_SQLITE3=${EXE_SQLITE3} \
      ${SRC_DIR}

make -j${CPU_COUNT} ${VERBOSE_CM}

# skip tests on linux32 due to rounding error causing issues
if [[ ! ${HOST} =~ .*linux.* ]] || [[ ! ${ARCH} == 32 ]]; then
if [[ "${CONDA_BUILD_CROSS_COMPILATION:-}" != "1" || "${CROSSCOMPILING_EMULATOR}" != "" ]]; then
    ctest --output-on-failure
fi
fi

make install -j${CPU_COUNT}

ACTIVATE_DIR=${PREFIX}/etc/conda/activate.d
DEACTIVATE_DIR=${PREFIX}/etc/conda/deactivate.d
mkdir -p ${ACTIVATE_DIR}
mkdir -p ${DEACTIVATE_DIR}

cp ${RECIPE_DIR}/scripts/activate.sh ${ACTIVATE_DIR}/proj4-activate.sh
cp ${RECIPE_DIR}/scripts/deactivate.sh ${DEACTIVATE_DIR}/proj4-deactivate.sh
cp ${RECIPE_DIR}/scripts/activate.csh ${ACTIVATE_DIR}/proj4-activate.csh
cp ${RECIPE_DIR}/scripts/deactivate.csh ${DEACTIVATE_DIR}/proj4-deactivate.csh
cp ${RECIPE_DIR}/scripts/activate.fish ${ACTIVATE_DIR}/proj4-activate.fish
cp ${RECIPE_DIR}/scripts/deactivate.fish ${DEACTIVATE_DIR}/proj4-deactivate.fish

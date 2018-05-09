#!/bin/bash

pushd $SRC_DIR/nad
# FIXME: check the sha256 manually 054e7b63b474926c79f25fbe5cd8760351e8d93e5a167b5473e993c01bb08866
curl -L -O http://download.osgeo.org/proj/proj-datumgrid-1.7.zip
unzip -o proj-datumgrid-1.7.zip
rm -rf proj-datumgrid-1.7.zip
popd


./configure --prefix=$PREFIX --without-jni

export CFLAGS="-O2 -Wl,-S $CFLAGS"

make -j$CPU_COUNT
make check -j$CPU_COUNT
make install -j$CPU_COUNT

ACTIVATE_DIR=$PREFIX/etc/conda/activate.d
DEACTIVATE_DIR=$PREFIX/etc/conda/deactivate.d
mkdir -p $ACTIVATE_DIR
mkdir -p $DEACTIVATE_DIR

cp $RECIPE_DIR/scripts/activate.sh $ACTIVATE_DIR/proj4-activate.sh
cp $RECIPE_DIR/scripts/deactivate.sh $DEACTIVATE_DIR/proj4-deactivate.sh

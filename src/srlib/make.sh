#!/bin/bash

compile_scratch() {
  SCRATCHDIR=../../srlib/scratch
  mkdir -p $SCRATCHDIR
  cp *.h *.cpp *.rasl $SCRATCHDIR

  ../../bin/srefc-core -C $SREFC_FLAGS $SOURCES

  for s in $SOURCES; do
    grep '//FROM' < $s.sref > $SCRATCHDIR/$s.rasl.froms
    [ -e $s.cpp ] && mv $s.cpp $SCRATCHDIR
    mv $s.rasl $SCRATCHDIR
  done

  for d in platform-*; do
    if [ -d $d ]; then
      mkdir -p $SCRATCHDIR/$d
      cp $d/*.cpp $SCRATCHDIR/$d
      cp $d/*.rasl $SCRATCHDIR/$d
    fi
  done
}

compile_rich() {
  RICHDIR=../../srlib/rich

  mkdir -p $RICHDIR
  ( cd ../srlib-rich-prefix && ./make.sh "$SOURCES $RT" )

  mv ../../bin/rich-prefix* $RICHDIR/rich.exe-prefix
  # Префикс не должен быть исполнимым
  chmod -x $RICHDIR/rich.exe-prefix

  for s in $SOURCES $RT; do
    cat /dev/null > $RICHDIR/$s.rasl
    echo '//PREFIX rich' > $RICHDIR/$s.rasl.froms
  done
}

prepare_common() {
  mkdir -p ../../srlib/common
  cp -R common/* ../../srlib/common
}

(
  SOURCES="Library LibraryEx GetOpt Hash"
  RT="refalrts refalrts-platform-specific refalrts-platform-POSIX"

  mkdir -p ../../srlib/src
  cp LICENSE ../../srlib
  for s in $SOURCES; do
    cp $s.sref ../../srlib/src
  done

  compile_scratch
  compile_rich
  prepare_common
)

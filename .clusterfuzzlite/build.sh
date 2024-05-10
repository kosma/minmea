#!/bin/bash
for file in "minmea.c"; do
  $CC $CFLAGS -c ${file}
done

rm -f ./test*.o
llvm-ar rcs libfuzz.a *.o


$CC $CFLAGS $LIB_FUZZING_ENGINE $SRC/fuzzer.c -Wl,--whole-archive $SRC/minmea/libfuzz.a -Wl,--allow-multiple-definition -I$SRC/minmea/ -I$SRC/minmea/compat  -o $OUT/fuzzer

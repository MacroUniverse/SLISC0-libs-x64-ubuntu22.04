#!/bin/bash

if [ `uname` = "Darwin" ]; then
    LDPATHPREFIX="DYLD_LIBRARY_PATH=/home/docker/MPLAPACK/lib"
else
    LDPATHPREFIX="LD_LIBRARY_PATH=/home/docker/MPLAPACK/lib:$LD_LIBRARY_PATH"
fi

####
MPLIBS="_Float128 _Float64x dd double"

for _mplib in $MPLIBS; do
env $LDPATHPREFIX ./Rgemv.${_mplib}_opt -NOCHECK  >& log.Rgemv.${_mplib}_opt
env $LDPATHPREFIX ./Rgemv.${_mplib}     -NOCHECK  >& log.Rgemv.${_mplib}
done
####

####
MPLIBS="mpfr gmp qd"

for _mplib in $MPLIBS; do
env $LDPATHPREFIX ./Rgemv.${_mplib}_opt -NOCHECK  >& log.Rgemv.${_mplib}_opt
env $LDPATHPREFIX ./Rgemv.${_mplib}     -NOCHECK  >& log.Rgemv.${_mplib}
done
####

####
if [ `uname` = "Linux" ]; then
    MODELNAME=`lscpu | grep 'Model name' | uniq | awk '{for(i=3;i<=NF;i++) printf $i FS }'`
    SED=sed
elif [ `uname` = "Darwin" ]; then
    MODELNAME=`sysctl machdep.cpu.brand_string | awk '{for(i=2;i<=NF;i++) printf $i FS }'`
    SED=gsed
else
    MODELNAME="unknown"
fi

$SED -i -e "s/%%MODELNAME%%/$MODELNAME/g" Rgemv1.plt
$SED -i -e "s/%%MODELNAME%%/$MODELNAME/g" Rgemv2.plt
$SED -i -e "s/%%MODELNAME%%/$MODELNAME/g" Rgemv3.plt
####

gnuplot Rgemv1.plt > Rgemv1.pdf
gnuplot Rgemv2.plt > Rgemv2.pdf
gnuplot Rgemv3.plt > Rgemv3.pdf

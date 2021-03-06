#!/bin/sh

TOP=`pwd`

: ${LOGS:="${TOP}/logs"}
mkdir -p ${LOGS}

: ${BUILD_TYPE:="Release"}
export CMAKE="cmake -G Ninja -D CMAKE_BUILD_TYPE=${BUILD_TYPE}"

echo "Building CADETS LLVM and FreeBSD in ${TOP}"


#
# Build LLVM and add it to the PATH
#
cd ${TOP}/llvm
mkdir -p build/${BUILD_TYPE} && cd build/${BUILD_TYPE}
export LLVM_PREFIX=`pwd`

echo ""
echo "Building LLVM in ${LLVM_PREFIX}"

echo -n "Configuring... "
env > ${LOGS}/llvm-config.env
${CMAKE} ../.. 2>&1 > ${LOGS}/llvm-config.log || exit 1
echo "done."

echo -n "Building... "
nice ninja || exit 1

export PATH=${LLVM_PREFIX}/bin:$PATH


#
# Build LLVM Loom using our newly-built LLVM
#
cd ${TOP}/loom
mkdir -p build/${BUILD_TYPE} && cd build/${BUILD_TYPE}
export LOOM_PREFIX=`pwd`

echo ""
echo "Building LLVM Loom in ${LOOM_PREFIX}"

echo -n "Configuring... "
env > ${LOGS}/loom-config.env
${CMAKE} ../.. 2>&1 > ${LOGS}/loom-config.log || exit 1
echo "done."

echo -n "Building... "
nice ninja || exit 1


#
# Build llvm-prov
#

cd ${TOP}/llvm-prov
mkdir -p build/${BUILD_TYPE} && cd build/${BUILD_TYPE}
export LLVM_PROV_PREFIX=`pwd`

echo ""
echo "Building llvm-prov in ${LLVM_PROV_PREFIX}"

echo -n "Configuring... "
env > ${LOGS}/llvm-prov-config.env
${CMAKE} ../.. 2>&1 > ${LOGS}/llvm-prov-config.log || exit 1
echo "done."

echo -n "Building... "
nice ninja || exit 1

export LLVM_PROV_MAKE=${TOP}/llvm-prov/scripts/llvm-prov-make


#
# Finally, build FreeBSD with llvm-prov:
#

#export LLVM_PROV_LIB=${TOP}/llvm-prov/build/${BUILD_TYPE}/lib/LLVMProv.so

echo ""
echo "Building FreeBSD from `pwd`"

LOGFILE=${LOGS}/freebsd-build.log
echo "Logging to: ${LOGFILE}"
echo "OBJDIR: `make -V .OBJDIR`"
time ${TOP}/cadets-ci/scripts/cadets-build.sh ${TOP}/freebsd > ${LOGFILE}

echo ""
echo "All done!"

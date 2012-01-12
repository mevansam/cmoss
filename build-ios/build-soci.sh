#!/bin/sh
set -e

# Copyright (c) 2011, Mevan Samaratunga
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#     * Redistributions of source code must retain the above copyright
#       notice, this list of conditions and the following disclaimer.
#     * Redistributions in binary form must reproduce the above copyright
#       notice, this list of conditions and the following disclaimer in the
#       documentation and/or other materials provided with the distribution.
#     * The name of Mevan Samaratunga may not be used to endorse or
#       promote products derived from this software without specific prior
#       written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL PIERRE-OLIVIER LATOUR BE LIABLE FOR ANY
# DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
# (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
# LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
# ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

# Download source
if [ ! -e "soci-${SOCI_VERSION}.zip" ]
then
  curl $PROXY -O "http://surfnet.dl.sourceforge.net/project/soci/soci/soci-${SOCI_VERSION}/soci-${SOCI_VERSION}.zip"
fi

# Extract source
rm -rf "soci-${SOCI_VERSION}"
unzip "soci-${SOCI_VERSION}.zip"

# Copy customized make files
cp -f ${TOPDIR}/build-ios/Makefile.soci-core soci-${SOCI_VERSION}/core
cp -f ${TOPDIR}/build-ios/Makefile.soci-sqlite3 soci-${SOCI_VERSION}/backends/sqlite3

# Build
BIGFILES=-D_FILE_OFFSET_BITS=64
export DEVROOT="${DEVELOPER}/Platforms/${PLATFORM}.platform/Developer"
export SDKROOT="${DEVROOT}/SDKs/${PLATFORM}${SDK}.sdk"
export CC=${DEVROOT}/usr/bin/gcc
export LD=${DEVROOT}/usr/bin/ld
export CPP=${DEVROOT}/usr/bin/cpp
export CXX=${DEVROOT}/usr/bin/g++
export AR=${DEVROOT}/usr/bin/ar
export AS=${DEVROOT}/usr/bin/as
export NM=${DEVROOT}/usr/bin/nm
export CXXCPP=${DEVROOT}/usr/bin/cpp
export RANLIB=${DEVROOT}/usr/bin/ranlib
export LDFLAGS="-Os -fvisibility=hidden -arch ${ARCH} -pipe -no-cpp-precomp -isysroot ${SDKROOT} -L${ROOTDIR}/lib"
export CFLAGS="-Os -fvisibility=hidden -arch ${ARCH} -pipe -no-cpp-precomp -isysroot ${SDKROOT} -I${ROOTDIR}/include -g ${BIGFILES}"
export CXXFLAGS="-Os -fvisibility=hidden -arch ${ARCH} -pipe -no-cpp-precomp -isysroot ${SDKROOT} -I${ROOTDIR}/include"
if [ "${SDK}" == "3.2" ]
then
  if [ "${PLATFORM}" == "iPhoneSimulator" ]
  then
    # Work around linker error "ld: library not found for -lcrt1.10.6.o" on iPhone Simulator 3.2
    export LDFLAGS="${LDFLAGS} -mmacosx-version-min=10.5"
    export CFLAGS="${CFLAGS} -mmacosx-version-min=10.5"
    export CXXFLAGS="${CXXFLAGS} -mmacosx-version-min=10.5"
  fi
fi

pushd soci-${SOCI_VERSION}/core
make -f Makefile.soci-core install CXX="${CXX}" AR="${AR}" CXXFLAGS="${CXXFLAGS}" PREFIX="${ROOTDIR}"
popd
pushd soci-${SOCI_VERSION}/backends/sqlite3
make -f Makefile.soci-sqlite3 install CXX="${CXX}" AR="${AR}" RANLIB="${RANLIB}" CXXFLAGS="${CXXFLAGS}" PREFIX="${ROOTDIR}"
popd

# Clean up
rm -rf "soci-${SOCI_VERSION}"


#!/bin/bash

## Variables
OPENSSL_VERSION=1_1_1s_mac_1

##############################
### BUILD SCRIPT #############
##############################

echo "Download OpenSSL: ${OPENSSL_VERSION}"
curl -JLO https://github.com/Dragon-S/openssl/archive/refs/tags/OpenSSL_${OPENSSL_VERSION}.tar.gz
tar xf openssl-OpenSSL_${OPENSSL_VERSION}.tar.gz && rm -rf openssl-OpenSSL_${OPENSSL_VERSION}.tar.gz

# We need absolute path
TMP_DIR="`pwd`/build_openssl"

# # Change to OpenSSL directory
cd openssl-OpenSSL_${OPENSSL_VERSION}

function build_for ()
{
  ARCH=$1
  PLATFORM=darwin64-$1-cc

  echo "Building Open SSL for ${ARCH}"
  if [ -f "configdata.pm" ]; then
    make clean
  fi

  ./Configure $PLATFORM no-asm no-shared no-hw no-async --prefix=${TMP_DIR}/${ARCH} || exit 1
  make && make install_sw || exit 2
}

function pack_for ()
{
  LIBNAME=$1
  mkdir -p ${TMP_DIR}/lib/
  ${DEVROOT}/usr/bin/lipo \
  ${TMP_DIR}/x86_64/lib/lib${LIBNAME}.a \
  ${TMP_DIR}/arm64/lib/lib${LIBNAME}.a \
  -output ${TMP_DIR}/lib/lib${LIBNAME}.a -create
}

echo "Start Building OpenSSL... "
build_for arm64 || exit 2
build_for x86_64 || exit 3

echo "Building FAT binary release version"
pack_for ssl || exit 4
pack_for crypto || exit 5
echo "  |> copy header files"
cp -r ${TMP_DIR}/arm64/include $TMP_DIR/lib/

echo "Build-Script is done."
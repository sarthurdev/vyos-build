#!/bin/bash
CWD=$(pwd)
set -e

SRC=wpa

if [ ! -d ${SRC} ]; then
    echo "${SRC} directory does not exists, please 'git clone'"
    exit 1
fi

echo "I: Copy Debian build instructions"
for f in patches/* ; do
    cp $f ${SRC}/debian/patches/
    echo $(basename $f) >> ${SRC}/debian/patches/series
done

# Build Debian package
cd ${SRC}

echo "I: Build Debian hostap Package"
dpkg-buildpackage -us -uc -tc -b -Ppkg.wpa.nogui

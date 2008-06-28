#!/bin/bash
#
# Small install script


PREFIX=$1

echo -n "Installing Kitaman ... "

mkdir -p $PREFIX/var/kitaman
mkdir -p $PREFIX/usr/kitaman/{pkg,src,kita}

cp *.py $PREFIX/usr/bin/
mv $PREFIX/usr/bin/kitaman.py $PREFIX/usr/bin/kitaman
cp kitaman.conf $PREFIX/etc/
cp kitaman.repos $PREFIX/etc/
cp kitaman.sources $PREFIX/etc/
cp -r kita $PREFIX/usr/kitaman/
echo "Done"

#!/bin/bash

PREFIX=/usr

echo -n "Installing Kitaman ... "

mkdir -p $PREFIX/kitaman/{pkg,src,kita}

cp *.py $PREFIX/bin/
mv $PREFIX/bin/kitaman.py $PREFIX/bin/kitaman
cp kitaman.conf $PREFIX/etc/
cp kitaman.repos $PREFIX/etc/
cp kitaman.sources $PREFIX/etc/
cp -r kita $PREFIX/kitaman/
echo "Done"

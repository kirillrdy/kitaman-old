#!/bin/bash
#
# Small install script


PREFIX=$1

echo -n "Installing Kitaman ... "

mkdir -p $PREFIX/usr/lib/ruby/1.8/kitaman
mkdir -p $PREFIX/var/kitaman/{build,install}
mkdir -p $PREFIX/usr/kitaman/{pkg,src,kita_files}

cp kitaman.rb $PREFIX/usr/bin/kitaman
mkdir -p $PREFIX/usr/lib/ruby/1.9.1/kitaman
cp lib/* $PREFIX/usr/lib/ruby/1.9.1/kitaman/
cp etc/kitaman.conf $PREFIX/etc/
cp etc/kitaman.repos $PREFIX/etc/
#cp kitaman.repos $PREFIX/etc/
#cp kitaman.sources $PREFIX/etc/
cp -r kita_files $PREFIX/usr/kitaman/
echo "Done"

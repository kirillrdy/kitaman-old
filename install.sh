#!/bin/bash

echo -n "Installing Kitaman ..."
cp *.py /usr/bin/
mv /usr/bin/kitaman.py /usr/bin/kitaman
cp kitaman.conf /etc/
cp kitaman.repos /etc/
cp kitaman.sources /etc/
echo "Done"

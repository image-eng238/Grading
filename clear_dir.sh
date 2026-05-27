#!/bin/bash

echo -n "? [Y/n]: "
read ANS

if [ "$ANS" = "Y" ] || [ "$ANS" = "y" ]; then
cd data
rm -rf *
cd ..

cd bin
rm -rf *
cd ..

cd log
rm -rf *
cd ..
fi

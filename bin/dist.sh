#!/bin/bash

./bin/clean.sh

./bin/assemble.sh

echo "Making .love dist"

cd temp
zip -9 -r magic-shapes.love .
cp magic-shapes.love ../dist

echo 'done'

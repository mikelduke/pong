#!/bin/bash

./bin/clean.sh

./bin/assemble.sh

NAME="air-hockey"

echo "Making $NAME.love dist"

cd temp
zip -9 -r $NAME.love .
cp $NAME.love ../dist

echo 'done'

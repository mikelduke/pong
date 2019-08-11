#!/bin/bash

echo 'assembling to temp'

mkdir -p dist
mkdir -p temp

mkdir -p temp/assets
cp -rf *.* temp/
cp -rf assets/ temp/

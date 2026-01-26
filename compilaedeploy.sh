#!/bin/bash

echo "Compila e deploy .."

make release-win64 -j4
cd build/release
make deploy

echo "fatto"
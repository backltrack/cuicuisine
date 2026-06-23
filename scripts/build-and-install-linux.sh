#!/bin/bash

flutter build linux --release
if [ -f "build/linux/x64/release/bundle/cuicuisine" ]; then
    tar -czf scripts/linux/bundle.tar.gz -C build/linux/x64/release bundle
    cd scripts/linux
    makepkg -si
    rm -rf pkg src bundle.tar.gz cuicuisine-*
else
    echo "Linux build failed."
fi

#!/bin/bash
if [[ $# != 1 ]]; then
    echo Usage: $0 VERSION
    echo Example: $0 0.2
    exit 1
fi
VERSION=$1

zip -r vgaonoff-v$VERSION.zip VGAONOFF.COM COPYING README.md example/ vgaonoff.asm build.bat

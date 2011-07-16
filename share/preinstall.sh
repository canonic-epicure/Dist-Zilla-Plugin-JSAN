#!/bin/bash

#PODNAME: pre_install_jsan.sh

ROOT=$(npm root 2>/dev/null)

if [ "$(npm config get global 2>/dev/null)" == "true" ] 
then
    export NPM_ROOT="$ROOT"
else
	export NPM_ROOT=$(readlink -m "$ROOT/../..")
fi

echo "Current npm root: $NPM_ROOT"

mkdir -p "$NPM_ROOT/.jsan"
mkdir -p "$NPM_ROOT/.jsanver"

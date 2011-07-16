#!/bin/bash

#PODNAME: preinstall.sh

NPM_ROOT=$(pwd)
NPM_ROOT=$(readlink -m "$NPM_ROOT/..")

mkdir -p "$NPM_ROOT/.jsan"
mkdir -p "$NPM_ROOT/.jsanver"

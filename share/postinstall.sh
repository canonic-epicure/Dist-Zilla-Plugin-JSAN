#!/bin/bash

#PODNAME: postinstall.sh

NPM_ROOT=$(pwd)
NPM_ROOT=$(readlink -m "$NPM_ROOT/..")

until [ ! -d "$NPM_ROOT/../../.jsan" ] 
do
	NPM_ROOT=$(readlink -m "$NPM_ROOT/../..")
done

echo "Top-level npm root: $NPM_ROOT"


print_key() {
	CONTENT=$(cat $1)
	
	KEY=$(node -e "($CONTENT).$2")
}

compare_versions() {
	CMP_RES=$(node -e "require('./__script/semver').compare('$1', '$2')")
}

print_key ./package.json name

DIST_NAME=$KEY
DIST_VER_FILE="$NPM_ROOT/.jsanver/$DIST_NAME.json"

print_key ./package.json version

GOING_TO_INSTALL=$KEY


if [ -e "$DIST_VER_FILE" ]
then
	print_key $DIST_VER_FILE version
	
	ALREADY_HAS=$KEY
	
	echo "Version file exists for: $DIST_VER_FILE, we have $ALREADY_HAS and installing $GOING_TO_INSTALL"
	
	compare_versions $ALREADY_HAS $GOING_TO_INSTALL
	
	if [ $CMP_RES != "-1" ]
	then
		echo "Already have the same or newer version"
		
		exit 0
	fi
	
fi

echo "Installing $DIST_NAME to .jsan"

cp -r ./lib/* "$NPM_ROOT/.jsan"      
cp -r ./package.json $DIST_VER_FILE



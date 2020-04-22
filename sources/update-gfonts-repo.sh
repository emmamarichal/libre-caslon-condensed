#!/bin/bash

# This script copies the latest builds to the google fonts dir in order to run QA checks and prep for a PR
#
# USAGE: 
# Install requirements with `pip install -U -r misc/googlefonts-qa/requirements.txt`
# 
# after  `misc/googlefonts-qa/build.sh`
# call this script from the root of your inter repo, with the absolute path your your google/fonts repo
# `misc/googlefonts-qa/fix-move-check.sh <your_username>/<path>/fonts`
#
# add `push` to the end if you wish to push the result to GitHub

set -e
source venv/bin/activate


gFontsDir=$1
if [[ -z "$gFontsDir" || $gFontsDir = "--help" ]] ; then
    echo 'Add absolute path to your Google Fonts Git directory, like:'
    echo 'sources/update-gfonts-repo.sh /Users/username/type-repos/google-font-repos/fonts'
    exit 2
fi

# option to push to GitHub. Without this, it will do a dry run.
pushToGitHub=$2

libreCaslonDir=$(pwd)

# libreCaslonQADir=$libreCaslonDir/misc/googlefonts-qa

libreCaslonRomanVF=$libreCaslonDir/fonts/LibreCaslonText\[wght\].ttf
libreCaslonItalicVF=$libreCaslonDir/fonts/LibreCaslonText-Italic\[wght\].ttf


# -------------------------------------------------------------------
# get latest font version to use in PR commit message ---------------
set +e

ttx -t head $libreCaslonRomanVF
fontVersion=v$(xml sel -t --match "//*/fontRevision" -v "@value" ${libreCaslonRomanVF/".ttf"/".ttx"})

echo $fontVersion

rm ${libreCaslonRomanVF/".ttf"/".ttx"}

set -e

# -------------------------------------------------------------------
# navigate to google/fonts repo, get latest, then update inter branch

cd $gFontsDir
git checkout master
git pull upstream master
git reset --hard
git checkout -B inter
git clean -f -d

# -------------------------------------------------------------------
# move fonts --------------------------------------------------------

mkdir -p ofl/librecaslontext

cp $interFullVF    ofl/inter/Inter\[slnt,wght\].ttf
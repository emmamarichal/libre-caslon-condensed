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

# -------------------------------------------------------------------
# UPDATE VARIABLES ABOVE AS NEEDED

gFontsDir="/Users/stephennixon/type-repos/google-font-repos/fonts" # absolute path to your google/fonts repo directory
gFontsSubDir="librecaslontext"                                     # name for this directory within google/fonts/ofl

libreCaslonDir=$(pwd)
libreCaslonRomanVF=$libreCaslonDir/fonts/LibreCaslonText\[wght\].ttf
libreCaslonItalicVF=$libreCaslonDir/fonts/LibreCaslonText-Italic\[wght\].ttf

# UPDATE VARIABLES ABOVE AS NEEDED
# -------------------------------------------------------------------

set -e
source venv/bin/activate

# option to push to GitHub. Without this, it will do a dry run.
pushToGitHub=$1
if [[ "$pushToGitHub" = "-h" || $pushToGitHub = "--help" ]] ; then
    echo 'Add absolute path to your Google Fonts Git directory, like:'
    echo 'sources/update-gfonts-repo.sh /Users/username/type-repos/google-font-repos/fonts'
    exit 2
fi

# -------------------------------------------------------------------
# get latest font version to use in PR commit message 
set +e

ttx -t head $libreCaslonRomanVF
fontVersion=v$(xml sel -t --match "//*/fontRevision" -v "@value" ${libreCaslonRomanVF/".ttf"/".ttx"})

echo $fontVersion

rm ${libreCaslonRomanVF/".ttf"/".ttx"}

set -e

# -------------------------------------------------------------------
# navigate to google/fonts repo, get latest, then clear branch & font subdirectory

cd $gFontsDir
git checkout master
git pull upstream master
git reset --hard
git checkout -B $gFontsSubDir
git clean -f -d
rm -r ofl/$gFontsSubDir

# -------------------------------------------------------------------
# copy fonts

mkdir -p ofl/$gFontsSubDir

cp $libreCaslonRomanVF    ofl/$gFontsSubDir/$(basename $libreCaslonRomanVF)
cp $libreCaslonItalicVF    ofl/$gFontsSubDir/$(basename $libreCaslonItalicVF)

# -------------------------------------------------------------------
# make or move basic metadata 

gftools add-font ofl/$gFontsSubDir # do this the first time, then edit as needed 

category="SERIF"
designer="Pablo Impallari"

# update these to be accurate if needed
sed -i "" "s/SANS_SERIF/$category/g" ofl/$gFontsSubDir/METADATA.pb
sed -i "" "s/UNKNOWN/$designer/g" ofl/$gFontsSubDir/METADATA.pb

cp $libreCaslonDir/OFL.txt ofl/$gFontsSubDir/OFL.txt

cp $libreCaslonDir/gfonts-description.html ofl/$gFontsSubDir/DESCRIPTION.en_us.html

# -------------------------------------------------------------------
# copy static fonts

cp -r $libreCaslonDir/fonts/static ofl/$gFontsSubDir/static

# -------------------------------------------------------------------
# adds and commits new changes, then force pushes

if [[ $pushToGitHub = "push" ]] ; then
    git add .
    git commit -m "$gFontsSubDir: $fontVersion added."

    # push to upstream branch (you must manually go to GitHub to make PR from there)
    # this is set to push to my upstream (google/fonts) rather than origin so that TravisCI can run
    git push --force upstream $gFontsSubDir
fi
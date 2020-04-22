#!/bin/sh
set -e

# ------------------------------------------------------
# static fonts

# echo "Generating Static fonts"
# mkdir -p ../fonts
# fontmake -g sources/LibreCaslonText.glyphs -i -o ttf --output-dir fonts/static
# fontmake -g sources/LibreCaslonText-Italic.glyphs -i -o ttf --output-dir fonts/static

# echo "Post processing statics"
# ttfs=$(ls fonts/**/*.ttf)
# for ttf in $ttfs
# do
# 	gftools fix-dsig -f $ttf
# 	gftools fix-gasp --autofix $ttf
# 	mv ${ttf/".ttf"/".ttf.fix"} $ttf
# 	gftools fix-nonhinting $ttf $ttf
# 	rm ${ttf/".ttf"/"-backup-fonttools-prep-gasp.ttf"}
# done


# ------------------------------------------------------
# variable fonts

echo "Generating VFs"
fontmake -g sources/LibreCaslonText.glyphs -o variable --output-path fonts/LibreCaslonText-Roman-VF.ttf
fontmake -g sources/LibreCaslonText-Italic.glyphs -o variable --output-path fonts/LibreCaslonText-Italic-VF.ttf

rm -rf master_ufo/ instance_ufo/


echo "Fixing VF Meta"
vfs=$(ls fonts/*-VF.ttf)
gftools fix-vf-meta $vfs;

for vf in $vfs
do
	mv ${vf/".ttf"/".ttf.fix"} $vf

	ttx -x MVAR $vf                 # drop mvar table using fonttools/ttx
	ttx ${vf/'.ttf'/'.ttx'}         # convert back to TTF
	rm ${vf/'.ttf'/'.ttx'}          # erase temp TTX 
	mv ${vf/'.ttf'/'#1.ttf'} $vf    # overwrite original TTF with edited copy
done

# update names
mv "fonts/LibreCaslonText-Roman-VF.ttf" "fonts/LibreCaslonText[wght].ttf"
mv "fonts/LibreCaslonText-Italic-VF.ttf" "fonts/LibreCaslonText-Italic[wght].ttf"
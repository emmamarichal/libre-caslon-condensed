#!/bin/sh
set -e
source venv/bin/activate

# ------------------------------------------------------
# static fonts

echo "Generating Static fonts"
mkdir -p ../fonts
fontmake -g sources/LibreCaslonText.glyphs -i -o ttf --output-dir fonts/static
fontmake -g sources/LibreCaslonText-Italic.glyphs -i -o ttf --output-dir fonts/static

echo "Post processing statics"
ttfs=$(ls fonts/**/*.ttf)
for ttf in $ttfs
do
	gftools fix-dsig -f $ttf
	gftools fix-gasp --autofix $ttf
	mv ${ttf/".ttf"/".ttf.fix"} $ttf
	gftools fix-nonhinting $ttf $ttf.fix
	mv  $ttf.fix $ttf
	rm ${ttf/".ttf"/"-backup-fonttools-prep-gasp.ttf"}
done


# ------------------------------------------------------
# variable fonts

echo "Generating VFs"
fontmake -g sources/LibreCaslonText.glyphs -o variable --output-path fonts/LibreCaslonText-Roman-VF.ttf
fontmake -g sources/LibreCaslonText-Italic.glyphs -o variable --output-path fonts/LibreCaslonText-Italic-VF.ttf

rm -rf master_ufo/ instance_ufo/


echo "Fixing VF Metadata"
vfs=$(ls fonts/*-VF.ttf)
for vf in $vfs; do
	# use statmake to set STAT table
	python sources/scripts/set-stat-table.py $vf

	# other table fixes
	gftools fix-dsig -f $vf
	gftools fix-gasp --autofix $vf
	mv ${vf/".ttf"/".ttf.fix"} $vf
	gftools fix-nonhinting $vf $vf.fix
	mv $vf.fix $vf
	rm ${vf/".ttf"/"-backup-fonttools-prep-gasp.ttf"}

	ttx -x MVAR $vf                 # drop mvar table using fonttools/ttx
	ttx ${vf/'.ttf'/'.ttx'}         # convert back to TTF
	rm ${vf/'.ttf'/'.ttx'}          # erase temp TTX 
	mv ${vf/'.ttf'/'#1.ttf'} $vf    # overwrite original TTF with edited copy
done

# update names
mv "fonts/LibreCaslonText-Roman-VF.ttf" "fonts/LibreCaslonText[wght].ttf"
mv "fonts/LibreCaslonText-Italic-VF.ttf" "fonts/LibreCaslonText-Italic[wght].ttf"
set -x

mkdir -p font_checks

ttfs=$(ls fonts/*.ttf)
for ttf in $ttfs
do
	fontCheck=${ttf/".ttf"/"-fontbakery-report.md"}
    fontbakery check-googlefonts $ttf --ghmarkdown $fontCheck
    mv $fontCheck ${fontCheck/"fonts"/"font_checks"}
done

"""
	Set metrics in all masters of a Glyphs source to easily adjust metrics with 
	a minimum of clicking and typing. Update values, then run once.

	USAGE:

	You must have glyphsLib installed, for instance via `pip install glyphsLib`.

	Then, run this via the terminal, adding the path to a Glyphs source:

	python3 sources/scripts/set-metrics.py sources/LibreCaslonText.glyphs
"""

from glyphsLib import GSFont
import sys

filepath = sys.argv[1]

font = GSFont(filepath)

for master in font.masters:
	master.customParameters["hheaAscender"] = 1940
	master.customParameters["hheaDescender"] = -520
	master.customParameters["hheaLineGap"] = 0
	master.customParameters["typoAscender"] = 1940
	master.customParameters["typoDescender"] = -520
	master.customParameters["typoLineGap"] = 0
	master.customParameters["winAscent"] = 1696
	master.customParameters["winDescent"] = 531

font.save(filepath)
"""
	Script to check combined width of ASCII uppercase + lowercase.
"""

import string

alphabet = " ".join(string.ascii_letters).split()

font = Glyphs.font

totalWidth = 0

for name in alphabet:
	for layer in font.glyphs[name]:
		totalWidth += layer.width

print(totalWidth)
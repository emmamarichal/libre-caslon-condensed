"""
    Script to use statmake to add STAT table to Libre Caslon
"""

import sys
import statmake.classes
import statmake.lib
from fontTools.ttLib import TTFont

font_path = sys.argv[1]

STAT = {
    "axes": [
        {
            "name": "Weight",
            "tag": "wght",
            "locations": [
                {
                    "name": "Regular",
                    "value": 400,
                    "linked_value": 700,
                    "flags": ["ElidableAxisValueName"]
                },
                {
                    "name": "Medium",
                    "value": 500
                },
                {
                    "name": "SemiBold",
                    "value": 600
                },
                {
                    "name": "Bold",
                    "value": 700
                }
            ]
        },
        {
            "name": "Italic",
            "tag": "ital",
            "locations": [
                {
                    "name": "Roman",
                    "value": 0,
                    "linked_value": 1,
                    "flags": ["ElidableAxisValueName"]
                },
                {
                    "name": "Italic",
                    "value": 1
                }
            ]
        }
    ]
}


def makeStylespace(font_path):

    stylespace = statmake.classes.Stylespace.from_dict(STAT)

    font = TTFont(font_path)

    if "Italic" in font_path:
        addedLocs = {"Italic": 1}
    else:
        addedLocs = {"Italic": 0}

    statmake.lib.apply_stylespace_to_variable_font(
        stylespace=stylespace,
        varfont=font,
        additional_locations=addedLocs
    )
    font.save(font_path)


makeStylespace(font_path)

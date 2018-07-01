M98 Phomeu.g                  ; get the U carriage out of the way
G1 X150 Y100 F6000 S2  ; center the X axis with the Z probe
G91                ; relative mode
G1 Z4 F200         ; lower bed 4mm to ensure it is below the Z probe trigger height
G90                ; back to absolute mode
G30
M98 Phomex.g                  ; get the X carriage out of the way
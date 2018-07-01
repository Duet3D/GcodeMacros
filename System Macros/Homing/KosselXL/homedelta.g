; homedelta.g

; Use relative positioning
G91

; Move all towers to the high end stopping at the endstops (first pass)
G1 X650 Y650 Z650 F12000 S1

; Go down a few mm
G1 X-5 Y-5 Z-5 F6000 S2

; Move all towers up once more (second pass)
G1 X10 Y10 Z10 F360 S1

; Move down a few mm so that the nozzle can be moved without crashing
G1 Z-50 F9000

; Switch back to absolute positioning and go to the centre
G90
G1 X0 Y0 F9000

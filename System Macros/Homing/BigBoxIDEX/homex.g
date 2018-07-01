G91                ; relative mode
G1 X-400 F6000 S1  ; move up to 400mm in the -X direction, stopping if the homing switch is triggered
G1 X4 F600 S2         ; move slowly 4mm in the +X direction
G1 X-10 F300  S1         ; move slowly 10mm in the -X direction, stopping at the homing switch
G90                ; back to absolute mode


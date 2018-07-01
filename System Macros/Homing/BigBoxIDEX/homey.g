G91                ; relative mode
G1 Y-400 F6000 S1  ; move up to 400mm in the -Y direction, stopping if the homing switch is triggered
G1 Y4 F600 S2        ; move slowly 4mm in the +Y direction
G1 Y-10 F300 S1         ; move slowly 10mm in the -Y direction, stopping at the homing switch
G90                ; back to absolute mode



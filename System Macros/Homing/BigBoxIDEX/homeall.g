G91
G1 Z4 F200                    ; raise head 4mm to keep it clear of the bed
G1 X-400 Y-400 U400 F6000 S1  ; course home X, Y and U
G1 X4 Y4 U-4 F600 S2          ; move 2mm away from the homing switches
G1 X-10 Y-10 U10 F300 S1	      ; fine home X, Y and U
G90
; Now home Z using the Z probe
G1 X150 Y100 F6000 S2  ; center the X axis with the Z probe
G30               
M98 Phomex.g  ; get the X carriage out of the way
  
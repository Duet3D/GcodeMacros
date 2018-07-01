;M83               ; relative extruder movement
;G1 E-4 F3600      ; retract 2mm
;M82               ; absolute extruder positioning (Cura)
;G91               ; relative axis movement
;G1 Z0.5 F500      ; up 0.5mm
;G90               ; absolute axis movement
G28 X U           ; home the X and U carriages
;G91               ; relative axis movement
;G1 Z-0.5 F500      ; down 0.5mm
;G90               ; absolute axis movement


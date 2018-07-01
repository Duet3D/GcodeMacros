M116 P2           ; wait for tool 2 heaters to reach operating temperature
M83               ; relative extruder movement
M567 P2 E1:1      ; set tool mix ratio
;G1 E4 F3600       ; extrude 2mm from both extruders
M82               ; absolute extruder positioning (Cura)
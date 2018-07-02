;Cold pull filament unload - change Tn and Pn to use with other tools
; change the temperatures to suite the filament type.
M302 P1; Allow cold extrude 
T0; select tool 0
G10 P0 S180; heat tool 0 to 180 and wait
M116 P0
G10 P0 S120; cool tool 0 to 120 and wait
M116 P0
G1 E-20 F300; retract 20mm at 5mm/sec
; change the following E values to suit your Bowden Tube length 
G1 E-50 F600; retract another 50mm at 10mm/sec
G1 E-200 F3000; retract another 150mm at 50mm/sec
G10 P0 S0; turn heater off 
M302 P0 ; Dis-allow cold extrude 

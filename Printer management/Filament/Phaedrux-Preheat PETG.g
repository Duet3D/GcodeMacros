; Raise temp of heated bed to 80 and nozzle to 240
;

M291 P"Setting PID and retraction values for PETG" R"Proceed?" S3 

; New values
M307 H1 A439.9 C168.0 D2.8 S1.00 V23.9 B0 ; Hotend PID tune for 250c
M307 H0 A156.8 C387.7 D2.8 S1.00 V24.0 B0 ; Bed PID tune for 90c
M572 D0 S0.07   ; Pressure advance for Edge PETG
M207 S0.8 R-0.000 F8000 T1500   ; retraction settings for Edge PETG

T0

M140 S80			; Set bed temp to 80
M116				; Wait for temps to be reached...
G10 P0 S240			; Set extruder temp (tool 0) to 200
M116
M117 PETG Preheat complete	; and send a notice to the screen that temps have been reached
;Play a tone
M300 S1250 P200
G4 P201
M300 S1500 P200
G4 P201
M300 S1100 P200
G4 P201
M300 S950 P300
G4 P400
M300 S1175 P300
G4 S1

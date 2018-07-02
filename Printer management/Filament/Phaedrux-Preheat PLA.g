; Raise temp of heated bed to 60 and nozzle to 210
;

M291 P"Setting PID and retraction values for PLA" R"Proceed?" S3 

; New values
M307 H0 A82.6 C112.0 D2.7 S1.00 V24.0 B0 ; PID tune for bed at 60c
M307 H1 A460.6 C173.6 D3.1 S1.00 V23.9 B0 ; Pid tune for hotend at 210c
M572 D0 S0.05   ; Pressure advance for PLA
M207 S0.7 R-0.000 F8000 T1500   ; retraction settings for PLA

T0

M140 S60			; Set bed temp to 80
M116				; Wait for temps to be reached...
G10 P0 S180			; Set extruder temp (tool 0) to 200
M116
M117 PLA Preheat complete	; and send a notice to the screen that temps have been reached
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

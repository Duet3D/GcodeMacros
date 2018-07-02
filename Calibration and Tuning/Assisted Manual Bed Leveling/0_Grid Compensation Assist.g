; Macro to run a mesh bed compensation routine (G29)
;

M291 P"Grid bed compensation map will be cleared and re-calculated. Ok or Cancel?" R"WARNING. This will take about 30 minutes." S3 ; User must click OK or cancel.

; Preheat to probing temps
;
M291 P"Preheating to bed to 60 and nozzle to 210 for accurate probing" R"Proceed?" S3
T0			; Activate first tool
M190 S60		; Set bed to 60 and wait
M109 S210		; Set nozzle to 210 and wait

; Clear current mesh compensation map and disable compensation.
;
M561			; Disable any current bed compensation
G29 S2			; Clear mesh bed compensation parameters
G28			; Home all
G29 S2			; Clear mesh bed compensation parameters

; Set lower speeds for Z homing and lower Z motor current
;
;M566 Z10			; Set maximum instantaneous speed changes (mm/min) (Jerk)
;M203 Z400			; Set maximum speeds (mm/min)
;M201 Z100	 		; Set maximum accelerations (mm/s^2)
;M906 Z900			; Drop motor current to prevent damage in case of head crash

M291 P"Running mesh grid compensation probing cycle. Do not disturb the printer." T0 S0

G29			; Run mesh compensation

; Turn off heaters
; 
M140 S0		; Set bed to 0 and release
M104 S0		; turn off hot end heater
;M906 Z1500	; Return Z motor current to normal
G28		; Home all

; Tone to get user attention
;
M400			; Clear movement buffer so tones play reliably
M300 S666 P500
G4 P501
M300 S1111 P300
G4 P301

M291 P"Check heightmap for results." R"Probing complete!" S3




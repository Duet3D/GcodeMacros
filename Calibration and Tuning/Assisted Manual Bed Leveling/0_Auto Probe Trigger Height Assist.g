; Clear compensation map and Zprobe trigger height
;
M291 P"Grid bed compensation map and ZProbe trigger height will be cleared. Ok or Cancel?" R"WARNING" S3 ; User must click OK or cancel.
M561			; Disable any current bed compensation
G29 S2			; Clear mesh bed compensation perameters

; Preheat to probing temps
;
M291 P"Preheating to bed to 60 and nozzle to 210 for accurate probing" R"Proceed?" S3
T0			; Activate first tool
M104 S210		; Set nozzle to 210 and release
M140 S60		; Set bed temp to 60 and release

; home all axis
;
G28			; Home all axis
M190 S60		; Set bed to 60 and wait
M109 S210		; Set nozzle to 210 and wait

; Move nozzle to center of bed at z10
;
M291 P"Nozzle will now move to center of bed to reset Z0 and calibrate probe" S3
G90			; Absolute positioning
G1 X150 Y150 F6000	; Move to bed center
G31 Z0				; Reset zprobe trigger height
G92 Z5				; Reset z to 5 to allow jogging up to touch bed to nozzle

; configure settings for setting Z=0 to limit ability to damage bed
;
M203 Z400			; Set maximum speeds (mm/min)
M913 Z60 			; set Z motors to 40% of their normal current for homing
M566 Z5				; Set maximum instantaneous speed changes (mm/min) (Jerk)
M201 Z20	 		; Set maximum accelerations (mm/s^2)

; Dialog to allow user to jog z to touch nozzle to bed gently and then move Z down 10
;
M291 P"Jog the Z Axis until the bed and nozzle are touching and click OK" R"Setting Z=0" Z1 S3
G92 Z0			; Set z = 0

; Move probe to center of bed and get probe trigger heights
;
M291 P"Probe will now measure trigger height 10 times" R"ZProbe Trigger Height Calibration" S3
;G1 Z1			; Drop bed for nozzle clearance
;G1 X190 Y90 F4000 	; Move to bed center

M291 P"Heights will be found in gcode console if logging is enabled" R"Did you remember to enabled gcode logging?" S3

; G30 S-1 10 times
;

; 1
G1 Z3
G30 S-1

; 2
G1 Z3
G30 S-1

; 3
G1 Z3
G30 S-1

; 4
G1 Z3
G30 S-1

; 5
G1 Z3
G30 S-1

; 6
G1 Z3
G30 S-1

; 7
G1 Z3
G30 S-1

; 8
G1 Z3
G30 S-1

; 9
G1 Z3
G30 S-1

; 10
G1 Z3
G30 S-1

G1 Z3

; Turn off heaters
; 
M104 S0		; Set nozzle to 0 and release
M140 S0		; Set bed to 0 and release

; Set normal settings after stall detection probing
;
M203 Z600			; Set maximum speeds (mm/min)
M566 Z100			; Set maximum instantaneous speed changes (mm/min) (Jerk)
M201 Z300			; Set maximum accelerations (mm/s^2)
M913 Z100   		      	; restore current to 100%
M915 Z S63 F1 R0		; Set StallGuard sensitivity for normal movement

M291 P"Probing complete. Turning off heaters and homing axis."
M291 P"Check log for trigger heights and enter average into config.g"

G28 XY		; Home XY

; Tone to get user attention
;
M400			; Clear movement buffer so tones play reliably
M300 S666 P600
G4 P601
M300 S1511 P300
G4 P301
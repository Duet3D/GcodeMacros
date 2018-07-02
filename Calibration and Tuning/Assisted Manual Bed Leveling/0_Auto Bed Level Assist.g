; Helps guide leveling the bed mechanically, and calibrate the ZProbe trigger height before running a grid bed compensation routine..
;

; Preamble to tell the user to prepare the printer before continuing
;
;M291 P"Before proceeding make sure the printer is mechanically sound and properly functioning." R"Prepare printer for leveling routine" S3 ; User must click OK
;M291 P"ZProbe should be configured and working. Clear the print bed of any obstacles or debris." R"Prepare printer for leveling routine" S3 ; User must click OK
;M291 P"This routine will take about 10-20 minutes and heat both the bed and nozzle." R"Prepare printer for leveling routine" S3 ; User must click OK
;M291 P"You will need a screwdriver and piece of paper. Filament will be unloaded." R"Prepare printer for leveling routine" S3 ; User must click OK
;M291 P"Make sure you have successful Gcodes logged to the console before proceeding." R"WARNING" S3 ; User must click OK or cancel
;M291 P"Make a note of your M558 Z value and backup current heightmap before proceeding." R"WARNING" S3 ; User must click OK or cancel

; Clear compensation map and Zprobe trigger height
;
M291 P"Grid bed compensation map will be disabled. Ok or Cancel?" R"WARNING" S3 ; User must click OK or cancel.
M561			; Disable any current bed compensation
;G29 S2			; Clear mesh bed compensation perameters
;G31 Z0			; Reset zprobe trigger height

; Heat up bed and nozzle to PLA temps in prep for filament removal and probing
;
M291 P"Bed and nozzle will preheat and home all axis." R"Preheat and Home" S3 T0 ; User must click OK or cancel
M104 S130		; Set nozzle to 130 and release
M140 S55		; Set bed to 55 and release

; home all axis
;
G28 XY
G28 Z			; Home all axis
G90			; Absolute positioning
T0			; Activate first tool

; Set lower speeds for Z homing and lower Z motor current
;
M566 Z10			; Set maximum instantaneous speed changes (mm/min) (Jerk)
M203 Z400			; Set maximum speeds (mm/min)
M201 Z100	 		; Set maximum accelerations (mm/s^2)
M913 Z40			; Drop motor current to prevent damage in case of head crash

; Move nozzle forward for filament removal
;
M291 P"Moving nozzle to the front for filament removal and cleaning." T0
G1 X50 Y5 Z100		; Moves print head to front left and drops the bed down for easy access
M109 S130		; Set nozzle to 130 and wait

; Tone to get user attention
;
M400			; Clear movement buffer so tones play reliably
M300 S666 P500
G4 P501
M300 S1111 P300
G4 P301

; Unload filament and clean nozzle
;
M291 P"Unload filament if loaded and clean nozzle, then press OK to continue" R"Unload Filament" S3 T0 ; User must click OK or cancel

; Preheat to probing temps
;
M291 P"Preheating the bed to 60 and nozzle to 210 for accurate probing" T0
M104 S210		; Set nozzle to 210 and release
M190 S60		; Set bed to 60 and wait
M109 S210		; Set nozzle to 210 and wait

; Tone to get user attention
;
M400			; Clear movement buffer so tones play reliably
M300 S666 P500
G4 P501
M300 S1111 P300
G4 P301

; Move nozzle to center of bed at Z10 and drop to Z1
;
M291 P"Nozzle will now move to center of bed and move close to the bed" T0
G1 X150 Y110 Z3 F4000	; move to bed center

; Reset z to 8 to allow jogging up to touch bed to nozzle
;
G92 Z8

; Dialog to allow user to job z to touch nozzle to bed gently and then move Z down 10
;
M291 P"Carefully Jog the Z Axis until the bed and nozzle are touching and click OK" R"Setting Z=0" Z1 S3
G92 Z0      		; set z = 0

; Move nozzle to leveling points and prompt user to level bed at each
;
M291 P"Nozzle will now move to the 3 leveling points twice." S1 T2

; Move to leveling point 1
G1 Z2      		; move to z2 for travel
G1 X40 Y270 F6000	; Move to rear left corner

M400
M291 P"Adjust point 1 using a piece of paper and screw driver. Use the jog buttons if needed." R"Adjustment Point 1" S2 Z1

; Move to leveling point 2
G1 Z2			; Move to Z2 for clearance
G1 X265 Y270 F6000	; Move to rear right corner

M400
M291 P"Adjust point 2 using a piece of paper and screw driver. Use the jog buttons if needed." R"Adjustment Point 2" S2 Z1

; Move to leveling point 3
G1 Z2			; Move to Z2 for clearance
G1 X158 Y15 F6000	; Move to front middle

M400
M291 P"Adjust point 3 using a piece of paper and screw driver. Use the jog buttons if needed." R"Adjustment Point 3" S2 Z1

; Repeat to verify
;
M291 P"The adjustment sequence will now repeat for fine adjustment." S1 T2

; Move to leveling point 1
G1 Z2      		; move to z2 for travel
G1 X40 Y270 F6000	; Move to rear left corner

M400
M291 P"Adjust point 1 using a piece of paper and screw driver. Use the jog buttons if needed." R"Adjustment Point 1" S2 Z1

; Move to leveling point 2
G1 Z2			; Move to Z2 for clearance
G1 X265 Y270 F6000	; Move to rear right corner

M400
M291 P"Adjust point 2 using a piece of paper and screw driver. Use the jog buttons if needed." R"Adjustment Point 2" S2 Z1

; Move to leveling point 3
G1 Z2			; Move to Z2 for clearance
G1 X158 Y15 F6000	; Move to front middle

M400
M291 P"Adjust point 3 using a piece of paper and screw driver. Use the jog buttons if needed." R"Adjustment Point 3" S2 Z1

; Move nozzle to center of bed at z10
;
M291 P"Nozzle will now move to center of bed to reset Z0" S3
G1 Z1			; Drop bed for nozzle clearance
G1 X150 Y110 Z2 F4000	; Move to bed center

; Reset z to 5 to allow jogging up to touch bed to nozzle
;
G92 Z5

; Dialog to allow user to jog z to touch nozzle to bed gently and then move Z down 10
;
M291 P"Jog the Z Axis until the bed and nozzle are touching and click OK" R"Setting Z=0" Z1 S3
G92 Z0			; Set z = 0
G1 Z1			; Drop bed for nozzle clearance

M291 P"The bed has been mechanically leveled and Z0 set." S2

; Turn off heaters
; 
M104 S0		; Set nozzle to 0 and release
M140 S0		; Set bed to 0 and release
M913 Z85	; Return Z motor current to normal
G28 XY		; Home XY

; Tone to get user attention
;
M400			; Clear movement buffer so tones play reliably
M300 S666 P500
G4 P501
M300 S1111 P300
G4 P301

; Tell user to take values from gcode console log and average the Z height and use that as the new Z probe trigger height
;
;M291 P"Average the 10 Z height values in the console and round to 2 decimal places" S2
;M291 P"The resulting value is the ZProbe trigger height value (M558 Zn)" S2
;M291 P"Either set the value in config.g and reboot, or send M558 Zn in the console before running G29." S2
;M291 P"The bed is now mechanically leveled and probe height calibrated." R"Congratulations!" S2
;M291 P"You may now run a Grid Bed Compensation Detailed Probe. (G92)." S2
;
; Run bed grid compensation routine

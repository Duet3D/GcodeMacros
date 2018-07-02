; Commissioning
; During commissioning, you can test the X and Y motors independently by using the S2 modifier on the G1 command, like this:
;
M291 P"Motors should move 10mm back and forth." R"Commissioning: Testing X and Y motors." S1 T10
;
G91 		; relative mode
G1 S2 X10 	; move the X motor forward 10mm
G1 S2 X-10 	; move the X motor back 10mm
G1 S2 Y10 	; move the Y motor forward 10mm
G1 S2 Y-10 	; move the Y motor back 10mm
G90 		; back to absolute mode
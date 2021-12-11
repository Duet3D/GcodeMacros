;Calibrate BL Touch
; Reprap firmware version 3.3b2 or later required!
; If macro is called using parameters these will be used in testing
; if no paramters are passed,the "default values" will be used.  Adjust these to suit your requirements
; parameters which can be passed are
; T - Tool to use
; B - bed temperature to use
; R - Nozzle temperature to use (may be turned off before probing commences if configuerd to do so in config.g by M558 B1)
; P - probe number to use
; F -  X/Y travel speed to use (in mm/sec)
; Z - Z travel speed to use
; S - Probe speed to use (in mm/sec)
; I - Number of times to probe (high and low value will be discarded)

if !exists(global.bedTemp)
	global bedTemp = 0

if exists(param.B)
	set global.bedTemp = param.B
else 
	set global.bedTemp = 0

if !(global.bedTemp >=0)
	abort "invalid bed temp - test aborted"

if !exists(global.nozzleTemp)
	global nozzleTemp = 0
if exists(param.R)
	set global.nozzleTemp = param.R
else 
	set global.nozzleTemp = 0

if !(global.nozzleTemp >= 0) ; validate temp
	abort "Invalid nozzle temp - test aborted"

if !exists(global.probeNumber)
	global probeNumber = 0
if exists(param.P)
	set global.probeNumber = param.P
else
	set global.probeNumber = 0

if (global.probeNumber > #sensors.probes - 1) || (global.probeNumber < 0) ; validate probe number
	echo "Invalid probe number (" ^ global.probeNumber ^ ") , test will be carried out using probe 0"
	set global.probeNumber = 0

if !exists(global.NumTests)
	global NumTests = 10
if exists(param.I)
	if param.I<=2
		abort "I parameter must be > 2 - Test aborted"
	else
		set global.NumTests = param.I
else 
	set global.NumTests=10 ; modify this value to define default number of tests

if !exists(global.travelSpeed)
	global travelSpeed = 3600
if exists(param.F)
	set global.travelSpeed = param.F * 60
else
	set global.travelSpeed = 3600 ; default travel speed (60mm/sec)

if !exists(global.ZtravelSpeed)
	global ZtravelSpeed = 360
if exists(param.Z)
	set global.ZtravelSpeed = param.Z * 60
else
	set global.ZtravelSpeed = 360 ; default travel speed (6mm/sec)

if !exists(global.probeSpeed)
	global probeSpeed = 60
if exists(param.S)
	set global.probeSpeed = param.S * 60
	if global.probeSpeed <=0 ; validate
		set global.probeSpeed = 60 ; set to 1mm/sec if invalid parameter passed
else
	set global.probeSpeed = 60 ; default probe speed (1mm/sec)

; if two speed probing is configured in M558,we probably want to reduce the speed for this test
var ProbeSpeedHigh = sensors.probes[0].speeds[0] ; save currently configured speed for fast probe
var ProbeSpeedLow = sensors.probes[0].speeds[1] ; save currently configured speed for slow probe

; validate probe speed
if global.probeSpeed > var.ProbeSpeedLow 
	M291 S3 R"Warning" P"Probe speed (" ^ var.probeSpeed ^ ") is set higher than defined in config.g (" ^ var.ProbeSpeedLow ^ ") Continue?" 


M558 F{global.probeSpeed} ; reduce probe speed for accuracy 

; Do not change below this line
var RunningTotal=0
var Average=0
var Lowest=0
var Highest=0

if (global.nozzleTemp > 0) || (global.bedTemp > 0)
	if exists(param.T)
		if param.T > {#tools - 1}
			abort "Invalid T parameter - cannot be higher than " ^ {#tools - 1}
		T{param.T} ; select the tool passed
	else 
		T0 ; default to T0
	if (global.nozzleTemp > 0)
		M568 P{param.T} S{global.nozzleTemp} S{global.nozzleTemp} A2 ; set active temperatures for tool 
	if (global.bedTemp > 0)
		M140 H0 S{global.bedTemp}



; If the printer hasn't been homed, home it
if !move.axes[0].homed || !move.axes[1].homed || !move.axes[2].homed
  G28
else
	G1 Z{sensors.probes[0].diveHeight} F{global.ZtravelSpeed} ; if axes homed move to dive height

M561 ; clear any bed transform

M290 R0 S0 ; clear babystepping

; move nozzle to centre of bed
G1 X{(move.axes[0].min + move.axes[0].max)/2} Y{(move.axes[1].min + move.axes[1].max)/2} F{global.travelSpeed}

if (global.nozzleTemp > 0) || (global.bedTemp > 0)
	echo "Waiting for temps to stabilise"
	M116 ; wait for temps

M564 S0 H0 ; Allow movement beyond limits

;ensure you have room for the probe
if move.axes[2].machinePosition < sensors.probes[0].diveHeight
	G1 Z{sensors.probes[0].diveHeight} F{global.ZtravelSpeed}
M280 P0 S160 I1 ; reset BL Touch
G4 S0.5
M98 P"0:/sys/retractprobe.g" ; Ensure probe is retracted & reset
G4 S0.5
M561 ; clear any bed transform
; Jog head to position
M291 P"Jog nozzle to touch bed" R"Set nozzle to zero" S3 Z1

G92 Z0 ; set Z position to zero
M291 P"Press OK to begin" R"Ready?" S3;

; Move probe over top of same point that nozzle was when zero was set
G1 Z{sensors.probes[0].diveHeight} F{global.ZtravelSpeed}; lift head
G1 X{move.axes[0].machinePosition - sensors.probes[0].offsets[0]} Y{move.axes[1].machinePosition - sensors.probes[0].offsets[1]} F{global.travelSpeed}

echo "Current probe offset = " ^ sensors.probes[0].triggerHeight ^ "mm"

; carry out 10 probes (or what is set in NumTests variable)

while iterations < global.NumTests
	G1 Z{sensors.probes[0].diveHeight} F{global.ZtravelSpeed}; move to dive height
	if sensors.probes[0].value[0]=1000 ; if probe is in error state
		echo "Probe in error state - resetting"
		M280 P0 S160 I1 ; reset BL Touch
		G4 S0.5
		M98 P"0:/sys/retractprobe.g" ; Ensure probe is retracted & reset
		G4 S0.5
	G30 S-1
	M118 P2 S{"Test # " ^ (iterations+1) ^ " Triggered @ " ^ move.axes[2].machinePosition ^ "mm"} ; send trigger height to Paneldue console
	M118 P3 S{"Test # " ^ (iterations+1) ^ " Triggered @ " ^ move.axes[2].machinePosition ^ "mm"} ; send trigger height to DWC console

	if iterations == 0
		set var.Lowest={move.axes[2].machinePosition} ; set the new lowest reading to first probe height
		set var.Highest={move.axes[2].machinePosition} ; set the new highest reading to first probe height

	if move.axes[2].machinePosition < var.Lowest
		set var.Lowest={move.axes[2].machinePosition} ; set the new lowest reading
		;M118 P3 S{"new low reading = " ^ move.axes[2].machinePosition} ; send trigger height to DWC console
		G4 S0.3
	if move.axes[2].machinePosition > var.Highest
		set var.Highest={move.axes[2].machinePosition} ; set the new highest reading

		;M118 P3 S{"new high reading = " ^ move.axes[2].machinePosition} ; send trigger height to DWC console
		G4 S0.3
	set var.RunningTotal={var.RunningTotal + move.axes[2].machinePosition} ; set new running total
	;M118 P3 S{"running total = " ^ var.RunningTotal} ; send running total to DWC console
	G4 S0.5
set var.Average = {(var.RunningTotal - var.Highest - var.Lowest) / (global.NumTests - 2)} 	; calculate the average after discarding the high & low reading

;M118 P3 S{"running total = " ^ var.RunningTotal} ; send running total to DWC console
;M118 P3 S{"low reading = " ^ var.Lowest} ; send low reading to DWC console
;M118 P3 S{"high reading = " ^ var.Highest} ; send high reading to DWC console
M118 P2 S{"Average excluding high and low reading = " ^ var.Average} ; send average to PanelDue console
M118 P3 S{"Average excluding high and low reading = " ^ var.Average} ; send average to DWC console

;suggest new G31 values
echo "suggested edit for G31 in config.g if not saved to config-overide.g"
echo "change G31 Z parameter from Z" ^ sensors.probes[0].triggerHeight ^ " to Z" ^ var.Average

G31 P500 Z{var.Average} ; set Z probe offset to the average reading
M564 S1 H1 ; Reset limits
M558 F{var.ProbeSpeedHigh}:{var.ProbeSpeedLow} ; reset probe speed to original
G1 Z{sensors.probes[0].diveHeight} F{global.ZtravelSpeed} ; move head back to dive height

M140 R0 S0 ; set bed to zero
M140 S-276 ; turn off bed
M568 R0 S0 ; set heater to zero
M568 A0 ; turn off heater on current tool

M291 P{"Trigger height set to : " ^ sensors.probes[0].triggerHeight  ^ " OK to save to config-overide.g, cancel to use until next restart"} R"Finished" S3
M500 P31 ; optionally save result to config-overide.g
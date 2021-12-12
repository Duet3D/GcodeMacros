;Calibrate BL Touch
; Reprap firmware version 3.3b2 or later required!
; If macro is called using parameters these will be used in testing
; parameters which can be passed are
; T - Tool to use
; B - bed temperature to use
; R - Nozzle temperature to use (may be turned off before probing commences if configuerd to do so in config.g by M558 B1)
; P - probe number to use
; F -  X/Y travel speed to use (in mm/sec)
; Z - Z travel speed to use
; S - Probe speed to use (in mm/sec)
; I - Number of times to probe (high and low value will be discarded)

var NumTests = 10 ; modify this value to define default number of tests
var travelSpeed = 3600 ; modify this value to define the default travel speed in mm/min
var ZtravelSpeed = 360 ; modify this value to define default Z travel speed in mm/min (not probe speed)
var probeSpeed = 60 ; modify this value to define default Z travel speed during probing in m/min
var ProbePointX = (move.axes[0].min + move.axes[0].max)/2 ; modify to specify the X probe point.
var ProbePointY = (move.axes[1].min + move.axes[1].max)/2 ; modify to specify the Y probe point.

; Do not change below this line
var bedTemp = 0 ; default to not heating bed
if exists(param.B)
	set var.bedTemp = param.B

if !(var.bedTemp >=0) || (var.bedTemp > heat.heaters[heat.bedHeaters[0]].max)
	abort "invalid bed temp - test aborted"

var nozzleTemp = 0 ; default to not heating nozzle
if exists(param.R)
	if !exists(param.T)
		abort "Nozzle temp set, but no tool specified"
	set var.nozzleTemp = param.R

if !(var.nozzleTemp >= 0) || (var.nozzleTemp > heat.heaters[tools[param.T].heaters[0]].max); validate temp
	abort "Invalid nozzle temp - test aborted"

var probeNumber = 0
if exists(param.P)
	set var.probeNumber = param.P

if (var.probeNumber > #sensors.probes - 1) || (var.probeNumber < 0) ; validate probe number
	echo "Invalid probe number (" ^ var.probeNumber ^ ") , test will be carried out using probe 0"
	set var.probeNumber = 0

if exists(param.I)
	if param.I<=2
		abort "I parameter must be > 2 - Test aborted"
	else
		set var.NumTests = param.I

if exists(param.F)
	set var.travelSpeed = param.F * 60

if exists(param.Z)
	set var.ZtravelSpeed = param.Z * 60

if exists(param.S)
	set var.probeSpeed = param.S * 60
	if var.probeSpeed <=0 ; validate
		set var.probeSpeed = 60 ; set to 1mm/sec if invalid parameter passed

; if two speed probing is configured in M558,we probably want to reduce the speed for this test
var ProbeSpeedHigh = sensors.probes[0].speeds[0] ; save currently configured speed for fast probe
var ProbeSpeedLow = sensors.probes[0].speeds[1] ; save currently configured speed for slow probe

; validate probe speed
if var.probeSpeed > var.ProbeSpeedLow
	var ErrorMsg = "Probe speed (" ^ var.probeSpeed ^ "mm/min) is set higher than defined in config.g (" ^ var.ProbeSpeedLow ^ "mm/min) Continue?"
	M291 S3 R"Warning" P{var.ErrorMsg} 


M558 F{var.probeSpeed} ; reduce probe speed for accuracy 


var RunningTotal=0
var Average=0
var Lowest=0
var Highest=0

if (var.nozzleTemp > 0) || (var.bedTemp > 0)
	if exists(param.T)
		if param.T > {#tools - 1}
			abort "Invalid T parameter - cannot be higher than " ^ {#tools - 1}
		T{param.T} ; select the tool passed
	else 
		T0 ; default to T0
	if (var.nozzleTemp > 0)
		M568 P{param.T} S{var.nozzleTemp} S{var.nozzleTemp} A2 ; set active temperatures for tool 
	if (var.bedTemp > 0)
		M140 H0 S{var.bedTemp}

if state.gpOut[0].pwm=0.03 ; check if probe is already deployed
	echo "Probe ia already deployed - retracting"
	M280 P0 S80 ; retract BLTouch
	G4 S0.5

if sensors.endstops[2].triggered ; check if probe is already triggered
	echo "Probe ia already triggered - resetting"
	M280 P0 S160 ; reset BL Touch
	G4 S0.5

if sensors.probes[0].value[0]=1000 ; check if probe is in error state
	echo "Probe in error state - resetting"
	M280 P0 S160 I1 ; reset BL Touch
	G4 S0.5
	M280 P0 S80 ; retract BLTouch
	G4 S0.5

; If the printer hasn't been homed, home it
if !move.axes[0].homed || !move.axes[1].homed || !move.axes[2].homed
  G28
else
	G1 Z{sensors.probes[0].diveHeight} F{var.ZtravelSpeed} ; if axes homed move to dive height

M561 ; clear any bed transform

M290 R0 S0 ; clear babystepping

M291 P{"Press OK to move to probe point X" ^ floor(var.ProbePointX) ^ " Y" ^ floor(var.ProbePointY)} R"Ready?" S3;
; move nozzle to defined probe point
G1 X{var.ProbePointX} Y{var.ProbePointY} F{var.travelSpeed}

if (var.nozzleTemp > 0) || (var.bedTemp > 0)
	echo "Waiting for temps to stabilise"
	M116 ; wait for temps

M564 S0 H0 ; Allow movement beyond limits

;ensure you have room for the probe
if move.axes[2].machinePosition < sensors.probes[0].diveHeight
	G1 Z{sensors.probes[0].diveHeight} F{var.ZtravelSpeed}
	


M561 ; clear any bed transform

; Notify user to jog nozzle to start position
M291 P"Jog nozzle to touch bed" R"Set nozzle to zero" S3 Z1

G92 Z0 ; set Z position to zero
M291 P"Press OK to begin probing" R"Ready?" S3;

; Move probe over top of same point that nozzle was when zero was set
G1 Z{sensors.probes[0].diveHeight} F{var.ZtravelSpeed}; lift head
G1 X{move.axes[0].machinePosition - sensors.probes[0].offsets[0]} Y{move.axes[1].machinePosition - sensors.probes[0].offsets[1]} F{var.travelSpeed}

echo "Current probe offset = " ^ sensors.probes[0].triggerHeight ^ "mm"

; carry out 10 probes (or what is set in NumTests variable)

while iterations < var.NumTests
	G1 Z{sensors.probes[0].diveHeight} F{var.ZtravelSpeed}; move to dive height
		
	if state.gpOut[0].pwm=0.03
		echo "Probe ia already deployed - retracting"
		M280 P0 S80 ; retract BLTouch
		G4 S0.5
	if sensors.endstops[2].triggered
		echo "Probe ia already triggered - resetting"
		M280 P0 S160 ; reset BL Touch
		G4 S0.5
	if sensors.probes[0].value[0]=1000 ; if probe is in error state
		echo "Probe in error state - resetting"
		M280 P0 S160 I1 ; reset BL Touch
		G4 S0.5
		M280 P0 S80 ; retract BLTouch
		G4 S0.5

	G30 S-1 ; do probe at current point
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
set var.Average = {(var.RunningTotal - var.Highest - var.Lowest) / (var.NumTests - 2)} 	; calculate the average after discarding the high & low reading

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
G1 Z{sensors.probes[0].diveHeight} F{var.ZtravelSpeed} ; move head back to dive height

if var.bedTemp > 0
	M140 R0 S0 ; set bed to zero
	M140 S-276 ; turn off bed
if (var.nozzleTemp > 0) && (state.currentTool >-1)
	M568 R0 S0 ; set heater to zero
	M568 A0 ; turn off heater on current tool

M291 P{"Trigger height set to : " ^ sensors.probes[0].triggerHeight  ^ "mm. Press OK to save to config-overide.g, cancel to use until next restart"} R"Finished" S3
M500 P31 ; optionally save result to config-overide.g

M291 P{"Reload config.g to restore defaults?"} R"Restore?" S3
M98 P"0:/sys/config.g"

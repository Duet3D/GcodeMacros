;PA_adjust_height.g
; macro - PA_adjust.g
; adjusts M72 setting at a designated frequency
; To be called from slicer "after layer change"
; must have these parameters passed.
; I = the amount to increment at each change
; C = The Z height in millimeters between each change
; S = the starting value for P/A
; D = optional - Extruder number(s) to apply settings - for multipe extruders, separate by colon e.g. D0:1:2. If no D parameter set, defaults to zero
; e.g. M98 P"0:/macros/tuning/PA_adjust_height.g" I0.002 C5 S0.06 D0:1

if job.layer = null
	echo "no layer value found in object model"
	M99 ; break out of macro if we can't get layer info yet

	
if !exists(param.C)
   abort "no C parameter passed to macro" 
    

if !exists(param.I)
	abort "no I parameter passed to macro"

if !exists(param.S)
	abort "no S parameter passed to macro"
	
if !exists(global.NextHeight)
	global NextHeight=param.C ; set initaial change point
else
	if job.layer = 1 ; reset in case the print was re-started
		set global.NextHeight=param.C


if !exists(global.AtChangePoint)
	global AtChangePoint=false
	;echo "global.AtChangePoint created"
else
	if job.layer > 1 ; after the first layer start setting the change point.
		set global.AtChangePoint = floor(move.axes[2].userPosition) >= global.NextHeight) 
		;echo "global.AtChangePoint set to " ^ global.AtChangePoint 

if (move.axes[2].userPosition) < param.C
	if exists(param.D)
		M572 D{param.D} S{param.S}
	else
		M572 D0 S{param.S}	
	echo "M572 value set to " ^ {param.S}
else
	if global.AtChangePoint=true
		if !exists(global.NewValue)
			global NewValue = floor(floor(move.axes[2].userPosition) /param.C) * param.I + param.S
		else
			set global.NewValue = floor(floor(move.axes[2].userPosition) /param.C) * param.I + param.S
		if exists(param.D)
			M572 D{param.D} S{global.NewValue}
		else
			M572 D0 S{global.NewValue}
		echo "M572 value set to " ^ {global.NewValue}  ^ " @ Z = " ^ {move.axes[2].userPosition} ^ "mm"
			if job.layer > 1
		set global.NextHeight = global.NextHeight + param.C 
		echo "next change point @ Z =  " ^ global.NextHeight ^ "mm"
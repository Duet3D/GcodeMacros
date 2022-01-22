; macro - PA_adjust_layer.g
; adjusts M72 setting at a designated frequency
; To be called from slicer "on layer change"
; must have these parameters passed.
; I = the amount to increment at each change
; C = The number of layers between each Change
; S = the starting point
; D = optional - Extruder number(s) to apply settings - for multipe extruders, separate by colon e.g. D0:1:2.  Default to zero if not present
; e.g. M98 P"0:/macros/tuning/PA_adjust_height.g" I0.002 C5 S0.06 D0:1

if job.layer = null
	;echo "no layer value found in object model"
	M99 ; break out of macro if we can't get layer info yet
else
	;echo "processing layer " ^ job.layer 
	
if !exists(param.C)
   abort "no C parameter passed to macro" 
   

if !exists(param.I)
	abort "no I parameter passed to macro"

if !exists(param.S)
	abort "no S parameter passed to macro"

if !exists(global.AtChangePoint)
	global AtChangePoint=false
	;echo "global.AtChangePoint created"
else
	set global.AtChangePoint = mod(job.layer,param.C) = 0 ; should only evaluate to true every X x ChangeValue
	;echo "global.AtChangePoint set to " ^ global.AtChangePoint 

if job.layer < param.C
	if exists(param.D)
		M572 D{param.D} S{param.S}
	else
		M572 D0 S{param.S}
	
	;echo "M572 value set to " ^ {param.S}
else
	if global.AtChangePoint=true
		if !exists(global.NewValue)
			global NewValue = floor(job.layer/param.C) * param.I + param.S
		else
			set global.NewValue = floor(job.layer/param.C) * param.I + param.S
		if exists(param.D)
			M572 D{param.D} S{global.NewValue}
		else
			M572 D0 S{global.NewValue}
		echo "M572 value set to " ^ {global.NewValue}  ^ " @ Z = " ^ {move.axes[2].userPosition} ^ "mm"
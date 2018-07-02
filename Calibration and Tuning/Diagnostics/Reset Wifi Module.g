; Use in case wifi module is not running. (Blue light off)
;
M291 P"Resetting wifi module..." S3 T10

M552 S0			; Disable network module
G4 S5			; wait 5 seconds
M552 S1			; Enable network module

M291 P"Wifi module reset. Check console or DWC." S2
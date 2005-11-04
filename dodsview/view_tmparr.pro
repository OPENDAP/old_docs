FUNCTION view_tmparr,var

restore,"myarray.dat"
restore,"mymask.dat"
restore,"myinputs.dat"

set_plot,'Z'
testpal3,r,g,b
tv,BYTE(array(0:100,0:100))
better=tvrd()
write_gif,"array.gif",better,r,g,b
if var EQ 1 then begin
	 return,array 
endif else begin
  if var EQ 0 then return, mask 
endelse
return,inputs

END

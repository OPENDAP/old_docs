;An IDL program intended for use with dodsview and Peter's satellite data.
;Sven Olsen-- Summer 200

PRO peter_nwa, array, output_file, lonlow, lonhigh, latlow, lathigh, orientation, fillval, mask

print, lonlow, lonhigh, latlow, lathigh
ind=where(array EQ fillval, count)
IF count NE 0 THEN array[ind]=!VALUES.F_NAN

;Turn the datamatrix into an 8bit byte matrix
;array=bytscl(array,/NAN)
;If a landmask matrix is provided, put it ontop of the byte matrix
msize=size(mask);
;msize=0;
IF msize(0) NE 0 THEN BEGIN
	ind=where(mask EQ 1);
	array[ind]=4;
ENDIF

;Reverse the matrix if neccessary
IF orientation EQ 'machine' THEN array=reverse(array,2)

;Set the device to z, this is usefully given that all I want to do is generate graphics
set_plot,'z'


latdel=round((lathigh-latlow)/5);
londel=round((lonhigh-lonlow)/5);

					;Start up the IDL mapping tools
MAP_SET, LIMIT=[latlow, lonlow, lathigh,lonhigh], /GRID, /CONTINENTS,/HIRES,$
     XMARGIN=[4,8],YMARGIN=[2,1],COLOR=4

;Run the byte array through those tools
; map_image call puts data in startx & starty
result=MAP_IMAGE(array,startx,starty, mxsize, mysize, COMPRESS=1, LATMIN=latlow,$
    LONMIN=lonlow, LATMAX=lathigh, LONMAX=lonhigh)
tv, result, startx, starty

;Set continents and grid specifications.  

MAP_CONTINENTS, /HIRES,FILL_CONTINENTS=1,COLOR=1
MAP_CONTINENTS, /HIRES, /COASTS, COLOR=0

MAP_grid, latdel=latdel, londel=londel, GLINETHICK=1, /LABEL, latlab=lonlow-0.5, lonlab=latlow-1.0, lonalign=0.5, latalign=1.0,$
 COLOR=4, CLIP_TEXT=0


;Get the map that I have created out of sudo-video memory and turn it into a byte array
better=tvrd()
;Load a palette from the r, g, b values stored in newpal.sav
; starting here remove the old calls

testpal3,r,g,b;was once testpal4,r,g,b

 ; Make a colorbar for the output image
cbar,VMIN=0,VMAX=32,CMIN=5,CMAX=255, $  ;cmax changed from 254  	    
	/VERTICAL,POS=[.925,.05,.97,.975],color=4,charsize=1, yticklen= 0.3,charthick=1,ytitle='Temperature' 

; reread the tv to apply the color bar to the current output
better=tvrd();
write_gif,output_file,better,r,g,b
END


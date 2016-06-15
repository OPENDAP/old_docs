;An IDL program intended for use with dodsview and Peter's satellite data.
; Mark Schneider, 2004

PRO peter_pacific, array, output_file, lonlow, lonhigh, latlow, lathigh, orientation, fillval, mask

;save,array,filename="myarray.dat"
print, lonlow, lonhigh, latlow, lathigh
;Take care of missing values
ind=where(array EQ fillval, count)
IF count NE 0 THEN array[ind]=!VALUES.F_NAN

;Turn the datamatrix into an 8bit byte matrix
array2=bytscl(array,/NAN)
;array2=transpose(array3)
;If a landmask matrix is provided, put it ontop of the byte matrix
msize=size(mask);
;msize=0;
IF msize(0) NE 0 THEN BEGIN
	ind=where(mask EQ 1);
	array2[ind]=2;
ENDIF

;Reverse the matrix if neccessary
IF orientation EQ 'machine' THEN array2=reverse(array2,2)

;Set the device to z, this is usefully given that all I want to do is generate graphics
set_plot,'z'

;lonlow *= (-1);
;lonhigh *= (-1);
;save,pac_lon_hi,filename="lon_high.out";

latdel=round((lathigh-latlow)/5);
londel=round((lonhigh-lonlow)/5);

;Start up the IDL mapping tools
MAP_SET, LIMIT=[latlow, lonlow, lathigh,lonhigh], /GRID, /CONTINENTS
;MAP_SET, LIMIT=[latlow, pac_lon_low, lathigh,pac_lon_hi], /GRID, /CONTINENTS
;MAP_SET, LIMIT=[latlow, lonlow, lathigh,lonhigh], /GRID, /CONTINENTS
;MAP_SET, 90, 90,180, LIMIT=[latlow, lonlow, lathigh,lonhigh], /GRID, /CONTINENTS
;MAP_SET, 90, 90,180, /GOODESHOMOLOSINE , /MILLER_CYLINDRICAL , LIMIT=[latlow, lonlow, lathigh,lonhigh], /GRID, /CONTINENTS
;MAP_SET, 90, 90,180, /ISOTROPIC, /CYLINDRICAL, LIMIT=[latlow, lonlow, lathigh,lonhigh], /GRID, /CONTINENTS

;Run the byte array through those tools
; map_image call puts data in startx & starty
result=MAP_IMAGE(array2,startx,starty, mxsize, mysize, COMPRESS=1, LATMIN=latlow, LONMIN=lonlow, LATMAX=lathigh, LONMAX=lonhigh)
tv, result, startx, starty
;tv,result
;tv, result, startx, starty,0

;Set continents and grid specifications.  

;MAP_CONTINENTS, COLOR=254

MAP_CONTINENTS, /coasts, /hires, /continents,LIMIT=[latlow, lonlow, lathigh,lonhigh], COLOR=red

save,lonhigh,filename="lon_high.out";
save,lonlow,filename="lon_low.out";
MAP_grid, latdel=latdel, londel=londel, GLINETHICK=1, /LABEL, latlab=lonlow,lonlab=latlow, lonalign=0.5, latalign=0.0, COLOR=255, CLIP_TEXT=0, /BOX_AXIS
;MAP_grid, latdel=latdel, londel=londel, GLINETHICK=1, /LABEL, latlab=lonlow,lonlab=latlow, lonalign=0.5, latalign=0.0, COLOR=255, CLIP_TEXT=0, /BOX_AXIS

;MAP_CONTINENTS, /coasts,  COLOR=254
;MAP_CONTINENTS, /coasts, /hires, COLOR=254

;Get the map that I have created out of sudo-video memory and turn it into a byte array
better=tvrd()

testpal2,r,g,b

;calling color bar: cbar
; code courtesy of David Rosenfield

 ; Make a colorbar for the output image
  ;====> HORIZONTAL Using PAL_SW2, indices 251-254 are grays; 255 is white
cbar,VMIN=-4.0,VMAX=28.0,CMIN=0,CMAX=254, $
POS=[.02,.935,.4,.98],color=77,charsize=.5,xthick=.5, $
xtickinterval=0,xticklen= .5,charthick=1, xtitle='color-temp scale'

  ;==> or VERTICAL
  ;	    /VERTICAL,POS=[.92,.05,.97,.85],color=0,charsize=2.5,$
  ;	    yticklen= 0.2,charthick=2,ytitle='Sea Surface Temperature (!Uo!NC)'
  ;=============>
; reread the tv to apply the color bar to the current output
better=tvrd();

;Write the generated image

write_gif,output_file,better,r,g,b
END


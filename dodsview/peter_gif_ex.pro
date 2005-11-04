;peter_gif_ex.pro an example to tease out display procedures
;An IDL program intended for use with dodsview and Peter's satellite data.
;Sven Olsen-- Summer 2000; D Rosenfield Summer 2004 

PRO peter_gif_ex
;@setup_ex
inputs=view_tmparr(2)
mask=view_tmparr(0)
array=view_tmparr(1)
lonlow=inputs(0)
lonhigh=inputs(1)
latlow=inputs(2)
lathigh=inputs(3)
orientation=inputs(4)
fillval=inputs(5)

;since fillval is NAN this code piece doesn't do anything...
				;Take care of missing values
ind=where(array EQ fillval, count)
IF count NE 0 THEN array[ind]=!VALUES.F_NAN
;ind2=where(array EQ LONG(0), count0)
;IF count0 NE 0 THEN array[ind2]=4

;bytscl isn't GOOD and array is already 8bit byte matrix
				;Turn the datamatrix into an 8bit byte matrix
;array2=bytscl(array,min=0.0,max=32.0,/NAN)

;since mask isn't provided, this code piece doesn't do anything
				;If provided, layer landmask on byte matrix
msize=size(mask);
IF msize(0) NE 0 THEN BEGIN
	ind=where(mask EQ 1);
	array[ind]=2;
ENDIF

				;Reverse the matrix if neccessary
IF orientation EQ 'machine' THEN array=reverse(array,2)

				;Set device to z, hust want to generate graphics
set_plot,'z'


latdel=round((lathigh-latlow)/5);
londel=round((lonhigh-lonlow)/5);


				;Start up the IDL mapping tools
MAP_SET, LIMIT=[latlow, lonlow, lathigh,lonhigh], /GRID, /CONTINENTS,/HIRES,$
     XMARGIN=[4,9],YMARGIN=[2,2],COLOR=4

				;Run the byte array through those tools
				;map_image call puts data in startx & starty
result=MAP_IMAGE(array,startx,starty,mxsize,mysize,COMPRESS=1,LATMIN=latlow,$
   LONMIN=lonlow, LATMAX=lathigh, LONMAX=lonhigh)
tv, result, startx, starty

				;Set continents and grid specifications.  
				;TRY later: E_GRID and E_CONTINENTS in map_set 
MAP_CONTINENTS, /HIRES,FILL_CONTINENTS=1, COLOR=1	;0TH position of color palette for land
MAP_CONTINENTS, /HIRES,/COASTS,COLOR=0			;1ST position of color palette for land border


MAP_grid, latdel=latdel, londel=londel, GLINETHICK=1, /BOX_AXES, /LABEL,$; /LABEL,$
 latlab=lonlow-0.5, lonlab=latlow-1.0, lonalign=0.5, latalign=1.0,$
 COLOR=4, CLIP_TEXT=0

				;Load color palette
testpal3,r,g,b

				;Make a VERTICAL colorbar for the output image
				;left border is 91.8 % to right of img
				;right border is 93 % to right of img
cbar,VMIN=0,VMAX=32,CMIN=5,CMAX=254,/VERTICAL,POS=[.9,.044,.93,.957],$
        color=4,charsize=1, yticklen= 0.3,charthick=1,ytitle='Temperature (!Uo!NC)' 
				
				;Get map from pseudo-video memory & make it a byte array
				;reread tv & apply color bar to current output
better=tvrd();
				;Start up the IDL mapping tools
				;Write the generated image
write_gif,"myex2.gif",better,r,g,b
stop
END

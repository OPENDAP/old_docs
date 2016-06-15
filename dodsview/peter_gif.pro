;peter_gif.pro
;An IDL program intended for use with dodsview and Peter's satellite data.
;Sven Olsen-- Summer 2000; D Rosenfield Summer 2004 
;A note about the display's colors
;COLOR in MAP_SET command determines the border
;      in MAP_CONTINENTS commands (1) determines fill color (2) coast color
;      in CBAR command determines colorbar border and labels

PRO peter_gif, array, output_file, lonlow, lonhigh, latlow, lathigh, orientation, fillval, mask
;print, lonlow, lonhigh, latlow, lathigh
;inputs=[lonlow, lonhigh, latlow, lathigh, orientation, fillval]
;save,inputs,filename="myinputs.dat"
;save,mask,filename="mymask.dat"
;save,array,filename="myarray.dat"

				;Take care of missing values
ind=where(array EQ fillval, count)
IF count NE 0 THEN array[ind]=0;!VALUES.F_NAN


				;Turn the datamatrix into an 8bit byte matrix
;array=bytscl(array,/NAN)

				;If provided, layer landmask on byte matrix
msize=size(mask);
IF msize(0) NE 0 THEN BEGIN
	ind=where(mask EQ 1);
	array[ind]=1;
ENDIF

				;Reverse the matrix if neccessary
IF orientation EQ 'machine' THEN array=reverse(array,2)

				;Set device to z, all I want is to generate graphics
set_plot,'z'


latdel=round((lathigh-latlow)/5);
londel=round((lonhigh-lonlow)/5);

				;Start up the IDL mapping tools
MAP_SET, LIMIT=[latlow, lonlow, lathigh,lonhigh], /GRID, /CONTINENTS,/HIRES,$
     XMARGIN=[4,11],YMARGIN=[2,2],COLOR=4
;NOTE: because xmargin extended to right, the far-right lon. label comes up...

				;Run the byte array through those tools
				;map_image call puts data in startx & starty
result=MAP_IMAGE(array,startx,starty,mxsize,mysize,COMPRESS=1,LATMIN=latlow,$
   LONMIN=lonlow, LATMAX=lathigh, LONMAX=lonhigh)
tv, result, startx, starty

				;Set continents and grid specifications.  
				;TRY later: E_GRID and E_CONTINENTS in map_set 
MAP_CONTINENTS, /HIRES,FILL_CONTINENTS=1, COLOR=1	
				;1st position of color palette for land 
MAP_CONTINENTS, /HIRES,/COASTS,COLOR=0			
				;0th position of color palette for land border

MAP_grid, latdel=latdel, londel=londel, GLINETHICK=1, /BOX_AXES, /LABEL,$
 latlab=lonlow-0.5, lonlab=latlow-1.0, lonalign=0.5, latalign=1.0,$
 COLOR=4, CLIP_TEXT=0

				;Load color palette
testpal3,r,g,b

				;Make a VERTICAL colorbar for the output image
cbar,VMIN=0,VMAX=32,CMIN=5,CMAX=254,/VERTICAL,POS=[.9,.044,.93,.957],$
        color=4,charsize=1, yticklen= 0.3,charthick=1,ytitle='Temperature (!Uo!NC)' 

				;Get map from pseudo-video memory & make it a byte array
				;reread tv & apply color bar to current output
better=tvrd();
				;Write the generated image
write_gif,output_file,better,r,g,b
END

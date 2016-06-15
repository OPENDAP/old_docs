; $Id$
PRO WRITEPALETTE,NAME=name,R,G,B

;+
; NAME:
;       WRITEPAL
;
; PURPOSE:
;       Program Writes palette rgb's to a palette file
;       which may be subsequently used as a palette program .
;
; CATEGORY:
;       Input/Output.
;
; CALLING SEQUENCE:
;       WRITEPAL,NAME=name,r,g,b
;
; INPUTS:
;       File:  Full name of the file to write palette info
;
;       r,g,b: Variables for storing red,green,blue values
;
; KEYWORD PARAMETERS:
;     NAME:    (In quotes): Name of palette
;              (a program will be made with this name and a ".pro" extension'
;
; OUTPUTS:
;     File containg 256 colors with r,g,b values
;
; SIDE EFFECTS:
;
;       Program calls function PARSE_IT.pro
;       to extract name from file.\
;
; RESTRICTIONS:
;
;
; PROCEDURE:
;       Straightforward.
;
; MODIFICATION HISTORY:
;       Written by:  J.E.O'Reilly,  April 1, 1997
;       Modified by: D.A.Rosenfield March 18, 2004
;-
;  ====================================>
;  Get a single file using the mouse if
;  the user does not supply a file=' file name '

  IF N_ELEMENTS(R) LT 256 AND N_ELEMENTS(G) LT 256 AND N_ELEMENTS(B) LT 256 THEN BEGIN
    TVLCT,R,G,B,/GET

    IF N_ELEMENTS(R) LT 256 THEN BEGIN
      short = 256 - N_ELEMENTS(R)
      R = [R, REPLICATE(0b,short)]
      G = [G, REPLICATE(0b,short)]
      B = [B, REPLICATE(0b,short)]
    ENDIF
  ENDIF

  txt = ''
  IF KEYWORD_SET(name) EQ 0 THEN READ,txt,prompt='ENTER THE NAME FOR THIS PALETTE (Do not enter the file extension)'
  name = txt
  file = txt + '.pro'
  PRINT, 'Making Palette Program: ', file
  OPENW,lun,file,/get_lun
;STOP
  c = ' '

; ====================>
; Remove comments below if want plain r,g,b values in output file
; FOR i = 0,255 do begin
;   c = ','
;   PRINTF, lun, i,c, r(i),c, g(i),c, b(i),c, format='(4(i3,a1))'
; ENDFOR


  PRINTF, lun, 'PRO ' + name + ' ,R,G,B'
  PRINTF, lun, 'R=BYTARR(256) & G=BYTARR(256) & B=BYTARR(256) '

  FOR I = 0, N_ELEMENTS(R)-1 do begin
    PRINTF, lun, $
    'R(',i,')=', r(i),' & ','G(',i,')=', g(i),' & ','B(',i,')=', b(i),' & ',$
    FORMAT='(3(A2,I3,A2,I3,A3))'
  ENDFOR
 PRINTF,lun, 'TVLCT,R,G,B'
 PRINTF, lun, 'END'
 FREE_LUN, lun
 CLOSE, lun
PRINT, " program WRITEPALETTE finished"

STOP
END

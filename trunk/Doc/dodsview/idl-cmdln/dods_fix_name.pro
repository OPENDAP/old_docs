; IDL-DODS interface.
; Written by Daniel J. Carr - Research Systems, Inc.
; Copyright 1999, UCAR
;
; Procedure to convert a string or byte array into a valid
; IDL variable name or a valid IDL structure tag name.
;
;    name - (I/O)
;       Named IDL variable containing a string or byte array to process.
;       Processed name is returned through this parameter.
;

PRO DODS_FIX_NAME, name
   
   ; Removed the part of the code that attached a DODS_ to the front of the variable
   ; names. 06/12/00 rph.

   ; Make upper case.
   name = BYTE(STRUPCASE(name))
           
   ; Substitute invalid characters with blanks.

   index = WHERE(name LT 36B)
   IF (index[0] GE 0L) THEN name[index] = 32B
   
   ; Look for %20's in the name, and replace them with spaces
   index = STRPOS(name, '%20')
   WHILE(index NE -1) DO BEGIN
        name[index:index+2] = 32B
        index = STRPOS(name, '%20')
   ENDWHILE
   
   index = WHERE((name GT 36B) AND (name LT 48B))
   IF (index[0] GE 0L) THEN name[index] = 32B

   index = WHERE((name GT 57B) AND (name LT 65B))
   IF (index[0] GE 0L) THEN name[index] = 32B

   index = WHERE((name GT 90B) AND (name NE 95B))
   IF (index[0] GE 0L) THEN name[index] = 32B
   
   ; Remove leading/trailing blanks, and compress all
   ; internal adjacent blanks into one blank.
   name = BYTE(STRCOMPRESS(TEMPORARY(name)))
   IF (N_ELEMENTS(name) GT 63L) THEN name = name[0:63]

   DODS_NAME = STRING('')

   IF ((name[0] LT 65B) OR ((name[0] GT 90B) AND (name[0] NE 95B))) THEN BEGIN
	DODS_NAME = 'dods__' + STRING(name)
        name = DODS_NAME
   ENDIF ELSE BEGIN
	name = STRING(name)
   ENDELSE

   ; Substitute an underscore character for all remaining blanks.
   blank_pos = STRPOS(name, ' ')
   WHILE (blank_pos GE 0L) DO BEGIN
      STRPUT, name, '_', blank_pos
      blank_pos = STRPOS(name, ' ')
   ENDWHILE

   ; Prepend "DODS_" to the name.
   ; name = 'DODS_' + name
 
END


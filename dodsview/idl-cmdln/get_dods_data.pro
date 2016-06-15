; IDL-DODS interface.
; Written by Daniel J. Carr - Research Systems, Inc.
; Copyright 1999, UCAR
;
; Function to establish a connection and get DODS data.
;
;    url - (Input )
;       URL location to connect to.
;    ce - (Input )
;       Data constraint expression.
;    dods_data - (Output)
;       Returns the requested DODS data as an IDL structure.
;    gui - (Optional input flag)
;       Flag for gui display (1=yes, 0=no (default)).
;    www_errors - (Optional input flag)
;       WWW_VERBOSE_ERRORS flag (1=yes, 0=no (default)).
;    deflate - (Optional input flag)
;       ACCEPT_DEFLATE flag  (1=yes (default), 0=no).
;    returns -
;       Status (1=ok, 0=fail).
;

FUNCTION GET_DODS_DATA, url, dods_data, CE=ce, GUI=gui, $
                        WWW_ERRORS=www_errors, DEFLATE=deflate, $
                        SEQ_BLOCKSIZE=seq_blocksize, MODE=mode
    
   IF (mode EQ 1L) THEN BEGIN
      get_data = 0UL
   ENDIF ELSE BEGIN
      get_data = 1UL
   ENDELSE

   ; Initialize variables (allocate memory).
   dds = 0UL
   n_vars = 0UL

   ; Attempt to connect.
   conn = DODS_CONNECT([BYTE(STRTRIM(url[0], 2)),0B], $
             [BYTE(STRTRIM(ce[0], 2)),0B], $
             dds, n_vars, $
             ULONG(KEYWORD_SET(www_errors)), $
             ULONG(KEYWORD_SET(deflate)), $
             ULONG(KEYWORD_SET(gui)), $
             mode )

   IF ( (conn EQ 0UL) OR (dds EQ 0UL) ) THEN BEGIN
       print, 'Connection failed, aborting'
       RETURN, 0UL              ; Connect failed.
   ENDIF
   IF (n_vars EQ 0UL) THEN BEGIN
       print, 'No variables, aborting'
       RETURN, 0UL              ; No variables.
   ENDIF
   
   ; Get the first variable.
   var_p = DODS_VAR_P(conn, dds, 1UL)

   status = DODS_VAR(conn, dds, var_p, var, names, $
                     SEQ_BLOCKSIZE=seq_blocksize, GET_DATA=get_data)
   IF ((status EQ 0UL) OR (N_ELEMENTS(var) LE 0L)) THEN $
      RETURN, 0UL ; Failed to get first variable.

   DODS_FIX_NAME, names
   var_ptrs = PTR_NEW(TEMPORARY(var))

   ; Get the rest of the variables.
   FOR i=2UL, n_vars DO BEGIN
      var_p = DODS_VAR_P(conn, dds, i)
      status = DODS_VAR(conn, dds, var_p, var, name, $
                        SEQ_BLOCKSIZE=seq_blocksize, GET_DATA=get_data)
      DODS_FIX_NAME, name
      IF ((status GT 0UL) AND (N_ELEMENTS(var) GT 0L)) THEN BEGIN
         names = [TEMPORARY(names), TEMPORARY(name)]
         var_ptrs = [TEMPORARY(var_ptrs), PTR_NEW(TEMPORARY(var))]
      ENDIF ELSE i = n_vars + 1UL ; Break out of FOR loop.
   ENDFOR

   ; Build IDL structure to hold them all.

   IF(N_ELEMENTS(var_ptrs) GT 0) THEN $
      dods_data = CREATE_STRUCT(names[0], TEMPORARY(*var_ptrs[0]))
   FOR i=1L, N_ELEMENTS(var_ptrs)-1L DO BEGIN
      ind = WHERE(TAG_NAMES(dods_data) EQ names[i])
      IF (ind[0] GE 0L) THEN names[i] = names[i] + '_1'
      dods_data = CREATE_STRUCT(TEMPORARY(dods_data), names[i], $
                                TEMPORARY(*var_ptrs[i]))
   ENDFOR

   
   PTR_FREE, var_ptrs

   ; Free the connection object and dds object.

   ; deleting the DDS currently causes the program to segfault if an
   ; empty DDS structure is requested.  Hopefully this will only be
   ; temporary. rph 05/29/01.

   IF(get_data EQ 1) THEN DODS_FREE, conn, dds

   RETURN, 1UL ; Everything OK.
END






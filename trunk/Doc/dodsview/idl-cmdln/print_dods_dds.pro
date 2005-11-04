;
; A procedure to print out the DDS for a DODS dataset.
;

PRO PRINT_DODS_DDS, url, CE=ce, GUI=gui, $
   WWW_ERRORS=www_errors, DEFLATE=deflate

   DEFSYSV, '!dods_null_c', EXISTS=dods_defined
   IF (dods_defined EQ 0) THEN BEGIN
      print, 'Because of the way IDL handles external functions,'
      print, '@dods_setup must be run before this procedure is compiled.'
      print, 'Please run "@dods_setup" and then recompile the procedure'
      print, '(.compile print_dods_dds)'
      RETURN
   ENDIF
   
   IF (N_ELEMENTS(url) LE 0L) THEN RETURN
   IF (STRCOMPRESS(url) EQ '') THEN RETURN

   IF (N_ELEMENTS(ce) LE 0L) THEN ce = ''

   IF (N_ELEMENTS(gui) LE 0L) THEN gui = 0UL
   IF (N_ELEMENTS(www_errors) LE 0L) THEN www_errors = 0UL
   IF (N_ELEMENTS(deflate) LE 0L) THEN deflate = 1UL
   
   dds = 0UL
   n_vars = 0UL
   
   conn = DODS_CONNECT([BYTE(STRTRIM(url[0], 2)),0B], $
             [BYTE(STRTRIM(ce[0], 2)),0B], $
             dds, n_vars, $
             ULONG(KEYWORD_SET(www_errors)), $
             ULONG(KEYWORD_SET(deflate)), $
             ULONG(KEYWORD_SET(gui)), 1UL )
   
   IF ( (conn EQ 0UL) OR (dds EQ 0UL) ) THEN BEGIN
       print, 'Connection failed, aborting' ; Connect failed.
   ENDIF ELSE BEGIN
       DODS_PRINT_DDS, dds
   ENDELSE
   
END




















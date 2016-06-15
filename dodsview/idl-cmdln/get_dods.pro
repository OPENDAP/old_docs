; IDL-DODS interface.
; Written by Daniel J. Carr - Research Systems, Inc.
; Copyright 1999, UCAR
;
; Main interface routine for IDL-DODS link.
; GET_DODS sets up the environment, and then calls
; "GET_DODS_DATA" to establish a connection and
; return the DODS data.
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
;    mode - (Optional input flag)
;       Flag for the type of data to retrieve 
;       (0 or 'DATA' for the data (default), 1 or 'DAS' for the DAS) 
;    seq_blocksize - (Optional input flag)
;       How many elements should be allocated at once for sequence data
;       Default: 4096
;
;    returns -
;       Status (1=ok, 0=fail).
;
; The DODS data ("dods_data" parameter) is returned as an
; IDL structure variable.   The IDL structure will have one
; tag for each DODS variable that is returned, and the tag
; name is the same as the DODS name for that variable.
; For simple DODS variables, the value of the corresponding
; IDL structure tag will be an IDL scalar value.   Other
; DODS variable types will be returned as nested structures:
;
; DODS data type:         Returned IDL structure:
; 
;    ARRAY                   {ARRAY:data, 
;                             START_STRIDE_STOP:fltarr(3,N),
;                             DIMENSION_NAMES:strarr(N)}
;
;    GRID                    {GRID:data,
;                             dimension_name_0:dimension_data_0,
;                             ...
;                             dimension_name_n:dimension_data_n}
;
;       NOTE: the grid dimension names are optional -
;       not all grids will have them.
;
;    STRUCTURE               {var_name_0:var_data_0,
;                             ...
;                             var_name_n:var_data_n}
;
;    SEQUENCE                {record_name_0:record_data_0,
;                             ...
;                             record_name_n:record_data_n}
;
;       NOTE: each record_data field corresponds to a
;       sequence "column".
;
; Tag names in capital letters are literal.
; Other tag names are derived from the DODS data.
;
; EXAMPLE:
;
; IDL> url = 'http://dods.gso.uri.edu/nph-nc/data/fnoc1.nc'
; IDL> stat = GET_DODS(url, data)
; % Compiled module: GET_DODS.
; % Compiled module: GET_DODS_DATA.
; % Compiled module: DODS_VAR.
; % Compiled module: DODS_FIX_NAME.
; IDL> print, stat
; 1
; IDL> help, /str, data
; ** Structure <4008a1b8>, 5 tags, length=46320, refs=1:
;    U               STRUCT    -> <Anonymous> Array[1]
;    V               STRUCT    -> <Anonymous> Array[1]
;    LAT             STRUCT    -> <Anonymous> Array[1]
;    LON             STRUCT    -> <Anonymous> Array[1]
;    TIME            STRUCT    -> <Anonymous> Array[1]
; IDL> print, TAG_NAMES(data)
; U V LAT LON TIME
; IDL> help, /str, data.u
; ** Structure <40088fa8>, 3 tags, length=22908, refs=2:
;    ARRAY           LONG      Array[16, 17, 21]
;    START_STRIDE_STOP
;                    LONG      = Array[3, 3]
;    DIMENSION_NAMES STRING    Array[3]
; IDL> print, data.u.dimension_names
; TIME_A LAT LON
;
;
FUNCTION GET_DODS, url, dods_data, CE=ce, GUI=gui, $
                   WWW_ERRORS=www_errors, DEFLATE=deflate, MODE=mode, $
                   SEQ_BLOCKSIZE=seq_blocksize

   DEFSYSV, '!dods_null_c', EXISTS=dods_defined
   
   
   
   ; If this is the first time run in this IDL session,
   ; then define system variables and link external routines.
   IF (dods_defined EQ 0) THEN BEGIN
      @dods_setup
   ENDIF
   
   IF (N_ELEMENTS(url) LE 0L) THEN RETURN, 0L
   IF (STRCOMPRESS(url) EQ '') THEN RETURN, 0L
   IF (N_ELEMENTS(ce) LE 0L) THEN ce = ''

   IF (N_ELEMENTS(gui) LE 0L) THEN gui = 0L
   IF (N_ELEMENTS(www_errors) LE 0L) THEN www_errors = 0L
   IF (N_ELEMENTS(deflate) LE 0L) THEN deflate = 0L

   IF ( N_ELEMENTS(mode) LE 0L ) THEN BEGIN 
     mode = 0UL 
   
   ; For some reason I had made this check for 'DDS' instead of 'DATA'. 
   ; rph 05/25/01

   ENDIF ELSE BEGIN 
     IF (STRCMP(mode,'DATA',/FOLD_CASE) EQ 1L) THEN BEGIN
        mode = 0UL
     ENDIF ELSE BEGIN
        IF (STRCMP(mode,'DDS',/FOLD_CASE) EQ 1L) THEN BEGIN
           mode = 1UL
	ENDIF ELSE BEGIN
           IF (STRCMP(mode,'DAS',/FOLD_CASE) EQ 1L) THEN BEGIN
              mode = 2UL
           ENDIF ELSE BEGIN
              PRINT, 'Unrecognized Keyword parameter, MODE=',STRING(mode)
	      PRINT, 'options are: dds, das, data'
	      RETURN, 0UL
           ENDELSE
	ENDELSE
     ENDELSE
   ENDELSE
 
   IF ( N_ELEMENTS(seq_blocksize) LE 0L ) THEN seq_blocksize = 4096UL
   
   stat = 0

   IF ( mode EQ 0 OR MODE EQ 1) THEN $
     stat = GET_DODS_DATA(url, dods_data, CE=ce, GUI=gui, $
                          WWW_ERRORS=www_errors, DEFLATE=deflate, $
                          SEQ_BLOCKSIZE=seq_blocksize, MODE=mode) $ 
   ELSE IF ( mode EQ 2 ) THEN $
     stat = GET_DODS_DAS(url, dods_data, CE=ce, GUI=gui, $
                         WWW_ERRORS=www_errors, DEFLATE=deflate)
   RETURN, stat
END






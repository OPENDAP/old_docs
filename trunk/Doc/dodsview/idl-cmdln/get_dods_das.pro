; Function to establish a connection and get the DAS for a 
; DODS dataset
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

FUNCTION GET_DODS_DAS, url, dods_data, CE=ce, GUI=gui, $
                       WWW_ERRORS=www_errors, DEFLATE=deflate
    
    
    das = 0UL
    n_vars = 0UL

    conn = DODS_CONNECT( [BYTE(STRTRIM(url[0], 2)), 0B], $
                         [BYTE(STRTRIM(ce[0], 2)),0B], $
                         das, n_vars, $
                         ULONG(KEYWORD_SET(www_errors)), $
			 ULONG(KEYWORD_SET(deflate)), $
                         ULONG(KEYWORD_SET(gui)), $
			 2UL )
    
    IF ( (conn EQ 0UL) OR (das EQ 0UL) ) THEN BEGIN
        print, 'no connection'
        RETURN, 0UL
    ENDIF
    
    
    ; Get a pointer to the first attribute in the DAS and 
    ; then retrieve it using dods_attrget_
    
    DODS_DAS_FIRST_ATTR, das, num_attrs, attr_p, name
	
    status = DODS_ATTR(attr_p, name, attr)

    IF ( status EQ 1 ) THEN BEGIN
        DODS_FIX_NAME, name
        dods_data = CREATE_STRUCT(name, attr); 
    ENDIF ELSE BEGIN
	DODS_FIX_NAME, name
	attr = CREATE_STRUCT(name, '"Empty"');
        dods_data = CREATE_STRUCT(name, attr); 
    ENDELSE
    
    ; Get the next attribute in the DAS
    FOR i=2UL, num_attrs DO BEGIN

    	DODS_DAS_NEXT, das, i-1, attr_p, name
    
        status = DODS_ATTR(attr_p, name, attr)

        IF ( status EQ 1 ) THEN BEGIN
	    DODS_FIX_NAME, name
            dods_data = CREATE_STRUCT(TEMPORARY(dods_data), name, attr)  
        ENDIF ELSE BEGIN
	    DODS_FIX_NAME, name
	    attr = CREATE_STRUCT(name, '"Empty"');
            dods_data = CREATE_STRUCT(TEMPORARY(dods_data), name, attr)  
        ENDELSE

    ENDFOR
    
    RETURN, status
END

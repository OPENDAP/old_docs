; DODS_ATTR()
; Returns and IDL structure for a given DAS attribute table
;   attr_p - (Input ) The pointer to the attribute table
;   name   - (Input ) The name of the attribute table
;   attr   - (Output) An IDL structure representing the attr table
;

FUNCTION DODS_ATTR, attr_p, name, attr

    num_attrs = DODS_FIRST_ATTR(attr_p)

    sub_attr_p = 0UL
    next_pix = 0UL
    is_container = 0UL

    attr_ptrs = PTR_NEW()

    names = ''
    
    IF ( num_attrs EQ 0 ) THEN BEGIN
        attr = CREATE_STRUCT('Empty', '"Empty"');
	RETURN, 1L
    ENDIF

    FOR i=1UL, num_attrs DO BEGIN

	; Find out the name of first the attribute in the table, 
        ; and if it contains other attributes.
	
        DODS_ATTR_INFO, attr_p, i-1, is_container, curr_name
        ; Convert the pix into an attribute pointer, and get the
        ; next pix in the table.

        DODS_FIX_NAME, curr_name

        IF ( is_container EQ 1UL ) THEN BEGIN
            status = DODS_ATTR(sub_attr_p, curr_name, curr_attr)
            IF ((status NE 0UL) AND (N_ELEMENTS(curr_attr) GT 0L)) THEN BEGIN
                attr_ptrs = [TEMPORARY(attr_ptrs), PTR_NEW(TEMPORARY(curr_attr))]
                ;attr_ptrs = [TEMPORARY(attr_ptrs), PTR_NEW(TEMPORARY(values))]
                names = [TEMPORARY(names), curr_name]
            ENDIF
        ENDIF ELSE BEGIN
            
            ; If the attribute contains data, find out what type and how much
            DODS_ATTR_DATA_INFO, attr_p, i-1, type, num_elements

	    IF ( num_elements GE 1UL ) THEN $
                values =  DODS_ATTR_DATA(attr_p, i-1, 0)
	    FOR ii=1, num_elements - 1 DO BEGIN
                values = [TEMPORARY(values), $
                          DODS_ATTR_DATA(attr_p, i-1, ii) ]
            ENDFOR
	
            IF ( num_elements GE 1UL ) THEN BEGIN
                attr_ptrs = [TEMPORARY(attr_ptrs), PTR_NEW(TEMPORARY(values))]
                names = [TEMPORARY(names), curr_name]
            ENDIF
        ENDELSE

    ENDFOR
    
    ; Create a structure and put the attributes in it
    
    attr_ptrs = attr_ptrs[1:*]
    names = names[1:*]
    
    IF ( N_ELEMENTS(names) GE 1UL ) THEN $
      attr = CREATE_STRUCT(names[0], *attr_ptrs[0]);
    FOR i=1, N_ELEMENTS(names) - 1 DO BEGIN
        attr = CREATE_STRUCT(TEMPORARY(attr), names[i], TEMPORARY(*attr_ptrs[i]));
    ENDFOR

    IF ( N_TAGS(attr) GE 1 ) THEN RETURN, 1UL $
    ELSE RETURN, 0UL
END
























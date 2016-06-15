; This function compares two structures to see if they hold the same data.

FUNCTION COMP_STRUCT, struct1, struct2
   IF(N_TAGS(struct1) NE N_TAGS(struct2)) THEN RETURN, 0
   
   FOR i=0, N_TAGS(struct1) - 1 DO BEGIN
      IF(SIZE(struct1.(i), /TYPE) NE SIZE(struct2.(i), /TYPE)) THEN RETURN, 0
      IF(N_ELEMENTS(struct1.(i)) NE N_ELEMENTS(struct1.(i))) THEN RETURN, 0
      IF(N_ELEMENTS(struct1.(i)) GE 1) THEN BEGIN
         
         ; If it's a string, use string compare to check it
         IF(SIZE(struct1.(i), /TYPE) EQ 7) THEN BEGIN
            FOR j=0L, N_ELEMENTS(struct1.(i)) - 1 DO BEGIN
               IF(STRCMP(struct1.(i)[j], struct2.(i)[j]) NE 1) THEN RETURN, 0
            ENDFOR

         ; If it's a structure, use comp_struct recursively to check
         ENDIF ELSE IF(SIZE(struct1.(i), /TYPE) EQ 8) THEN BEGIN
            FOR j=0L, N_ELEMENTS(struct1.(i)) - 1 DO BEGIN
               IF(COMP_STRUCT(struct1.(i)[j], struct2.(i)[j]) NE 1) $
                 THEN RETURN, 0
            ENDFOR

         ; Otherwise use the NE operator
         ENDIF ELSE BEGIN
            FOR j=0L, N_ELEMENTS(struct1.(i)) - 1 DO BEGIN
               IF(struct1.(i)[j] NE struct2.(i)[j]) THEN RETURN, 0
            ENDFOR
         ENDELSE
      
      ENDIF
   ENDFOR
   
   RETURN, 1
END

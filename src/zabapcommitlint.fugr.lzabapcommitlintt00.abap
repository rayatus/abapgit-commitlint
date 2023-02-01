*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZABAPCOMMITLINT.................................*
DATA:  BEGIN OF STATUS_ZABAPCOMMITLINT               .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZABAPCOMMITLINT               .
CONTROLS: TCTRL_ZABAPCOMMITLINT
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZABAPCOMMITLINT               .
TABLES: ZABAPCOMMITLINT                .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .

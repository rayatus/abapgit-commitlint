CLASS zcx_abapgit_commitlint DEFINITION
  PUBLIC
  INHERITING FROM cx_static_check
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_t100_dyn_msg .
    INTERFACES if_t100_message .

    DATA message TYPE string READ-ONLY .

    METHODS constructor
      IMPORTING
        !textid   LIKE if_t100_message=>t100key OPTIONAL
        !previous LIKE previous OPTIONAL
        !message  TYPE string OPTIONAL .

    METHODS if_message~get_text
        REDEFINITION .
  PROTECTED SECTION.
  PRIVATE SECTION.


ENDCLASS.



CLASS zcx_abapgit_commitlint IMPLEMENTATION.


  METHOD constructor ##ADT_SUPPRESS_GENERATION.
    CALL METHOD super->constructor
      EXPORTING
        previous = previous.
    CLEAR me->textid.
    IF textid IS INITIAL.
      if_t100_message~t100key = if_t100_message=>default_textid.
    ELSE.
      if_t100_message~t100key = textid.
    ENDIF.
    me->message = message.

  ENDMETHOD.


  METHOD if_message~get_text.
    IF message IS INITIAL.
      result = super->if_message~get_text( ).
    ELSE.
      result = message.
    ENDIF.

  ENDMETHOD.
ENDCLASS.

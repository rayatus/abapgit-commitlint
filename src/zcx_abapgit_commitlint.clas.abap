CLASS zcx_abapgit_commitlint DEFINITION
  PUBLIC
  INHERITING FROM cx_static_check
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_t100_dyn_msg .
    INTERFACES if_t100_message .

    TYPES ty_t_log TYPE zcl_abapgit_commitlint=>ty_t_log.
    DATA message TYPE string READ-ONLY .
    METHODS constructor
      IMPORTING
        !textid   LIKE if_t100_message=>t100key OPTIONAL
        !previous LIKE previous OPTIONAL
        !message  TYPE string OPTIONAL
        !it_log   TYPE ty_t_log OPTIONAL.
    METHODS get_log RETURNING VALUE(rt_log) TYPE zcl_abapgit_commitlint=>ty_t_log.
  PROTECTED SECTION.
  PRIVATE SECTION.
    DATA mt_log TYPE ty_t_log.

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
    mt_log = it_log.
  ENDMETHOD.
  METHOD get_log.
    rt_log = mt_log.
  ENDMETHOD.

ENDCLASS.

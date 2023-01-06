CLASS zcl_abapgit_commitlint DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    TYPES ty_v_severity TYPE c LENGTH 1.
    CONSTANTS: BEGIN OF mc_severity,
                 error   TYPE ty_v_severity VALUE 'E',
                 warning TYPE ty_v_severity VALUE 'W',
                 info    TYPE ty_v_severity VALUE 'I',
               END OF mc_severity.

    TYPES: BEGIN OF ty_s_message_log,
             severity TYPE ty_v_severity,
             message  TYPE string,
           END   OF ty_s_message_log,
           ty_t_log TYPE STANDARD TABLE OF ty_s_message_log WITH EMPTY KEY.

    METHODS constructor
      IMPORTING
        !is_comment     TYPE zif_abapgit_definitions=>ty_comment
        !iv_url         TYPE string
        !iv_branch_name TYPE string
        !io_rules       TYPE REF TO zif_abapgit_commitlint_rules
      RAISING
        zcx_abapgit_commitlint .

    METHODS has_errors RETURNING VALUE(rv_has_errors) TYPE abap_bool.
    METHODS get_log RETURNING VALUE(rt_log) TYPE ty_t_log.

    METHODS validate
      RAISING zcx_abapgit_commitlint.

  PROTECTED SECTION.

  PRIVATE SECTION.
    TYPES: BEGIN OF ty_s_parsed_comment,
             header TYPE string,
             body   TYPE string,
           END   OF ty_s_parsed_comment.

    CONSTANTS cv_comment_separator TYPE string VALUE '\n\n'.

    DATA ms_parsed_comment TYPE ty_s_parsed_comment.
    DATA mt_log TYPE ty_t_log.
    DATA mv_has_errors TYPE abap_bool.
    DATA mo_rules TYPE REF TO zif_abapgit_commitlint_rules.

    METHODS parse IMPORTING is_comment     TYPE zif_abapgit_definitions=>ty_comment.

    METHODS add_error
      IMPORTING
        iv_message TYPE string.

    METHODS add_warning
      IMPORTING
        iv_message TYPE String.

    METHODS add_info
      IMPORTING
        iv_message TYPE String.

    METHODS add_message
      IMPORTING
        iv_severity TYPE ty_v_severity
        iv_message  TYPE String.


ENDCLASS.



CLASS zcl_abapgit_commitlint IMPLEMENTATION.

  METHOD constructor.
    parse( is_comment ).
    mo_rules = io_rules.
  ENDMETHOD.

  METHOD validate.


    IF has_errors(  ).
      RAISE EXCEPTION TYPE zcx_abapgit_commitlint
        EXPORTING
          it_log = get_log( ).
    ENDIF.
  ENDMETHOD.

  METHOD parse.
    "commit title is separated from body by '\n\n'
    SPLIT is_comment-comment AT cv_comment_separator INTO ms_parsed_comment-header ms_parsed_comment-body.
  ENDMETHOD.

  METHOD has_errors.
    rv_has_errors = mv_has_errors.
  ENDMETHOD.

  METHOD get_log.
    rt_log = mt_log.
  ENDMETHOD.

  METHOD add_error.
    add_message( iv_severity = mc_severity-error iv_message = iv_message ).
  ENDMETHOD.
  METHOD add_warning.
    add_message( iv_severity = mc_severity-warning iv_message = iv_message ).
  ENDMETHOD.
  METHOD add_info.
    add_message( iv_severity = mc_severity-info iv_message = iv_message ).
  ENDMETHOD.

  METHOD add_message.
    INSERT VALUE #( severity = iv_severity message = iv_message ) INTO TABLE mt_log.
  ENDMETHOD.

ENDCLASS.

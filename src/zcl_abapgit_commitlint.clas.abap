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
             severity  TYPE ty_v_severity,
             rule_name TYPE string,
             message   TYPE string,
           END   OF ty_s_message_log,
           ty_t_log TYPE STANDARD TABLE OF ty_s_message_log WITH DEFAULT KEY.

    METHODS constructor
      IMPORTING
        !is_comment     TYPE zif_abapgit_definitions=>ty_comment
        !iv_url         TYPE string
        !iv_branch_name TYPE string
        !io_rules       TYPE REF TO zif_abapgit_commitlint_rules.

    METHODS has_errors RETURNING VALUE(rv_has_errors) TYPE abap_bool.
    METHODS get_log RETURNING VALUE(rt_log) TYPE ty_t_log.

    METHODS validate
      RAISING zcx_abapgit_commitlint.

  PROTECTED SECTION.

  PRIVATE SECTION.

    DATA: BEGIN OF ms_detail,
            comment     TYPE zif_abapgit_definitions=>ty_comment,
            repo_url    TYPE string,
            branch_name TYPE string,
            rules       TYPE REF TO zif_abapgit_commitlint_rules,
          END OF ms_detail.

    DATA mt_log TYPE ty_t_log.
    DATA mv_has_errors TYPE abap_bool.

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
    METHODS set_log
      IMPORTING
        it_log TYPE ty_t_log.


ENDCLASS.



CLASS zcl_abapgit_commitlint IMPLEMENTATION.

  METHOD constructor.
    ms_detail-branch_name = iv_branch_name.
    ms_detail-comment = is_comment.
    ms_detail-repo_url = iv_url.
    ms_detail-rules = io_rules.
  ENDMETHOD.

  METHOD validate.

    set_log( NEW zcl_abapgit_commitlint_srv( )->lint( ms_detail-comment-comment ) ).

    IF has_errors(  ).
      RAISE EXCEPTION TYPE zcx_abapgit_commitlint
        EXPORTING
          it_log = get_log( ).
    ENDIF.
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


  METHOD set_log.
    mt_log = it_log.
    IF line_exists( mt_log[ severity = mc_severity-error ] ).
      mv_has_errors = abap_true.
    ENDIF.
  ENDMETHOD.

ENDCLASS.

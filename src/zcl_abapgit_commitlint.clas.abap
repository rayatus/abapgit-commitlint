CLASS zcl_abapgit_commitlint DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.



    METHODS constructor
      IMPORTING
        !is_comment     TYPE zif_abapgit_definitions=>ty_comment
        !iv_url         TYPE string
        !iv_branch_name TYPE string
        !io_linter      TYPE REF TO zif_abapgit_commitlint_linter.

    METHODS has_errors RETURNING VALUE(rv_has_errors) TYPE abap_bool.
    METHODS get_log RETURNING VALUE(rt_log) TYPE zif_abapgit_commitlint_types=>ty_t_log.
    METHODS validate
      RAISING zcx_abapgit_commitlint.

    CLASS-METHODS get_linter
      IMPORTING io_repo          TYPE REF TO zcl_abapgit_repo_online
      RETURNING VALUE(ro_linter) TYPE REF TO zif_abapgit_commitlint_linter
      RAISING   zcx_abapgit_commitlint.

    CLASS-METHODS is_push_allowed_with_errors
      IMPORTING io_repo           TYPE REF TO zcl_abapgit_repo_online
      RETURNING VALUE(rf_allowed) TYPE abap_bool
      RAISING   zcx_abapgit_commitlint.



  PROTECTED SECTION.

  PRIVATE SECTION.

    DATA: BEGIN OF ms_detail,
            comment     TYPE zif_abapgit_definitions=>ty_comment,
            repo_url    TYPE string,
            branch_name TYPE string,
            linter      TYPE REF TO zif_abapgit_commitlint_linter,
          END OF ms_detail.

    DATA mt_log TYPE zif_abapgit_commitlint_types=>ty_t_log.
    DATA mv_has_errors TYPE abap_bool.

    METHODS set_log
      IMPORTING
        it_log TYPE zif_abapgit_commitlint_types=>ty_t_log.


ENDCLASS.



CLASS zcl_abapgit_commitlint IMPLEMENTATION.

  METHOD constructor.
    ms_detail-branch_name   = iv_branch_name.
    ms_detail-comment       = is_comment.
    ms_detail-repo_url      = iv_url.
    ms_detail-linter        = io_linter.
  ENDMETHOD.

  METHOD validate.
    set_log( ms_detail-linter->lint( ms_detail-comment-comment ) ).
  ENDMETHOD.

  METHOD has_errors.
    rv_has_errors = mv_has_errors.
  ENDMETHOD.

  METHOD get_log.
    rt_log = mt_log.
  ENDMETHOD.

  METHOD set_log.
    mt_log = it_log.
    IF line_exists( mt_log[ severity = zif_abapgit_commitlint_types=>mc_severity-error ] ).
      mv_has_errors = abap_true.
    ENDIF.
  ENDMETHOD.

  METHOD get_linter.
    DATA(lv_repourl) = io_repo->get_url(  ).
    ro_linter = lcl_custo_reader=>factory(  )->get_linter_from_repourl( lv_repourl ).
  ENDMETHOD.

  METHOD is_push_allowed_with_errors.
    DATA(lv_repourl) = io_repo->get_url(  ).
    rf_allowed = lcl_custo_reader=>factory(  )->get_by_repourl( lv_repourl )-allow_push_if_error.
  ENDMETHOD.

ENDCLASS.

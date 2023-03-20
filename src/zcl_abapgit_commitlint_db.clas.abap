CLASS zcl_abapgit_commitlint_db DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    METHODS get_settings
      IMPORTING io_repo         TYPE REF TO zif_abapgit_repo_online
      RETURNING VALUE(rs_custo) TYPE zabapcommitlint
      RAISING   zcx_abapgit_commitlint.

    METHODS save_settings
      IMPORTING io_repo     TYPE REF TO zif_abapgit_repo_online
                is_settings TYPE zabapcommitlint
      RAISING   zcx_abapgit_commitlint.


  PROTECTED SECTION.
  PRIVATE SECTION.
    TYPES ty_t_custo TYPE STANDARD TABLE OF zabapcommitlint WITH DEFAULT KEY.

    DATA mt_custo TYPE ty_t_custo.

    METHODS get_by_repourl
      IMPORTING VALUE(iv_repourl) TYPE string
      RETURNING VALUE(rs_custo)   TYPE zabapcommitlint
      RAISING   zcx_abapgit_commitlint.


    METHODS set_custo
      IMPORTING it_custo TYPE ty_t_custo.
ENDCLASS.



CLASS zcl_abapgit_commitlint_db IMPLEMENTATION.

  METHOD get_by_repourl.
    TRANSLATE iv_repourl TO UPPER CASE.

    SELECT *
    INTO TABLE @mt_custo
    FROM zabapcommitlint.                           "#EC CI_SUBRC

    ASSIGN mt_custo[ repourl = iv_repourl ] TO FIELD-SYMBOL(<ls_custo>).
    IF sy-subrc IS INITIAL.
      rs_custo = <ls_custo>.
    ENDIF.
  ENDMETHOD.


  METHOD set_custo.
    mt_custo = it_custo.
  ENDMETHOD.

  METHOD get_settings.
    rs_custo = get_by_repourl( io_repo->get_url(  ) ).
  ENDMETHOD.

  METHOD save_settings.
    DATA ls_settings TYPE zabapcommitlint.

    MOVE-CORRESPONDING is_settings TO ls_settings.
    ls_settings-repourl = io_repo->get_url(  ).
    TRANSLATE ls_settings-repourl TO UPPER CASE.
    MODIFY zabapcommitlint FROM ls_settings.

  ENDMETHOD.

ENDCLASS.


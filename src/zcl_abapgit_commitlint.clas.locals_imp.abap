CLASS lcl_custo_reader DEFINITION CREATE PRIVATE.

  PUBLIC SECTION.
    TYPES ty_t_custo TYPE STANDARD TABLE OF zabapcommitlint WITH DEFAULT KEY.

    CLASS-METHODS factory RETURNING VALUE(ro_instance) TYPE REF TO lcl_custo_reader.
    METHODS constructor.
    METHODS get_by_repourl
      IMPORTING VALUE(iv_repourl) TYPE string
      RETURNING VALUE(rs_custo)   TYPE zabapcommitlint
      RAISING   zcx_abapgit_commitlint.
    METHODS get_linter_from_repourl
      IMPORTING iv_repourl       TYPE string
      RETURNING VALUE(ro_linter) TYPE REF TO zif_abapgit_commitlint_linter
      RAISING   zcx_abapgit_commitlint .

    METHODS set_custo
      IMPORTING it_custo TYPE ty_t_custo.

  PROTECTED SECTION.
  PRIVATE SECTION.

    DATA mt_custo TYPE ty_t_custo.
    CLASS-DATA mo_singleton TYPE REF TO lcl_custo_reader.

    METHODS create_linter
      IMPORTING iv_linter        TYPE zabapcommitlint-linter
      RETURNING VALUE(ro_linter) TYPE REF TO zif_abapgit_commitlint_linter
      RAISING   zcx_abapgit_commitlint .

ENDCLASS.

CLASS lcl_custo_reader IMPLEMENTATION.

  METHOD constructor.
    SELECT *
        INTO TABLE @mt_custo
        FROM zabapcommitlint.                             "#EC CI_SUBRC
  ENDMETHOD.

  METHOD factory.
    IF mo_singleton IS NOT BOUND.
      mo_singleton = NEW #(  ).
    ENDIF.
    ro_instance = mo_singleton.
  ENDMETHOD.

  METHOD get_by_repourl.
    TRANSLATE iv_repourl TO UPPER CASE.
    ASSIGN mt_custo[ repourl = iv_repourl ] TO FIELD-SYMBOL(<ls_custo>).
    IF sy-subrc IS INITIAL.
      rs_custo = <ls_custo>.
    ENDIF.
  ENDMETHOD.

  METHOD get_linter_from_repourl.

    DATA(ls_custo) = get_by_repourl( iv_repourl ).
    IF ls_custo-linter IS NOT INITIAL.
      ro_linter = create_linter( ls_custo-linter ).
    ENDIF.

  ENDMETHOD.


  METHOD create_linter.
    TRY.
        CREATE OBJECT ro_linter TYPE (iv_linter).
      CATCH cx_sy_create_object_error.
        RAISE EXCEPTION TYPE zcx_abapgit_commitlint
          EXPORTING
            message = |{ iv_linter } does not implement 'zif_abapgit_commitlint_linter' interface.|.
    ENDTRY.

  ENDMETHOD.

  METHOD set_custo.
    mt_custo = it_custo.
  ENDMETHOD.

ENDCLASS.

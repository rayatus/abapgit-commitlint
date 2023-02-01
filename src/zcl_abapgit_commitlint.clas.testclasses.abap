CLASS ltcl_engine DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.
    METHODS:
      non_existing_linter FOR TESTING RAISING cx_static_check,
      existing_linter FOR TESTING RAISING cx_static_check,
      linter_no_interface FOR TESTING RAISING cx_static_check.


ENDCLASS.


CLASS ltcl_engine IMPLEMENTATION.


  METHOD non_existing_linter.
    DATA lv_repourl TYPE string VALUE 'Repo with empty Linter config'.

    DATA(lo_custo_reader) = lcl_custo_reader=>factory(  ).
    lo_custo_reader->set_custo( VALUE #( ( repourl = lv_repourl ) ) ).
    DATA(lo_linter) = lo_custo_reader->get_linter_from_repourl( lv_repourl ).

    cl_abap_unit_assert=>assert_not_bound(
      EXPORTING
        act = lo_linter
        msg = 'Repo should not have linter assigned' ).

  ENDMETHOD.



  METHOD existing_linter.

    DATA(lo_custo_reader) = lcl_custo_reader=>factory(  ).
    lo_custo_reader->set_custo( VALUE #( ( repourl = 'DummyWithOKLinter'
                                           linter  = 'ZCL_ABAPGIT_COMMITLINT_SRV' ) ) ).

    DATA(lo_linter) =  lo_custo_reader->get_linter_from_repourl( 'DummyWithOKLinter' ).
    cl_abap_unit_assert=>assert_bound(
      EXPORTING
        act = lo_linter
        msg = 'Repo should have linter assigned' ).
  ENDMETHOD.

  METHOD linter_no_interface.

    "try to create a linter from a 'class name' that does not implement Linter interface
    TRY.
        data(lo_custo_reader) = lcl_custo_reader=>factory(  ).
        lo_custo_reader->set_custo( value #( ( repourl = 'Dummy'
                                               linter  = 'CL_SALV_TABLE') ) ).


        lcl_custo_reader=>factory(  )->get_linter_from_repourl( 'Dummy' ).
        cl_abap_unit_assert=>abort(
          EXPORTING
            msg = 'Provided linter class should not implement Linter interface' ).
      CATCH zcx_abapgit_commitlint INTO DATA(lo_error).
        "Do nothing: fails as expected
    ENDTRY.

  ENDMETHOD.

ENDCLASS.

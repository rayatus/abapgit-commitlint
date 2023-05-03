CLASS zcl_abapgit_user_exit DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES zif_abapgit_exit .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_abapgit_user_exit IMPLEMENTATION.
  METHOD zif_abapgit_exit~adjust_display_commit_url.

  ENDMETHOD.

  METHOD zif_abapgit_exit~adjust_display_filename.

  ENDMETHOD.

  METHOD zif_abapgit_exit~allow_sap_objects.

  ENDMETHOD.

  METHOD zif_abapgit_exit~change_local_host.

  ENDMETHOD.

  METHOD zif_abapgit_exit~change_proxy_authentication.

  ENDMETHOD.

  METHOD zif_abapgit_exit~change_proxy_port.

  ENDMETHOD.

  METHOD zif_abapgit_exit~change_proxy_url.

  ENDMETHOD.

  METHOD zif_abapgit_exit~change_tadir.

  ENDMETHOD.

  METHOD zif_abapgit_exit~create_http_client.

  ENDMETHOD.

  METHOD zif_abapgit_exit~custom_serialize_abap_clif.

  ENDMETHOD.

  METHOD zif_abapgit_exit~deserialize_postprocess.

  ENDMETHOD.

  METHOD zif_abapgit_exit~determine_transport_request.

  ENDMETHOD.

  METHOD zif_abapgit_exit~get_ci_tests.

  ENDMETHOD.

  METHOD zif_abapgit_exit~get_ssl_id.

  ENDMETHOD.

  METHOD zif_abapgit_exit~http_client.

  ENDMETHOD.

  METHOD zif_abapgit_exit~on_event.

    CASE ii_event->mv_action.
      WHEN 'commitlint'.
        TRY.
            DATA(lv_key) = ii_event->query( )->get( 'KEY' ).
            IF lv_key IS NOT INITIAL.
              DATA(lo_repo) = CAST zcl_abapgit_repo( zcl_abapgit_repo_srv=>get_instance( )->get( CONV #( lv_key ) ) ).
            ENDIF.

            rs_handled-page  = zcl_abapgit_commitlint_page=>create( lo_repo ).
            rs_handled-state = zcl_abapgit_gui=>c_event_state-new_page.

          CATCH zcx_abapgit_commitlint INTO DATA(lo_exception).
            zcx_abapgit_exception=>raise( iv_text     = lo_exception->get_text(  )
                                          ix_previous = lo_exception ).
        ENDTRY.


    ENDCASE.

  ENDMETHOD.

  METHOD zif_abapgit_exit~pre_calculate_repo_status.

  ENDMETHOD.

  METHOD zif_abapgit_exit~serialize_postprocess.

  ENDMETHOD.

  METHOD zif_abapgit_exit~validate_before_push.
    TRY.
        DATA(lo_commit_linter)     = zcl_abapgit_commitlint=>get_linter( io_repo ).

        IF lo_commit_linter IS BOUND.
          DATA(lo_commitlint_engine) = NEW zcl_abapgit_commitlint( is_comment        = is_comment
                                                                   io_repo           = io_repo
                                                                   io_linter         = lo_commit_linter ).
          lo_commitlint_engine->validate( ).
          IF lo_commitlint_engine->has_errors(  ) = abap_true.
            zcl_abapgit_commitlint_ui=>display_log( lo_commitlint_engine->get_log( ) ).

            IF zcl_abapgit_commitlint=>is_push_allowed_with_errors( io_repo ) = abap_false.
              "Abort commit
              zcx_abapgit_exception=>raise(
                EXPORTING
                  iv_text = 'Commit message does not stick to the rules.' ).
            ENDIF.
          ENDIF.
        ENDIF.

      CATCH zcx_abapgit_commitlint INTO DATA(lo_exception).
        zcx_abapgit_exception=>raise(
          EXPORTING
            iv_text     = lo_exception->get_text( )
            ix_previous = lo_exception ).
    ENDTRY.

  ENDMETHOD.

  METHOD zif_abapgit_exit~wall_message_list.

  ENDMETHOD.

  METHOD zif_abapgit_exit~wall_message_repo.

  ENDMETHOD.

  method zif_abapgit_exit~enhance_repo_toolbar.

    io_menu->add( iv_txt = 'CommitLint'
                  iv_act = |{ zcl_abapgit_commitlint_page=>mc_id }?key={ iv_key }|
                  iv_cur = boolc( iv_act = zcl_abapgit_commitlint_page=>mc_id ) ).

  ENDMETHOD.

ENDCLASS.


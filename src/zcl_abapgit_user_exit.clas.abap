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

  ENDMETHOD.

  METHOD zif_abapgit_exit~pre_calculate_repo_status.

  ENDMETHOD.

  METHOD zif_abapgit_exit~serialize_postprocess.

  ENDMETHOD.

  METHOD zif_abapgit_exit~validate_before_push.
    TRY.

        NEW zcl_abapgit_commitlint(
          is_comment        = is_comment
          iv_url            = iv_url
          iv_branch_name    = iv_branch_name
          io_linter         = NEW zcl_abapgit_commitlint_srv( )
          )->validate( ).

      CATCH zcx_abapgit_commitlint INTO DATA(lo_exception).

        DATA(lt_log) = lo_exception->get_log( ).
        IF lt_log IS NOT INITIAL.
          TRY.
              cl_salv_table=>factory(
                IMPORTING
                  r_salv_table = DATA(lo_alv)
                CHANGING
                  t_table      = lt_log ).

              lo_alv->get_columns( )->set_optimize( ).

              lo_alv->set_screen_popup(
                EXPORTING
                  start_column = 1
                  end_column   = 10
                  start_line   = 1
                  end_line     = 5
              ).
              lo_alv->display( ).

              zcx_abapgit_exception=>raise(
                EXPORTING
                  iv_text = 'Git message does not stick with the rules.' ).

            CATCH cx_salv_msg INTO DATA(lo_alv_exception).
              zcx_abapgit_exception=>raise(
                EXPORTING
                  iv_text     = 'CommitLit exception while displaying report log'
                  ix_previous = lo_alv_exception ).
          ENDTRY.
        ELSE.
          zcx_abapgit_exception=>raise(
            EXPORTING
              iv_text = lo_exception->get_text( ) ).
        ENDIF.

    ENDTRY.

  ENDMETHOD.

  METHOD zif_abapgit_exit~wall_message_list.

  ENDMETHOD.

  METHOD zif_abapgit_exit~wall_message_repo.

  ENDMETHOD.

ENDCLASS.

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

        DATA(lo_commitlint) = NEW zcl_abapgit_commitlint( is_comment        = is_comment
                                                          iv_url            = iv_url
                                                          iv_branch_name    = iv_branch_name
                                                          io_linter         = NEW zcl_abapgit_commitlint_srv( ) ).
        lo_commitlint->validate( ).
        IF lo_commitlint->has_errors(  ) = abap_true.
          zcl_abapgit_commitlint_ui=>display_log( lo_commitlint->get_log( ) ).
        ENDIF.

      CATCH zcx_abapgit_commitlint INTO DATA(lo_exception).
        zcx_abapgit_exception=>raise(
          EXPORTING
            iv_text = lo_exception->get_text( ) ).
    ENDTRY.

  ENDMETHOD.

  METHOD zif_abapgit_exit~wall_message_list.

  ENDMETHOD.

  METHOD zif_abapgit_exit~wall_message_repo.

  ENDMETHOD.

ENDCLASS.

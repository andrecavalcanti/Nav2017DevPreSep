page 70018014 "EDI Security Eff. Permissions"
{
  // version FLS1.00

  // ECLIPSE - SupplyPoint (ECSP)
  // ----------------------------
  //   ECSP2.00j

  CaptionML=ENU='Security Effective Permissions',
            ENA='Security Effective Permissions';
  DeleteAllowed=false;
  InsertAllowed=false;
  ModifyAllowed=false;
  PageType=Worksheet;
  ShowFilter=false;
  SourceTable="EDI Security Permission Buffer";
  SourceTableTemporary=true;
  SourceTableView=SORTING("Table No.","Field No.")
                  ORDER(Ascending)
                  WHERE("Field No."=FILTER(>0));

  layout
  {
    area(content)
    {
      group(General)
      {
        CaptionML=ENU='General',
                  ENA='General';
        field(currentUserID;currentUserID)
        {
          ApplicationArea=Basic;
          CaptionML=ENU='User ID',
                    ENA='User ID';

          trigger OnLookup(Text : Text) : Boolean;
          var
            userMgt : Codeunit 418;
          begin
            userMgt.LookupUserID(currentUserID);
            ResetPage;
          end;

          trigger OnValidate();
          var
            userMgt : Codeunit 418;
          begin
            userMgt.ValidateUserID(currentUserID);
            ResetPage;
          end;
        }
        field(controlStatus;controlStatus)
        {
          ApplicationArea=Basic;
          CaptionML=ENU='Controlled By',
                    ENA='Controlled By';
          Editable=false;
        }
      }
      group("Table Permissions")
      {
        CaptionML=ENU='Table Permissions',
                  ENA='Table Permissions';
        Editable=false;
        field(TableReadPermission;readPerm)
        {
          ApplicationArea=Basic;
          AssistEdit=false;
          CaptionML=ENU='Read Permission',
                    ENA='Read Permission';
          DrillDown=false;
          Editable=false;
          Enabled=false;
          Lookup=false;
        }
        field(TableInsertPermission;insertPerm)
        {
          ApplicationArea=Basic;
          AssistEdit=false;
          CaptionML=ENU='Insert Permission',
                    ENA='Insert Permission';
          DrillDown=false;
          Editable=false;
          Enabled=false;
          Lookup=false;
        }
        field(TableModifyPermission;modifyPerm)
        {
          ApplicationArea=Basic;
          AssistEdit=false;
          CaptionML=ENU='Modify Permission',
                    ENA='Modify Permission';
          DrillDown=false;
          Editable=false;
          Enabled=false;
          Lookup=false;
        }
        field(TableDeletePermission;deletePerm)
        {
          ApplicationArea=Basic;
          AssistEdit=false;
          CaptionML=ENU='Delete Permission',
                    ENA='Delete Permission';
          DrillDown=false;
          Editable=false;
          Enabled=false;
          Lookup=false;
        }
      }
      group(Handler)
      {
        CaptionML=ENU='Handler',
                  ENA='Handler';
        field(processorCode;processorCode)
        {
          ApplicationArea=Basic;
          CaptionML=ENU='Processor Code',
                    ENA='Processor Code';
          Editable=false;
        }
        field(handlerCode;handlerCode)
        {
          ApplicationArea=Basic;
          CaptionML=ENU='Handler Code',
                    ENA='Handler Code';
          Editable=false;
        }
        field(tableFullName;tableFullName)
        {
          ApplicationArea=Basic;
          CaptionML=ENU='Table Name',
                    ENA='Table Name';
          Editable=false;
        }
      }
      repeater(Group)
      {
        Editable=false;
        field("Field No.";"Field No.")
        {
          ApplicationArea=Basic;
          AssistEdit=false;
          CaptionML=ENU='Field No.',
                    ENA='Field No.';
          DrillDown=false;
          Lookup=false;
          StyleExpr=styleFormat;
        }
        field("Field Name";"Field Name")
        {
          ApplicationArea=Basic;
          StyleExpr=styleFormat;
        }
        field("Issued By";"Issued By")
        {
          ApplicationArea=Basic;
          StyleExpr=styleFormat;
        }
        field("Direct Read";"Direct Read")
        {
          ApplicationArea=Basic;
        }
        field("Direct Modify";"Direct Modify")
        {
          ApplicationArea=Basic;
        }
        field("Indirect Read";"Indirect Read")
        {
          ApplicationArea=Basic;
          Visible=false;
        }
        field("Indirect Modify";"Indirect Modify")
        {
          ApplicationArea=Basic;
          Visible=false;
        }
        field(Visible;Visible)
        {
          ApplicationArea=Basic;
          Visible=false;
        }
      }
      group("Important Notes")
      {
        CaptionML=ENU='Important Notes',
                  ENA='Important Notes';
        fixed(Group1101235025)
        {
          group(Group1101235028)
          {
            field(text16016310G;text16016310G)
            {
              ApplicationArea=Basic;
              ShowCaption=false;
              Style=Attention;
              StyleExpr=TRUE;
            }
            field(text16016311G;text16016311G)
            {
              ApplicationArea=Basic;
              ShowCaption=false;
              Style=Attention;
              StyleExpr=TRUE;
            }
          }
        }
      }
    }
  }

  actions
  {
    area(processing)
    {
      action(Calculate)
      {
        ApplicationArea=Basic;
        CaptionML=ENU='Calculate',
                  ENA='Calculate';
        Image=EncryptionKeys;
        Promoted=true;
        //The property 'PromotedCategory' can only be set if the property 'Promoted' is set to 'true'
        //PromotedCategory=Process;
        //The property 'PromotedIsBig' can only be set if the property 'Promoted' is set to 'true'
        //PromotedIsBig=true;

        trigger OnAction();
        begin
          Calculate;
        end;
      }
    }
  }

  trigger OnAfterGetRecord();
  begin
    styleFormat := 'Standard';
    IF "Issued By" = "Issued By"::"SupplyPoint Security" THEN BEGIN
      IF "SupplyPoint Controlled" AND "Direct Read" AND NOT "Direct Modify" THEN
        styleFormat := 'Unfavorable';
      IF NOT "Direct Read" THEN
        styleFormat := 'StrongAccent';
      IF "SupplyPoint Controlled" AND "Direct Modify" THEN
        styleFormat := 'Favorable';
    END;
  end;

  trigger OnOpenPage();
  begin
    currentUserID := 'ECLAUS\SCreanor';
  end;

  var
    tableNo : Integer;
    currentUserID : Code[50];
    tableFullName : Text[50];
    readPerm : Text[30];
    insertPerm : Text[30];
    modifyPerm : Text[30];
    deletePerm : Text[30];
    controlStatus : Text[30];
    [InDataSet]
    styleFormat : Text[50];
    processorCode : Code[10];
    handlerCode : Code[20];
    text16016310G : TextConst ENU='This Effective Permissions analysis does not take into account any other Security Handlers which may be configured against this table.',ENA='This Effective Permissions analysis does not take into account any other Security Handlers which may be configured against this table.';
    text16016311G : TextConst ENU='It is an isolated view of what the selected Handler will allow for the nominated user.',ENA='It is an isolated view of what the selected Handler will allow for the nominated user.';

  procedure SetProperties("table" : Integer;procCode : Code[10];handCode : Code[20]);
  var
    "object" : Record 2000000001;
  begin
    tableNo := table;
    object.SETRANGE(Type, object.Type::Table);
    object.SETRANGE(ID, tableNo);
    IF object.FINDFIRST THEN
      tableFullName := object.Name
    ELSE
      tableFullName := '';

    processorCode := procCode;
    handlerCode := handCode;

    RESET;
    DELETEALL;
  end;

  local procedure Calculate();
  var
    text16016310L : TextConst ENU='You must specify the User to Calculate Effective Permissions for.',ENA='You must specify the User to Calculate Effective Permissions for.';
    text16016311L : TextConst ENU='User ''%1'' cannot be found in the User Security system.',ENA='User ''%1'' cannot be found in the User Security system.';
    user : Record 2000000120;
    access : Record 2000000053;
    permSet : Record 2000000004;
    permission : Record 2000000005;
    permission2 : Record 2000000005;
    permFilter : Text;
    text16016312L : TextConst ENU='''''|%1',ENA='''''|%1';
    "field" : Record 2000000041;
    tableRead : Boolean;
    tableModify : Boolean;
    text16016313L : TextConst ENU='None',ENA='None';
    text16016314L : TextConst ENU='Yes',ENA='Yes';
    text16016315L : TextConst ENU='Indirect',ENA='Indirect';
    tableIndirectRead : Boolean;
    tableIndirectModify : Boolean;
    secField : Record 70018011;
    handler : Record 70018002;
    text16016316L : TextConst ENU='License',ENA='License';
    text16016317L : TextConst ENU='Permission Set',ENA='Permission Set';
    text16016318L : TextConst ENU='SupplyPoint Security',ENA='SupplyPoint Security';
    secMgt : Codeunit 70018005;
    text16016319L : TextConst ENU='No - SupplyPoint Security',ENA='No - SupplyPoint Security';
    tablePerm : Record 70018013;
  begin
    IF COUNT > 0 THEN BEGIN
      CurrPage.UPDATE(TRUE);
      RESET;
      DELETEALL;
    END;

    xRec := Rec;
    COMMIT;

    CurrPage.UPDATE(FALSE);

    IF currentUserID = '' THEN
      ERROR(text16016310L);

    user.SETRANGE("User Name", currentUserID);
    IF NOT user.FINDFIRST THEN
      ERROR(STRSUBSTNO(text16016311L, currentUserID));

    // Build the list of permission sets the user belongs to
    permFilter := '';
    access.SETRANGE("User Security ID", user."User Security ID");
    access.SETFILTER("Company Name", STRSUBSTNO(text16016312L, COMPANYNAME));
    IF access.FINDSET THEN REPEAT
      IF permFilter = '' THEN
        permFilter := access."Role ID"
      ELSE
        permFilter := permFilter + '|' + access."Role ID";
    UNTIL access.NEXT = 0;

    // First do the Table permissions from the permission set
    permission.SETRANGE("Object Type", permission."Object Type"::Table);
    permission.SETRANGE("Object ID", tableNo);
    permission.SETFILTER("Role ID", permFilter);
    IF NOT permission.FINDFIRST THEN
      permission.SETRANGE("Object ID", 0);

    permission2.SETRANGE("Object Type", permission."Object Type"::"Table Data");
    permission2.SETRANGE("Object ID", tableNo);
    permission2.SETFILTER("Role ID", permFilter);
    IF NOT permission2.FINDFIRST THEN
      permission2.SETRANGE("Object ID", 0);

    IF NOT (permission.FINDFIRST OR permission2.FINDFIRST) THEN BEGIN
      INIT;
      "Table No." := tableNo;
      "Field No." := 0;
      readPerm := text16016313L;
      insertPerm := text16016313L;
      modifyPerm := text16016313L;
      deletePerm := text16016313L;
      IF NOT CheckTableLicense(tableNo) THEN
        controlStatus := text16016316L
      ELSE
        controlStatus := text16016317L;
      Rec.INSERT;
      EXIT;
    END;

    controlStatus := text16016317L;
    INIT;
    "Table No." := tableNo;
    "Field No." := 0;
    "Direct Read" := ConvertTablePermission(permission."Read Permission", permission2."Read Permission");
    "Direct Insert" := ConvertTablePermission(permission."Insert Permission", permission2."Insert Permission");
    "Direct Modify" := ConvertTablePermission(permission."Modify Permission", permission2."Modify Permission");
    "Direct Delete" := ConvertTablePermission(permission."Delete Permission", permission2."Delete Permission");
    "Indirect Read" := ConvertTableIndirectPermission(permission."Read Permission", permission2."Read Permission");
    "Indirect Insert" := ConvertTableIndirectPermission(permission."Insert Permission", permission2."Insert Permission");
    "Indirect Modify" := ConvertTableIndirectPermission(permission."Modify Permission", permission2."Modify Permission");
    "Indirect Delete" := ConvertTableIndirectPermission(permission."Delete Permission", permission2."Delete Permission");
    INSERT;

    IF "Direct Read" THEN
      readPerm := text16016314L
    ELSE BEGIN
      IF "Indirect Read" THEN
        readPerm := text16016315L
      ELSE
        readPerm := text16016313L;
    END;

    IF "Direct Insert" THEN
      insertPerm := text16016314L
    ELSE BEGIN
      IF "Indirect Insert" THEN
        insertPerm := text16016315L
      ELSE
        insertPerm := text16016313L;
    END;

    IF "Direct Modify" THEN
      modifyPerm := text16016314L
    ELSE BEGIN
      IF "Indirect Modify" THEN
        modifyPerm := text16016315L
      ELSE
        modifyPerm := text16016313L;
    END;

    IF "Direct Delete" THEN
      deletePerm := text16016314L
    ELSE BEGIN
      IF "Indirect Delete" THEN
        deletePerm := text16016315L
      ELSE
        deletePerm := text16016313L;
    END;

    IF tablePerm.GET(processorCode, handlerCode) THEN BEGIN
      IF NOT secMgt.CanChangeTable(currentUserID, tablePerm."Permit Insert User Group Code", tablePerm."Deny Insert User Group Code") THEN BEGIN
        "Direct Insert" := FALSE;
        "Indirect Insert" := FALSE;
        insertPerm := text16016319L
      END;
      IF NOT secMgt.CanChangeTable(currentUserID, tablePerm."Permit Modify User Group Code", tablePerm."Deny Modify User Group Code") THEN BEGIN
        "Direct Modify" := FALSE;
        "Indirect Modify" := FALSE;
        modifyPerm := text16016319L
      END;
      IF NOT secMgt.CanChangeTable(currentUserID, tablePerm."Permit Delete User Group Code", tablePerm."Deny Delete User Group Code") THEN BEGIN
        "Direct Delete" := FALSE;
        "Indirect Delete" := FALSE;
        deletePerm := text16016319L
      END;
    END;

    tableRead := "Direct Read";
    tableModify := "Direct Modify";
    tableIndirectRead := "Indirect Read";
    tableIndirectModify := "Indirect Modify";

    // Insert All the Fields with the setting from the Table
    field.SETRANGE(TableNo, tableNo);
    IF field.FINDSET THEN REPEAT
      INIT;
      "Table No." := tableNo;
      "Field No." := field."No.";
      "Field Name" := field.FieldName;
      "Direct Read" := tableRead;
      "Direct Modify" := tableModify;
      "Indirect Read" := NOT tableRead AND tableIndirectRead;
      "Indirect Modify" := NOT tableIndirectModify AND tableIndirectModify;
      "Issued By" := "Issued By"::"Permission Set";
      Visible := TRUE;
      INSERT;
    UNTIL field.NEXT = 0;

    // Now update based on Field Security
    handler.SETRANGE("Processor Code", processorCode);
    handler.SETRANGE(Code, handlerCode);
    IF NOT handler.FINDFIRST THEN
      EXIT;

    secField.SETRANGE("Processor Code", handler."Processor Code");
    secField.SETRANGE("Handler Code", handler.Code);
    secField.SETRANGE("Table No.", tableNo);
    RESET;
    SETRANGE("Table No.", tableNo);
    IF secField.FINDSET THEN BEGIN
      controlStatus := text16016318L;
      REPEAT
        SETRANGE("Field No.", secField."Field No.");
        IF FINDFIRST THEN BEGIN
          "SupplyPoint Controlled" := TRUE;
          "Issued By" := "Issued By"::"SupplyPoint Security";
          IF NOT secMgt.CanChangeField(currentUserID, secField) THEN
            "Direct Modify" := FALSE;
          MODIFY;
        END;
      UNTIL secField.NEXT = 0;
    END;

    RESET;
    SETRANGE("Table No.", tableNo);
    SETFILTER("Field No.", '>0');
    FINDFIRST;
    CurrPage.UPDATE;
  end;

  local procedure ConvertTablePermission(tablePermission : Integer;tableDataPermission : Integer) : Boolean;
  begin
    CASE tablePermission OF
      0 : BEGIN
          CASE tableDataPermission OF
            0 : EXIT(FALSE);
            1 : EXIT(FALSE);
            2 : EXIT(FALSE);
          END;
        END;
      1 : BEGIN
          CASE tableDataPermission OF
            0 : EXIT(FALSE);
            1 : EXIT(TRUE);
            2 : EXIT(FALSE);
          END;
        END;
      2 : BEGIN
          CASE tableDataPermission OF
            0 : EXIT(FALSE);
            1 : EXIT(FALSE);
            2 : EXIT(FALSE);
          END;
        END;
    END;
  end;

  local procedure ConvertTableIndirectPermission(tablePermission : Integer;tableDataPermission : Integer) : Boolean;
  begin
    CASE tablePermission OF
      0 : BEGIN
          CASE tableDataPermission OF
            0 : EXIT(FALSE);
            1 : EXIT(FALSE);
            2 : EXIT(FALSE);
          END;
        END;
      1 : BEGIN
          CASE tableDataPermission OF
            0 : EXIT(FALSE);
            1 : EXIT(TRUE);
            2 : EXIT(TRUE);
          END;
        END;
      2 : BEGIN
          CASE tableDataPermission OF
            0 : EXIT(FALSE);
            1 : EXIT(TRUE);
            2 : EXIT(TRUE);
          END;
        END;
    END;
  end;

  local procedure CheckTableLicense(tableNo : Integer) : Boolean;
  var
    licensePermission : Record 2000000043;
  begin
    licensePermission.SETRANGE("Object Type", licensePermission."Object Type"::Table);
    licensePermission.SETRANGE("Object Number", tableNo);
    licensePermission.SETFILTER("Modify Permission",'<>%1', licensePermission."Modify Permission"::" ");
    IF licensePermission.COUNT > 0 THEN
      EXIT(TRUE)
    ELSE
      EXIT(FALSE);
  end;

  local procedure ResetPage();
  begin
    IF COUNT > 0 THEN
      CurrPage.UPDATE(TRUE);
    RESET;
    DELETEALL;
    controlStatus := '';
    readPerm := '';
    insertPerm := '';
    modifyPerm := '';
    deletePerm := '';
    CurrPage.UPDATE(FALSE);
  end;
}


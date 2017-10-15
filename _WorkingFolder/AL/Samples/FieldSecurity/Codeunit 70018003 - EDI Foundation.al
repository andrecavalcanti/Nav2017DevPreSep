codeunit 70018003 "EDI Foundation"
{
  // version FLS1.00

  // ECLIPSE - SupplyPoint (ECSP)
  // ----------------------------
  //   ECSP2.00j


  trigger OnRun();
  begin
  end;

  var
    "3TierMgt" : Codeunit 419;
    ediType : Record 70018009;
    ediEvent : Record 70018008;
    spointFoundation : Codeunit 70018008;
    gotSetup : Boolean;
    ediSetup : Record 70018000;

  procedure CheckTableExists(tableNo : Integer) : Boolean;
  var
    AllObjWithCaption : Record 2000000058;
  begin
    AllObjWithCaption.SETRANGE("Object Type", AllObjWithCaption."Object Type"::Table);
    AllObjWithCaption.SETRANGE("Object ID", tableNo);
    IF AllObjWithCaption.FINDFIRST THEN
      EXIT(TRUE)
    ELSE
      EXIT(FALSE);
  end;

  procedure GetTableFieldNos(tableNo : Integer) : Text[100];
  var
    "field" : Record 2000000041;
    working : Text[1024];
  begin
    working := '';
    field.SETRANGE(TableNo, tableNo);
    IF field.FINDSET THEN REPEAT
      IF IsFieldKey(tableNo, field."Field Caption") THEN BEGIN
        IF working = '' THEN
          working := FORMAT(field."No.")
        ELSE
          working := working + ',' + FORMAT(field."No.");
      END;
    UNTIL field.NEXT = 0;
    EXIT(working);
  end;

  procedure IsFieldKey(tableNo : Integer;fieldName : Text[50]) : Boolean;
  var
    "key" : Record 2000000063;
    check : Text[50];
    pos : Integer;
    preCheck : Text[1];
    postCheck : Text[1];
    working : Text;
    exitLoop : Boolean;
  begin
    key.SETRANGE(TableNo, tableNo);
    key.SETRANGE("No.", 1);
    IF NOT key.FINDFIRST THEN
      EXIT(FALSE);

    working := key.Key;

    REPEAT
      pos := STRPOS(working, fieldName);
      IF pos > 0 THEN BEGIN
        IF pos = 1 THEN BEGIN
          postCheck := COPYSTR(working, pos + STRLEN(fieldName), 1);
          IF (postCheck = '') OR (postCheck = ',') THEN
            EXIT(TRUE)
          ELSE
            EXIT(FALSE);
        END;

        check := COPYSTR(working, pos, STRLEN(fieldName));
        preCheck := COPYSTR(working, pos - 1, 1);
        postCheck := COPYSTR(working, pos + STRLEN(fieldName), 1);
        IF (check = fieldName) THEN BEGIN
          IF ((preCheck = '') OR (preCheck = ',')) AND ((postCheck = '') OR (postCheck = ',')) THEN
            EXIT(TRUE)
          ELSE BEGIN
            working := COPYSTR(working, pos + STRLEN(fieldName) + 1);
            IF STRPOS(working, fieldName) < 1 THEN BEGIN
              exitLoop := TRUE;
              EXIT(FALSE);
            END;
          END;
        END ELSE BEGIN
          exitLoop := TRUE;
          EXIT(FALSE);
        END;
      END ELSE BEGIN
        exitLoop := TRUE;
        EXIT(FALSE);
      END;
    UNTIL exitLoop;
  end;

  procedure InitialiseSqlTableDataSet(ruleCode : Code[20];tableNo : Integer;keepOldSet : Boolean) : Integer;
  var
    ediField : Record 70018003;
    tableName : ARRAY [10] OF Text[50];
    oldFields : Record 70018003 TEMPORARY;
    AllObjWithCaption : Record 2000000058;
  begin
    IF keepOldSet THEN BEGIN
      oldFields.RESET;
      oldFields.DELETEALL;
      ediField.SETRANGE("Rule Code", ruleCode);
      IF ediField.FINDSET THEN REPEAT
        oldFields.COPY(ediField);
        oldFields.INSERT;
      UNTIL ediField.NEXT = 0;
    END;

    ediField.RESET;
    ediField.SETRANGE("Rule Code", ruleCode);
    ediField.DELETEALL;
    ediField.RESET;
    AllObjWithCaption.SETRANGE("Object Type", AllObjWithCaption."Object Type"::Table);
    AllObjWithCaption.SETRANGE("Object ID", tableNo);
    IF AllObjWithCaption.FINDFIRST THEN
      ediField.InitialiseTable(ruleCode, 0, tableNo, AllObjWithCaption."Object Name", 0, 0, 0, oldFields);
  end;

  procedure LookupSource(direction : Integer;type : Integer;currentSourceId : Integer) : Integer;
  var
    objectPage : Page 70018000;
    text16016312L : TextConst ENU='You must select a Type before selecting a Source',ENA='You must select a Type before selecting a Source';
    text16016313L : TextConst ENU='''''|%1',ENA='''''|%1';
    AllObjWithCaption : Record 2000000058;
  begin
    IF type = 0 THEN
      ERROR(text16016312L);

    //AllObjWithCaption.SETCURRENTKEY("Object Type","Company Name",ID);
    AllObjWithCaption.SETCURRENTKEY("Object Type","Object ID");
    AllObjWithCaption.RESET;
    AllObjWithCaption.SETRANGE("Object Type", AllObjWithCaption."Object Type"::Table);
    //AllObjWithCaption.SETFILTER("Company Name", STRSUBSTNO(text16016313L, COMPANYNAME));
    AllObjWithCaption.SETRANGE("Object ID", currentSourceId);
    IF AllObjWithCaption.FINDFIRST THEN
      objectPage.SETRECORD(AllObjWithCaption);
    AllObjWithCaption.SETRANGE("Object ID");
    objectPage.SETTABLEVIEW(AllObjWithCaption);
    objectPage.LOOKUPMODE := TRUE;
    IF objectPage.RUNMODAL = ACTION::LookupOK THEN BEGIN
      objectPage.GETRECORD(AllObjWithCaption);
      EXIT(AllObjWithCaption."Object ID")
    END ELSE
      EXIT(currentSourceId);
  end;

  procedure CheckSource(direction : Integer;type : Integer;data : Text) : Integer;
  var
    text16016310L : TextConst ENU='%1*',ENA='%1*';
    text16016311L : TextConst ENU='The value ''%1'' is not a valid Source',ENA='The value ''%1'' is not a valid Source';
    ediHandler : Record 70018002;
    obj : Record 2000000001;
    text16016312L : TextConst ENU='You must select a Type before selecting a Source',ENA='You must select a Type before selecting a Source';
    text16016313L : TextConst ENU='''''|%1',ENA='''''|%1';
    AllObjWithCaption : Record 2000000058;
  begin
    IF type = 0 THEN
      ERROR(text16016312L);

    IF data = '' THEN
      EXIT(0);

    AllObjWithCaption.RESET;
    AllObjWithCaption.SETRANGE("Object Type", AllObjWithCaption."Object Type"::Table);
    //AllObjWithCaption.SETFILTER("Company Name", STRSUBSTNO(text16016313L, COMPANYNAME));
    AllObjWithCaption.SETFILTER("Object Name", STRSUBSTNO(text16016310L, data));
    IF AllObjWithCaption.FINDFIRST THEN
      EXIT(AllObjWithCaption."Object ID")
    ELSE
      ERROR(text16016311L, data);
  end;

  procedure CheckEvent(type : Integer;source : Integer;data : Text) : Integer;
  var
    ediEvent : Record 70018008;
    text16016310L : TextConst ENU='%1*',ENA='%1*';
    text16016311L : TextConst ENU='The value ''%1'' is not a valid Event',ENA='The value ''%1'' is not a valid Event';
  begin
    IF data = '' THEN
      EXIT(0);
    ediEvent.RESET;
    ediEvent.SETFILTER("Event Name", STRSUBSTNO(text16016310L, data));
    IF type = ediType.Type_Table THEN
      ediEvent.SETFILTER("Event Id", '0|1|2|3|4|10|20');
    IF ediEvent.FINDFIRST THEN
      EXIT(ediEvent."Event Id")
    ELSE
      ERROR(text16016311L, data);
  end;

  procedure SyncEDISecurityTables(showMessage : Boolean;calledFromSecurity : Boolean;calledFromInitialisation : Boolean);
  var
    "table" : Record 70018010;
    text16016310L : TextConst ENU='The %1 Tables have been synchronised.\ \The change will not take effect until you close all sessions and restart your Dynamics NAV client.',ENA='The %1 Tables have been synchronised.\ \The change will not take effect until you close all sessions and restart your Dynamics NAV client.';
    text16016311L : TextConst ENU='EDI / Workflow',ENA='EDI / Workflow';
    text16016312L : TextConst ENU='Security',ENA='Security';
    handler : Record 70018002;
    tempTable : Record 70018010 TEMPORARY;
  begin
    tempTable.RESET;
    tempTable.DELETEALL;

    table.RESET;
    IF table.FINDSET THEN REPEAT
      tempTable.COPY(table);
      tempTable.INSERT;
    UNTIL table.NEXT = 0;

    table.DELETEALL;
    table.RESET;
    table.SETAUTOCALCFIELDS("Table Name");

    handler.RESET;
    handler.SETRANGE(Direction, handler.Direction::Security);
    handler.SETFILTER("Table No.", '>0');
    IF handler.FINDSET THEN REPEAT
      IF handler."Table No." > 0 THEN BEGIN
        IF NOT table.GET(handler."Table No.") THEN BEGIN
          table.INIT;
          table.VALIDATE("Table No.", handler."Table No.");
          table."Parent Table No." := 0;
          table."Change Trigger" := TRUE;
          table."Field Trigger" := TRUE;
          table."Action Trigger" := FALSE;
          table.INSERT;
        END;
      END;
    UNTIL handler.NEXT = 0;

    IF NOT calledFromInitialisation THEN BEGIN
      // Finally restore any custom config already done.
      table.RESET;
      IF table.FINDSET THEN REPEAT
        IF tempTable.GET(table."Table No.") THEN BEGIN
          table."Change Trigger" := tempTable."Change Trigger";
          table."Field Trigger" := tempTable."Field Trigger";
          table."Action Trigger" := tempTable."Action Trigger";
          table.MODIFY;
        END;
      UNTIL table.NEXT = 0;
    END;

    IF GUIALLOWED AND showMessage THEN
      MESSAGE(STRSUBSTNO(text16016310L, text16016312L))
  end;

  local procedure GetSetup();
  begin
    IF gotSetup THEN
      EXIT;

    gotSetup := ediSetup.GET;
  end;

  procedure CheckUserBelongsToGroup(groupCode : Code[250]) : Boolean;
  var
    ediUser : Record 70018006;
  begin
    IF STRLEN(groupCode) > 10 THEN
      EXIT(FALSE);
    ediUser.SETRANGE("User ID", USERID);
    ediUser.SETRANGE("Workflow Group Code", groupCode);
    IF NOT ediUser.FINDFIRST THEN
      EXIT(FALSE)
    ELSE
      EXIT(TRUE);
  end;

  procedure LookupSecurityUserGroup(currentCode : Code[20]) : Code[20];
  var
    userGrp : Record 70018005;
    grpPage : Page 70018008;
  begin
    IF currentCode <> '' THEN BEGIN
      userGrp.SETRANGE(Code, currentCode);
      IF userGrp.FINDFIRST THEN
        grpPage.SETRECORD(userGrp);
    END;
    userGrp.RESET;
    grpPage.LOOKUPMODE := TRUE;
    IF grpPage.RUNMODAL = ACTION::LookupOK THEN BEGIN
      grpPage.GETRECORD(userGrp);
      EXIT(userGrp.Code);
    END ELSE
      EXIT(currentCode);
  end;
}


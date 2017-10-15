codeunit 70018005 "EDI Security Mgt."
{
  // version FLS1.00

  // ECLIPSE - SupplyPoint (ECSP)
  // ----------------------------
  //   ECSP2.00j


  trigger OnRun();
  begin
  end;

  var
    spointEdiMgt : Codeunit 70018007;
    recRefMaster : RecordRef;
    oldRecRefMaster : RecordRef;
    ediFoundation : Codeunit 70018003;
    ediHandler : Record 70018002;
    ediEvent : Record 70018008;
    ediType : Record 70018009;
    gotEdiSetup : Boolean;
    tablePerm : Record 70018013;
    permitTableCode : Code[10];
    denyTableCode : Code[10];
    isFieldCheck : Boolean;
    fieldNoToCheck : Integer;

  procedure RecordHandler(refOldRecord : RecordRef;refRecord : RecordRef;eventType : Integer);
  var
    messId : Integer;
    sourceValue : Integer;
    fldRef : FieldRef;
    fldRef2 : FieldRef;
    fldRef3 : FieldRef;
    fld1KeyReq : Boolean;
    fld2KeyReq : Boolean;
    fld3KeyReq : Boolean;
    fldSubRef : FieldRef;
    fldSubRef2 : FieldRef;
    fldSubRef3 : FieldRef;
    optionValue : Integer;
    vntRecord : Variant;
    indentation : ARRAY [10] OF Integer;
    sortSequence : ARRAY [10] OF Integer;
    currentDirection : Option Security,Outbound,,Workflow,"Table",STOP;
  begin
    IF NOT IsSecurityActive THEN
      EXIT;

    isFieldCheck := FALSE;
    fieldNoToCheck := 0;

    oldRecRefMaster := refOldRecord;
    recRefMaster := refRecord;

    ediHandler.SETRANGE("Event", ediEvent.Event_FieldChange);
    ediHandler.SETRANGE(Direction, ediHandler.Direction::Security);
    ediHandler.SETRANGE(Type, ediType.Type_Table);
    ediHandler.SETRANGE(Active, TRUE);
    ediHandler.SETRANGE("Table No.", recRefMaster.NUMBER);

    IF ediHandler.FINDSET THEN BEGIN
      IF NOT ediEvent.GET(eventType) THEN
        EXIT;
      REPEAT
        IF CheckHandlerRequired THEN BEGIN
          CheckSecurity;
        END;
      UNTIL ediHandler.NEXT = 0;
    END;
  end;

  procedure FieldHandler(refOldRecord : RecordRef;refRecord : RecordRef;fieldNo : Integer);
  var
    messId : Integer;
    sourceValue : Integer;
    fldRef : FieldRef;
    fldRef2 : FieldRef;
    fldRef3 : FieldRef;
    fld1KeyReq : Boolean;
    fld2KeyReq : Boolean;
    fld3KeyReq : Boolean;
    fldSubRef : FieldRef;
    fldSubRef2 : FieldRef;
    fldSubRef3 : FieldRef;
    optionValue : Integer;
    vntRecord : Variant;
    indentation : ARRAY [10] OF Integer;
    sortSequence : ARRAY [10] OF Integer;
    currentDirection : Option Security,Outbound,,Workflow,"Table",STOP;
  begin
    IF NOT IsSecurityActive THEN
      EXIT;

    oldRecRefMaster := refOldRecord;
    recRefMaster := refRecord;

    ediHandler.SETRANGE("Event", ediEvent.Event_FieldChange);
    ediHandler.SETRANGE(Direction, ediHandler.Direction::Security);
    ediHandler.SETRANGE(Type, ediType.Type_Table);
    ediHandler.SETRANGE(Active, TRUE);
    ediHandler.SETRANGE("Table No.", recRefMaster.NUMBER);

    IF ediHandler.FINDSET THEN BEGIN
      IF NOT ediEvent.GET(ediEvent.Event_Modify) THEN
        EXIT;
      isFieldCheck := TRUE;
      fieldNoToCheck := fieldNo;
      REPEAT
        IF CheckHandlerRequired THEN BEGIN
          CheckSecurity;
        END;
      UNTIL ediHandler.NEXT = 0;
    END;
  end;

  local procedure CheckHandlerRequired() : Boolean;
  var
    requiresTableCheck : Boolean;
  begin
    permitTableCode := '';
    denyTableCode := '';
    requiresTableCheck := FALSE;

    IF tablePerm.GET(ediHandler."Processor Code", ediHandler.Code) THEN BEGIN
      CASE ediEvent."Event Id" OF
        1 : BEGIN // Insert
            permitTableCode := tablePerm."Permit Insert User Group Code";
            denyTableCode := tablePerm."Deny Insert User Group Code";
          END;
        2 : BEGIN // Modify
            permitTableCode := tablePerm."Permit Modify User Group Code";
            denyTableCode := tablePerm."Deny Modify User Group Code";
          END;
        3 : BEGIN // Delete
            permitTableCode := tablePerm."Permit Delete User Group Code";
            denyTableCode := tablePerm."Deny Delete User Group Code";
          END;
      END;
    END;

    IF (permitTableCode <> '') OR (denyTableCode <> '') THEN
      requiresTableCheck := TRUE;

    IF NOT CheckFieldChange AND NOT requiresTableCheck THEN
      EXIT(FALSE);

    IF NOT CheckFieldAssessmentFilter THEN
      EXIT(FALSE);

    EXIT(TRUE);
  end;

  local procedure CheckFieldChange() : Boolean;
  var
    fldRef : FieldRef;
    fldRefOld : FieldRef;
    fieldMonitor : Record 70018011;
  begin
    fieldMonitor.SETRANGE("Processor Code", ediHandler."Processor Code");
    fieldMonitor.SETRANGE("Handler Code", ediHandler.Code);
    IF fieldMonitor.FINDSET THEN REPEAT
      IF fieldMonitor."Field No." > 0 THEN BEGIN
        fldRef := recRefMaster.FIELD(fieldMonitor."Field No.");
        fldRefOld := oldRecRefMaster.FIELD(fieldMonitor."Field No.");
        IF FORMAT(fldRef) <> FORMAT(fldRefOld) THEN
          EXIT(TRUE);
      END;
    UNTIL fieldMonitor.NEXT = 0;
    EXIT(FALSE);
  end;

  local procedure CheckFieldAssessmentFilter() : Boolean;
  var
    ediFieldCheck : Record 70018003;
    fldRef : FieldRef;
    recRefCheck : RecordRef;
  begin
    IF ediHandler."Assessment Filter" = '' THEN
      EXIT(TRUE);

    ediFieldCheck.SETAUTOCALCFIELDS("Multi Language Set");
    ediFieldCheck.SETRANGE("Rule Code", ediHandler."Assessment Filter");
    ediFieldCheck.SETRANGE("Table No.", recRefMaster.NUMBER);
    ediFieldCheck.SETRANGE(Active, TRUE);
    ediFieldCheck.SETFILTER("Field No.", '>0');
    IF ediFieldCheck.ISEMPTY THEN
      EXIT(TRUE);

    IF ediFieldCheck.FINDSET THEN BEGIN
      recRefCheck := recRefMaster.DUPLICATE;
      IF NOT ApplyFieldAssessmentKeyFilters(recRefCheck) THEN
        EXIT(TRUE);
      REPEAT
        fldRef := recRefMaster.FIELD(ediFieldCheck."Field No.");
        IF NOT CheckFieldAssessmentField(fldRef, ediFieldCheck, recRefCheck) THEN
          EXIT(FALSE);
      UNTIL ediFieldCheck.NEXT = 0;
    END;

    EXIT(TRUE);
  end;

  local procedure CheckFieldAssessmentField(fldRef : FieldRef;"field" : Record 70018003;recRefCheck : RecordRef) : Boolean;
  var
    recRef : RecordRef;
    recRef2 : RecordRef;
    fldRef2 : FieldRef;
    booleanValue : Boolean;
    booleanTextValue : Text[30];
    multiLangField : Record 70018007;
  begin
    IF field."Multi Language Set" THEN BEGIN
      multiLangField.SETCURRENTKEY("Rule Code", "Table No.", "Field No.", "Windows Language ID");
      multiLangField.SETRANGE("Rule Code", field."Rule Code");
      multiLangField.SETRANGE("Table No.", field."Table No.");
      multiLangField.SETRANGE("Field No.", field."Field No.");
      multiLangField.SETRANGE("Windows Language ID", GLOBALLANGUAGE);
      IF NOT multiLangField.FINDFIRST THEN BEGIN
        multiLangField.INIT;
        multiLangField.Filter := field.Filter;
      END;
    END ELSE BEGIN
      multiLangField.INIT;
      multiLangField.Filter := field.Filter;
    END;

    CASE field."Data Type" OF
      field."Data Type"::Boolean : BEGIN
          booleanTextValue := FORMAT(fldRef);
          IF (booleanTextValue = '1') OR (UPPERCASE(booleanTextValue) = 'YES') OR (UPPERCASE(booleanTextValue) = 'TRUE') THEN
            booleanValue := TRUE
          ELSE
            booleanValue := FALSE;
          IF multiLangField.Filter <> '' THEN BEGIN
            IF (multiLangField.Filter = '1') OR (UPPERCASE(multiLangField.Filter) = 'YES') OR (UPPERCASE(multiLangField.Filter) = 'TRUE') THEN BEGIN
              IF NOT booleanValue THEN
                EXIT(FALSE);
            END ELSE BEGIN
              IF booleanValue THEN
                EXIT(FALSE);
            END;
          END;
        END;
      field."Data Type"::String : BEGIN
          IF multiLangField.Filter <> '' THEN BEGIN
            fldRef2 := recRefCheck.FIELD(fldRef.NUMBER);
            fldRef2.SETFILTER(multiLangField.Filter);
            IF NOT recRefCheck.FINDFIRST THEN
              EXIT(FALSE);
            fldRef2.SETRANGE;
          END;
        END;
      field."Data Type"::Option : BEGIN
          IF multiLangField.Filter <> '' THEN BEGIN
            fldRef2 := recRefCheck.FIELD(fldRef.NUMBER);
            fldRef2.SETFILTER(multiLangField.Filter);
            IF NOT recRefCheck.FINDFIRST THEN
              EXIT(FALSE);
            fldRef2.SETRANGE;
          END;
        END;
      field."Data Type"::Decimal : BEGIN
          IF multiLangField.Filter <> '' THEN BEGIN
            fldRef2 := recRefCheck.FIELD(fldRef.NUMBER);
            fldRef2.SETFILTER(multiLangField.Filter);
            IF NOT recRefCheck.FINDFIRST THEN
              EXIT(FALSE);
            fldRef2.SETRANGE;
          END;
        END;
      field."Data Type"::Integer : BEGIN
          IF multiLangField.Filter <> '' THEN BEGIN
            fldRef2 := recRefCheck.FIELD(fldRef.NUMBER);
            fldRef2.SETFILTER(multiLangField.Filter);
            IF NOT recRefCheck.FINDFIRST THEN
              EXIT(FALSE);
            fldRef2.SETRANGE;
          END;
        END;
      field."Data Type"::Date : BEGIN
          IF multiLangField.Filter <> '' THEN BEGIN
            fldRef2 := recRefCheck.FIELD(fldRef.NUMBER);
            fldRef2.SETFILTER(multiLangField.Filter);
            IF NOT recRefCheck.FINDFIRST THEN
              EXIT(FALSE);
            fldRef2.SETRANGE;
          END;
        END;
      field."Data Type"::DateTime : BEGIN
          IF multiLangField.Filter <> '' THEN BEGIN
            fldRef2 := recRefCheck.FIELD(fldRef.NUMBER);
            fldRef2.SETFILTER(multiLangField.Filter);
            IF NOT recRefCheck.FINDFIRST THEN
              EXIT(FALSE);
            fldRef2.SETRANGE;
          END;
        END;
      field."Data Type"::Time : BEGIN
          IF multiLangField.Filter <> '' THEN BEGIN
            fldRef2 := recRefCheck.FIELD(fldRef.NUMBER);
            fldRef2.SETFILTER(multiLangField.Filter);
            IF NOT recRefCheck.FINDFIRST THEN
              EXIT(FALSE);
            fldRef2.SETRANGE;
          END;
        END;
    END;
    EXIT(TRUE);
  end;

  local procedure ApplyFieldAssessmentKeyFilters(var recRefCheck : RecordRef) : Boolean;
  var
    ediTable : Record 70018010;
    fldRef1 : FieldRef;
    fldRef2 : FieldRef;
    fldRef3 : FieldRef;
    fldRef4 : FieldRef;
    fldRef5 : FieldRef;
    fldRef6 : FieldRef;
    fldRef7 : FieldRef;
    fldRef8 : FieldRef;
    fldRef9 : FieldRef;
    fldRef10 : FieldRef;
  begin
    IF NOT ediTable.GET(recRefMaster.NUMBER) THEN
      EXIT(FALSE);

    IF (ediTable."Key Field No. 1" > 0) THEN BEGIN
      fldRef1 := recRefCheck.FIELD(ediTable."Key Field No. 1");
      fldRef1.SETRANGE(fldRef1.VALUE);
    END;
    IF (ediTable."Key Field No. 2" > 0) THEN BEGIN
      fldRef2 := recRefCheck.FIELD(ediTable."Key Field No. 2");
      fldRef2.SETRANGE(fldRef2.VALUE);
    END;
    IF (ediTable."Key Field No. 3" > 0) THEN BEGIN
      fldRef3 := recRefCheck.FIELD(ediTable."Key Field No. 3");
      fldRef3.SETRANGE(fldRef3.VALUE);
    END;
    IF (ediTable."Key Field No. 4" > 0) THEN BEGIN
      fldRef4 := recRefCheck.FIELD(ediTable."Key Field No. 4");
      fldRef4.SETRANGE(fldRef4.VALUE);
    END;
    IF (ediTable."Key Field No. 5" > 0) THEN BEGIN
      fldRef5 := recRefCheck.FIELD(ediTable."Key Field No. 5");
      fldRef5.SETRANGE(fldRef5.VALUE);
    END;
    IF (ediTable."Key Field No. 6" > 0) THEN BEGIN
      fldRef6 := recRefCheck.FIELD(ediTable."Key Field No. 6");
      fldRef6.SETRANGE(fldRef6.VALUE);
    END;
    IF (ediTable."Key Field No. 7" > 0) THEN BEGIN
      fldRef7 := recRefCheck.FIELD(ediTable."Key Field No. 7");
      fldRef7.SETRANGE(fldRef7.VALUE);
    END;
    IF (ediTable."Key Field No. 8" > 0) THEN BEGIN
      fldRef8 := recRefCheck.FIELD(ediTable."Key Field No. 8");
      fldRef8.SETRANGE(fldRef8.VALUE);
    END;
    IF (ediTable."Key Field No. 9" > 0) THEN BEGIN
      fldRef9 := recRefCheck.FIELD(ediTable."Key Field No. 9");
      fldRef9.SETRANGE(fldRef9.VALUE);
    END;
    IF (ediTable."Key Field No. 10" > 0) THEN BEGIN
      fldRef10 := recRefCheck.FIELD(ediTable."Key Field No. 10");
      fldRef10.SETRANGE(fldRef10.VALUE);
    END;
    EXIT(TRUE);
  end;

  local procedure CheckSecurity();
  var
    fldRef : FieldRef;
    fldRefOld : FieldRef;
    fieldMonitor : Record 70018011;
    ediUsers : Record 70018006;
    text16016310L : TextConst ENU='Field ''%1'' has been configured to prevent you from changing the current value because you are a member of the ''%2'' Group.',ENA='Field ''%1'' has been configured to prevent you from changing the current value because you are a member of the ''%2'' Group.';
    text16016311L : TextConst ENU='Field ''%1'' has been configured to require membership of the ''%2'' Group to permit changes.',ENA='Field ''%1'' has been configured to require membership of the ''%2'' Group to permit changes.';
    text16016312L : TextConst ENU='The record has not been %1 because Table ''%2'' has been configured to prevent this because you are a member of the ''%3'' Group.',ENA='The record has not been %1 because Table ''%2'' has been configured to prevent this because you are a member of the ''%3'' Group.';
    text16016313L : TextConst ENU='The record has not been %1 because Table ''%2'' has been configured to require membership of the ''%3'' Group to permit this activity.',ENA='The record has not been %1 because Table ''%2'' has been configured to require membership of the ''%3'' Group to permit this activity.';
  begin
    // First make sure we are not permitted to ignore security
    ediUsers.SETRANGE("User ID", USERID);
    ediUsers.SETRANGE("Allow Override Field Security", TRUE);
    IF NOT ediUsers.ISEMPTY THEN
      EXIT;

    ediUsers.RESET;
    ediUsers.SETRANGE("User ID", USERID);

    // First Check Table Level Security
    IF denyTableCode <> '' THEN BEGIN
      ediUsers.SETRANGE("Workflow Group Code", denyTableCode);
      IF NOT ediUsers.ISEMPTY THEN
        ERROR(STRSUBSTNO(text16016312L, ediEvent."Past Tense", ediHandler."Source Name", denyTableCode));
    END;
    IF permitTableCode <> '' THEN BEGIN
      ediUsers.SETRANGE("Workflow Group Code", permitTableCode);
      IF ediUsers.ISEMPTY THEN
        ERROR(STRSUBSTNO(text16016313L, ediEvent."Past Tense", ediHandler."Source Name", permitTableCode));
    END;

    fieldMonitor.SETRANGE("Processor Code", ediHandler."Processor Code");
    fieldMonitor.SETRANGE("Handler Code", ediHandler.Code);
    IF isFieldCheck THEN
      fieldMonitor.SETRANGE("Field No.", fieldNoToCheck)
    ELSE
      fieldMonitor.SETRANGE("Field No.");

    IF fieldMonitor.FINDSET THEN REPEAT
      IF fieldMonitor."Field No." > 0 THEN BEGIN
        fldRef := recRefMaster.FIELD(fieldMonitor."Field No.");
        fldRefOld := oldRecRefMaster.FIELD(fieldMonitor."Field No.");
        IF FORMAT(fldRef) <> FORMAT(fldRefOld) THEN BEGIN
          // One of the fields we are interested in has changed so check the security
          // First check the Deny because that takes priority
          IF fieldMonitor."Deny User Group Code" <> '' THEN BEGIN
            ediUsers.SETRANGE("Workflow Group Code", fieldMonitor."Deny User Group Code");
            IF NOT ediUsers.ISEMPTY THEN
              ERROR(STRSUBSTNO(text16016310L, fieldMonitor."Field Name", fieldMonitor."Deny User Group Code"));
          END;
          // The user has not been specifically denied the ability to change it so have the been specifically allowed to change it
          IF fieldMonitor."Permit User Group Code" <> '' THEN BEGIN
            ediUsers.SETRANGE("Workflow Group Code", fieldMonitor."Permit User Group Code");
            IF ediUsers.ISEMPTY THEN
              ERROR(STRSUBSTNO(text16016311L, fieldMonitor."Field Name", fieldMonitor."Permit User Group Code"));
          END;
        END;
      END;
    UNTIL fieldMonitor.NEXT = 0;
  end;

  procedure CanChangeField(userIdent : Code[50];fieldMonitor : Record 70018011) : Boolean;
  var
    fldRef : FieldRef;
    fldRefOld : FieldRef;
    ediUsers : Record 70018006;
    text16016310L : TextConst ENU='Field ''%1'' has been configured to prevent you from changing the current value because you are a member of the ''%2'' Group.',ENA='Field ''%1'' has been configured to prevent you from changing the current value because you are a member of the ''%2'' Group.';
    text16016311L : TextConst ENU='Field ''%1'' has been configured to require membership of the ''%2'' Group to permit changes.',ENA='Field ''%1'' has been configured to require membership of the ''%2'' Group to permit changes.';
  begin
    // First make sure we are not permitted to ignore security
    ediUsers.SETRANGE("User ID", userIdent);
    ediUsers.SETRANGE("Allow Override Field Security", TRUE);
    IF NOT ediUsers.ISEMPTY THEN
      EXIT(TRUE);

    ediUsers.RESET;
    IF fieldMonitor."Field No." > 0 THEN BEGIN
      IF fieldMonitor."Deny User Group Code" <> '' THEN BEGIN
        ediUsers.SETRANGE("User ID", userIdent);
        ediUsers.SETRANGE("Workflow Group Code", fieldMonitor."Deny User Group Code");
        IF NOT ediUsers.ISEMPTY THEN
          EXIT(FALSE);
      END;
      IF fieldMonitor."Permit User Group Code" <> '' THEN BEGIN
        ediUsers.SETRANGE("User ID", userIdent);
        ediUsers.SETRANGE("Workflow Group Code", fieldMonitor."Permit User Group Code");
        IF ediUsers.ISEMPTY THEN
          EXIT(FALSE);
      END;
    END;
    EXIT(TRUE);
  end;

  procedure CanChangeTable(userIdent : Code[50];permitCode : Code[10];denyCode : Code[10]) : Boolean;
  var
    fldRef : FieldRef;
    fldRefOld : FieldRef;
    ediUsers : Record 70018006;
    text16016310L : TextConst ENU='Field ''%1'' has been configured to prevent you from changing the current value because you are a member of the ''%2'' Group.',ENA='Field ''%1'' has been configured to prevent you from changing the current value because you are a member of the ''%2'' Group.';
    text16016311L : TextConst ENU='Field ''%1'' has been configured to require membership of the ''%2'' Group to permit changes.',ENA='Field ''%1'' has been configured to require membership of the ''%2'' Group to permit changes.';
  begin
    // First make sure we are not permitted to ignore security
    ediUsers.SETRANGE("User ID", userIdent);
    ediUsers.SETRANGE("Allow Override Field Security", TRUE);
    IF NOT ediUsers.ISEMPTY THEN
      EXIT(TRUE);

    ediUsers.RESET;
    ediUsers.SETRANGE("User ID", userIdent);
    IF denyCode <> '' THEN BEGIN
      ediUsers.SETRANGE("Workflow Group Code", denyTableCode);
      IF NOT ediUsers.ISEMPTY THEN
        EXIT(FALSE);
    END;
    IF permitCode <> '' THEN BEGIN
      ediUsers.SETRANGE("Workflow Group Code", permitTableCode);
      IF ediUsers.ISEMPTY THEN
        EXIT(FALSE);
    END;
    EXIT(TRUE);
  end;

  local procedure IsSecurityActive() : Boolean;
  var
    ediSetup : Record 70018000;
  begin
    ediSetup.RESET;
    ediSetup.SETRANGE("Security Active", TRUE);
    EXIT(spointEdiMgt.ValidateSecurityIsOk AND NOT ediSetup.ISEMPTY);
  end;
}


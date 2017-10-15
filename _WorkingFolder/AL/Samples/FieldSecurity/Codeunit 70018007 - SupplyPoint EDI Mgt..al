codeunit 70018007 "SupplyPoint EDI Mgt."
{
  // version [EVENT - Subscriber]FLS1.00

  // ECLIPSE - SupplyPoint (ECSP)
  // ----------------------------
  //   ECSP2.00j

  SingleInstance=true;

  trigger OnRun();
  var
    rItem : Record 27;
    rItem2 : Record 27;
  begin
  end;

  var
    spointFoundation : Codeunit 70018008;
    ediSetup : Record 70018000;
    ediEvent : Record 70018008;
    gotEdiSetup : Boolean;
    tempEdiTable : Record 70018010 TEMPORARY;
    validatedEdiIsOk : Boolean;
    isEdiOk : Boolean;
    validatedWorkflowIsOk : Boolean;
    isWorkflowOk : Boolean;
    ediFoundation : Codeunit 70018003;
    validatedSecurityIsOk : Boolean;
    isSecurityOk : Boolean;
    security : Codeunit 70018005;
    dataMgt : Codeunit 701;
    integrationTablesLoaded : Boolean;

  [EventSubscriber(ObjectType::Codeunit, 1, 'OnAfterGetDatabaseTableTriggerSetup', '', false, false)]
  local procedure RunOnAfterGetDatabaseTableTriggerSetup(TableId : Integer;var OnDatabaseInsert : Boolean;var OnDatabaseModify : Boolean;var OnDatabaseDelete : Boolean;var OnDatabaseRename : Boolean);
  begin
    IF COMPANYNAME = '' THEN
      EXIT;

    IF TableId = DATABASE::Table16016341 THEN
      EXIT;

    IF NOT IsSecurityActivated() THEN
      EXIT;

    IF IsIntegrationRecord(TableId, TRUE, FALSE) THEN BEGIN
      OnDatabaseInsert := TRUE;
      OnDatabaseModify := TRUE;
      OnDatabaseDelete := TRUE;
      OnDatabaseRename := TRUE;
    END;
  end;

  [EventSubscriber(ObjectType::Codeunit, 1, 'OnAfterOnDatabaseInsert', '', false, false)]
  local procedure RunOnAfterOnDatabaseInsert(RecRef : RecordRef);
  var
    xRecRef : RecordRef;
  begin
    IF RecRef.ISTEMPORARY THEN
      EXIT;

    IF NOT GetDatabaseInsertTrigger(RecRef.NUMBER) THEN
      EXIT;

    xRecRef := RecRef.DUPLICATE;
    security.RecordHandler(xRecRef, RecRef, ediEvent.Event_Insert);
  end;

  [EventSubscriber(ObjectType::Codeunit, 1, 'OnAfterOnDatabaseModify', '', false, false)]
  local procedure RunOnAfterOnDatabaseModify(RecRef : RecordRef);
  var
    xRecRef : RecordRef;
  begin
    IF RecRef.ISTEMPORARY THEN
      EXIT;

    IF NOT GetDatabaseModifyTrigger(RecRef.NUMBER) THEN
      EXIT;

    IF NOT xRecRef.GET(RecRef.RECORDID) THEN
      EXIT;

    security.RecordHandler(xRecRef, RecRef, ediEvent.Event_Modify);
  end;

  [EventSubscriber(ObjectType::Codeunit, 1, 'OnAfterOnDatabaseDelete', '', false, false)]
  local procedure RunOnAfterOnDatabaseDelete(RecRef : RecordRef);
  var
    xRecRef : RecordRef;
  begin
    IF RecRef.ISTEMPORARY THEN
      EXIT;

    IF NOT GetDatabaseDeleteTrigger(RecRef.NUMBER) THEN
      EXIT;

    xRecRef := RecRef.DUPLICATE;
    security.RecordHandler(xRecRef, RecRef, ediEvent.Event_Delete);
  end;

  [EventSubscriber(ObjectType::Codeunit, 1, 'OnAfterOnDatabaseRename', '', false, false)]
  local procedure RunOnAfterOnDatabaseRename(RecRef : RecordRef;xRecRef : RecordRef);
  begin
    IF RecRef.ISTEMPORARY THEN
      EXIT;

    IF NOT GetDatabaseRenameTrigger(RecRef.NUMBER) THEN
      EXIT;

    IF NOT xRecRef.GET(xRecRef.RECORDID) THEN
      EXIT;

    security.RecordHandler(xRecRef, RecRef, ediEvent.Event_Rename);
  end;

  [EventSubscriber(ObjectType::Codeunit, 16015949, 'OnAfterFieldValidated', '', false, false)]
  local procedure RunOnAfterFieldValidated(xVnt : Variant;vnt : Variant;fieldNo : Integer);
  var
    recRef : RecordRef;
    xRecRef : RecordRef;
  begin
    IF NOT dataMgt.GetRecordRef(vnt, recRef) THEN
      EXIT;
    IF NOT dataMgt.GetRecordRef(xVnt, xRecRef) THEN
      EXIT;
    IF NOT GetDatabaseModifyTrigger(recRef.NUMBER) THEN
      EXIT;

    security.FieldHandler(xRecRef, recRef, fieldNo);
  end;

  [IntegrationEvent(false, false)]
  procedure OnAfterFieldValidated(xVnt : Variant;vnt : Variant;fieldNo : Integer);
  begin
  end;

  local procedure GetEdiSetup();
  begin
    IF NOT gotEdiSetup THEN BEGIN
      IF NOT ediSetup.GET THEN
        ediSetup.INIT;
      gotEdiSetup := TRUE;
    END;
  end;

  local procedure GetEDITriggerSetup(tableId : Integer;isChange : Boolean;isAction : Boolean) : Boolean;
  begin
    IF COMPANYNAME = '' THEN
      EXIT(FALSE);

    IF NOT IsSecurityActivated THEN
      EXIT(FALSE);

    EXIT(IsIntegrationRecord(tableId, isChange, isAction))
  end;

  local procedure LoadIntegrationRecords();
  var
    ediTable : Record 70018010;
  begin
    IF integrationTablesLoaded THEN
      EXIT;

    tempEdiTable.RESET;
    tempEdiTable.DELETEALL;

    integrationTablesLoaded := TRUE;
    ediTable.RESET;
    IF ediTable.FINDSET THEN REPEAT
      tempEdiTable.COPY(ediTable);
      tempEdiTable.INSERT;
    UNTIL ediTable.NEXT = 0;
  end;

  local procedure IsIntegrationRecord(tableID : Integer;isChange : Boolean;isAction : Boolean) : Boolean;
  begin
    LoadIntegrationRecords;
    tempEdiTable.RESET;
    tempEdiTable.SETRANGE("Table No.", tableID);
    IF isChange THEN
      tempEdiTable.SETRANGE("Change Trigger", TRUE);
    IF isAction THEN
      tempEdiTable.SETRANGE("Action Trigger", TRUE);

    IF tempEdiTable.FINDFIRST THEN
      EXIT(TRUE)
    ELSE
      EXIT(FALSE);
  end;

  procedure IsSecurityActivated() : Boolean;
  begin
    GetEdiSetup;

    EXIT(ediSetup."Security Active");
  end;

  local procedure GetDatabaseInsertTrigger(tableID : Integer) : Boolean;
  var
    insert : Boolean;
    modify : Boolean;
    delete : Boolean;
    rename : Boolean;
  begin
    EXIT(GetEDITriggerSetup(tableID, TRUE, FALSE));
  end;

  local procedure GetDatabaseModifyTrigger(tableID : Integer) : Boolean;
  var
    insert : Boolean;
    modify : Boolean;
    delete : Boolean;
    rename : Boolean;
  begin
    EXIT(GetEDITriggerSetup(tableID, TRUE, FALSE));
  end;

  local procedure GetDatabaseDeleteTrigger(tableID : Integer) : Boolean;
  var
    insert : Boolean;
    modify : Boolean;
    delete : Boolean;
    rename : Boolean;
  begin
    EXIT(GetEDITriggerSetup(tableID, TRUE, FALSE));
  end;

  local procedure GetDatabaseRenameTrigger(tableID : Integer) : Boolean;
  var
    insert : Boolean;
    modify : Boolean;
    delete : Boolean;
    rename : Boolean;
  begin
    EXIT(GetEDITriggerSetup(tableID, TRUE, FALSE));
  end;

  local procedure GetDatabaseFieldChangeTrigger(tableID : Integer) : Boolean;
  var
    insert : Boolean;
    modify : Boolean;
    delete : Boolean;
    rename : Boolean;
  begin
    EXIT(GetEDITriggerSetup(tableID, TRUE, FALSE));
  end;

  local procedure GetDatabaseActionTrigger(tableID : Integer) : Boolean;
  var
    insert : Boolean;
    modify : Boolean;
    delete : Boolean;
    rename : Boolean;
  begin
    EXIT(GetEDITriggerSetup(tableID, FALSE, TRUE));
  end;

  procedure ValidateSecurityIsOk() : Boolean;
  var
    result : Boolean;
    compInfo : Record 79;
    ediEnabled : Boolean;
    workflowEnabled : Boolean;
    text16016310L : TextConst ENU='EDI is not currently licensed correctly.',ENA='EDI is not currently licensed correctly.';
  begin
    IF validatedSecurityIsOk THEN
      EXIT(isSecurityOk);

    GetEdiSetup;

    validatedSecurityIsOk := TRUE;
    isSecurityOk := TRUE;

    EXIT(isSecurityOk);
  end;

  procedure Event_None() : Integer;
  begin
    EXIT(0);
  end;

  procedure Event_Insert() : Integer;
  begin
    EXIT(1);
  end;

  procedure Event_Modify() : Integer;
  begin
    EXIT(2);
  end;

  procedure Event_Delete() : Integer;
  begin
    EXIT(3);
  end;

  procedure Event_Rename() : Integer;
  begin
    EXIT(4);
  end;
}


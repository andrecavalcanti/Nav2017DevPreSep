codeunit 70018001 "Extension Upgrade Mgt."
{
  // version FLS1.00


  trigger OnRun();
  begin
  end;

  procedure OnNavAppUpgradePerDatabase();
  begin
  end;

  procedure OnNavAppUpgradePerCompany();
  begin
    RestoreFieldsInModifiedTables(70018000,70018013);
    RestoreAppTables(70018013,70018013);
  end;

  local procedure RestoreFieldsInModifiedTables(FromField : Integer;ToField : Integer);
  var
    "Field" : Record 2000000041;
    AllObj : Record 2000000038;
    SourceRecRef : RecordRef;
    DestinationRecRef : RecordRef;
    KeyRef : KeyRef;
  begin
    WITH AllObj DO BEGIN
      SETRANGE("Object Type","Object Type"::Table);

      IF FINDSET THEN
        REPEAT
            Field.SETRANGE(TableNo, "Object ID");
            Field.SETRANGE("No.", FromField, ToField);
            IF NOT Field.ISEMPTY THEN BEGIN
              IF NAVAPP.GETARCHIVERECORDREF("Object ID", SourceRecRef) THEN BEGIN
                IF SourceRecRef.FINDSET THEN
                  REPEAT
                    DestinationRecRef.OPEN("Object ID",FALSE);
                    IF GetRecRefFromRecRef(SourceRecRef,DestinationRecRef) THEN BEGIN
                      TransferCustomFieldRefs(SourceRecRef,DestinationRecRef,FromField,ToField);
                      DestinationRecRef.MODIFY;
                    END ELSE BEGIN
                      ERROR('Destination record not found.  Data would be lost.  RecordID: %1',FORMAT(SourceRecRef.RECORDID));
                    END;
                    DestinationRecRef.CLOSE;
                  UNTIL SourceRecRef.NEXT < 1;
               END;
            END;
        UNTIL NEXT < 1;
    END;
  end;

  local procedure RestoreAppTables(FromTableID : Integer;ToTableID : Integer);
  var
    SourceRecRef : RecordRef;
    DestinationRecRef : RecordRef;
    "Field" : Record 2000000041;
    AllObj : Record 2000000038;
  begin
    WITH AllObj DO BEGIN
      SETRANGE("Object Type", "Object Type"::Table);
      SETRANGE("Object ID", FromTableID,ToTableID);

      IF FINDSET THEN
        REPEAT
          IF NAVAPP.GETARCHIVERECORDREF("Object ID", SourceRecRef) THEN BEGIN
            IF SourceRecRef.FINDSET THEN
              REPEAT
                DestinationRecRef.OPEN("Object ID",FALSE);

                TransferFieldRefs(SourceRecRef,DestinationRecRef);
                DestinationRecRef.INSERT;

                DestinationRecRef.CLOSE;
              UNTIL SourceRecRef.NEXT = 0;
          END;
        UNTIL NEXT < 1;
    END;
  end;

  local procedure TransferFieldRefs(var SourceRecRef : RecordRef;var DestinationRecRef : RecordRef);
  var
    "Field" : Record 2000000041;
    SourceFieldRef : FieldRef;
    DestinationFieldRef : FieldRef;
  begin
    WITH Field DO BEGIN
      SETRANGE(TableNo, DestinationRecRef.NUMBER);
      IF FINDSET THEN
        REPEAT
          IF SourceRecRef.FIELDEXIST(Field."No.") THEN BEGIN
            SourceFieldRef := SourceRecRef.FIELD(Field."No.");
            DestinationFieldRef := DestinationRecRef.FIELD(Field."No.");
            DestinationFieldRef.VALUE := SourceFieldRef.VALUE;
          END;
        UNTIL NEXT = 0;
    END;
  end;

  local procedure TransferCustomFieldRefs(var SourceRecRef : RecordRef;var DestinationRecRef : RecordRef;FromField : Integer;ToField : Integer);
  var
    "Field" : Record 2000000041;
    SourceFieldRef : FieldRef;
    DestinationFieldRef : FieldRef;
  begin
    WITH Field DO BEGIN
      SETRANGE(TableNo, DestinationRecRef.NUMBER);
      SETRANGE("No.",FromField,ToField);
      IF FINDSET THEN
        REPEAT
          IF SourceRecRef.FIELDEXIST(Field."No.") THEN BEGIN
            SourceFieldRef := SourceRecRef.FIELD(Field."No.");
            DestinationFieldRef := DestinationRecRef.FIELD(Field."No.");
            DestinationFieldRef.VALUE := SourceFieldRef.VALUE;
          END;
        UNTIL NEXT = 0;
    END;
  end;

  local procedure GetRecRefFromRecRef(var SourceRecRef : RecordRef;var DestinationRecRef : RecordRef) : Boolean;
  var
    KeyRef : KeyRef;
    i : Integer;
    FieldRef : FieldRef;
    SourceFieldRef : FieldRef;
    DestinationFieldRef : FieldRef;
  begin
    KeyRef := DestinationRecRef.KEYINDEX(1);
    FOR i := 1 TO KeyRef.FIELDCOUNT DO BEGIN
      FieldRef := KeyRef.FIELDINDEX(i);

      SourceFieldRef := SourceRecRef.FIELD(FieldRef.NUMBER);
      DestinationFieldRef := DestinationRecRef.FIELD(FieldRef.NUMBER);

      DestinationFieldRef.VALUE := SourceFieldRef.VALUE;
    END;

    IF NOT DestinationRecRef.FIND('=') THEN
      EXIT(FALSE)
    ELSE
      EXIT(TRUE);
  end;
}


table 70018010 "EDI Table"
{
  // version FLS1.00

  // ECLIPSE - SupplyPoint (ECSP)
  // ----------------------------
  //   ECSP2.00j

  CaptionML=ENU='EDI Table',
            ENA='EDI Table';

  fields
  {
    field(1;"Table No.";Integer)
    {
      CaptionML=ENU='Table No.',
                ENA='Table No.';
      Description='ECSP2.00j';

      trigger OnValidate();
      var
        loop : Integer;
      begin
        loop := 1;
        REPEAT
          CASE loop OF
            1 : "Key Field No. 1" := GetKeyFieldNo(loop, "Table No.");
            2 : "Key Field No. 2" := GetKeyFieldNo(loop, "Table No.");
            3 : "Key Field No. 3" := GetKeyFieldNo(loop, "Table No.");
            4 : "Key Field No. 4" := GetKeyFieldNo(loop, "Table No.");
            5 : "Key Field No. 5" := GetKeyFieldNo(loop, "Table No.");
            6 : "Key Field No. 6" := GetKeyFieldNo(loop, "Table No.");
            7 : "Key Field No. 7" := GetKeyFieldNo(loop, "Table No.");
            8 : "Key Field No. 8" := GetKeyFieldNo(loop, "Table No.");
            9 : "Key Field No. 9" := GetKeyFieldNo(loop, "Table No.");
            10 : "Key Field No. 10" := GetKeyFieldNo(loop, "Table No.");
          END;
          loop := loop + 1;
        UNTIL loop > 10;
      end;
    }
    field(10;"Table Name";Text[50])
    {
      CalcFormula=Lookup(Object.Name WHERE (Type=CONST(Table),
                                            ID=FIELD("Table No.")));
      CaptionML=ENU='Table Name',
                ENA='Table Name';
      Description='ECSP2.00j';
      Editable=false;
      FieldClass=FlowField;
    }
    field(30;"Key Field No. 1";Integer)
    {
      CaptionML=ENU='Key Field No. 1',
                ENA='Key Field No. 1';
      Description='ECSP2.00j';
    }
    field(40;"Key Field No. 2";Integer)
    {
      CaptionML=ENU='Key Field No. 2',
                ENA='Key Field No. 2';
      Description='ECSP2.00j';
    }
    field(50;"Key Field No. 3";Integer)
    {
      CaptionML=ENU='Key Field No. 3',
                ENA='Key Field No. 3';
      Description='ECSP2.00j';
    }
    field(60;"Key Field No. 4";Integer)
    {
      CaptionML=ENU='Key Field No. 4',
                ENA='Key Field No. 4';
      Description='ECSP2.00j';
    }
    field(70;"Key Field No. 5";Integer)
    {
      CaptionML=ENU='Key Field No. 5',
                ENA='Key Field No. 5';
      Description='ECSP2.00j';
    }
    field(80;"Key Field No. 6";Integer)
    {
      CaptionML=ENU='Key Field No. 6',
                ENA='Key Field No. 6';
      Description='ECSP2.00j';
    }
    field(90;"Key Field No. 7";Integer)
    {
      CaptionML=ENU='Key Field No. 7',
                ENA='Key Field No. 7';
      Description='ECSP2.00j';
    }
    field(100;"Key Field No. 8";Integer)
    {
      CaptionML=ENU='Key Field No. 8',
                ENA='Key Field No. 8';
      Description='ECSP2.00j';
    }
    field(110;"Key Field No. 9";Integer)
    {
      CaptionML=ENU='Key Field No. 9',
                ENA='Key Field No. 9';
      Description='ECSP2.00j';
    }
    field(120;"Key Field No. 10";Integer)
    {
      CaptionML=ENU='Key Field No. 10',
                ENA='Key Field No. 10';
      Description='ECSP2.00j';
    }
    field(130;"Parent Table No.";Integer)
    {
      CaptionML=ENU='Parent Table No.',
                ENA='Parent Table No.';
      Description='ECSP2.00j';
    }
    field(150;"Parent Table Name";Text[50])
    {
      CalcFormula=Lookup(Object.Name WHERE (Type=CONST(Table),
                                            ID=FIELD("Parent Table No.")));
      CaptionML=ENU='Parent Table Name',
                ENA='Parent Table Name';
      Description='ECSP2.00j';
      Editable=false;
      FieldClass=FlowField;
    }
    field(170;"Change Trigger";Boolean)
    {
      CaptionML=ENU='Change Trigger',
                ENA='Change Trigger';
      Description='ECSP2.00j';
      Editable=false;
    }
    field(180;"Field Trigger";Boolean)
    {
      CaptionML=ENU='Field Trigger',
                ENA='Field Trigger';
      Description='ECSP2.00j';
      Editable=false;
    }
    field(190;"Action Trigger";Boolean)
    {
      CaptionML=ENU='Action Trigger',
                ENA='Action Trigger';
      Description='ECSP2.00j';
      Editable=false;
    }
  }

  keys
  {
    key(Key1;"Table No.")
    {
      Clustered=true;
    }
  }

  fieldgroups
  {
  }

  var
    ediFoundation : Codeunit 70018008;
    tableType : Option Master,Header,Line,Journal;

  procedure GetKeyFieldNo(index : Integer;tableNo : Integer) : Integer;
  var
    "key" : Record 2000000063;
    pos : Integer;
    "field" : Record 2000000041;
    currentIndex : Integer;
    fieldName : Text[50];
    fieldNo : Integer;
    exitLoop : Boolean;
    working : Text;
  begin
    key.SETRANGE(TableNo, tableNo);
    key.SETRANGE("No.", 1);
    IF NOT key.FINDFIRST THEN
      EXIT(0);

    working := key.Key;
    exitLoop := FALSE;
    currentIndex := 0;
    REPEAT
      pos := STRPOS(working, ',');
      IF pos > 0 THEN BEGIN
        fieldName := COPYSTR(working, 1, pos - 1);
        working := COPYSTR(working, pos + 1);
        field.SETRANGE(TableNo, tableNo);
        field.SETRANGE(FieldName, fieldName);
        IF field.FINDFIRST THEN
          fieldNo := field."No."
        ELSE
          fieldNo := 0;
        currentIndex := currentIndex + 1;
        IF currentIndex = index THEN
          EXIT(fieldNo);
      END ELSE BEGIN
        fieldName := working;
        field.SETRANGE(TableNo, tableNo);
        field.SETRANGE(FieldName, fieldName);
        IF field.FINDFIRST THEN
          fieldNo := field."No."
        ELSE
          fieldNo := 0;
        currentIndex := currentIndex + 1;
        IF currentIndex = index THEN
          EXIT(fieldNo);
        exitLoop := TRUE;
      END;
    UNTIL (currentIndex = index) OR exitLoop;
  end;

  procedure GetKeyFieldName(index : Integer;tableNo : Integer) : Text[50];
  var
    "key" : Record 2000000063;
    pos : Integer;
    "field" : Record 2000000041;
    currentIndex : Integer;
    fieldName : Text[50];
    fieldNo : Integer;
    exitLoop : Boolean;
    working : Text;
  begin
    key.SETRANGE(TableNo, tableNo);
    key.SETRANGE("No.", 1);
    IF NOT key.FINDFIRST THEN
      EXIT('');

    working := key.Key;
    exitLoop := FALSE;
    currentIndex := 0;
    REPEAT
      pos := STRPOS(working, ',');
      IF pos > 0 THEN BEGIN
        fieldName := COPYSTR(working, 1, pos - 1);
        working := COPYSTR(working, pos + 1);
        field.SETRANGE(TableNo, tableNo);
        field.SETRANGE(FieldName, fieldName);
        IF field.FINDFIRST THEN
          fieldNo := field."No."
        ELSE
          fieldNo := 0;
        currentIndex := currentIndex + 1;
        IF currentIndex = index THEN BEGIN
          IF fieldNo = 0 THEN
            EXIT('')
          ELSE
            EXIT(fieldName);
        END;
      END ELSE BEGIN
        fieldName := working;
        field.SETRANGE(TableNo, tableNo);
        field.SETRANGE(FieldName, fieldName);
        IF field.FINDFIRST THEN
          fieldNo := field."No."
        ELSE
          fieldNo := 0;
        currentIndex := currentIndex + 1;
        IF currentIndex = index THEN BEGIN
          IF fieldNo = 0 THEN
            EXIT('')
          ELSE
            EXIT(fieldName);
        END;
        exitLoop := TRUE;
      END;
    UNTIL (currentIndex = index) OR exitLoop;
  end;
}


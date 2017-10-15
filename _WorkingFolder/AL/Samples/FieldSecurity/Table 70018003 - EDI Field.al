table 70018003 "EDI Field"
{
  // version FLS1.00

  // ECLIPSE - SupplyPoint (ECSP)
  // ----------------------------
  //   ECSP2.00j

  CaptionML=ENU='EDI Field',
            ENA='EDI Field';

  fields
  {
    field(1;"Rule Code";Code[20])
    {
      CaptionML=ENU='Rule Code',
                ENA='Rule Code';
      Description='ECSP2.00j';
      NotBlank=true;
      TableRelation="EDI Workflow Rule".Code;
    }
    field(2;"Table No.";Integer)
    {
      BlankZero=true;
      CaptionML=ENU='Table No.',
                ENA='Table No.';
      Description='ECSP2.00j';
      Editable=false;
      NotBlank=true;
    }
    field(3;"Field No.";Integer)
    {
      BlankZero=true;
      CaptionML=ENU='Field No.',
                ENA='Field No.';
      Description='ECSP2.00j';
      NotBlank=true;
      TableRelation=Field."No." WHERE (TableNo=FIELD("Table No."));
      ValidateTableRelation=false;

      trigger OnLookup();
      var
        "field" : Record 2000000041;
        fieldPage : Page 70018001;
      begin
        field.SETRANGE(TableNo, "Table No.");
        field.SETRANGE("No.", "Field No.");
        IF field.FINDFIRST THEN
          fieldPage.SETRECORD(field);
        field.SETRANGE("No.");
        fieldPage.SETTABLEVIEW(field);
        fieldPage.LOOKUPMODE := TRUE;
        IF fieldPage.RUNMODAL = ACTION::LookupOK THEN BEGIN
          fieldPage.GETRECORD(field);
          VALIDATE("Field No.", field."No.")
        END;
      end;

      trigger OnValidate();
      var
        "field" : Record 2000000041;
      begin
        field.SETRANGE(TableNo, "Table No.");
        field.SETRANGE("No.", "Field No.");
        IF field.FINDFIRST THEN BEGIN
          "Field Name" := field.FieldName;
          "Data Type" := GetDataType(field."Type Name");
          "Field Length" := GetFieldLen("Data Type", field.Len);
          IF field.Class = field.Class::FlowField THEN
            "Flow Field" := TRUE
          ELSE
            "Flow Field" := FALSE;
          "Key Field" := ediFoundation.IsFieldKey("Table No.", field.FieldName);
          Filter := '';
        END ELSE BEGIN
          "Field Name" := '';
          "Data Type" := "Data Type"::String;
          "Field Length" := 0;
          "Flow Field" := FALSE;
          "Key Field" := FALSE;
          "Sort Field Name" := '';
          Filter := '';
        END;
      end;
    }
    field(4;"Parent Table No.";Integer)
    {
      CaptionML=ENU='Parent Table No.',
                ENA='Parent Table No.';
      Description='ECSP2.00j';
      Editable=false;
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
    field(20;"Field Name";Text[50])
    {
      CaptionML=ENU='Field Name',
                ENA='Field Name';
      Description='ECSP2.00j';
      Editable=false;
    }
    field(30;"Data Type";Option)
    {
      CaptionML=ENU='Data Type',
                ENA='Data Type';
      Description='ECSP2.00j';
      Editable=false;
      OptionCaptionML=ENU='String,Decimal,Integer,Boolean,Date,DateTime,Time,Option,DateFormula',
                      ENA='String,Decimal,Integer,Boolean,Date,DateTime,Time,Option,DateFormula';
      OptionMembers=String,Decimal,"Integer",Boolean,Date,DateTime,Time,Option,DateFormula;
    }
    field(40;"Field Length";Integer)
    {
      BlankZero=true;
      CaptionML=ENU='Field Length',
                ENA='Field Length';
      Description='ECSP2.00j';
      Editable=false;
    }
    field(50;"Flow Field";Boolean)
    {
      CaptionML=ENU='Flow Field',
                ENA='Flow Field';
      Description='ECSP2.00j';
      Editable=false;
    }
    field(60;"Key Field";Boolean)
    {
      CaptionML=ENU='Key Field',
                ENA='Key Field';
      Description='ECSP2.00j';
      Editable=false;
    }
    field(100;Indentation;Integer)
    {
      CaptionML=ENU='Indentation',
                ENA='Indentation';
      Description='ECSP2.00j';
    }
    field(120;Highlight;Boolean)
    {
      CaptionML=ENU='Highlight',
                ENA='Highlight';
      Description='ECSP2.00j';
    }
    field(130;"Sort Sequence";Decimal)
    {
      CaptionML=ENU='Sort Sequence',
                ENA='Sort Sequence';
      Description='ECSP2.00j';
    }
    field(140;"Sort Field Name";Text[50])
    {
      CaptionML=ENU='Sort Field Name',
                ENA='Sort Field Name';
      Description='ECSP2.00j';
    }
    field(150;"Filter";Text[250])
    {
      CaptionML=ENU='Filter',
                ENA='Filter';
      Description='ECSP2.00j';

      trigger OnValidate();
      var
        text16016310L : TextConst ENU='You cannot validate %1 with a Filter check because it is a %2 field.',ENA='You cannot validate %1 with a Filter check because it is a %2 field';
        text16016311L : TextConst ENU='When applying filters against Key Fields you must ensure that you do not use every key field or the filter will fail.',ENA='When applying filters against Key Fields you must ensure that you do not use every key field or the filter will fail.';
        ediRule : Record 70018004;
      begin
        IF Filter <> '' THEN BEGIN
          field.RESET;
          field.SETRANGE(TableNo, "Table No.");
          field.SETRANGE("No.", "Field No.");
          IF NOT field.FINDFIRST THEN
            EXIT;

          IF field.Class = field.Class::FlowFilter THEN
            ERROR(text16016310L, field.FieldName, field.Class);

          IF ediRule.GET("Rule Code") THEN BEGIN
            IF "Key Field" AND (ediRule.Type <> ediRule.Type::Filter) THEN
              MESSAGE(text16016311L);
          END;
        END;
      end;
    }
    field(160;Active;Boolean)
    {
      CaptionML=ENU='Active',
                ENA='Active';
      Description='ECSP2.00j';
    }
    field(270;"Multi Language Set";Boolean)
    {
      CalcFormula=Exist("EDI Field Language" WHERE ("Rule Code"=FIELD("Rule Code"),
                                                    "Table No."=FIELD("Table No."),
                                                    "Field No."=FIELD("Field No."),
                                                    "Parent Table No."=FIELD("Parent Table No.")));
      CaptionML=ENU='Multi Language Set',
                ENA='Multi Language Set';
      Description='ECSP2.00j';
      Editable=false;
      FieldClass=FlowField;
    }
    field(320;"Has Attributes";Boolean)
    {
      CaptionML=ENU='Has Attributes',
                ENA='Has Attributes';
      Description='ECSP2.00j';
      Editable=false;
    }
    field(340;"Add-in Code";Code[20])
    {
      CaptionML=ENU='Add-in Code',
                ENA='Add-in Code';
      Description='ECSP2.00j';
      Editable=false;
    }
  }

  keys
  {
    key(Key1;"Rule Code","Table No.","Field No.","Parent Table No.")
    {
      Clustered=true;
    }
    key(Key2;"Sort Sequence","Sort Field Name")
    {
    }
    key(Key3;"Sort Sequence","Field No.")
    {
    }
  }

  fieldgroups
  {
  }

  var
    ediFoundation : Codeunit 70018003;
    "field" : Record 2000000041;
    text16016310G : TextConst ENU='You cannot apply a Default Value to a Flowfield.',ENA='You cannot apply a Default Value to a Flowfield.';

  procedure GetDataType(dataType : Code[30]) : Integer;
  begin
    // String,Decimal,Integer,Boolean,Date,DateTime,Time,Option,DateFormula
    //      0,      1,      2,      3,   4,       5,   6,     7,          8

    CASE dataType OF
      'DATEFORMULA' : EXIT(8);
      'DECIMAL' : EXIT(1);
      'BOOLEAN' : EXIT(3);
      'DATE' : EXIT(4);
      'DATETIME' : EXIT(5);
      'TIME' : EXIT(6);
      'OPTION' : EXIT(7);
      'INTEGER' : EXIT(2);
      ELSE EXIT(0);
    END;
  end;

  procedure GetFieldLen(dataType : Integer;len : Integer) : Integer;
  begin
    // String,Decimal,Integer,Boolean,Date,DateTime,Time,Option,DateFormula
    //      0,      1,      2,      3,   4,       5,   6,     7,          8

    CASE dataType OF
      0 : EXIT(len);
      1 : EXIT(20);
      2 : EXIT(20);
      3 : EXIT(len);
      4 : EXIT(10);
      5 : EXIT(22);
      6 : EXIT(12);
      7 : EXIT(100);
      9 : EXIT(50);
      ELSE EXIT(len);
    END;
  end;

  procedure InitialiseTable(ruleCode : Code[20];source : Integer;tableNo : Integer;tableName : Text[50];parentTableNo : Integer;indentation : Integer;sortSequence : Decimal;var oldFieldSet : Record 70018003 TEMPORARY);
  var
    ediField : Record 70018003;
    "field" : Record 2000000041;
    mapField : Record 2000000041;
    setupMapField : Boolean;
    mapTableNo : Integer;
    ediRule : Record 70018004;
    ediTable : Record 70018010;
  begin
    IF ruleCode = '' THEN
      EXIT;

    IF NOT ediRule.GET(ruleCode) THEN
      EXIT;

    IF tableNo = 0 THEN
      EXIT;

    field.SETRANGE(TableNo, tableNo);
    IF field.FINDSET THEN BEGIN
      // First Put the Header In
      IF NOT ediField.GET(ruleCode, tableNo, 0, parentTableNo) THEN BEGIN
        ediField.VALIDATE("Rule Code", ruleCode);
        ediField.VALIDATE("Table No.", tableNo);
        ediField.VALIDATE("Field No.", 0);
        ediField.VALIDATE("Parent Table No.", parentTableNo);
        ediField."Field Name" := tableName;
        ediField."Sort Field Name" := '.';
        ediField.Highlight := TRUE;
        ediField.Indentation := indentation;
        ediField."Sort Sequence" := sortSequence;
        ediField.INSERT;
        ediField.Active := TRUE;
        ediField.MODIFY;
      END ELSE BEGIN
        ediField.VALIDATE("Field No.", 0);
        ediField."Field Name" := tableName;
        ediField."Sort Field Name" := '.';
        ediField.Highlight := TRUE;
        ediField.Indentation := indentation;
        ediField."Sort Sequence" := sortSequence;
        ediField.Active := TRUE;
        ediField.MODIFY;
      END;

      sortSequence := sortSequence + 0.01;
      setupMapField := FALSE;
      mapTableNo := 0;

      REPEAT
          InitialiseEntry(ruleCode, tableNo, parentTableNo, field."No.", field.FieldName, indentation,
                            sortSequence, 0, 0, 0, 0);
      UNTIL field.NEXT = 0;

    END;

    oldFieldSet.RESET;
    ediField.RESET;
    IF oldFieldSet.FINDSET THEN REPEAT
      IF ediField.GET(oldFieldSet."Rule Code", oldFieldSet."Table No.", oldFieldSet."Field No.", oldFieldSet."Parent Table No.") THEN BEGIN
        ediField.Filter := oldFieldSet.Filter;
        ediField.Active := oldFieldSet.Active;
        ediField.MODIFY;
      END;
    UNTIL oldFieldSet.NEXT = 0;
  end;

  local procedure InitialiseEntry(ruleCode : Code[20];tableNo : Integer;parentTableNo : Integer;createFieldNo : Integer;fieldName : Text[50];indentation : Integer;sortSequence : Decimal;specialHandling : Integer;mapTableNo : Integer;createHoldingFieldNo : Integer;dummyRealField : Integer);
  var
    ediField : Record 70018003;
  begin
    IF NOT ediField.GET(ruleCode, tableNo, createFieldNo, parentTableNo) THEN BEGIN
      ediField.INIT;
      ediField.VALIDATE("Rule Code", ruleCode);
      ediField.VALIDATE("Table No.", tableNo);
      ediField.VALIDATE("Parent Table No.", parentTableNo);
      IF dummyRealField > 0 THEN BEGIN
        ediField.VALIDATE("Field No.", dummyRealField);
        ediField."Field No." := createFieldNo;
      END ELSE
        ediField.VALIDATE("Field No.", createFieldNo);
      ediField."Field Name" := fieldName;
      ediField."Sort Field Name" := fieldName;
      ediField.Highlight := FALSE;
      ediField.Indentation := indentation + 1;
      ediField."Sort Sequence" := sortSequence;
      ediField.INSERT;
    END ELSE BEGIN
      IF dummyRealField > 0 THEN BEGIN
        ediField.VALIDATE("Field No.", dummyRealField);
        ediField."Field No." := createFieldNo;
      END ELSE
        ediField.VALIDATE("Field No.", createFieldNo);
      ediField."Field Name" := fieldName;
      ediField."Sort Field Name" := fieldName;
      ediField.Highlight := FALSE;
      ediField.Indentation := indentation + 1;
      ediField."Sort Sequence" := sortSequence;
      ediField.MODIFY;
    END;
  end;
}


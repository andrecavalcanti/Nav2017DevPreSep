table 70018011 "EDI Handler Field Monitor"
{
  // version FLS1.00

  // ECLIPSE - SupplyPoint (ECSP)
  // ----------------------------
  //   ECSP2.00j

  CaptionML=ENU='EDI Handler Field Monitor',
            ENA='EDI Handler Field Monitor';
  DrillDownPageID=16016382;
  LookupPageID=16016382;

  fields
  {
    field(1;"Processor Code";Code[10])
    {
      CaptionML=ENU='Processor Code',
                ENA='Processor Code';
      Description='ECSP2.00j';
      NotBlank=true;
      TableRelation="EDI Processor".Code WHERE (Direction=FILTER("0"|2|Security));

      trigger OnValidate();
      begin
        SetTableNo;
      end;
    }
    field(2;"Handler Code";Code[20])
    {
      CaptionML=ENU='Handler Code',
                ENA='Handler Code';
      Description='ECSP2.00j';
      NotBlank=true;
      TableRelation="EDI Handler".Code WHERE ("Processor Code"=FIELD("Processor Code"));

      trigger OnValidate();
      begin
        SetTableNo;
      end;
    }
    field(3;"Field No.";Integer)
    {
      BlankZero=true;
      CaptionML=ENU='Field Change Field No.',
                ENA='Field Change Field No.';
      Description='ECSP2.00j';
      NotBlank=true;
      TableRelation=Field."No." WHERE (TableNo=FIELD("Table No."));

      trigger OnLookup();
      var
        "field" : Record 2000000041;
        fieldPage : Page 70018001;
      begin
        SetTableNo;
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
        SetTableNo;
        field.SETRANGE(TableNo, "Table No.");
        field.SETRANGE("No.", "Field No.");
        IF field.FINDFIRST THEN
          "Field Name" := field.FieldName
        ELSE
          "Field Name" := '';
      end;
    }
    field(10;"Table No.";Integer)
    {
      CaptionML=ENU='Table No.',
                ENA='Table No.';
      Description='ECSP2.00j';
      Editable=false;
    }
    field(20;"Field Name";Text[50])
    {
      CaptionML=ENU='Field Name',
                ENA='Field Name';
      Description='ECSP2.00j';
      Editable=false;
    }
    field(30;"Processor Description";Text[50])
    {
      CalcFormula=Lookup("EDI Processor".Description WHERE (Code=FIELD("Processor Code")));
      CaptionML=ENU='Processor Description',
                ENA='Processor Description';
      Description='ECSP2.00j';
      Editable=false;
      FieldClass=FlowField;
    }
    field(40;"Handler Description";Text[50])
    {
      CalcFormula=Lookup("EDI Handler".Description WHERE ("Processor Code"=FIELD("Processor Code"),
                                                          Code=FIELD("Handler Code")));
      CaptionML=ENU='Handler Description',
                ENA='Handler Description';
      Description='ECSP2.00j';
      Editable=false;
      FieldClass=FlowField;
    }
    field(50;"Permit User Group Code";Code[10])
    {
      CaptionML=ENU='Permit User Group Code',
                ENA='Permit User Group Code';
      Description='ECSP2.00j';
      TableRelation="EDI Workflow User Group".Code;

      trigger OnValidate();
      begin
        IF ("Permit User Group Code" <> '') AND ("Permit User Group Code" = "Deny User Group Code") THEN
          ERROR(text16016310G);
      end;
    }
    field(60;"Permit User Group Description";Text[50])
    {
      CalcFormula=Lookup("EDI Workflow User Group".Description WHERE (Code=FIELD("Permit User Group Code")));
      CaptionML=ENU='Permit User Group Description',
                ENA='Permit User Group Description';
      Description='ECSP2.00j';
      Editable=false;
      FieldClass=FlowField;
    }
    field(70;"Deny User Group Code";Code[10])
    {
      CaptionML=ENU='Deny User Group Code',
                ENA='Deny User Group Code';
      Description='ECSP2.00j';
      TableRelation="EDI Workflow User Group".Code;

      trigger OnValidate();
      begin
        IF ("Deny User Group Code" <> '') AND ("Permit User Group Code" = "Deny User Group Code") THEN
          ERROR(text16016310G);
      end;
    }
    field(80;"Deny User Group Description";Text[50])
    {
      CalcFormula=Lookup("EDI Workflow User Group".Description WHERE (Code=FIELD("Deny User Group Code")));
      CaptionML=ENU='Deny User Group Description',
                ENA='Deny User Group Description';
      Description='ECSP2.00j';
      Editable=false;
      FieldClass=FlowField;
    }
    field(90;"Visible User Group Code";Code[10])
    {
      CaptionML=ENU='Visible User Group Code',
                ENA='Visible User Group Code';
      Description='ECSP2.00j';
      TableRelation="EDI Workflow User Group".Code;

      trigger OnValidate();
      begin
        IF ("Permit User Group Code" <> '') AND ("Permit User Group Code" = "Deny User Group Code") THEN
          ERROR(text16016310G);
      end;
    }
    field(100;"Visible User Group Description";Text[50])
    {
      CalcFormula=Lookup("EDI Workflow User Group".Description WHERE (Code=FIELD("Visible User Group Code")));
      CaptionML=ENU='Visible User Group Description',
                ENA='Visible User Group Description';
      Description='ECSP2.00j';
      Editable=false;
      FieldClass=FlowField;
    }
    field(110;"Hide User Group Code";Code[10])
    {
      CaptionML=ENU='Hide User Group Code',
                ENA='Hide User Group Code';
      Description='ECSP2.00j';
      TableRelation="EDI Workflow User Group".Code;

      trigger OnValidate();
      begin
        IF ("Deny User Group Code" <> '') AND ("Permit User Group Code" = "Deny User Group Code") THEN
          ERROR(text16016310G);
      end;
    }
    field(120;"Hide User Group Description";Text[50])
    {
      CalcFormula=Lookup("EDI Workflow User Group".Description WHERE (Code=FIELD("Hide User Group Code")));
      CaptionML=ENU='Hide User Group Description',
                ENA='Hide User Group Description';
      Description='ECSP2.00j';
      Editable=false;
      FieldClass=FlowField;
    }
  }

  keys
  {
    key(Key1;"Processor Code","Handler Code","Field No.")
    {
      Clustered=true;
    }
  }

  fieldgroups
  {
  }

  var
    text16016310G : TextConst ENU='You cannot specify the same User Group code for both Allow and Deny change.',ENA='You cannot specify the same User Group code for both Allow and Deny change.';

  procedure SetTableNo();
  var
    handler : Record 70018002;
  begin
    IF NOT handler.GET("Processor Code", "Handler Code") THEN
      "Table No." := 0
    ELSE
      "Table No." := handler."Table No.";
  end;
}


table 70018012 "EDI Security Permission Buffer"
{
  // version FLS1.00

  // ECLIPSE - SupplyPoint (ECSP)
  // ----------------------------
  //   ECSP2.00j

  CaptionML=ENU='EDI Security Permission Buffer',
            ENA='EDI Security Permission Buffer';

  fields
  {
    field(1;"Table No.";Integer)
    {
      CaptionML=ENU='Table No.',
                ENA='Table No.';
      Description='ECSP2.00j';
      Editable=false;
    }
    field(2;"Field No.";Integer)
    {
      BlankZero=true;
      CaptionML=ENU='Field Change Field No.',
                ENA='Field Change Field No.';
      Description='ECSP2.00j';
      Editable=false;
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
    field(10;"Field Name";Text[50])
    {
      CaptionML=ENU='Field Name',
                ENA='Field Name';
      Description='ECSP2.00j';
      Editable=false;
    }
    field(20;"Direct Read";Boolean)
    {
      CaptionML=ENU='Read',
                ENA='Read';
      Description='ECSP2.00j';
      Editable=false;
    }
    field(30;"Direct Insert";Boolean)
    {
      CaptionML=ENU='Insert',
                ENA='Insert';
      Description='ECSP2.00j';
      Editable=false;
    }
    field(40;"Direct Modify";Boolean)
    {
      CaptionML=ENU='Modify',
                ENA='Modify';
      Description='ECSP2.00j';
      Editable=false;
    }
    field(50;"Direct Delete";Boolean)
    {
      CaptionML=ENU='Delete',
                ENA='Delete';
      Description='ECSP2.00j';
      Editable=false;
    }
    field(60;"Issued By";Option)
    {
      CaptionML=ENU='Issued By',
                ENA='Issued By';
      Description='ECSP2.00j';
      Editable=false;
      OptionCaptionML=ENU='License,"Permission Set","SupplyPoint Security"',
                      ENA='License,"Permission Set","SupplyPoint Security"';
      OptionMembers=License,"Permission Set","SupplyPoint Security";
    }
    field(70;Visible;Boolean)
    {
      CaptionML=ENU='Visible',
                ENA='Visible';
      Description='ECSP2.00j';
      Editable=false;
    }
    field(80;"Indirect Read";Boolean)
    {
      CaptionML=ENU='Indirect Read',
                ENA='Indirect Read';
      Description='ECSP2.00j';
      Editable=false;
    }
    field(90;"Indirect Insert";Boolean)
    {
      CaptionML=ENU='Indirect Insert',
                ENA='Indirect Insert';
      Description='ECSP2.00j';
      Editable=false;
    }
    field(100;"Indirect Modify";Boolean)
    {
      CaptionML=ENU='Indirect Modify',
                ENA='Indirect Modify';
      Description='ECSP2.00j';
      Editable=false;
    }
    field(110;"Indirect Delete";Boolean)
    {
      CaptionML=ENU='Indirect Delete',
                ENA='Indirect Delete';
      Description='ECSP2.00j';
      Editable=false;
    }
    field(120;"SupplyPoint Controlled";Boolean)
    {
      CaptionML=ENU='SupplyPoint Controlled',
                ENA='SupplyPoint Controlled';
      Description='ECSP2.00j';
      Editable=false;
    }
  }

  keys
  {
    key(Key1;"Table No.","Field No.")
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
    IF NOT handler.GET("Table No.", "Field No.") THEN
      "Table No." := 0
    ELSE
      "Table No." := handler."Table No.";
  end;
}


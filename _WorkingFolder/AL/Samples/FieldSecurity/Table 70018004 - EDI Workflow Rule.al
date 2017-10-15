table 70018004 "EDI Workflow Rule"
{
  // version FLS1.00

  // ECLIPSE - SupplyPoint (ECSP)
  // ----------------------------
  //   ECSP2.00j

  CaptionML=ENU='EDI / Workflow Rule',
            ENA='EDI / Workflow Rule';

  fields
  {
    field(1;"Code";Code[20])
    {
      CaptionML=ENU='Code',
                ENA='Code';
      Description='ECSP2.00j';
      NotBlank=true;
    }
    field(10;Description;Text[100])
    {
      CaptionML=ENU='Description',
                ENA='Description';
      Description='ECSP2.00j';
    }
    field(40;"Last Modified Date/Time";DateTime)
    {
      CaptionML=ENU='Last Modified Date/Time',
                ENA='Last Modified Date/Time';
      Description='ECSP2.00j';
      Editable=false;
    }
    field(80;"System Generated";Boolean)
    {
      CaptionML=ENU='System Generated',
                ENA='System Generated';
      Description='ECSP2.00j';
      Editable=false;
    }
    field(130;"Extended Description";Text[250])
    {
      CaptionML=ENU='Extended Description',
                ENA='Extended Description';
      Description='ECSP2.00j';
    }
    field(140;"Extended Description 2";Text[250])
    {
      CaptionML=ENU='Extended Description 2',
                ENA='Extended Description 2';
      Description='ECSP2.00j';
    }
    field(150;"Extended Description 3";Text[250])
    {
      CaptionML=ENU='Extended Description 2',
                ENA='Extended Description 2';
      Description='ECSP2.00j';
    }
    field(160;"Extended Description 4";Text[250])
    {
      CaptionML=ENU='Extended Description 4',
                ENA='Extended Description 4';
      Description='ECSP2.00j';
    }
    field(170;"Table No.";Integer)
    {
      BlankZero=true;
      CaptionML=ENU='Table No.',
                ENA='Table No.';
      Description='ECSP2.00j';
      Editable=false;

      trigger OnLookup();
      var
        ediTable : Record 70018010;
        ediTablePage : Page 70018004;
      begin
        CheckNoRuleSetsActive(Code);

        ediTable.SETRANGE("Table No.", "Table No.");
        IF ediTable.FINDFIRST THEN
          ediTablePage.SETRECORD(ediTable);
        ediTable.SETRANGE("Table No.");
        ediTablePage.LOOKUPMODE := TRUE;
        ediTablePage.SETTABLEVIEW(ediTable);
        IF ediTablePage.RUNMODAL = ACTION::LookupOK THEN BEGIN
          ediTablePage.GETRECORD(ediTable);
          VALIDATE("Table No.", ediTable."Table No.");
        END;
      end;

      trigger OnValidate();
      var
        "object" : Record 2000000001;
        keepOldSet : Boolean;
      begin
        CheckNoRuleSetsActive(Code);

        IF "Table No." = 0 THEN
          "Table Name" := '';

        object.SETRANGE(Type, object.Type::Table);
        object.SETRANGE(ID, "Table No.");
        IF object.FINDFIRST THEN
          "Table Name" := object.Name
        ELSE
          "Table Name" := '';

        keepOldSet := xRec."Table No." = "Table No.";

        ediFoundation.InitialiseSqlTableDataSet(Code, Source, keepOldSet)
      end;
    }
    field(180;"Table Name";Text[50])
    {
      CaptionML=ENU='Table Name',
                ENA='Table Name';
      Description='ECSP2.00j';
      Editable=false;
    }
    field(190;Type;Option)
    {
      CaptionML=ENU='Type',
                ENA='Type';
      Description='ECSP2.00j';
      OptionCaptionML=ENU=',,,,,,,,Filter',
                      ENA=',,,,,,,,Filter';
      OptionMembers=,,,,,,,,"Filter";

      trigger OnValidate();
      var
        ediFields : Record 70018003;
      begin
        CheckNoRuleSetsActive(Code);
        IF (xRec.Type = Type::Filter) AND (Type <> Type::Filter) THEN BEGIN
          ediFields.SETRANGE("Rule Code", Code);
          ediFields.DELETEALL;
        END;

        VALIDATE("Table No.");
      end;
    }
    field(200;"User Group Code";Code[10])
    {
      CaptionML=ENU='User Group Code',
                ENA='User Group Code';
      Description='ECSP2.00j';
      TableRelation="EDI Workflow User Group".Code;
    }
    field(210;"User Group Description";Text[50])
    {
      CalcFormula=Lookup("EDI Workflow User Group".Description WHERE (Code=FIELD("User Group Code")));
      CaptionML=ENU='User Group Description',
                ENA='User Group Description';
      Description='ECSP2.00j';
      Editable=false;
      FieldClass=FlowField;
    }
    field(280;"Record Type";Integer)
    {
      CaptionML=ENU='Record Type',
                ENA='Record Type';
      Description='ECSP2.00j';
      Editable=false;

      trigger OnValidate();
      var
        ediHandler : Record 70018002;
        text16016310L : TextConst ENU='You can only use the ''Table'' Record Type if the Workflow Rule is of Type ''Outbound'', ''Filters'', ''Inbound'' or ''Assessment''',ENA='You can only use the ''Table'' Record Type if the Workflow Rule is of Type ''Outbound'', ''Filters'', ''Inbound'' or ''Assessment''';
      begin
        IF xRec."Record Type" = "Record Type" THEN
          EXIT;

        CheckNoRuleSetsActive(Code);

        IF ediType.GET("Record Type") THEN
          "Record Type Name" := ediType."Type Name"
        ELSE BEGIN
          "Record Type" := 0;
          "Record Type Name" := '';
        END;

        Source := 0;
        "Source Name" := '';
      end;
    }
    field(290;"Record Type Name";Text[50])
    {
      CaptionML=ENU='Record Type Name',
                ENA='Record Type Name';
      Description='ECSP2.00j';
    }
    field(300;Source;Integer)
    {
      CaptionML=ENU='Source',
                ENA='Source';
      Description='ECSP2.00j';
      Editable=false;

      trigger OnValidate();
      var
        obj : Record 2000000001;
        localSource : Integer;
        text16016310L : TextConst ENU='''''|%1',ENA='''''|%1';
      begin
        CheckNoRuleSetsActive(Code);

        localSource := Source;
        obj.SETRANGE(Type, obj.Type::Table);
        obj.SETFILTER("Company Name", STRSUBSTNO(text16016310L,COMPANYNAME));
        obj.SETRANGE(ID, Source);
        IF obj.FINDFIRST THEN
          "Source Name" := obj.Name
        ELSE
          "Source Name" := '';
        VALIDATE("Table No.", localSource);
      end;
    }
    field(310;"Source Name";Text[50])
    {
      CaptionML=ENU='Source Name',
                ENA='Source Name';
      Description='ECSP2.00j';
    }
    field(440;"Display Sequence";Integer)
    {
      CaptionML=ENU='Display Sequence',
                ENA='Display Sequence';
      Description='ECSP2.00j';
      Editable=false;
    }
    field(450;"Display Indentation";Integer)
    {
      CaptionML=ENU='Display Indentation',
                ENA='Display Indentation';
      Description='ECSP2.00j';
      Editable=false;
    }
    field(460;"Display Name";Text[100])
    {
      CaptionML=ENU='Display Name',
                ENA='Display Name';
      Description='ECSP2.00j';
      Editable=false;
    }
    field(470;"Display Heading";Boolean)
    {
      CaptionML=ENU='Display Heading',
                ENA='Display Heading';
      Description='ECSP2.00j';
      Editable=false;
    }
    field(570;"Security Rule";Boolean)
    {
      CaptionML=ENU='Security Rule',
                ENA='Security Rule';
      Description='ECSP2.00j';
      Editable=false;
    }
    field(580;"Override User Group Code";Code[10])
    {
      CaptionML=ENU='Override User Group Code',
                ENA='Override User Group Code';
      Description='ECSP2.00j';
      TableRelation="EDI Workflow User Group".Code;
    }
    field(590;"Override User Group Desc.";Text[50])
    {
      CalcFormula=Lookup("EDI Workflow User Group".Description WHERE (Code=FIELD("Override User Group Code")));
      CaptionML=ENU='Override User Group Desc.',
                ENA='Override User Group Desc.';
      Description='ECSP2.00j';
      Editable=false;
      FieldClass=FlowField;
    }
    field(600;"Allow Override";Boolean)
    {
      CaptionML=ENU='Allow Override',
                ENA='Allow Override';
      Description='ECSP2.00j';

      trigger OnValidate();
      begin
        IF NOT "Allow Override" THEN
          "Override User Group Code" := '';
      end;
    }
    field(620;"Add-in Code";Code[20])
    {
      CaptionML=ENU='Add-in Code',
                ENA='Add-in Code';
      Description='ECSP2.00j';
      Editable=false;
    }
  }

  keys
  {
    key(Key1;"Code")
    {
      Clustered=true;
    }
    key(Key2;"Table Name",Type)
    {
    }
    key(Key3;Type,"Table Name")
    {
    }
    key(Key4;"Display Sequence")
    {
    }
  }

  fieldgroups
  {
    fieldgroup(DropDown;"Code",Description,Type,"Table Name")
    {
    }
  }

  trigger OnDelete();
  var
    "field" : Record 70018003;
    ediHandler : Record 70018002;
    ediUsers : Record 70018006;
    isAdmin : Boolean;
  begin
    ediHandler.RESET;
    ediHandler.SETRANGE("Assessment Filter", Code);
    ediHandler.MODIFYALL("Assessment Filter", '');

    field.SETRANGE("Rule Code", Code);
    field.DELETEALL;
  end;

  trigger OnInsert();
  begin
    "Last Modified Date/Time" := CURRENTDATETIME;
  end;

  trigger OnModify();
  begin
    "Last Modified Date/Time" := CURRENTDATETIME;
  end;

  trigger OnRename();
  begin
    ERROR(text16016310G);
  end;

  var
    text16016310G : TextConst ENU='You cannot rename a Workflow Rule.',ENA='You cannot rename a Workflow Rule.';
    ediFoundation : Codeunit 70018003;
    text16016311G : TextConst ENU='This field is not applicable unless the Type is %1 and the Rule Action is %2',ENA='This field is not applicable unless the Type is %1 and the Rule Action is %2';
    ediType : Record 70018009;
    calledBySetup : Boolean;
    text16016312G : TextConst ENU='This field is not applicable unless the Type is %1',ENA='This field is not applicable unless the Type is %1';

  procedure CheckNoRuleSetsActive(ruleCode : Code[20]);
  begin
    IF calledBySetup THEN
      EXIT;
  end;

  procedure StoreExtendedDescription(data : Text[1024]);
  var
    dataLength : Integer;
  begin
    dataLength := STRLEN(data);
    CASE TRUE OF
      dataLength < 251 : BEGIN
          "Extended Description" := data;
          "Extended Description 2" := '';
          "Extended Description 3" := '';
          "Extended Description 4" := '';
        END;
      dataLength < 501 : BEGIN
          "Extended Description" := COPYSTR(data, 1, 250);
          "Extended Description 2" := COPYSTR(data, 251, 250);
          "Extended Description 3" := '';
          "Extended Description 4" := '';
        END;
      dataLength < 751 : BEGIN
          "Extended Description" := COPYSTR(data, 1, 250);
          "Extended Description 2" := COPYSTR(data, 251, 250);
          "Extended Description 3" := COPYSTR(data, 501, 250);
          "Extended Description 4" := '';
        END;
      ELSE BEGIN
          "Extended Description" := COPYSTR(data, 1, 250);
          "Extended Description 2" := COPYSTR(data, 251, 250);
          "Extended Description 3" := COPYSTR(data, 501, 250);
        END;
    END;
  end;

  procedure SetCalledBySetup(value : Boolean);
  begin
    calledBySetup := value;
  end;

  procedure InitialiseSecurityRule();
  begin
    "Security Rule" := TRUE;
    VALIDATE("Record Type", ediType.Type_Table);
    Type := Type::Filter;
  end;
}


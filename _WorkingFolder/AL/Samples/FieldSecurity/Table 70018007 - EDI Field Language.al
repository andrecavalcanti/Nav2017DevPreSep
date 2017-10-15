table 70018007 "EDI Field Language"
{
  // version FLS1.00

  // ECLIPSE - SupplyPoint (ECSP)
  // ----------------------------
  //   ECSP2.00j

  CaptionML=ENU='EDI Field Language',
            ENA='EDI Field Language';
  DrillDownPageID="EDI Field Languages";
  LookupPageID="EDI Field Languages";

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
    }
    field(4;"Language Code";Code[10])
    {
      Description='ECSP2.00j';
      NotBlank=true;
      TableRelation=Language.Code;

      trigger OnValidate();
      var
        lang : Record 8;
      begin
        lang.GET("Language Code");
        "Windows Language ID" := lang."Windows Language ID";
      end;
    }
    field(5;"Parent Table No.";Integer)
    {
      CaptionML=ENU='Parent Table No.',
                ENA='Parent Table No.';
      Description='ECSP2.00j';
      Editable=false;
    }
    field(10;"Filter";Text[250])
    {
      CaptionML=ENU='Filter',
                ENA='Filter';
      Description='ECSP2.00j';
    }
    field(20;"Set Field Value";Text[250])
    {
      CaptionML=ENU='Set Field Value',
                ENA='Set Field Value';
      Description='ECSP2.00j';
    }
    field(30;"Default Value";Text[250])
    {
      CaptionML=ENU='Default Value',
                ENA='Default Value';
      Description='ECSP2.00j';
    }
    field(40;"Windows Language ID";Integer)
    {
      CaptionML=ENU='Windows Language ID',
                ENA='Windows Language ID';
      Description='ECSP2.00j';
      Editable=false;

      trigger OnValidate();
      begin
        CALCFIELDS("Windows Language Name");
      end;
    }
    field(50;"Windows Language Name";Text[80])
    {
      CalcFormula=Lookup("Windows Language".Name WHERE ("Language ID"=FIELD("Windows Language ID")));
      CaptionML=ENU='Windows Language Name',
                ENA='Windows Language Name';
      Description='ECSP2.00j';
      Editable=false;
      FieldClass=FlowField;
    }
  }

  keys
  {
    key(Key1;"Rule Code","Table No.","Field No.","Language Code","Parent Table No.")
    {
      Clustered=true;
    }
    key(Key2;"Rule Code","Table No.","Field No.","Parent Table No.","Windows Language ID")
    {
    }
  }

  fieldgroups
  {
  }
}


table 70018013 "EDI Security Table Permission"
{
  // version FLS1.00

  // ECLIPSE - SupplyPoint (ECSP)
  // ----------------------------
  //   ECSP2.00j

  CaptionML=ENU='EDI Security Table Permission',
            ENA='EDI Security Table Permission';

  fields
  {
    field(1;"Processor Code";Code[10])
    {
      CaptionML=ENU='Processor Code',
                ENA='Processor Code';
      Description='ECSP2.00j';
      NotBlank=true;
      TableRelation="EDI Processor".Code;
    }
    field(2;"Handler Code";Code[20])
    {
      CaptionML=ENU='Handler Code',
                ENA='Handler Code';
      Description='ECSP2.00j';
      NotBlank=true;
      TableRelation=Table16016312.Field2 WHERE (Field1=FIELD("Processor Code"));
    }
    field(10;"Permit Insert User Group Code";Code[10])
    {
      CaptionML=ENU='Permit Insert User Group Code',
                ENA='Permit Insert User Group Code';
      Description='ECSP2.00j';
      TableRelation="EDI Workflow User Group".Code;

      trigger OnValidate();
      begin
        IF ("Permit Insert User Group Code" <> '') AND ("Permit Insert User Group Code" = "Deny Insert User Group Code") THEN
          ERROR(text16016317G);
      end;
    }
    field(20;"Deny Insert User Group Code";Code[10])
    {
      CaptionML=ENU='Deny Insert User Group Code',
                ENA='Deny Insert User Group Code';
      Description='ECSP2.00j';
      TableRelation="EDI Workflow User Group".Code;

      trigger OnValidate();
      begin
        IF ("Deny Insert User Group Code" <> '') AND ("Permit Insert User Group Code" = "Deny Insert User Group Code") THEN
          ERROR(text16016317G);
      end;
    }
    field(30;"Permit Modify User Group Code";Code[10])
    {
      CaptionML=ENU='Permit Modify User Group Code',
                ENA='Permit Modify User Group Code';
      Description='ECSP2.00j';
      TableRelation="EDI Workflow User Group".Code;

      trigger OnValidate();
      begin
        IF ("Permit Modify User Group Code" <> '') AND ("Permit Modify User Group Code" = "Deny Modify User Group Code") THEN
          ERROR(text16016317G);
      end;
    }
    field(40;"Deny Modify User Group Code";Code[10])
    {
      CaptionML=ENU='Deny Modify User Group Code',
                ENA='Deny Modify User Group Code';
      Description='ECSP2.00j';
      TableRelation="EDI Workflow User Group".Code;

      trigger OnValidate();
      begin
        IF ("Deny Modify User Group Code" <> '') AND ("Permit Modify User Group Code" = "Deny Modify User Group Code") THEN
          ERROR(text16016317G);
      end;
    }
    field(50;"Permit Delete User Group Code";Code[10])
    {
      CaptionML=ENU='Permit Delete User Group Code',
                ENA='Permit Delete User Group Code';
      Description='ECSP2.00j';
      TableRelation="EDI Workflow User Group".Code;

      trigger OnValidate();
      begin
        IF ("Permit Delete User Group Code" <> '') AND ("Permit Delete User Group Code" = "Deny Delete User Group Code") THEN
          ERROR(text16016317G);
      end;
    }
    field(60;"Deny Delete User Group Code";Code[10])
    {
      CaptionML=ENU='Deny Delete User Group Code',
                ENA='Deny Delete User Group Code';
      Description='ECSP2.00j';
      TableRelation="EDI Workflow User Group".Code;

      trigger OnValidate();
      begin
        IF ("Deny Delete User Group Code" <> '') AND ("Permit Delete User Group Code" = "Deny Delete User Group Code") THEN
          ERROR(text16016317G);
      end;
    }
  }

  keys
  {
    key(Key1;"Processor Code","Handler Code")
    {
      Clustered=true;
    }
  }

  fieldgroups
  {
  }

  var
    text16016317G : TextConst ENU='You cannot specify the same User Group code for both Allow and Deny actions.',ENA='You cannot specify the same User Group code for both Allow and Deny actions.';
}


table 70018006 "EDI Workflow User"
{
  // version FLS1.00

  // ECLIPSE - SupplyPoint (ECSP)
  // ----------------------------
  //   ECSP2.00j

  CaptionML=ENU='EDI Workflow User',
            ENA='EDI Workflow User';
  DrillDownPageID="User Setup";
  LookupPageID="User Setup";

  fields
  {
    field(1;"Workflow Group Code";Code[10])
    {
      CaptionML=ENU='Workflow Group Code',
                ENA='Workflow Group Code';
      Description='ECSP2.00j';
      NotBlank=true;
      TableRelation="EDI Workflow User Group".Code;
    }
    field(2;"User ID";Code[50])
    {
      CaptionML=ENU='User ID',
                ENA='User ID';
      Description='ECSP2.00j';
      NotBlank=true;
      TableRelation=User."User Name";
      //This property is currently not supported
      //TestTableRelation=false;
      ValidateTableRelation=false;

      trigger OnLookup();
      var
        userMgt : Codeunit 418;
      begin
        userMgt.LookupUserID("User ID");
      end;

      trigger OnValidate();
      var
        userMgt : Codeunit 418;
      begin
        userMgt.ValidateUserID("User ID");
      end;
    }
    field(110;"Allow Override Field Security";Boolean)
    {
      CaptionML=ENU='Allow Override Field Security',
                ENA='Allow Override Field Security';
      Description='ECSP2.00j';
      Editable=false;
    }
    field(120;"Add-in Code";Code[20])
    {
      CaptionML=ENU='Add-in Code',
                ENA='Add-in Code';
      Description='ECSP2.00j';
      Editable=false;
    }
  }

  keys
  {
    key(Key1;"Workflow Group Code","User ID")
    {
      Clustered=true;
    }
  }

  fieldgroups
  {
  }
}


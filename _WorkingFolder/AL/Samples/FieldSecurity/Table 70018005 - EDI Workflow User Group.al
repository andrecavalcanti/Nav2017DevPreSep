table 70018005 "EDI Workflow User Group"
{
  // version FLS1.00

  // ECLIPSE - SupplyPoint (ECSP)
  // ----------------------------
  //   ECSP2.00j

  CaptionML=ENU='EDI Workflow User Group',
            ENA='EDI Workflow User Group';

  fields
  {
    field(1;"Code";Code[10])
    {
      Description='ECSP2.00j';
      NotBlank=true;
    }
    field(10;Description;Text[50])
    {
      Description='ECSP2.00j';
    }
    field(20;Method;Option)
    {
      CaptionML=ENU='Method',
                ENA='Method';
      Description='ECSP2.00j';
      OptionCaptionML=ENU='" ",Notification,"E-Mail","Notify And E-Mail"',
                      ENA='" ",Notification,"E-Mail","Notify And E-Mail"';
      OptionMembers=" ",Notification,"E-Mail","Notify And E-Mail";
    }
    field(100;"Allow Override Field Security";Boolean)
    {
      CaptionML=ENU='Allow Override Field Security',
                ENA='Allow Override Field Security';
      Description='ECSP2.00j';

      trigger OnValidate();
      var
        ediUser : Record 70018006;
      begin
        ediUser.SETRANGE("Workflow Group Code", Code);
        ediUser.MODIFYALL("Allow Override Field Security", "Allow Override Field Security");
      end;
    }
    field(110;"Add-in Code";Code[20])
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
  }

  fieldgroups
  {
  }
}


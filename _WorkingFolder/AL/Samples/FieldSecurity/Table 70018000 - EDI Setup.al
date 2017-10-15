table 70018000 "EDI Setup"
{
  // version FLS1.00

  // ECLIPSE - SupplyPoint (ECSP)
  // ----------------------------
  //   ECSP2.00j

  CaptionML=ENU='EDI Setup',
            ENA='EDI Setup';

  fields
  {
    field(1;"Primary Key";Code[10])
    {
      CaptionML=ENU='Primary Key',
                ENA='Primary Key';
      Description='ECSP2.00j';
    }
    field(450;"Security Active";Boolean)
    {
      CaptionML=ENU='Security Active',
                ENA='Security Active';
      Description='ECSP2.00j';
    }
  }

  keys
  {
    key(Key1;"Primary Key")
    {
      Clustered=true;
    }
  }

  fieldgroups
  {
  }

  var
    ediFoundation : Codeunit 70018003;
}


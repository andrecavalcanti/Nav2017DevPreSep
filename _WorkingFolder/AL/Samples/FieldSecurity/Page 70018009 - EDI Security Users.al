page 70018009 "EDI Security Users"
{
  // version FLS1.00

  // ECLIPSE - SupplyPoint (ECSP)
  // ----------------------------
  //   ECSP2.00j

  CaptionML=ENU='Security Users',
            ENA='Security Users';
  PageType=List;
  SourceTable="EDI Workflow User";

  layout
  {
    area(content)
    {
      repeater(Group)
      {
        field("Workflow Group Code";"Workflow Group Code")
        {
          ApplicationArea=Basic;
          CaptionML=ENU='Group Code',
                    ENA='Group Code';
          Editable=false;
        }
        field("User ID";"User ID")
        {
          ApplicationArea=Basic;
        }
        field("Allow Override Field Security";"Allow Override Field Security")
        {
          ApplicationArea=Basic;
        }
      }
    }
    area(factboxes)
    {
      systempart(Part1101235007;Notes)
      {
        ApplicationArea=Basic;
      }
      systempart(Part1101235008;Links)
      {
        ApplicationArea=Basic;
      }
    }
  }

  actions
  {
  }
}


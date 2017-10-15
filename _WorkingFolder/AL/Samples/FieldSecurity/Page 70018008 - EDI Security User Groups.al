page 70018008 "EDI Security User Groups"
{
  // version FLS1.00

  // ECLIPSE - SupplyPoint (ECSP)
  // ----------------------------
  //   ECSP2.00j

  CaptionML=ENU='Security User Groups',
            ENA='Security User Groups';
  PageType=List;
  SourceTable="EDI Workflow User Group";

  layout
  {
    area(content)
    {
      repeater(Group)
      {
        field("Code";Code)
        {
          ApplicationArea=Basic;
        }
        field(Description;Description)
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
      systempart(Part1101235005;Notes)
      {
        ApplicationArea=Basic;
      }
      systempart(Part1101235006;Links)
      {
        ApplicationArea=Basic;
      }
    }
  }

  actions
  {
    area(navigation)
    {
      action("&Users")
      {
        ApplicationArea=Basic;
        CaptionML=ENU='&Users',
                  ENA='&Users';
        Image=Users;
        Promoted=true;
        //The property 'PromotedCategory' can only be set if the property 'Promoted' is set to 'true'
        //PromotedCategory=Process;
        //The property 'PromotedIsBig' can only be set if the property 'Promoted' is set to 'true'
        //PromotedIsBig=true;
        RunObject=Page 16016428;
        RunPageLink=Field1=FIELD(Code);
      }
    }
  }
}


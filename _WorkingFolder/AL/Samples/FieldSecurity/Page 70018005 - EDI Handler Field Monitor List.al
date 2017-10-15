page 70018005 "EDI Handler Field Monitor List"
{
  // version FLS1.00

  // ECLIPSE - SupplyPoint (ECSP)
  // ----------------------------
  //   ECSP2.00j

  CaptionML=ENU='EDI / Workflow Handler Field Monitors',
            ENA='EDI / Workflow Handler Field Monitors';
  PageType=List;
  SourceTable="EDI Handler Field Monitor";

  layout
  {
    area(content)
    {
      repeater(Group)
      {
        field("Processor Code";"Processor Code")
        {
          ApplicationArea=Basic;
          Visible=false;
        }
        field("Handler Code";"Handler Code")
        {
          ApplicationArea=Basic;
          Visible=false;
        }
        field("Field No.";"Field No.")
        {
          ApplicationArea=Basic;
        }
        field("Field Name";"Field Name")
        {
          ApplicationArea=Basic;
        }
        field("Processor Description";"Processor Description")
        {
          ApplicationArea=Basic;
          Visible=false;
        }
        field("Handler Description";"Handler Description")
        {
          ApplicationArea=Basic;
          Visible=false;
        }
        field("Table No.";"Table No.")
        {
          ApplicationArea=Basic;
          Visible=false;
        }
      }
    }
  }

  actions
  {
  }
}


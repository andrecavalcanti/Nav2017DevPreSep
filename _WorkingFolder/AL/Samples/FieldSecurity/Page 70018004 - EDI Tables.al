page 70018004 "EDI Tables"
{
  // version FLS1.00

  // ECLIPSE - SupplyPoint (ECSP)
  // ----------------------------
  //   ECSP2.00j

  CaptionML=ENU='EDI / Workflow Tables',
            ENA='EDI / Workflow Tables';
  PageType=List;
  SourceTable="EDI Table";

  layout
  {
    area(content)
    {
      repeater(Group)
      {
        field("Table No.";"Table No.")
        {
          ApplicationArea=Basic;
        }
        field("Table Name";"Table Name")
        {
          ApplicationArea=Basic;
        }
        field("Parent Table No.";"Parent Table No.")
        {
          ApplicationArea=Basic;
          Visible=showAllColumns;
        }
        field("Parent Table Name";"Parent Table Name")
        {
          ApplicationArea=Basic;
        }
        field("Change Trigger";"Change Trigger")
        {
          ApplicationArea=Basic;
        }
        field("Field Trigger";"Field Trigger")
        {
          ApplicationArea=Basic;
        }
        field("Action Trigger";"Action Trigger")
        {
          ApplicationArea=Basic;
        }
        field("Key Field No. 1";"Key Field No. 1")
        {
          ApplicationArea=Basic;
          Visible=showAllColumns;
        }
        field("Key Field No. 2";"Key Field No. 2")
        {
          ApplicationArea=Basic;
          Visible=showAllColumns;
        }
        field("Key Field No. 3";"Key Field No. 3")
        {
          ApplicationArea=Basic;
          Visible=showAllColumns;
        }
        field("Key Field No. 4";"Key Field No. 4")
        {
          ApplicationArea=Basic;
          Visible=showAllColumns;
        }
        field("Key Field No. 5";"Key Field No. 5")
        {
          ApplicationArea=Basic;
          Visible=showAllColumns;
        }
        field("Key Field No. 6";"Key Field No. 6")
        {
          ApplicationArea=Basic;
          Visible=showAllColumns;
        }
        field("Key Field No. 7";"Key Field No. 7")
        {
          ApplicationArea=Basic;
          Visible=showAllColumns;
        }
        field("Key Field No. 8";"Key Field No. 8")
        {
          ApplicationArea=Basic;
          Visible=showAllColumns;
        }
        field("Key Field No. 9";"Key Field No. 9")
        {
          ApplicationArea=Basic;
          Visible=showAllColumns;
        }
        field("Key Field No. 10";"Key Field No. 10")
        {
          ApplicationArea=Basic;
          Visible=showAllColumns;
        }
      }
    }
  }

  actions
  {
  }

  var
    [InDataSet]
    showAllColumns : Boolean;

  procedure SetShowAllColumns();
  begin
    showAllColumns := TRUE;
  end;
}


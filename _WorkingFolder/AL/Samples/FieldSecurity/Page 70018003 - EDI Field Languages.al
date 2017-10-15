page 70018003 "EDI Field Languages"
{
  // version FLS1.00

  // ECLIPSE - SupplyPoint (ECSP)
  // ----------------------------
  //   ECSP2.00j

  CaptionML=ENU='Field Languages',
            ENA='Field Languages';
  PageType=List;
  SourceTable="EDI Field Language";

  layout
  {
    area(content)
    {
      repeater(Group)
      {
        field("Rule Code";"Rule Code")
        {
          ApplicationArea=Basic;
          Editable=false;
          Visible=false;
        }
        field("Table No.";"Table No.")
        {
          ApplicationArea=Basic;
          Visible=false;
        }
        field("Field No.";"Field No.")
        {
          ApplicationArea=Basic;
          Editable=false;
          Visible=false;
        }
        field("Language Code";"Language Code")
        {
          ApplicationArea=Basic;
        }
        field("Windows Language Name";"Windows Language Name")
        {
          ApplicationArea=Basic;
        }
        field("Filter";Filter)
        {
          ApplicationArea=Basic;
        }
        field("Set Field Value";"Set Field Value")
        {
          ApplicationArea=Basic;
          Visible=NOT isSecurity;
        }
        field("Default Value";"Default Value")
        {
          ApplicationArea=Basic;
          Visible=NOT isSecurity;
        }
      }
    }
    area(factboxes)
    {
      systempart(Part1101235010;Notes)
      {
        ApplicationArea=Basic;
      }
      systempart(Part1101235011;Links)
      {
        ApplicationArea=Basic;
      }
    }
  }

  actions
  {
  }

  trigger OnOpenPage();
  begin
    IF ediRule.GET("Rule Code") THEN
      isSecurity := ediRule."Security Rule"
    ELSE
      isSecurity := FALSE;
  end;

  var
    [InDataSet]
    isSecurity : Boolean;
    ediRule : Record 70018004;
}


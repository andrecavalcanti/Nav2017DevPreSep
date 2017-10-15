page 70018000 "SupplyPoint Nav Objects"
{
  // version FLS1.00

  // ECLIPSE - SupplyPoint (ECSP)
  // ----------------------------
  //   ECSP2.00j

  CaptionML=ENU='Nav Objects',
            ENA='Nav Objects';
  DeleteAllowed=false;
  Editable=false;
  InsertAllowed=false;
  ModifyAllowed=false;
  PageType=List;
  SourceTable="Object";

  layout
  {
    area(content)
    {
      repeater(Group)
      {
        field(Type;Type)
        {
          ApplicationArea=Basic;
          Visible=showType;
        }
        field(ID;ID)
        {
          ApplicationArea=Basic;
        }
        field(Name;Name)
        {
          ApplicationArea=Basic;
        }
      }
    }
  }

  actions
  {
  }

  var
    [InDataSet]
    showType : Boolean;

  procedure SetShowType(show : Boolean);
  begin
    showType := show;
  end;
}


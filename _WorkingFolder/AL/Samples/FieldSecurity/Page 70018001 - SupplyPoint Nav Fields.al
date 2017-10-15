page 70018001 "SupplyPoint Nav Fields"
{
  // version FLS1.00

  // ECLIPSE - SupplyPoint (ECSP)
  // ----------------------------
  //   ECSP2.00j

  CaptionML=ENU='Fields',
            ENA='Fields';
  DeleteAllowed=false;
  Editable=false;
  InsertAllowed=false;
  ModifyAllowed=false;
  PageType=List;
  SourceTable="Field";

  layout
  {
    area(content)
    {
      repeater(Group1)
      {
        field(TableNo;TableNo)
        {
          ApplicationArea=Basic;
          CaptionML=ENU='TableNo',
                    ENA='TableNo';
          Visible=false;
        }
        field("No.";"No.")
        {
          ApplicationArea=Basic;
          CaptionML=ENU='No.',
                    ENA='No.';
        }
        field(TableName;TableName)
        {
          ApplicationArea=Basic;
          CaptionML=ENU='TableName',
                    ENA='TableName';
          Visible=false;
        }
        field(FieldName;FieldName)
        {
          ApplicationArea=Basic;
          CaptionML=ENU='FieldName',
                    ENA='FieldName';
        }
        field(Type;Type)
        {
          ApplicationArea=Basic;
          CaptionML=ENU='Type',
                    ENA='Type';
        }
        field(Class;Class)
        {
          ApplicationArea=Basic;
          CaptionML=ENU='Class',
                    ENA='Class';
        }
      }
    }
    area(factboxes)
    {
      systempart(Part1900383207;Links)
      {
        ApplicationArea=Basic;
        Visible=false;
      }
      systempart(Part1905767507;Notes)
      {
        ApplicationArea=Basic;
        Visible=false;
      }
    }
  }

  actions
  {
  }
}


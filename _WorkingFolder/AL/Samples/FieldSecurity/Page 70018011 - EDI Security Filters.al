page 70018011 "EDI Security Filters"
{
  // version FLS1.00

  // ECLIPSE - SupplyPoint (ECSP)
  // ----------------------------
  //   ECSP2.00j

  CaptionML=ENU='Security Filters',
            ENA='Security Filters';
  CardPageID="EDI Security Filter";
  Editable=false;
  PageType=List;
  PromotedActionCategoriesML=ENU='New,Process,Report,Rule',
                             ENA='New,Process,Report,Rule';
  RefreshOnActivate=true;
  SaveValues=true;
  SourceTable="EDI Workflow Rule";
  SourceTableView=SORTING(Code)
                  ORDER(Ascending)
                  WHERE("Security Rule"=CONST(true));

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
        field(Type;Type)
        {
          ApplicationArea=Basic;
          Visible=false;
        }
        field("Table No.";"Table No.")
        {
          ApplicationArea=Basic;
          Visible=false;
        }
        field("Table Name";"Table Name")
        {
          ApplicationArea=Basic;
          Visible=false;
        }
      }
    }
    area(factboxes)
    {
      systempart(Part1101235011;Notes)
      {
        ApplicationArea=Basic;
      }
      systempart(Part1101235012;Links)
      {
        ApplicationArea=Basic;
      }
    }
  }

  actions
  {
  }

  trigger OnInsertRecord(BelowxRec : Boolean) : Boolean;
  begin
    InitialiseSecurityRule;
  end;

  trigger OnNewRecord(BelowxRec : Boolean);
  begin
    InitialiseSecurityRule;
  end;

  var
    ediFoundation : Codeunit 70018003;
}


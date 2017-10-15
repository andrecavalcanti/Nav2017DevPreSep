page 70018012 "EDI Security Filter"
{
  // version FLS1.00

  // ECLIPSE - SupplyPoint (ECSP)
  // ----------------------------
  //   ECSP2.00j

  CaptionML=ENU='Security Filter',
            ENA='Security Filter';
  PageType=Document;
  PromotedActionCategoriesML=ENU='New,Process,Report,Rule',
                             ENA='New,Process,Report,Rule';
  SourceTable="EDI Workflow Rule";
  SourceTableView=SORTING(Code)
                  ORDER(Ascending)
                  WHERE("Security Rule"=CONST(true));

  layout
  {
    area(content)
    {
      group(General)
      {
        CaptionML=ENU='General',
                  ENA='General';
        field("Code";Code)
        {
          ApplicationArea=Basic;
        }
        field(Description;Description)
        {
          ApplicationArea=Basic;
        }
        field("Table No.";"Table No.")
        {
          ApplicationArea=Basic;
          AssistEdit=false;
          DrillDown=false;
          Editable=false;
          Lookup=false;
        }
        field("Source Name";"Source Name")
        {
          ApplicationArea=Basic;
          CaptionML=ENU='Source',
                    ENA='Source';

          trigger OnLookup(Text : Text) : Boolean;
          begin
            VALIDATE(Source, ediFoundation.LookupSource(99, "Record Type", Source));
          end;

          trigger OnValidate();
          begin
            VALIDATE(Source, ediFoundation.CheckSource(99, "Record Type", "Source Name"));
          end;
        }
      }
      part(ediFieldAssess;"EDI Security Filter Fields")
      {
        ApplicationArea=Basic;
        SubPageLink="Rule Code"=FIELD(Code),
"Table No."=FIELD("Table No.");
      }
    }
    area(factboxes)
    {
      systempart(Part1101235020;Notes)
      {
        ApplicationArea=Basic;
      }
      systempart(Part1101235021;Links)
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

  trigger OnOpenPage();
  var
    rule : Record 70018004;
  begin
  end;

  var
    ediFoundation : Codeunit 70018003;
}


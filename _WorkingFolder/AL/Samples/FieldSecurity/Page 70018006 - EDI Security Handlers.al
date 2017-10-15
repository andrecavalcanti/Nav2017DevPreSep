page 70018006 "EDI Security Handlers"
{
  // version FLS1.00

  // ECLIPSE - SupplyPoint (ECSP)
  // ----------------------------
  //   ECSP2.00j

  CaptionML=ENU='Security Handlers',
            ENA='Security Handlers';
  CardPageID="EDI Security Handler Card";
  Editable=false;
  PageType=List;
  SaveValues=true;
  SourceTable="EDI Handler";
  SourceTableView=SORTING("Processor Code",Code)
                  ORDER(Ascending)
                  WHERE(Direction=CONST(Security));

  layout
  {
    area(content)
    {
      repeater(Group)
      {
        field("Code";Code)
        {
          ApplicationArea=Basic;
          Editable=false;
          NotBlank=true;
        }
        field(Description;Description)
        {
          ApplicationArea=Basic;
        }
        field("Source Name";"Source Name")
        {
          ApplicationArea=Basic;
          CaptionML=ENU='Source',
                    ENA='Source';
        }
        field(Active;Active)
        {
          ApplicationArea=Basic;
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
    area(processing)
    {
      action("Sync. Security Tables")
      {
        ApplicationArea=Basic;
        CaptionML=ENU='Sync. Security Tables',
                  ENA='Sync. Security Tables';
        Image=Apply;
        Promoted=true;
        //The property 'PromotedCategory' can only be set if the property 'Promoted' is set to 'true'
        //PromotedCategory=Process;
        //The property 'PromotedIsBig' can only be set if the property 'Promoted' is set to 'true'
        //PromotedIsBig=true;

        trigger OnAction();
        begin
          ediFoundation.SyncEDISecurityTables(TRUE, TRUE, FALSE);
        end;
      }
      action("Effective Permissions")
      {
        ApplicationArea=Basic;
        CaptionML=ENU='Effective Permissions',
                  ENA='Effective Permissions';
        Image=Lock;
        Promoted=true;
        //The property 'PromotedCategory' can only be set if the property 'Promoted' is set to 'true'
        //PromotedCategory=Process;
        //The property 'PromotedIsBig' can only be set if the property 'Promoted' is set to 'true'
        //PromotedIsBig=true;

        trigger OnAction();
        var
          effPerm : Page 70018014;
        begin
          effPerm.SetProperties("Table No.", "Processor Code", Code);
          effPerm.RUNMODAL;
        end;
      }
    }
  }

  trigger OnInsertRecord(BelowxRec : Boolean) : Boolean;
  begin
    InitialiseSecurityHandler;
  end;

  trigger OnNewRecord(BelowxRec : Boolean);
  begin
    InitialiseSecurityHandler;
  end;

  var
    ediFoundation : Codeunit 70018003;
}


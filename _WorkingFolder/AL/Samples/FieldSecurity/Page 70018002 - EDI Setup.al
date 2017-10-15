page 70018002 "EDI Setup"
{
  // version FLS1.00

  // ECLIPSE - SupplyPoint (ECSP)
  // ----------------------------
  //   ECSP2.00j

  CaptionML=ENU='Security Setup',
            ENA='Security Setup';
  PageType=Card;
  SaveValues=true;
  SourceTable="EDI Setup";

  layout
  {
    area(content)
    {
      group(General)
      {
        CaptionML=ENU='General',
                  ENA='General';
        field("Security Active";"Security Active")
        {
          ApplicationArea=Basic;
          Visible=isSecurityOk;
        }
      }
    }
    area(factboxes)
    {
      systempart(Part1101235034;Notes)
      {
        ApplicationArea=Basic;
      }
      systempart(Part1101235033;Links)
      {
        ApplicationArea=Basic;
      }
    }
  }

  actions
  {
    area(processing)
    {
      action("Initialise Security System")
      {
        ApplicationArea=Basic;
        CaptionML=ENU='Initialise Security System',
                  ENA='Initialise Security System';
        Image=LogSetup;

        trigger OnAction();
        var
          initialisation : Codeunit 70018004;
        begin
          initialisation.RUN;
        end;
      }
      action("Sync. Security Tables")
      {
        ApplicationArea=Basic;
        CaptionML=ENU='Sync. Security Tables',
                  ENA='Sync. Security Tables';
        Image=Apply;
        Visible=isSecurityOk;

        trigger OnAction();
        begin
          ediFoundation.SyncEDISecurityTables(TRUE, FALSE, FALSE);
        end;
      }
    }
  }

  trigger OnOpenPage();
  begin
    IF NOT GET THEN BEGIN
      INIT;
      INSERT;
      CurrPage.UPDATE(FALSE);
    END;
    isSecurityOk := TRUE;
  end;

  var
    ediFoundation : Codeunit 70018003;
    [InDataSet]
    isSecurityOk : Boolean;
}


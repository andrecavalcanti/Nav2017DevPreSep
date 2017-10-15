page 70018007 "EDI Security Handler Card"
{
  // version FLS1.00

  // ECLIPSE - SupplyPoint (ECSP)
  // ----------------------------
  //   ECSP2.00j

  CaptionML=ENU='Security Handler',
            ENA='Security Handler';
  PageType=Card;
  RefreshOnActivate=true;
  SaveValues=true;
  SourceTable="EDI Handler";
  SourceTableView=SORTING("Processor Code",Code)
                  ORDER(Ascending)
                  WHERE(Direction=CONST(Security));

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

          trigger OnValidate();
          begin
            GetTablePermissions;
          end;
        }
        field(Description;Description)
        {
          ApplicationArea=Basic;
        }
        field(Active;Active)
        {
          ApplicationArea=Basic;
        }
        field("Table No.";"Table No.")
        {
          ApplicationArea=Basic;
          AssistEdit=false;
          DrillDown=false;
          Lookup=false;
        }
      }
      group(Settings)
      {
        CaptionML=ENU='Settings',
                  ENA='Settings';
        field(SecuritySourceName;"Source Name")
        {
          ApplicationArea=Basic;
          CaptionML=ENU='Source',
                    ENA='Source';
          DrillDown=true;
          Lookup=true;

          trigger OnLookup(Text : Text) : Boolean;
          begin
            VALIDATE(Source, ediFoundation.LookupSource(Direction, Type, "Table No."));
          end;

          trigger OnValidate();
          begin
            VALIDATE(Source, ediFoundation.CheckSource(Direction, Type, "Source Name"));
          end;
        }
        field("Assessment Filter";"Assessment Filter")
        {
          ApplicationArea=Basic;
          CaptionML=ENU='Security Rule',
                    ENA='Security Rule';

          trigger OnLookup(Text : Text) : Boolean;
          var
            rule : Record 70018004;
            rulePage : Page 70018011;
          begin
            rule.SETRANGE(Type, rule.Type::Filter);
            rule.SETRANGE("Table No.", "Table No.");
            rule.SETRANGE("Display Heading", FALSE);
            rule.SETRANGE("Security Rule", TRUE);
            IF "Assessment Filter" <> '' THEN BEGIN
              rule.SETRANGE(Code, "Assessment Filter");
              IF rule.FINDFIRST THEN
                rulePage.SETRECORD(rule);
            END;
            rule.SETRANGE(Code);
            rulePage.SETTABLEVIEW(rule);
            rulePage.LOOKUPMODE := TRUE;
            IF rulePage.RUNMODAL = ACTION::LookupOK THEN BEGIN
              rulePage.GETRECORD(rule);
              VALIDATE("Assessment Filter", rule.Code);
            END;
          end;

          trigger OnValidate();
          var
            rule : Record 70018004;
            text16016310L : TextConst ENU='Security Rule ''%1'' is not valid.',ENA='Security Rule ''%1'' is not valid.';
          begin
            IF "Assessment Filter" = '' THEN
              EXIT;

            rule.SETRANGE(Type, rule.Type::Filter);
            rule.SETRANGE("Table No.", "Table No.");
            rule.SETRANGE("Display Heading", FALSE);
            rule.SETRANGE("Security Rule", TRUE);
            rule.SETRANGE(Code, "Assessment Filter");
            IF NOT rule.FINDFIRST THEN
              ERROR(text16016310L, "Assessment Filter");
          end;
        }
      }
      part("Table Permissions";"EDI Security Table Permission")
      {
        ApplicationArea=Basic;
        CaptionML=ENU='Table Permissions',
                  ENA='Table Permissions';
        SubPageLink="Processor Code"=FIELD("Processor Code"),
"Handler Code"=FIELD(Code);
      }
      part(fieldMonitor;"EDI Security Fields")
      {
        ApplicationArea=Basic;
        CaptionML=ENU='Fields',
                  ENA='Fields';
        ShowFilter=false;
        SubPageLink="Processor Code"=FIELD("Processor Code"),
"Handler Code"=FIELD(Code);
      }
    }
    area(factboxes)
    {
      systempart(Part1101235045;Notes)
      {
        ApplicationArea=Basic;
      }
      systempart(Part1101235046;Links)
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

  trigger OnAfterGetCurrRecord();
  begin
    GetTablePermissions;
  end;

  trigger OnInsertRecord(BelowxRec : Boolean) : Boolean;
  begin
    InitialiseSecurityHandler;
  end;

  trigger OnNewRecord(BelowxRec : Boolean);
  begin
    InitialiseSecurityHandler;
  end;

  trigger OnOpenPage();
  begin
    GetTablePermissions;
  end;

  var
    ediFoundation : Codeunit 70018003;
    tablePerm : Record 70018013;

  local procedure GetTablePermissions();
  begin
    IF ("Processor Code" <> '') AND (Code <> '') THEN BEGIN
      IF NOT tablePerm.GET("Processor Code", Code) THEN BEGIN
        tablePerm.INIT;
        tablePerm."Processor Code" := "Processor Code";
        tablePerm."Handler Code" := Code;
        tablePerm.INSERT;
      END;
    END;
  end;
}


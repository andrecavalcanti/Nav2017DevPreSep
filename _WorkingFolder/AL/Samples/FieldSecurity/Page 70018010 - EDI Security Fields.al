page 70018010 "EDI Security Fields"
{
  // version FLS1.00

  // ECLIPSE - SupplyPoint (ECSP)
  // ----------------------------
  //   ECSP2.00j

  CaptionML=ENU='Security Fields',
            ENA='Security Fields';
  PageType=ListPart;
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
          CaptionML=ENU='Field No.',
                    ENA='Field No.';
        }
        field("Field Name";"Field Name")
        {
          ApplicationArea=Basic;
        }
        field("Permit User Group Code";"Permit User Group Code")
        {
          ApplicationArea=Basic;

          trigger OnLookup(Text : Text) : Boolean;
          begin
            VALIDATE("Permit User Group Code", ediFoundation.LookupSecurityUserGroup("Permit User Group Code"));
          end;
        }
        field("Deny User Group Code";"Deny User Group Code")
        {
          ApplicationArea=Basic;

          trigger OnLookup(Text : Text) : Boolean;
          begin
            VALIDATE("Deny User Group Code", ediFoundation.LookupSecurityUserGroup("Deny User Group Code"));
          end;
        }
        field("Visible User Group Code";"Visible User Group Code")
        {
          ApplicationArea=Basic;
          Visible=false;

          trigger OnLookup(Text : Text) : Boolean;
          begin
            VALIDATE("Visible User Group Code", ediFoundation.LookupSecurityUserGroup("Visible User Group Code"));
          end;
        }
        field("Hide User Group Description";"Hide User Group Description")
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

  trigger OnOpenPage();
  var
    processor : Record 70018003;
  begin
  end;

  var
    ediFoundation : Codeunit 70018003;
}


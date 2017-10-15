page 70018016 "EDI Security Table Permission"
{
  // version FLS1.00

  // ECLIPSE - SupplyPoint (ECSP)
  // ----------------------------
  //   ECSP2.00j

  CaptionML=ENU='Security Table Permission',
            ENA='Security Table Permission';
  DeleteAllowed=false;
  InsertAllowed=false;
  PageType=CardPart;
  ShowFilter=false;
  SourceTable="EDI Security Table Permission";

  layout
  {
    area(content)
    {
      group(Group1101235009)
      {
        grid(Group1101235008)
        {
          GridLayout=Rows;
          group(Insert)
          {
            CaptionML=ENU='Insert',
                      ENA='Insert';
            field("Permit Insert User Group Code";"Permit Insert User Group Code")
            {
              ApplicationArea=Basic;
              CaptionML=ENU='Permit',
                        ENA='Permit';

              trigger OnLookup(Text : Text) : Boolean;
              begin
                VALIDATE("Permit Insert User Group Code", ediFoundation.LookupSecurityUserGroup("Permit Insert User Group Code"));
              end;
            }
            field("Deny Insert User Group Code";"Deny Insert User Group Code")
            {
              ApplicationArea=Basic;
              CaptionML=ENU='Deny',
                        ENA='Deny';

              trigger OnLookup(Text : Text) : Boolean;
              begin
                VALIDATE("Deny Insert User Group Code", ediFoundation.LookupSecurityUserGroup("Deny Insert User Group Code"));
              end;
            }
          }
          group(Modify)
          {
            CaptionML=ENU='Modify',
                      ENA='Modify';
            field("Permit Modify User Group Code";"Permit Modify User Group Code")
            {
              ApplicationArea=Basic;
              ShowCaption=false;

              trigger OnLookup(Text : Text) : Boolean;
              begin
                VALIDATE("Permit Modify User Group Code", ediFoundation.LookupSecurityUserGroup("Permit Modify User Group Code"));
              end;
            }
            field("Deny Modify User Group Code";"Deny Modify User Group Code")
            {
              ApplicationArea=Basic;
              ShowCaption=false;

              trigger OnLookup(Text : Text) : Boolean;
              begin
                VALIDATE("Deny Modify User Group Code", ediFoundation.LookupSecurityUserGroup("Deny Modify User Group Code"));
              end;
            }
          }
          group(Delete)
          {
            CaptionML=ENU='Delete',
                      ENA='Delete';
            field("Permit Delete User Group Code";"Permit Delete User Group Code")
            {
              ApplicationArea=Basic;
              ShowCaption=false;

              trigger OnLookup(Text : Text) : Boolean;
              begin
                VALIDATE("Permit Delete User Group Code", ediFoundation.LookupSecurityUserGroup("Permit Delete User Group Code"));
              end;
            }
            field("Deny Delete User Group Code";"Deny Delete User Group Code")
            {
              ApplicationArea=Basic;
              ShowCaption=false;

              trigger OnLookup(Text : Text) : Boolean;
              begin
                VALIDATE("Deny Delete User Group Code", ediFoundation.LookupSecurityUserGroup("Deny Delete User Group Code"));
              end;
            }
          }
        }
      }
    }
  }

  actions
  {
  }

  var
    ediFoundation : Codeunit 70018003;
}


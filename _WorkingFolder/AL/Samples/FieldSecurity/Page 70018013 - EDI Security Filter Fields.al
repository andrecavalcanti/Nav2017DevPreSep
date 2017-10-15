page 70018013 "EDI Security Filter Fields"
{
  // version FLS1.00

  // ECLIPSE - SupplyPoint (ECSP)
  // ----------------------------
  //   ECSP2.00j

  CaptionML=ENU='Security Filter Fields',
            ENA='Security Filter Fields';
  PageType=ListPart;
  SaveValues=true;
  SourceTable="EDI Field";
  SourceTableView=SORTING("Rule Code","Table No.","Field No.")
                  ORDER(Ascending);

  layout
  {
    area(content)
    {
      repeater(Group)
      {
        FreezeColumn="Field Name";
        IndentationColumn=Indentation;
        IndentationControls="Field Name";
        field("Rule Code";"Rule Code")
        {
          ApplicationArea=Basic;
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
        }
        field("Table Name";"Table Name")
        {
          ApplicationArea=Basic;
          Visible=false;
        }
        field("Field Name";"Field Name")
        {
          ApplicationArea=Basic;
          StyleExpr=fieldStyle;
        }
        field("Data Type";"Data Type")
        {
          ApplicationArea=Basic;
        }
        field("Field Length";"Field Length")
        {
          ApplicationArea=Basic;
        }
        field("Flow Field";"Flow Field")
        {
          ApplicationArea=Basic;
        }
        field("Key Field";"Key Field")
        {
          ApplicationArea=Basic;
        }
        field(Active;Active)
        {
          ApplicationArea=Basic;
        }
        field("Filter";Filter)
        {
          ApplicationArea=Basic;
        }
        field("Multi Language Set";"Multi Language Set")
        {
          ApplicationArea=Basic;
          AssistEdit=false;
          DrillDown=false;
          Lookup=false;
        }
      }
    }
  }

  actions
  {
    area(processing)
    {
      action("&Multi-Language")
      {
        ApplicationArea=Basic;
        CaptionML=ENU='&Multi-Language',
                  ENA='&Multi-Language';
        Image=Language;
        RunObject=Page 16016347;
        RunPageLink=Field1=FIELD("Rule Code"),
Field2=FIELD("Table No."),
Field3=FIELD("Field No."),
Field5=FIELD("Parent Table No.");
      }
      action("&Toggle Active")
      {
        ApplicationArea=Basic;
        CaptionML=ENU='&Toggle Active',
                  ENA='&Toggle Active';
        Image=ToggleBreakpoint;

        trigger OnAction();
        var
          "field" : Record 70018003;
        begin
          CurrPage.UPDATE(TRUE);
          ToggleActive(TRUE);
        end;
      }
    }
  }

  trigger OnAfterGetRecord();
  begin
    isHeading := Highlight;
    isKey := "Key Field";

    fieldStyle := 'Standard';
    IF isHeading THEN
      fieldStyle := 'Strong';
    IF isKey THEN
      fieldStyle := 'Attention';
  end;

  trigger OnOpenPage();
  var
    ediProcessor : Record 70018001;
  begin
  end;

  var
    ediField : Record 70018003;
    [InDataSet]
    isHeading : Boolean;
    [InDataSet]
    isKey : Boolean;
    showingActiveOnly : Boolean;
    fieldStyle : Text[50];

  local procedure ToggleActive(toggle : Boolean);
  var
    "field" : Record 70018003;
  begin
    IF NOT toggle THEN
      showingActiveOnly := NOT showingActiveOnly;

    IF showingActiveOnly THEN BEGIN
      FILTERGROUP(2);
      SETRANGE(Active);
      FILTERGROUP(0);
      CurrPage.UPDATE;
      showingActiveOnly := FALSE;
    END ELSE BEGIN
      field.SETRANGE("Rule Code", "Rule Code");
      field.SETRANGE(Highlight, TRUE);
      field.MODIFYALL(Active, TRUE);
      FILTERGROUP(2);
      SETRANGE(Active, TRUE);
      FILTERGROUP(0);
      CurrPage.UPDATE;
      showingActiveOnly := TRUE;
    END;
  end;
}


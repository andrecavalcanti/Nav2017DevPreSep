table 70018001 "EDI Processor"
{
  // version FLS1.00

  // ECLIPSE - SupplyPoint (ECSP)
  // ----------------------------
  //   ECSP2.00j

  CaptionML=ENU='EDI Processor',
            ENA='EDI Processor';
  DataCaptionFields="Code",Description;

  fields
  {
    field(1;"Code";Code[10])
    {
      CaptionML=ENU='Code',
                ENA='Code';
      Description='ECSP2.00j';
      NotBlank=true;

      trigger OnValidate();
      begin
        CheckIsOkToChangeConfig(xRec.Code, TRUE);
      end;
    }
    field(10;Description;Text[50])
    {
      CaptionML=ENU='Description',
                ENA='Description';
      Description='ECSP2.00j';
    }
    field(60;Active;Boolean)
    {
      CaptionML=ENU='Active',
                ENA='Active';
      Description='ECSP2.00j';
    }
    field(70;Direction;Option)
    {
      CaptionML=ENU='Direction / Type',
                ENA='Direction / Type';
      Description='ECSP2.00j';
      OptionCaptionML=ENU=',,,Security',
                      ENA=',,,Security';
      OptionMembers=,,,Security;

      trigger OnValidate();
      begin
        CheckIsOkToChangeConfig(xRec.Code, TRUE);
      end;
    }
    field(80;"System Generated";Boolean)
    {
      CaptionML=ENU='System Generated',
                ENA='System Generated';
      Description='ECSP2.00j';
      Editable=false;

      trigger OnValidate();
      begin
        CheckIsOkToChangeConfig(Code, TRUE);
      end;
    }
    field(140;"Add-in Code";Code[20])
    {
      CaptionML=ENU='Add-in Code',
                ENA='Add-in Code';
      Description='ECSP2.00j';
      Editable=false;
    }
  }

  keys
  {
    key(Key1;"Code")
    {
      Clustered=true;
    }
  }

  fieldgroups
  {
  }

  trigger OnDelete();
  var
    ediHandler : Record 70018002;
  begin
    ediHandler.SETRANGE("Processor Code", Code);
    ediHandler.DELETEALL;
  end;

  trigger OnModify();
  var
    text16016312L : TextConst ENU='Security is not currently licensed.',ENA='Security is not currently licensed.';
  begin
    IF NOT spointEdiMgt.ValidateSecurityIsOk THEN
      ERROR(text16016312L);
  end;

  trigger OnRename();
  begin
    CheckIsOkToChangeConfig(xRec.Code, TRUE);
  end;

  var
    ediFoundation : Codeunit 70018003;
    spointEdiMgt : Codeunit 70018007;

  procedure CheckIsOkToChangeConfig(processorCode : Code[10];throwError : Boolean) : Boolean;
  var
    ediHandler : Record 70018002;
    text16016312L : TextConst ENU='You cannot alter this value because there are EDI Handlers configured to use this record.',ENA='You cannot alter this value because there are EDI Handlers configured to use this record.';
  begin
    IF processorCode = '' THEN
      EXIT(TRUE);

    ediHandler.SETRANGE("Processor Code", processorCode);
    IF NOT ediHandler.ISEMPTY THEN BEGIN
      IF throwError THEN BEGIN
        ERROR(text16016312L);
        EXIT(FALSE);
      END ELSE
        EXIT(FALSE);
    END;
  end;

  local procedure CheckNotSecurity();
  var
    text16016310L : TextConst ENU='This field is not valid for Security Processors',ENA='This field is not valid for Security Processors';
  begin
    IF Direction <> Direction::Security THEN
      EXIT;

    ERROR(text16016310L);
  end;
}


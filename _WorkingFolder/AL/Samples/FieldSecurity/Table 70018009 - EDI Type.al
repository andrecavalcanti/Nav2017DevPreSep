table 70018009 "EDI Type"
{
  // version FLS1.00

  // ECLIPSE - SupplyPoint (ECSP)
  // ----------------------------
  //   ECSP2.00j

  CaptionML=ENU='EDI Type',
            ENA='EDI Type';

  fields
  {
    field(1;"Type Id";Integer)
    {
      CaptionML=ENU='Type Id',
                ENA='Type Id';
      Description='ECSP2.00j';
      Editable=false;
    }
    field(10;"Type Name";Text[50])
    {
      CaptionML=ENU='Type Name',
                ENA='Type Name';
      Description='ECSP2.00j';
      Editable=false;
    }
    field(20;"Record Type";Option)
    {
      CaptionML=ENU='Record Type',
                ENA='Record Type';
      Description='ECSP2.00j';
      Editable=false;
      OptionCaptionML=ENU='" ","Master Record",Document,Journal,,,,,Generic,Table,Custom',
                      ENA='" ","Master Record",Document,Journal,,,,,Generic,Table,Custom';
      OptionMembers=" ","Master Record",Document,Journal,,,,,Generic,"Table",Custom;
    }
  }

  keys
  {
    key(Key1;"Type Id")
    {
      Clustered=true;
    }
    key(Key2;"Type Name")
    {
    }
  }

  fieldgroups
  {
  }

  procedure InitialiseTypeEntries();
  var
    text16016314L : TextConst EUQ='Table',ENA='Table';
  begin
    InsertEntry(Type_None, '', 0);
    InsertEntry(Type_Table, text16016314L, 9);
  end;

  local procedure InsertEntry(id : Integer;name : Text[50];recordType : Integer);
  var
    ediType : Record 70018009;
  begin
    IF NOT ediType.GET(id) THEN BEGIN
      ediType.INIT;
      ediType."Type Id" := id;
      ediType."Type Name" := name;
      ediType."Record Type" := recordType;
      ediType.INSERT;
    END;
  end;

  procedure Type_None() : Integer;
  begin
    EXIT(0);
  end;

  procedure Type_Table() : Integer;
  begin
    EXIT(9);
  end;

  procedure GetTypeFromReference(recref : RecordRef) : Integer;
  var
    text16016310L : TextConst ENU='Could not determine the correct Type from the supplied Record Reference.',ENA='Could not determine the correct Type from the supplied Record Reference.';
    ediTable : Record 70018010;
  begin
    EXIT(Type_Table);
  end;
}


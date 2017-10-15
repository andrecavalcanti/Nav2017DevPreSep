table 70018008 "EDI Event"
{
  // version FLS1.00

  // ECLIPSE - SupplyPoint (ECSP)
  // ----------------------------
  //   ECSP2.00j

  CaptionML=ENU='EDI Event',
            ENA='EDI Event';

  fields
  {
    field(1;"Event Id";Integer)
    {
      CaptionML=ENU='Event Id',
                ENA='Event Id';
      Description='ECSP2.00j';
      Editable=false;
    }
    field(10;"Event Name";Text[50])
    {
      CaptionML=ENU='Event Name',
                ENA='Event Name';
      Description='ECSP2.00j';
      Editable=false;
    }
    field(20;"Current Tense";Text[50])
    {
      CaptionML=ENU='Current Tense',
                ENA='Current Tense';
      Description='ECSP2.00j';
    }
    field(30;"Past Tense";Text[50])
    {
      CaptionML=ENU='Past Tense',
                ENA='Past Tense';
      Description='ECSP2.00j';
    }
  }

  keys
  {
    key(Key1;"Event Id")
    {
      Clustered=true;
    }
    key(Key2;"Event Name")
    {
    }
  }

  fieldgroups
  {
  }

  procedure InitialiseEventEntries();
  var
    text16016310L : TextConst ENU='Insert',ENA='Insert';
    text16016311L : TextConst ENU='Modify',ENA='Modify';
    text16016312L : TextConst ENU='Delete',ENA='Delete';
    text16016313L : TextConst ENU='Rename',ENA='Rename';
    text16016319L : TextConst ENU='Field Change',ENA='Field Change';
    text16016410L : TextConst ENU='Insert',ENA='Insert';
    text16016411L : TextConst ENU='Modify',ENA='Modify';
    text16016412L : TextConst ENU='Delete',ENA='Delete';
    text16016413L : TextConst ENU='Rename',ENA='Rename';
    text16016419L : TextConst ENU='Field Change',ENA='Field Change';
    text16016510L : TextConst ENU='Inserted',ENA='Inserted';
    text16016511L : TextConst ENU='Modified',ENA='Modified';
    text16016512L : TextConst ENU='Deleted',ENA='Deleted';
    text16016513L : TextConst ENU='Renamed',ENA='Renamed';
    text16016519L : TextConst ENU='Field Changed',ENA='Field Changed';
  begin
    InsertEntry(Event_None, '', '', '');
    InsertEntry(Event_Insert, text16016310L, text16016410L, text16016510L);
    InsertEntry(Event_Modify, text16016311L, text16016411L, text16016511L);
    InsertEntry(Event_Delete, text16016312L, text16016412L, text16016512L);
    InsertEntry(Event_Rename, text16016313L, text16016413L, text16016513L);
    InsertEntry(Event_FieldChange, text16016319L, text16016419L, text16016519L);
  end;

  local procedure InsertEntry(id : Integer;name : Text[50];currentTense : Text[50];pastTense : Text[50]);
  var
    ediEvent : Record 70018008;
  begin
    IF NOT ediEvent.GET(id) THEN BEGIN
      ediEvent.INIT;
      ediEvent."Event Id" := id;
      ediEvent."Event Name" := name;
      ediEvent."Current Tense" := currentTense;
      ediEvent."Past Tense" := pastTense;
      ediEvent.INSERT;
    END ELSE BEGIN
      ediEvent."Event Name" := name;
      IF ediEvent."Current Tense" = '' THEN
        ediEvent."Current Tense" := currentTense;
      IF ediEvent."Past Tense" = '' THEN
        ediEvent."Past Tense" := pastTense;
      ediEvent.MODIFY;
    END;
  end;

  procedure Event_None() : Integer;
  begin
    EXIT(0);
  end;

  procedure Event_Insert() : Integer;
  begin
    EXIT(1);
  end;

  procedure Event_Modify() : Integer;
  begin
    EXIT(2);
  end;

  procedure Event_Delete() : Integer;
  begin
    EXIT(3);
  end;

  procedure Event_Rename() : Integer;
  begin
    EXIT(4);
  end;

  procedure Event_FieldChange() : Integer;
  begin
    EXIT(10);
  end;
}


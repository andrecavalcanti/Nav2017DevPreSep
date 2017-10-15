codeunit 70018004 "EDI System Initialisation"
{
  // version FLS1.00

  // ECLIPSE - SupplyPoint (ECSP)
  // ----------------------------
  //   ECSP2.00j


  trigger OnRun();
  begin
    Initialise;
  end;

  var
    processor : Record 70018001;
    type : Record 70018009;
    ediEvent : Record 70018008;
    "table" : Record 70018010;
    window : Dialog;
    text16016310G : TextConst ENU='Initialising: #1####################\ \@2@@@@@@@@@@@@@@@@',ENA='Initialising: #1####################\ \@2@@@@@@@@@@@@@@@@';
    text16016311G : TextConst ENU='Processors',ENA='Processors';
    text16016314G : TextConst ENU='Events',ENA='Events';
    text16016317G : TextConst ENU='Types',ENA='Types';
    text16016318G : TextConst ENU='Tables',ENA='Tables';
    text16016319G : TextConst ENU='The Security System has been initialised.',ENA='The Security System has been initialised.';
    text16016320G : TextConst ENU='This will initialise the Security System.\ \Are you sure ?',ENA='This will initialise the Security System.\ \Are you sure ?';
    calledInternally : Boolean;
    ediFoundation : Codeunit 70018003;
    addInMgt : Codeunit 70018006;
    calledFromTestUnit : Boolean;

  procedure Initialise();
  begin
    IF NOT calledFromTestUnit THEN
      IF NOT CONFIRM(text16016320G) THEN
        EXIT;

    window.OPEN(text16016310G);
    calledInternally := TRUE;

    UpdateWindow(text16016314G, 1);
    ediEvent.InitialiseEventEntries;

    UpdateWindow(text16016317G, 2);
    type.InitialiseTypeEntries;

    UpdateWindow(text16016318G, 3);
    ediFoundation.SyncEDISecurityTables(FALSE, FALSE, TRUE);

    UpdateWindow(text16016311G, 4);
    InitialiseProcessors;

    window.CLOSE;

    IF NOT calledFromTestUnit THEN
      MESSAGE(text16016319G);
  end;

  local procedure UpdateWindow(data : Text[50];percentage : Integer);
  var
    actualPercentage : Integer;
    noToprocess : Integer;
    increment : Integer;
  begin
    noToprocess := 4;
    increment := ROUND(9999 / noToprocess, 1);

    actualPercentage := percentage * increment;
    IF actualPercentage > 9999 THEN
      actualPercentage := 9999;

    window.UPDATE(1, data);
    window.UPDATE(2, actualPercentage);
  end;

  local procedure InitialiseProcessors();
  var
    text16016311L : TextConst ENU='API Inbound Processor',ENA='API Inbound Processor';
    text16016312L : TextConst ENU='Outbound Processor',ENA='Outbound Processor';
    text16016313L : TextConst ENU='Inbound Processor',ENA='Inbound Processor';
    text16016316L : TextConst ENU='Workflow Processor',ENA='Workflow Processor';
    text16016318L : TextConst ENU='Smtp Outbound Processor',ENA='Smtp Outbound Processor';
    text16016319L : TextConst ENU='API Outbound Processor',ENA='API Outbound Processor';
    text16016320L : TextConst ENU='Security Processor',ENA='Security Processor';
    proc : Record 70018001;
  begin
    addInMgt.CreateProcessor('SECURITY', text16016320L, 0, 0, 0, 0, processor.Direction::Security, FALSE, 0, '', 'SYSTEM');

    proc.GET('SECURITY');
    proc.Active := TRUE;
    proc.MODIFY;
  end;

  local procedure CreateProcessor("code" : Code[10];description : Text[50];pollMin : Integer;pollMax : Integer;pollRecords : Integer;backOff : Integer;direction : Integer;isApi : Boolean;retention : Integer;service : Code[10]);
  begin
    IF NOT processor.GET(code) THEN BEGIN
      processor.INIT;
      processor.Code := code;
      processor.INSERT(TRUE);
    END;

    processor.Description := description;
    processor.Direction := direction;
    processor."System Generated" := TRUE;
    processor.MODIFY;
  end;

  procedure SetCalledFromTestUnit(value : Boolean);
  begin
    calledFromTestUnit := value;
  end;
}


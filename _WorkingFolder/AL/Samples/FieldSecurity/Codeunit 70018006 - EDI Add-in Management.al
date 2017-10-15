codeunit 70018006 "EDI Add-in Management"
{
  // version FLS1.00

  // ECLIPSE - SupplyPoint (ECSP)
  // ----------------------------
  //   ECSP2.00j


  trigger OnRun();
  begin
  end;

  var
    rule : Record 70018004;
    processor : Record 70018001;
    handler : Record 70018002;
    "table" : Record 70018010;
    ediFoundation : Codeunit 70018008;
    systemInitial : Codeunit 70018004;
    window : Dialog;

  procedure CreateSystemWorkflowRule("code" : Code[20];description : Text[100];holdStart : Integer;abortOnWarning : Boolean;abortOnError : Boolean;codeunitId : Integer;workflowOptions : Text[100];lockAllValues : Boolean;refreshMessage : Boolean;tableNo : Integer;maxSeverity : Option Diagnostic,Information,Warning,Error;extendedDesc : Text[1024];allowWorkflowChange : Boolean;allowOverride : Boolean;addInCode : Code[20]);
  var
    extDescLen : Integer;
    alreadyExists : Boolean;
  begin
    rule.RESET;
    alreadyExists := TRUE;
    IF NOT rule.GET(code) THEN BEGIN
      rule.INIT;
      rule.Code := code;
      rule.INSERT(TRUE);
      alreadyExists := FALSE;
    END;

    rule.SetCalledBySetup(TRUE);

    rule."Add-in Code" := addInCode;
    rule.Description := description;
    rule."System Generated" := TRUE;
    rule.Type := rule.Type::"1";
    rule."Allow Override" := allowOverride;
    extDescLen := STRLEN(extendedDesc);
    CASE TRUE OF
      extDescLen < 251 : BEGIN
          rule."Extended Description" := COPYSTR(extendedDesc, 1, 250);
        END;
      extDescLen < 501 : BEGIN
          rule."Extended Description" := COPYSTR(extendedDesc, 1, 250);
          rule."Extended Description 2" := COPYSTR(extendedDesc, 251, 250);
        END;
      extDescLen < 751 : BEGIN
          rule."Extended Description" := COPYSTR(extendedDesc, 1, 250);
          rule."Extended Description 2" := COPYSTR(extendedDesc, 251, 250);
          rule."Extended Description 3" := COPYSTR(extendedDesc, 501, 250);
        END;
      ELSE BEGIN
          rule."Extended Description" := COPYSTR(extendedDesc, 1, 250);
          rule."Extended Description 2" := COPYSTR(extendedDesc, 251, 250);
          rule."Extended Description 3" := COPYSTR(extendedDesc, 501, 250);
          rule."Extended Description 4" := COPYSTR(extendedDesc, 751, 250);
        END;
    END;
    rule.MODIFY(FALSE);
    IF alreadyExists THEN
      EXIT;
    rule.VALIDATE("Table No.", tableNo);
    rule.MODIFY(TRUE);
  end;

  procedure CreateProcessor("code" : Code[10];description : Text[50];pollMin : Integer;pollMax : Integer;pollRecords : Integer;backOff : Integer;direction : Integer;isApi : Boolean;retention : Integer;service : Code[10];addInCode : Code[20]);
  begin
    IF NOT processor.GET(code) THEN BEGIN
      processor.INIT;
      processor.Code := code;
      processor.INSERT(TRUE);
    END;

    processor."Add-in Code" := addInCode;
    processor.Description := description;
    processor.Direction := direction;
    processor."System Generated" := TRUE;
    processor.MODIFY;
  end;

  procedure CreateBasicHandler(procCode : Code[10];handCode : Code[20];description : Text[50];accessMethod : Integer;procLibrary : Text[250];addInCode : Code[20]);
  begin
    processor.GET(procCode);

    IF NOT handler.GET(procCode, handCode) THEN BEGIN
      handler.INIT;
      handler."Processor Code" := procCode;
      handler.Code := handCode;
      handler.INSERT(TRUE);
    END;

    handler."Add-in Code" := addInCode;
    handler.Direction := processor.Direction;
    handler.Description := description;
    handler."System Generated" := TRUE;
    handler.MODIFY;
  end;

  procedure DeleteHandler(processorCode : Code[10];handlerCode : Code[20];addInCode : Code[20]);
  begin
    handler.RESET;
    handler.SETRANGE("Processor Code", processorCode);
    handler.SETRANGE(Code, handlerCode);
    handler.SETRANGE("Add-in Code", addInCode);
    handler.DELETEALL(FALSE);
  end;

  procedure DeleteWorkflowRule(ruleCode : Code[20];addInCode : Code[20]);
  begin
    rule.RESET;
    rule.SETRANGE(Code, ruleCode);
    rule.SETRANGE("Add-in Code", addInCode);
    rule.DELETEALL;
  end;

  procedure GetSourceFieldName(tableNo : Integer;fieldNo : Integer) : Text[50];
  var
    "field" : Record 2000000041;
  begin
    field.SETRANGE(TableNo, tableNo);
    field.SETRANGE("No.", fieldNo);
    IF field.FINDFIRST THEN
      EXIT(field.FieldName)
    ELSE
      EXIT('');
  end;

  procedure SortWorkflowRulesForDisplay(calledFromInstaller : Boolean);
  var
    displaySeq : Integer;
    workflowRule : Record 70018004;
    text16016310L : TextConst ENU='SYSTEM',ENA='SYSTEM';
    text16016311L : TextConst ENU='ASSESSMENT',ENA='ASSESSMENT';
    text16016312L : TextConst ENU='DATE',ENA='DATE';
    text16016313L : TextConst ENU='DOCUMENT',ENA='DOCUMENT';
    text16016314L : TextConst ENU='MANUAL',ENA='MANUAL';
    text16016315L : TextConst ENU='OUTBOUND',ENA='OUTBOUND';
    text16016316L : TextConst ENU='INBOUND',ENA='INBOUND';
    text16016317L : TextConst ENU='EXTERNAL',ENA='EXTERNAL';
    text16016318L : TextConst ENU='FILTER',ENA='FILTER';
    text16016320L : TextConst ENU='CUSTOM',ENA='CUSTOM';
    window : Dialog;
    text16016321L : TextConst ENU='Updating Workflow Rule Sequence.\ \Please Wait ...',ENA='Updating Workflow Rule Sequence.\ \Please Wait ...';
  begin
    workflowRule.RESET;
    workflowRule.SETCURRENTKEY(Type, "Table Name");

    IF NOT calledFromInstaller THEN
      window.OPEN(text16016321L);

    workflowRule.SETRANGE("Display Heading", FALSE);
    workflowRule.SETRANGE("Security Rule", FALSE);

    displaySeq := 20000;
    workflowRule.SETRANGE(Type, workflowRule.Type::"1");
    UpdateWorkflowRuleSection(text16016311L, displaySeq, workflowRule);

    IF NOT calledFromInstaller THEN
      window.CLOSE;
  end;

  local procedure UpdateWorkflowRuleSection(sectionName : Text[50];displaySeq : Integer;var workflowRule : Record 70018004);
  var
    text16016310L : TextConst ENU='%1 (Table)',ENA='%1 (Table)';
    text16016311L : TextConst ENU='General',ENA='General';
    rule : Record 70018004;
    text16016312L : TextConst ENU='HEADING-%1',ENA='HEADING-%1';
    currentTableNo : Integer;
    typeInteger : Integer;
    text16016313L : TextConst ENU='HEADING-%1-%2',ENA='HEADING-%1-%2';
  begin
    rule.RESET;
    rule.COPYFILTERS(workflowRule);
    rule.SETRANGE("Display Heading", TRUE);
    rule.DELETEALL;

    IF workflowRule.FINDSET THEN BEGIN
      rule.RESET;
      rule.SETRANGE("Display Heading", TRUE);
      rule.SETRANGE(Type, workflowRule.Type);
      rule.SETRANGE(Code, STRSUBSTNO(text16016312L, FORMAT(typeInteger)));
      typeInteger := workflowRule.Type;
      IF NOT rule.FINDFIRST THEN BEGIN
        rule.INIT;
        rule.Code := STRSUBSTNO(text16016312L, FORMAT(typeInteger));
        rule.Description := '';
        rule."Display Sequence" := displaySeq;
        displaySeq := displaySeq + 1;
        rule."Display Name" := sectionName;
        rule.Type := workflowRule.Type;
        rule."Display Indentation" := 0;
        rule."Display Heading" := TRUE;
        rule.INSERT;
      END;
      currentTableNo := -1;
      REPEAT
        IF workflowRule."Table No." <> currentTableNo THEN BEGIN
          rule.RESET;
          rule.SETRANGE("Display Heading", TRUE);
          rule.SETRANGE(Type, workflowRule.Type);
          rule.SETRANGE(Code, STRSUBSTNO(text16016313L, FORMAT(typeInteger), FORMAT(workflowRule."Table No.")));
          IF NOT rule.FINDFIRST THEN BEGIN
            rule.INIT;
            rule.Code := STRSUBSTNO(text16016313L, FORMAT(typeInteger), FORMAT(workflowRule."Table No."));
            rule.Description := '';
            rule."Display Sequence" := displaySeq;
            displaySeq := displaySeq + 1;
            IF workflowRule."Table Name" = '' THEN
              rule."Display Name" := text16016311L
            ELSE
              rule."Display Name" := STRSUBSTNO(text16016310L, workflowRule."Table Name");
            rule.Type := workflowRule.Type;
            rule."Display Indentation" := 1;
            rule."Display Heading" := TRUE;
            rule.INSERT;
          END ELSE BEGIN
            rule."Display Sequence" := displaySeq;
            displaySeq := displaySeq + 1;
            rule.MODIFY;
          END;
          currentTableNo := workflowRule."Table No.";
        END;
        workflowRule."Display Sequence" := displaySeq;
        displaySeq := displaySeq + 1;
        workflowRule."Display Indentation" := 2;
        workflowRule."Display Name" := workflowRule.Code;
        workflowRule."Display Heading" := FALSE;
        workflowRule.MODIFY;
      UNTIL workflowRule.NEXT = 0;
    END;
  end;
}


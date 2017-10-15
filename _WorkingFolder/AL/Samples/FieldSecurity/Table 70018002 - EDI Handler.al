table 70018002 "EDI Handler"
{
  // version FLS1.00

  // ECLIPSE - SupplyPoint (ECSP)
  // ----------------------------
  //   ECSP2.00j

  CaptionML=ENU='EDI Handler',
            ENA='EDI Handler';
  DataCaptionFields="Processor Code","Code",Description;

  fields
  {
    field(1;"Processor Code";Code[10])
    {
      CaptionML=ENU='Processor Code',
                ENA='Processor Code';
      Description='ECSP2.00j';
      NotBlank=true;
      TableRelation=Table16016311;

      trigger OnValidate();
      var
        ediProcessor : Record 70018001;
      begin
        ediProcessor.GET("Processor Code");
        Direction := ediProcessor.Direction;
        ClearUnusedFields;
      end;
    }
    field(2;"Code";Code[20])
    {
      CaptionML=ENU='Code',
                ENA='Code';
      Description='ECSP2.00j';
      NotBlank=true;
    }
    field(10;Type;Integer)
    {
      CaptionML=ENU='Type',
                ENA='Type';
      Description='ECSP2.00j';
      Editable=false;

      trigger OnValidate();
      var
        ediHandler : Record 70018002;
        text16016310L : TextConst ENU='The Type must be ''None'' or ''Table'' when using the Sql Integrator configuration.',ENA='The Type must be ''None'' or ''Table'' when using the Sql Integrator configuration.';
        text16016311L : TextConst ENU='The Type cannot be ''Table'' when the Handler is an Api Handler',ENA='The Type cannot be ''Table'' when the Handler is an Api Handler';
      begin
        IF ediType.GET(Type) THEN BEGIN
          "Type Name" := ediType."Type Name";
          IF ediType."Record Type" = ediType."Record Type"::Table THEN BEGIN
            IF Direction <> Direction::Security THEN BEGIN
              IF Direction = Direction::Inbound THEN
                ERROR(text16016314G);
            END;
          END;
        END ELSE BEGIN
          ediType.INIT;
          Type := 0;
          "Type Name" := '';
        END;

        VALIDATE(Source, 0);

        VALIDATE("Event", ediEvent.Event_FieldChange);

        "Assessment Filter" := '';
      end;
    }
    field(11;"Type Name";Text[50])
    {
      CaptionML=ENU='Type Name',
                ENA='Type Name';
      Description='ECSP2.00j';
    }
    field(20;Source;Integer)
    {
      CaptionML=ENU='Source',
                ENA='Source';
      Description='ECSP2.00j';
      Editable=false;

      trigger OnValidate();
      var
        "object" : Record 2000000001;
        localSource : Integer;
      begin
        IF xRec.Source = Source THEN
          EXIT;

        localSource := Source;
        Source := 0;
        object.SETRANGE(Type, object.Type::Table);
        object.SETRANGE(ID, localSource);
        IF object.FINDFIRST THEN BEGIN
          "Source Name" := object.Name;
          VALIDATE("Table No.", localSource);
        END ELSE BEGIN
          "Source Name" := '';
          VALIDATE("Table No.", 0);
        END;

        VALIDATE("Event", ediEvent.Event_FieldChange)
      end;
    }
    field(21;"Source Name";Text[50])
    {
      CaptionML=ENU='Source Name',
                ENA='Source Name';
      Description='ECSP2.00j';
    }
    field(30;"Event";Integer)
    {
      BlankZero=true;
      CaptionML=ENU='Event',
                ENA='Event';
      Description='ECSP2.00j';
      Editable=false;
      TableRelation=Table16016336.Field1;

      trigger OnValidate();
      begin
        IF ediEvent.GET("Event") THEN
          "Event Name" := ediEvent."Event Name"
        ELSE BEGIN
          "Event" := 0;
          "Event Name" := '';
        END;
      end;
    }
    field(31;"Event Name";Text[50])
    {
      CaptionML=ENU='Event Name',
                ENA='Event Name';
      Description='ECSP2.00j';
    }
    field(50;Active;Boolean)
    {
      CaptionML=ENU='Active',
                ENA='Active';
      Description='ECSP2.00j';
    }
    field(60;Direction;Option)
    {
      CaptionML=ENU='Direction / Type',
                ENA='Direction / Type';
      Description='ECSP2.00j';
      Editable=false;
      OptionCaptionML=ENU='Outbound,Inbound,Workflow,Security',
                      ENA='Outbound,Inbound,Workflow,Security';
      OptionMembers=Outbound,Inbound,Workflow,Security;
    }
    field(90;Description;Text[50])
    {
      CaptionML=ENU='Description',
                ENA='Description';
      Description='ECSP2.00j';
    }
    field(120;"Table No.";Integer)
    {
      BlankZero=true;
      CaptionML=ENU='Table No.',
                ENA='Table No.';
      Description='ECSP2.00j';
      Editable=false;

      trigger OnLookup();
      var
        "object" : Record 2000000001;
        objectPage : Page 358;
      begin
        object.SETRANGE(Type, object.Type::Table);
        objectPage.LOOKUPMODE := TRUE;
        objectPage.SETTABLEVIEW(object);
        IF objectPage.RUNMODAL = ACTION::LookupOK THEN BEGIN
          objectPage.GETRECORD(object);
          VALIDATE("Table No.", object.ID);
        END;
      end;

      trigger OnValidate();
      begin
        IF xRec."Table No." <> "Table No." THEN BEGIN
          IF Direction = Direction::Security THEN BEGIN
            fieldMonitor.SETRANGE("Processor Code", "Processor Code");
            fieldMonitor.SETRANGE("Handler Code", Code);
            fieldMonitor.DELETEALL;
            "Assessment Filter" := '';
          END;
        END;
      end;
    }
    field(130;"Table Name";Text[50])
    {
      CalcFormula=Lookup(Object.Name WHERE (Type=CONST(Table),
                                            ID=FIELD("Table No.")));
      CaptionML=ENU='Table Name',
                ENA='Table Name';
      Description='ECSP2.00j';
      Editable=false;
      FieldClass=FlowField;
    }
    field(760;"System Generated";Boolean)
    {
      CaptionML=ENU='System Generated',
                ENA='System Generated';
      Description='ECSP2.00j';
      Editable=false;
    }
    field(780;"Processor Active";Boolean)
    {
      CalcFormula=Lookup(Table16016311.Field60 WHERE (Field1=FIELD("Processor Code")));
      CaptionML=ENU='Processor Active',
                ENA='Processor Active';
      Description='ECSP2.00j';
      Editable=false;
      FieldClass=FlowField;
    }
    field(900;"Assessment Filter";Code[20])
    {
      CaptionML=ENU='Assessment Filter',
                ENA='Assessment Filter';
      Description='ECSP2.00j';
      TableRelation="EDI Workflow Rule".Code WHERE (Type=CONST(Filter),
                                "Display Heading"=CONST(false),
                                "Table No."=FIELD("Table No."),
                                "Security Rule"=CONST(true));
    }
    field(930;"Add-in Code";Code[20])
    {
      CaptionML=ENU='Add-in Code',
                ENA='Add-in Code';
      Description='ECSP2.00j';
      Editable=false;
    }
  }

  keys
  {
    key(Key1;"Processor Code","Code")
    {
      Clustered=true;
    }
    key(Key2;Description)
    {
    }
  }

  fieldgroups
  {
  }

  trigger OnDelete();
  var
    ediFieldChange : Record 70018011;
  begin
    ediFieldChange.RESET;
    ediFieldChange.SETRANGE("Processor Code", "Processor Code");
    ediFieldChange.SETRANGE("Handler Code", Code);
    ediFieldChange.DELETEALL;
  end;

  trigger OnInsert();
  var
    ediSetup : Record 70018000;
    ediProcessor : Record 70018001;
  begin
  end;

  trigger OnModify();
  var
    text16016310L : TextConst ENU='Workflow is not currently licensed.',ENA='Workflow is not currently licensed.';
    text16016311L : TextConst ENU='EDI is not currently licensed.',ENA='EDI is not currently licensed.';
    text16016312L : TextConst ENU='Security is not currently licensed.',ENA='Security is not currently licensed.';
  begin
    IF NOT spointEdiMgt.ValidateSecurityIsOk THEN
      ERROR(text16016312L);
  end;

  var
    ediFoundation : Codeunit 70018003;
    text16016310G : TextConst ENU='This field is only valid for Inbound or Workflow Handlers.',ENA='This field is only valid for Inbound or Workflow Handlers.';
    ediHandler : Record 70018002;
    text16016311G : TextConst ENU='This field is only valid for Outbound Handlers.',ENA='This field is only valid for Outbound Handlers.';
    text16016312G : TextConst ENU='This field is not valid for Outbound Handlers.',ENA='This field is not valid for Outbound Handlers.';
    text16016313G : TextConst ENU='You cannot specify a Reference Date Field No. when using the Workflow as the Source.',ENA='You cannot specify a Reference Date Field No. when using the Workflow as the Source.';
    ediEvent : Record 70018008;
    ediType : Record 70018009;
    spointEdiMgt : Codeunit 70018007;
    text16016314G : TextConst ENU='You cannot specify a Type of Table for Inbound Handlers',ENA='You cannot specify a Type of Table for Inbound Handlers';
    text16016316G : TextConst ENU='This field is only valid for Inbound Handlers.',ENA='This field is only valid for Inbound Handlers.';
    fieldMonitor : Record 70018011;

  procedure ClearUnusedFields();
  begin
    Type := Type::"0";
    Source := 0;
    "Source Name" := '';
    VALIDATE("Event", ediEvent.Event_FieldChange);
  end;

  procedure InitialiseSecurityHandler();
  begin
    Direction := Direction::Security;
    "Processor Code" := 'SECURITY';
    VALIDATE(Type, ediType.Type_Table);
    VALIDATE("Event", ediEvent.Event_FieldChange);
  end;
}


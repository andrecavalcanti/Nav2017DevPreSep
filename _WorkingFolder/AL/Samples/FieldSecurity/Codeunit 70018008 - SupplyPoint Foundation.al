codeunit 70018008 "SupplyPoint Foundation"
{
  // version [EVENT - Subscriber]FLS1.00

  // ECLIPSE - SupplyPoint (ECSP)
  // ----------------------------
  //   ECSP2.00j


  trigger OnRun();
  begin
  end;

  [EventSubscriber(ObjectType::Codeunit, 1, 'OnAfterGetApplicationVersion', '', false, false)]
  local procedure RunOnAfterGetApplicationVersion(var AppVersion : Text[80]);
  var
    text16015930L : TextConst ENU=' %1 - SupplyPoint %2 (Foundation)',ENA=' %1 - SupplyPoint %2 (Foundation)';
    working : Text;
  begin
    working := AppVersion + STRSUBSTNO(text16015930L, GetSPointCULevel, GetSPointNumericVersion);
    IF STRLEN(working) <= 80 THEN
      AppVersion := working
    ELSE
      AppVersion := COPYSTR(working, 1, 80);
  end;

  procedure CheckTableLicense(tableNo : Integer) : Boolean;
  var
    licensePermission : Record 2000000043;
  begin
    licensePermission.SETRANGE("Object Type", licensePermission."Object Type"::Table);
    licensePermission.SETRANGE("Object Number", tableNo);
    licensePermission.SETFILTER("Modify Permission",'<>%1', licensePermission."Modify Permission"::" ");
    IF licensePermission.COUNT > 0 THEN
      EXIT(TRUE)
    ELSE
      EXIT(FALSE);
  end;

  procedure CheckCodeunitLicense(codeunitNo : Integer) : Boolean;
  var
    licensePermission : Record 2000000043;
  begin
    licensePermission.SETRANGE("Object Type", licensePermission."Object Type"::Codeunit);
    licensePermission.SETRANGE("Object Number", codeunitNo);
    licensePermission.SETRANGE("Execute Permission", licensePermission."Execute Permission"::Yes);
    IF licensePermission.COUNT > 0 THEN
      EXIT(TRUE)
    ELSE
      EXIT(FALSE);
  end;

  procedure CheckEDIAccess() : Boolean;
  begin
    EXIT(CheckTableLicense(16016310));
  end;

  procedure GetSPointVersion() : Text;
  var
    string : DotNet "'mscorlib, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089'.System.String";
    "object" : Record 2000000001;
    working : Text;
    startPos : Integer;
    i : Integer;
    exitLoop : Boolean;
    char : Text[1];
    charTest : Integer;
    text16015930L : TextConst ENU='UNKNOWN',ENA='UNKNOWN';
  begin
    object.SETRANGE(Type, object.Type::Table);
    object.SETRANGE(ID, DATABASE::"Company Information");
    object.FINDFIRST;
    string := object."Version List";
    startPos := string.IndexOf('ECSP');
    IF startPos > 0 THEN
      working := string.Substring(startPos)
    ELSE
      EXIT(text16015930L);

    string := working;
    startPos := string.IndexOf(',');
    IF startPos > 0 THEN
      working := string.Substring(0, startPos);

    string := working;
    i := 4;
    REPEAT
      char := string.Substring(i, 1);
      IF char <> '.' THEN BEGIN
        IF NOT EVALUATE(charTest, char) THEN BEGIN
          working := string.Substring(0, i);
          EXIT(working);
        END;
      END;
      i := i + 1;
    UNTIL (i > string.Length - 1) OR exitLoop;
    EXIT(working);
  end;

  procedure GetSPointNumericVersion() : Text;
  var
    string : DotNet "'mscorlib, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089'.System.String";
    "object" : Record 2000000001;
    working : Text;
    startPos : Integer;
    i : Integer;
    exitLoop : Boolean;
    char : Text[1];
    charTest : Integer;
    text16015930L : TextConst ENU='UNKNOWN',ENA='UNKNOWN';
    text16015931L : TextConst ENU=' Microsoft Update: %1',ENA=' Microsoft Update: %1';
    cuLevel : Text;
  begin
    object.SETRANGE(Type, object.Type::Table);
    object.SETRANGE(ID, DATABASE::"Company Information");
    object.FINDFIRST;
    string := object."Version List";
    startPos := string.IndexOf('ECSP');
    IF startPos > 0 THEN
      working := string.Substring(startPos + 4)
    ELSE
      EXIT(text16015930L);

    string := working;
    startPos := string.IndexOf(',');
    IF startPos > 0 THEN
      working := string.Substring(0, startPos);

    string := working;
    i := 4;
    REPEAT
      char := string.Substring(i, 1);
      IF char <> '.' THEN BEGIN
        IF NOT EVALUATE(charTest, char) THEN BEGIN
          working := string.Substring(0, i);
          EXIT(working);
        END;
      END;
      i := i + 1;
    UNTIL (i > string.Length - 1) OR exitLoop;
    EXIT(working);
  end;

  procedure GetSPointCULevel() : Text;
  var
    string : DotNet "'mscorlib, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089'.System.String";
    "object" : Record 2000000001;
    working : Text;
    startPos : Integer;
    text16015930L : TextConst ENU='UNKNOWN',ENA='UNKNOWN';
  begin
    object.SETRANGE(Type, object.Type::Table);
    object.SETRANGE(ID, DATABASE::"Company Information");
    object.FINDFIRST;
    string := object."Version List";
    startPos := string.IndexOf('ECSP');
    IF startPos > 0 THEN
      working := string.Substring(startPos)
    ELSE
      EXIT(text16015930L);

    string := working;
    startPos := string.IndexOf(',');
    IF startPos > 0 THEN
      working := string.Substring(0, startPos);

    string := working;
    startPos := string.IndexOf('(');
    IF startPos < 0 THEN
      EXIT('');

    working := string.Substring(startPos + 1);
    string := working;
    startPos := string.IndexOf(')');
    IF startPos < 0 THEN
      EXIT('');

    working := string.Substring(0, startPos);
    EXIT(working);
  end;
}


unit PasDoc_GenHtmlHelp;

interface

uses PasDoc_GenHtml, PasDoc_GenFullHtml;

type
{$IFDEF old}
  THTMLHelpDocGenerator = class(TGenericHTMLDocGenerator)
{$ELSE}
  THTMLHelpDocGenerator = class(TFullHTMLDocGenerator)
{$ENDIF}
  private
    FContentsFile: string;

    { Writes the topic files for Html Help Generation }
    procedure WriteHtmlHelpProject;
  public
    procedure WriteDocumentation; override;
  published
    { Contains Name of a file to read HtmlHelp Contents from.
      If empty, create default contents file. }
    property ContentsFile: string read FContentsFile write FContentsFile;
  end;

implementation

uses SysUtils, PasDoc_Types, PasDoc_StringVector, PasDoc_Base, PasDoc_Items, 
  PasDoc_Languages, PasDoc_Gen;

{ HtmlHelp Content Generation inspired by Wim van der Vegt <wvd_vegt@knoware.nl> }

function BeforeEqualChar(const s: string): string;
var
  i: Cardinal;
begin
  Result := s;
  i := Pos('=', Result);
  if i <> 0 then
    SetLength(Result, i - 1);
end;

function AfterEqualChar(const s: string): string;
var
  i: Cardinal;
begin
  Result := s;
  i := Pos('=', Result);
  if i <> 0 then
    Delete(Result, 1, i)
  else
    Result := '';
end;

function GetLevel(var s: string): Integer;
var
  l: Cardinal;
  p: PChar;
begin
  Result := 0;
  p := Pointer(s);
  l := Length(s);
  while (l > 0) and (p^ in [' ', #9]) do begin
    Inc(Result);
    Inc(p);
    Dec(l);
  end;
  Delete(s, 1, Result);
end;

{ THTMLHelpDocGenerator ------------------------------------------------------ }

procedure THTMLHelpDocGenerator.WriteDocumentation; 
begin
  inherited;
  WriteHtmlHelpProject;
end;

procedure THTMLHelpDocGenerator.WriteHtmlHelpProject;
var
  DefaultContentsWritten: Boolean;
  DefaultTopic: string;

  procedure WriteLiObject(const Name, Local: string);
  begin
    WriteDirectLine('<li><object type="text/sitemap">');
    WriteDirectLine('<param name="Name" value="' + Name + '">');
    if Local <> '' then begin
      WriteDirectLine('<param name="Local" value="' + Local + '">');
      if DefaultTopic = '' then
        DefaultTopic := Local;
    end;
    WriteDirectLine('</object>');
  end;

  { ---------- }

  procedure WriteItemCollection(const _Filename: string; const c: TPasItems);
  var
    i: Integer;
    Item: TPasItem;
  begin
    if Assigned(c) then begin
      WriteDirectLine('<ul>');
      for i := 0 to c.Count - 1 do begin
        Item := c.PasItemAt[i];
        WriteLiObject(Item.Name, _Filename + '#' + Item.Name);
      end;
      WriteDirectLine('</ul>');
    end;
  end;

  { ---------- }

  procedure WriteItemHeadingCollection(const Title, ParentLink, Anchor: string; const
    c: TPasItems);
  begin
    if Assigned(c) and (c.Count > 0) then begin
      WriteLiObject(Title, ParentLink + '#' + Anchor);
      WriteItemCollection(ParentLink, c);
    end;
  end;

  { ---------- }

  procedure InternalWriteCIO(const ClassItem: TPasCio);
  begin
    WriteLiObject(ClassItem.Name, ClassItem.FullLink);
    WriteDirectLine('<ul>');

    WriteItemHeadingCollection(Language.Translation[trFields], ClassItem.FullLink, '@Fields', ClassItem.Fields);
    WriteItemHeadingCollection(Language.Translation[trProperties], ClassItem.FullLink, '@Properties', ClassItem.Properties);
    WriteItemHeadingCollection(Language.Translation[trMethods], ClassItem.FullLink, '@Methods', ClassItem.Methods);

    WriteDirectLine('</ul>');
  end;

  { ---------- }

  procedure ContentWriteUnits(const Text: string);
  var
    c: TPasItems;
    j, k: Integer;
    PU: TPasUnit;
  begin
    if Text <> '' then
      WriteLiObject(Text, OverviewFilesInfo[ofUnits].BaseFileName + GetFileExtension)
    else
      WriteLiObject(Language.Translation[trUnits], OverviewFilesInfo[ofUnits].BaseFileName +
        GetFileExtension);
    WriteDirectLine('<ul>');

    // Iterate all Units
    for j := 0 to Units.Count - 1 do begin
      PU := Units.UnitAt[j];
      WriteLiObject(PU.Name, PU.FullLink);
      WriteDirectLine('<ul>');

        // For each unit, write classes (if there are any).
      c := PU.CIOs;
      if Assigned(c) then begin
        WriteLiObject(Language.Translation[trClasses], PU.FullLink + '#@Classes');
        WriteDirectLine('<ul>');

        for k := 0 to c.Count - 1 do
          InternalWriteCIO(TPasCio(c.PasItemAt[k]));

        WriteDirectLine('</ul>');
      end;

        // For each unit, write Functions & Procedures.
      WriteItemHeadingCollection(Language.Translation[trFunctionsAndProcedures],
        PU.FullLink, '@FuncsProcs', PU.FuncsProcs);
        // For each unit, write Types.
      WriteItemHeadingCollection(Language.Translation[trTypes], PU.FullLink,
        '@Types', PU.Types);
        // For each unit, write Constants.
      WriteItemHeadingCollection(Language.Translation[trConstants], PU.FullLink,
        '@Constants', PU.Constants);

      WriteDirectLine('</ul>');
    end;
    WriteDirectLine('</ul>');
  end;

  { ---------- }

  procedure ContentWriteClasses(const Text: string);
  var
    c: TPasItems;
    j: Integer;
    PU: TPasUnit;
    FileName: string;
  begin
    FileName := OverviewFilesInfo[ofCios].BaseFileName + GetFileExtension;
    
    // Write Classes to Contents
    if Text <> '' then
      WriteLiObject(Text, FileName) else
      WriteLiObject(Language.Translation[trClasses], FileName);
    WriteDirectLine('<ul>');

    c := TPasItems.Create(False);
    // First collect classes
    for j := 0 to Units.Count - 1 do begin
      PU := Units.UnitAt[j];
      c.CopyItems(PU.CIOs);
    end;
    // Output sorted classes
    // TODO: Sort
    for j := 0 to c.Count - 1 do
      InternalWriteCIO(TPasCio(c.PasItemAt[j]));
    c.Free;
    WriteDirectLine('</ul>');
  end;

  { ---------- }

  procedure ContentWriteClassHierarchy();
  var
    FileName: string;
  begin
    FileName := OverviewFilesInfo[ofClassHierarchy].BaseFileName +
      GetFileExtension;

    WriteLiObject(Language.Translation[trClassHierarchy], FileName);
  end;

  { ---------- }

  procedure ContentWriteOverview(const Text: string);

    procedure WriteParam(Id: TTranslationId);
    begin
      WriteDirect('<param name="Name" value="');
      WriteConverted(Language.Translation[Id]);
      WriteDirectLine('">');
    end;

  var
    Overview: TCreatedOverviewFile;
  begin
    if Text <> '' then
      WriteLiObject(Text, '')
    else
      WriteLiObject(Language.Translation[trOverview], '');
    WriteDirectLine('<ul>');
    for Overview := LowCreatedOverviewFile to HighCreatedOverviewFile do
    begin
      WriteDirectLine('<li><object type="text/sitemap">');
      WriteParam(OverviewFilesInfo[Overview].TranslationHeadlineId);
      WriteDirect('<param name="Local" value="');
      WriteConverted(OverviewFilesInfo[Overview].BaseFileName + GetFileExtension);
      WriteDirectLine('">');
      WriteDirectLine('</object>');
    end;
    WriteDirectLine('</ul>');
  end;

  { ---------- }

  procedure ContentWriteLegend(const Text: string);
  var
    FileName: string;
  begin
    FileName := 'Legend' + GetFileExtension;
    if Text <> '' then
      WriteLiObject(Text, FileName) else
      WriteLiObject(Language.Translation[trLegend], FileName);
  end;

  { ---------- }

  procedure ContentWriteGVUses();
  var
    FileName: string;
  begin
    FileName := OverviewFilesInfo[ofGraphVizUses].BaseFileName + 
      '.' + LinkGraphVizUses;
      
    if LinkGraphVizUses <> '' then
      WriteLiObject(Language.Translation[trGvUses], FileName);
  end;

  { ---------- }

  procedure ContentWriteGVClasses();
  var
    FileName: string;
  begin
    FileName := OverviewFilesInfo[ofGraphVizClasses].BaseFileName + 
      '.' + LinkGraphVizClasses;
      
    if LinkGraphVizClasses <> '' then
      WriteLiObject(Language.Translation[trGvClasses], FileName);
  end;

  { ---------- }

  procedure ContentWriteCustom(const Text, Link: string);
  begin
    if CompareText('@Classes', Link) = 0 then begin
      DefaultContentsWritten := True;
      ContentWriteClasses(Text);
    end else if CompareText('@ClassHierarchy', Link) = 0 then begin
      DefaultContentsWritten := True;
      ContentWriteClassHierarchy({Text});
    end else if CompareText('@Units', Link) = 0 then begin
      DefaultContentsWritten := True;
      ContentWriteUnits(Text);
    end else if CompareText('@Overview', Link) = 0 then begin
      DefaultContentsWritten := True;
      ContentWriteOverview(Text);
    end else if CompareText('@Legend', Link) = 0 then begin
      DefaultContentsWritten := True;
      ContentWriteLegend(Text);
    end else
      WriteLiObject(Text, Link);
  end;

  { ---------- }

  Procedure ContentWriteIntroduction;
  begin
    if Introduction <> nil then
    begin
      WriteLiObject(Introduction.ShortTitle, Introduction.FullLink);
    end;
  end;

  { ---------- }

  Procedure ContentWriteConclusion;
  begin
    if Conclusion <> nil then
    begin
      WriteLiObject(Conclusion.ShortTitle, Conclusion.FullLink);
    end;
  end;

  procedure IndexWriteItem(const Item, PreviousItem, NextItem: TPasItem);
    { Item is guaranteed to be assigned, i.e. not to be nil. }
  begin
  (* All items have the same name. Could be:
    - overloaded proc/method
    - same identifier in different unit or CIO
  *)
  { TODO : this output doesn't look meaningful :-( }
    if Assigned(Item.MyObject) then begin
    //CIO member - check for equal CIO with prev or next item
    {$IFDEF old}
      if (Assigned(NextItem) and Assigned(NextItem.MyObject)
        and (CompareText(Item.MyObject.Name, NextItem.MyObject.Name) = 0))
      or (Assigned(PreviousItem) and Assigned(PreviousItem.MyObject) and
          (CompareText(Item.MyObject.Name, PreviousItem.MyObject.Name) = 0))
    {$ELSE}
      if (Assigned(NextItem) and (NextItem.MyObject = Item.MyObject))
      or (Assigned(PreviousItem) and (PreviousItem.MyObject = Item.MyObject))
    {$ENDIF}
    //looks as if the branches should be reversed?
      then //assume overloaded method
        WriteLiObject(Item.MyObject.Name + ' - ' + Item.MyUnit.Name + #32 +
          Language.Translation[trUnit], Item.FullLink)
      else
        WriteLiObject(Item.MyObject.Name, Item.FullLink);
    end else begin
    //not a CIO member
      WriteLiObject(Item.MyUnit.Name + #32 + Language.Translation[trUnit],
        Item.FullLink);
    end;
  end;

  procedure AddItems(c: TPasItems; scope: TPasScope);
  var
    i: integer;
    m: TPasItem;
    lst: TPasItems;
  begin
  //first add the immediate members, increasing capacity as required
    lst := scope.Members;
    c.CopyItems(lst);
  //then add all sub-scopes
    for i := 0 to lst.Count - 1 do begin
      m := lst.PasItemAt[i];
      if m is TPasScope then
        AddItems(c, TPasScope(m));
    end;
  end;

  { ---------------------------------------------------------------------------- }

var
  j, k, l: Integer;
  CurrentLevel, Level: Integer;
  //CIO: TPasCio;
  PU: TPasUnit;
  c: TPasItems;
  Item, NextItem, PreviousItem: TPasItem;
  Item2: TPasCio;
  s, Text, Link: string;
  SL: TStringVector;
  Overview: TCreatedOverviewFile;
begin
  { At this point, at least one unit has been parsed:
    Units is assigned and Units.Count > 0
    No need to test this again. }

  if CreateStream(ProjectName + '.hhc', True) = csError then begin
    DoMessage(1, pmtError, 'Could not create HtmlHelp Content file "%s.hhc' +
      '".', [ProjectName]);
    Exit;
  end;
  DoMessage(2, pmtInformation, 'Writing HtmlHelp Content file "' + ProjectName
    + '"...', []);

  // File Header
  WriteDirectLine('<!DOCTYPE HTML PUBLIC "-//IETF//DTD HTML//EN">');
  WriteDirectLine('<html>');
  WriteDirectLine('<head>');
  if GeneratorInfo then
    WriteDirect('<meta name="GENERATOR" content="' +
      PASDOC_NAME_AND_VERSION + '">', true);
  WriteDirectLine('</head><body>');
  WriteDirectLine('<ul>');

  DefaultContentsWritten := False;
  DefaultTopic := '';
  if ContentsFile <> '' then begin
    SL := NewStringVector;
    try
      SL.LoadFromTextFileAdd(ContentsFile);
    except
      on e: Exception do
        DoMessage(1, pmtError, e.Message +
          '. Writing default HtmlHelp contents.', []);
    end;

    CurrentLevel := 0;
    for j := 0 to SL.Count - 1 do begin
      s := SL[j];
      Text := BeforeEqualChar(s);
      Level := GetLevel(Text);
      Link := AfterEqualChar(s);

      if Level = CurrentLevel then
        ContentWriteCustom(Text, Link)
      else if CurrentLevel = (Level - 1) then begin
        WriteDirectLine('<ul>');
        Inc(CurrentLevel);
        ContentWriteCustom(Text, Link)
      end else if CurrentLevel > Level then begin
        WriteDirectLine('</ul>');
        Dec(CurrentLevel);
        while CurrentLevel > Level do begin
          WriteDirectLine('</ul>');
          Dec(CurrentLevel);
        end;
        ContentWriteCustom(Text, Link)
      end else begin
        DoMessage(1, pmtError, 'Invalid level ' + IntToStr(Level) +
          'in Content file (line ' + IntToStr(j) + ').', []);
        Exit;
      end;
    end;
    SL.Free;
  end;

  if not DefaultContentsWritten then begin
    ContentWriteIntroduction;
    ContentWriteUnits('');
    ContentWriteClassHierarchy();
    ContentWriteClasses('');
    ContentWriteOverview('');
    ContentWriteLegend('');
    ContentWriteGVClasses();
    ContentWriteGVUses();
    ContentWriteConclusion;
  end;

  // End of File
  WriteDirectLine('</ul>');
  WriteDirectLine('</body></html>');
  CloseStream;

  // Create Keyword Index
  // First collect all Items
  c := TPasItems.Create(False); // Don't free Items when freeing the container

  for j := 0 to Units.Count - 1 do begin
    PU := Units.UnitAt[j];
  {$IFDEF old}
    if Assigned(PU.CIOs) then
      for k := 0 to PU.CIOs.Count - 1 do begin
        CIO := TPasCio(PU.CIOs.PasItemAt[k]);
        c.Add(CIO);
        c.CopyItems(CIO.Fields);
        c.CopyItems(CIO.Properties);
        c.CopyItems(CIO.Methods);
      end;

    c.CopyItems(PU.Types);
    c.CopyItems(PU.Variables);
    c.CopyItems(PU.Constants);
    c.CopyItems(PU.FuncsProcs);
  {$ELSE}
    AddItems(c, PU);
  {$ENDIF}
  end;

  if CreateStream(ProjectName + '.hhk', True) = csError then begin
    DoMessage(1, pmtError, 'Could not create HtmlHelp Index file "%s.hhk' +
      '".', [ProjectName]);
    Exit;
  end;
  DoMessage(2, pmtInformation, 'Writing HtmlHelp Index file "%s"...',
    [ProjectName]);

  WriteDirectLine('<!DOCTYPE HTML PUBLIC "-//IETF//DTD HTML//EN">');
  WriteDirectLine('<html>');
  WriteDirectLine('<head>');
  if GeneratorInfo then
    WriteDirectLine('<meta name="GENERATOR" content="' + 
      PASDOC_NAME_AND_VERSION + '">');
  WriteDirectLine('</head><body>');
  WriteDirectLine('<ul>');

  // Write all Items to KeyWord Index

  c.SortShallow;

  if c.Count > 0 then begin
    Item := c.PasItemAt[0];
    j := 1;

    while j < c.Count do begin
      NextItem := c.PasItemAt[j];

      // Does the next Item have a different name?
      //(check for overloaded procedures, or same identifiers in different units)
      if CompareText(Item.Name, NextItem.Name) <> 0 then begin
        WriteLiObject(Item.Name, Item.FullLink);
        Item := NextItem;
      end
      else begin
        // Write the Item. It acts as a header for the subitems to follow.
        WriteLiObject(Item.Name, Item.FullLink);
        // Indent by one.
        WriteDirectLine('<ul>');

        // No previous Item as we start.
        PreviousItem := nil;

        // Keep on writing Items with the same name as subitems.
        repeat
          IndexWriteItem(Item, PreviousItem, NextItem);

          PreviousItem := Item;
          Item := NextItem;
          Inc(j);

          if j >= c.Count then Break;
          NextItem := c.PasItemAt[j];

                // Break as soon Items' names are different.
        until CompareText(Item.Name, NextItem.Name) <> 0;

              // No NextItem as we write the last one of the same Items.
        IndexWriteItem(Item, PreviousItem, nil);

        Item := NextItem;
        WriteDirectLine('</ul>');
      end;

      Inc(j);
    end;

      // Don't forget to write the last item. Can it ever by nil?
    WriteLiObject(Item.Name, Item.FullLink);
  end;

  c.Free;

  WriteDirectLine('</ul>');
  WriteDirectLine('</body></html>');
  CloseStream;

  // Create a HTML Help Project File
  if CreateStream(ProjectName + '.hhp', True) = csError then begin
    DoMessage(1, pmtError, 'Could not create HtmlHelp Project file "%s.hhp' +
      '".', [ProjectName]);
    Exit;
  end;
  DoMessage(3, pmtInformation, 'Writing Html Help Project file "%s"...',
    [ProjectName]);

  WriteDirectLine('[OPTIONS]');
  WriteDirectLine('Binary TOC=Yes');
  WriteDirectLine('Compatibility=1.1 or later');
  WriteDirectLine('Compiled file=' + ProjectName + '.chm');
  WriteDirectLine('Contents file=' + ProjectName + '.hhc');
  WriteDirectLine('Default Window=Default');
  WriteDirectLine('Default topic=' + DefaultTopic);
  WriteDirectLine('Display compile progress=Yes');
  WriteDirectLine('Error log file=' + ProjectName + '.log');
  WriteDirectLine('Full-text search=Yes');
  WriteDirectLine('Index file=' + ProjectName + '.hhk');
  if Title <> '' then
    WriteDirectLine('Title=' + Title)
  else
    WriteDirectLine('Title=' + ProjectName);

  WriteDirectLine('');
  WriteDirectLine('[WINDOWS]');
  if Title <> '' then
    WriteDirect('Default="' + Title + '","' + ProjectName +
      '.hhc","' + ProjectName + '.hhk",,,,,,,0x23520,,0x300e,,,,,,,,0', true)
  else
    WriteDirect('Default="' + ProjectName + '","' +
      ProjectName + '.hhc","' + ProjectName +
      '.hhk",,,,,,,0x23520,,0x300e,,,,,,,,0', true);

  WriteDirectLine('');
  WriteDirectLine('[FILES]');

  { HHC seems to know about the files by reading the Content and Index.
    So there is no need to specify them in the FILES section. }

  WriteDirectLine('Legend.html');

  If Introduction <> nil then
    WriteDirectLine(Introduction.FullLink);

  if (LinkGraphVizClasses <> '') then
    WriteDirectLine(OverviewFilesInfo[ofGraphVizClasses].BaseFileName + '.' +
      LinkGraphVizClasses);
    
  if LinkGraphVizUses <> '' then
    WriteDirectLine(OverviewFilesInfo[ofGraphVizUses].BaseFileName + '.' + 
      LinkGraphVizUses);

  for Overview := LowCreatedOverviewFile to HighCreatedOverviewFile do
    WriteDirectLine(OverviewFilesInfo[Overview].BaseFileName + '.html');

  if Assigned(Units) then
    for k := 0 to units.Count - 1 do
      begin
        Item := units.PasItemAt[k];
        PU := TPasUnit(units.PasItemAt[k]);
        WriteDirectLine(Item.FullLink);
        c := PU.CIOs;
        if Assigned(c) then
          for l := 0 to c.Count - 1 do
            begin
              Item2 := TPasCio(c.PasItemAt[l]);
              WriteDirectLine(Item2.OutputFilename);
            end;
      end;

  If Conclusion <> nil then
    WriteDirectLine(Conclusion.FullLink);

  WriteDirectLine('');

  WriteDirectLine('[INFOTYPES]');

  WriteDirectLine('');

  WriteDirectLine('[MERGE FILES]');

  CloseStream;
end;

initialization
  RegisterGenerator('htmlhelp', THTMLHelpDocGenerator);
end.
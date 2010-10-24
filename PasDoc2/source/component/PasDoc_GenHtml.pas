{ @abstract(Provides HTML document generator object.)
  @author(Johannes Berg <johannes@sipsolutions.de>)
  @author(Ralf Junker (delphi@zeitungsjunge.de))
  @author(Alexander Lisnevsky (alisnevsky@yandex.ru))
  @author(Erwin Scheuch-Heilig (ScheuchHeilig@t-online.de))
  @author(Marco Schmidt (marcoschmidt@geocities.com))
  @author(Hendy Irawan (ceefour@gauldong.net))
  @author(Wim van der Vegt (wvd_vegt@knoware.nl))
  @author(Thomas Mueller (www.dummzeuch.de))
  @author(David Berg (HTML Layout) <david@sipsolutions.de>)
  @author(Grzegorz Skoczylas <gskoczylas@rekord.pl>)
  @author(Michalis Kamburelis)
  @author(Richard B. Winston <rbwinst@usgs.gov>)
  @author(Ascanio Pressato)
  @author(DoDi)
  @cvs($Date$)

  Implements an object to generate HTML documentation, overriding many of
  @link(TDocGenerator)'s virtual methods. }

unit PasDoc_GenHtml;

interface

uses
  Classes,
  PasDoc_Base,
  PasDoc_Utils,
  PasDoc_Gen,
  PasDoc_Items,
  PasDoc_Languages,
  PasDoc_StringVector,
  PasDoc_Types;

type
  { @abstract(generates HTML documentation)
    Extends @link(TDocGenerator) and overwrites many of its methods to generate
    output in HTML (HyperText Markup Language) format. }
  TGenericHTMLDocGenerator = class(TDocGenerator)
  protected
    FLinkCount: Integer;
    FOddTableRow: boolean;

    FImages: TStringList;

  //-basic formatting
    procedure WriteSpellChecked(const AString: string);

    function  FormatAnAnchor(const AName, Caption: string): string;
    procedure WriteAnchor(const AName: string); overload;
    procedure WriteAnchor(const AName, Caption: string); overload;

    function MakeImage(const src, alt, CssClass: string): string;
    { writes a link
      @param href is the link's reference
      @param caption is the link's caption (must already been converted)
      @param CssClass is the link's CSS class }
    procedure WriteLink(const href, caption, CssClass: string);
    { writes a link with a target frame
      @param href is the link's reference
      @param caption is the link's caption (must already been converted)
      @param CssClass is the link's CSS class
      @param TargetFrame is the link's target frame (or empty) }
    procedure WriteTargettedLink(const href, caption, CssClass, TargetFrame: string);

    { makes a link with a target frame
      @param href is the link's reference
      @param caption is the link's text
      @param CssClass is the link's CSS class
      @param TargetFrame is the link's target frame (or empty) }
    function MakeTargettedLink(
      const href, caption, CssClass, TargetFrame: string): string;

    procedure WriteCodeWithLinks(const p: TPasItem; const Code: string;
      WriteItemLink: boolean);
    { Writes a cell into a table row with the Item's visibility image. }
    procedure WriteVisibilityCell(const Item: TPasItem);

    { Writes heading S to output, at heading level I.
      Write optional section anchor.
      For HTML, only levels 1 to 6 are valid, so that values smaller
      than 1 will be set to 1 and arguments larger than 6 are set to 6.
      The String S will then be enclosed in an element from H1 to H6,
      according to the level. }
    procedure WriteHeading(HL: integer; const CssClass: string; const s: string;
      const anchor: string = '');

    { Returns HTML heading tag. You can also make the anchor
      at this heading by passing AnchorName <> ''. }
    function FormatHeading(HL: integer; const CssClass: string;
      const s: string; const AnchorName: string): string;

    procedure WriteStartOfDocument(AName: string);
    { Starts an HTML paragraph element by writing an opening P tag. }
    procedure WriteStartOfParagraph; overload;
    procedure WriteStartOfParagraph(const CssClass: string); overload;
    { Starts an HTML table with a css class }
    procedure WriteStartOfTable(const CssClass: string);
    procedure WriteStartOfTableCell; overload;
    procedure WriteStartOfTableCell(const CssClass: string); overload;
    procedure WriteStartOfTable1Column(const CssClass: string);
    procedure WriteStartOfTable2Columns(const CssClass: string; const t1, t2: string);
    procedure WriteStartOfTable3Columns(const CssClass: string; const t1, t2, t3: string);
    procedure WriteStartOfTableRow(const CssClass: string);

    procedure WriteEndOfDocument;
    { Finishes an HTML paragraph element by writing a closing P tag. }
    procedure WriteEndOfParagraph;
    { Finishes an HTML table cell by writing a closing TD tag. }
    procedure WriteEndOfTableCell;
    { Finishes an HTML table by writing a closing TABLE tag. }
    procedure WriteEndOfTable;
    { Finishes an HTML table row by writing a closing TR tag. }
    procedure WriteEndOfTableRow;
    procedure WriteFooter;

  //-standard (sub)sections
    { Returns line with <meta http-equiv="Content-Type" ...>
      describing current charset (from Language). }
    function MetaContentType: string;
    { Writes information on doc generator to current output stream,
      including link to pasdoc homepage. }
    procedure WriteAppInfo;

    { Writes authors to output, at heading level HL. Will not write anything
      if collection of authors is not assigned or empty. }
    procedure WriteAuthors(HL: integer; Authors: TDescriptionItem);

  //-item tables
    { Used by WriteItemsSummary and WriteItemsDetailed. }
    procedure WriteItemTableRow(Item: TPasItem; ShowVisibility: boolean;
      WriteItemLink: boolean; MakeAnchor: boolean);

    procedure WriteItemsSummary(Items: TPasItems; ShowVisibility: boolean;
      HeadingLevel: Integer;
      const SectionAnchor: string; SectionName: TTranslationId);

  //-write files
    { output all the necessary images }
    procedure WriteBinaryFiles;
    { output the index.html and navigation.html files }
    procedure WriteFramesetFiles;
    { write the legend file for visibility markers }
    procedure WriteVisibilityLegendFile;

  protected
  //-override inherited
    function ConvertString(const s: string): string; override;

    { Called by @link(ConvertString) to convert a character.
      Will convert special characters to their html escape sequence
      -> test }
    function ConvertChar(c: char): string; override;

    { overrides @inherited.HtmlString to return the string verbatim
      (@inherited discards those strings) }
    function HtmlString(const S: string): string; override;

    // FormatPascalCode will cause Line to be formatted in
    // the way that Pascal code is formatted in Delphi.
    function FormatPascalCode(const Line: string): string; override;

    // FormatComment will cause AString to be formatted in
    // the way that comments other than compiler directives are
    // formatted in Delphi.  See: @link(FormatCompilerComment).
    function FormatComment(AString: string): string; override;

    // FormatHex will cause AString to be formatted in
    // the way that Hex are formatted in Delphi.
    function FormatHex(AString: string): string; override;

    // FormatNumeric will cause AString to be formatted in
    // the way that Numeric are formatted in Delphi.
    function FormatNumeric(AString: string): string; override;

    // FormatFloat will cause AString to be formatted in
    // the way that Float are formatted in Delphi.
    function FormatFloat(AString: string): string; override;

    // FormatKeyWord will cause AString to be formatted in
    // the way that strings are formatted in Delphi.
    function FormatString(AString: string): string; override;

    // FormatKeyWord will cause AString to be formatted in
    // the way that reserved words are formatted in Delphi.
    function FormatKeyWord(AString: string): string; override;

    // FormatCompilerComment will cause AString to be formatted in
    // the way that compiler directives are formatted in Delphi.
    function FormatCompilerComment(AString: string): string; override;

    { Makes a String look like a coded String, i.e. <CODE>TheString</CODE>
      in Html. }
    function CodeString(const s: string): string; override;

  // Create file name from qualified item name.
    function  NewLink(const AFullName: string): string;

    procedure WriteStartOfCode; override;
    procedure WriteEndOfCode; override;

    function Paragraph: string; override;

    function EnDash: string; override;
    function EmDash: string; override;

    function LineBreak: string; override;

    function URLLink(const URL: string): string; override;

    function MakeItemLink(const Item: TBaseItem;
      const LinkCaption: string;
      const LinkContext: TLinkContext): string; override;

    function EscapeURL(const AString: string): string; virtual;

    function FormatSection(HL: integer; const Anchor: string;
      const Caption: string): string; override;
    function FormatAnchor(const Anchor: string): string; override;

    function FormatBold(const Text: string): string; override;
    function FormatItalic(const Text: string): string; override;

    function FormatPreformatted(const Text: string): string; override;

    function FormatImage(FileNames: TStringList): string; override;

    function FormatList(ListData: TListData): string; override;

    function FormatTable(Table: TTableData): string; override;

    function FormatTableOfContents(Sections: TDescriptionItem): string; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    { Returns HTML file extension ".html". }
    function GetFileExtension: string; override;
  end;

{$IFDEF old}
  { This is the old TGenericHTMLDocGenerator. }
  THTMLDocGenerator = class(TGenericHTMLDocGenerator)
  protected
    { Returns a link to an anchor within a document.
      HTML simply concatenates the strings with a "#" character between them. }
    function  CreateLink(const Item: TBaseItem): string; override;
    { Writes a single class, interface or object CIO to output, at heading
      level HL. }
    procedure WriteCIO(HL: integer; const CIO: TPasCio);
    { Calls @link(WriteCIO) with each element in the argument collection C,
      using heading level HL. }
    procedure WriteCIOs(HL: integer; c: TPasItems);
    procedure WriteCIOSummary(HL: integer; c: TPasItems);
    { Writes dates Created and LastMod at heading level HL to output
      (if at least one the two has a value assigned). }
    procedure WriteDates(const HL: integer; Created, LastMod: TDescriptionItem);
    { Writes the Item's short description.
      This is either the explicit AbstractDescription (@@abstract)
      or the (abbreviated) DetailedDescription. }
    procedure WriteExternalCore(const ExternalItem: TExternalItem;
      const Id: TTranslationID); override;
    procedure WriteItemShortDescription(const AItem: TPasItem);
    (*Writes the Item's AbstractDescription followed by DetailedDescription.
      Include further descriptions, depening on item kind (parameters...).

      If OpenCloseParagraph then code here will open and close paragraph
      for itself. So you shouldn't
      surround it inside WriteStart/EndOfParagraph, like
      @longcode(#
        { BAD EXAMPLE }
        WriteStartOfParagraph;
        WriteItemLongDescription(Item, true);
        WriteEndOfParagraph;
      #)

      While you can pass OpenCloseParagraph = @false, do it with caution,
      and note that long description has often such large content that it
      really should be separated by paragraph. Passing
      OpenCloseParagraph = @false is sensible only if you will wrap this
      anyway inside some paragraph or similar block level element.
    *)
    procedure WriteItemLongDescription(const AItem: TPasItem;
      OpenCloseParagraph: boolean = true);
    procedure WriteItemsDetailed(Items: TPasItems; ShowVisibility: boolean;
      HeadingLevel: Integer; SectionName: TTranslationId);
    procedure WriteOverviewFiles;
    //override inherited global entry point
    procedure WriteUnit(const HL: integer; const U: TPasUnit); override;
  public
    { The method that does everything - writes documentation for all units
      and creates overview files. }
    procedure WriteDocumentation; override;
  end;
{$ELSE}
{$ENDIF}

const
  DefaultPasdocCss = {$I pasdoc.css.inc};

implementation

uses
  SysUtils,
  StrUtils, { if you are using Delphi 5 or fpc 1.1.x you must add ..\component\strutils to your search path }
  PasDoc_ObjectVector,
  PasDoc_Tipue,
  PasDoc_Aspell;

const
  img_automated : {$I automated.gif.inc};
  img_private   : {$I private.gif.inc};
  img_public    : {$I public.gif.inc};
  img_published : {$I published.gif.inc};
  img_protected : {$I protected.gif.inc};

const
  DoctypeFrameset = '<!DOCTYPE HTML PUBLIC ' +
    '"-//W3C//DTD HTML 4.01 Frameset//EN" ' +
    '"http://www.w3.org/TR/1999/REC-html401-19991224/frameset.dtd">';
  DoctypeNormal = '<!DOCTYPE HTML PUBLIC ' +
    '"-//W3C//DTD HTML 4.01 Transitional//EN" ' +
    '"http://www.w3.org/TR/1999/REC-html401-19991224/loose.dtd">';

constructor TGenericHTMLDocGenerator.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
{$IFDEF old}
  LinkCount := 1;
  if CSS = '' then
{$ELSE}
{$ENDIF}
  CSS := DefaultPasdocCss; //unless explicitly specified
  FImages := TStringList.Create;
end;

destructor TGenericHTMLDocGenerator.Destroy;
begin
  FImages.Free;
  inherited;
end;

function TGenericHTMLDocGenerator.HtmlString(const S: string): string;
begin
  Result := S;
end;

function TGenericHTMLDocGenerator.FormatString(AString: string): string;
begin
  result := '<span class="pascal_string">' + ConvertString(AString) + '</span>';
end;

function TGenericHTMLDocGenerator.FormatKeyWord(AString: string): string;
begin
  result := '<span class="pascal_keyword">' + ConvertString(AString) + '</span>';
end;

function TGenericHTMLDocGenerator.FormatComment(AString: string): string;
begin
  result := '<span class="pascal_comment">' + ConvertString(AString) + '</span>';
end;

function TGenericHTMLDocGenerator.FormatHex(AString: string): string;
begin
  result := '<span class="pascal_hex">' + ConvertString(AString) + '</span>';
end;

function TGenericHTMLDocGenerator.FormatNumeric(AString: string): string;
begin
  result := '<span class="pascal_numeric">' + ConvertString(AString) + '</span>';
end;

function TGenericHTMLDocGenerator.FormatFloat(AString: string): string;
begin
  result := '<span class="pascal_float">' + ConvertString(AString) + '</span>';
end;

function TGenericHTMLDocGenerator.FormatCompilerComment(AString: string): string;
begin
  result := '<span class="pascal_compiler_comment">' + ConvertString(AString) + '</span>';
end;

function TGenericHTMLDocGenerator.CodeString(const s: string): string;
begin
  Result := '<code>' + s + '</code>';
end;


function TGenericHTMLDocGenerator.NewLink(const AFullName: string): string;
begin
  Result := AFullName;
  if NumericFilenames then begin
    //Result := Format('%.8d', [FLinkCount]) + GetFileExtension;
    Str(FLinkCount:8, Result);
    Inc(FLinkCount);
  end;
  Result := Result + GetFileExtension;
end;

function TGenericHTMLDocGenerator.GetFileExtension: string;
begin
  Result := '.html';
end;

procedure TGenericHTMLDocGenerator.WriteAppInfo;
begin
  { check if user does not want a link to the pasdoc homepage }
  if Not GeneratorInfo then
    Exit;
  { write a horizontal line, pasdoc version and a link to the pasdoc homepage }
  WriteDirect('<hr noshade size="1">');
  WriteDirect('<span class="appinfo">');
  WriteDirect('<em>');
  WriteConverted(Language.Translation[trGeneratedBy] + ' ');
  WriteTargettedLink(PASDOC_HOMEPAGE, PASDOC_NAME_AND_VERSION, '', '_parent');
  WriteConverted(' ' + Language.Translation[trOnDateTime] + ' ' +
    FormatDateTime('yyyy-mm-dd hh:mm:ss', Now));
  WriteDirectLine('</em>');
  WriteDirectLine('</span>');
end;

//procedure TGenericHTMLDocGenerator.WriteAuthors(HL: integer; Authors: TStringVector);
procedure TGenericHTMLDocGenerator.WriteAuthors(HL: integer; Authors: TDescriptionItem);
var
  i: Integer;
  s, S1, S2: string;
  Address: string;
begin
  if IsEmpty(Authors) then Exit;

  if (Authors.Count = 1) then
    WriteHeading(HL, 'authors', Language.Translation[trAuthor])
  else
    WriteHeading(HL, 'authors', Language.Translation[trAuthors]);

  WriteDirectLine('<ul class="authors">');
  for i := 0 to Authors.Count - 1 do begin
    s := Authors.GetString(i);
    WriteDirect('<li>');

    if ExtractEmailAddress(s, S1, S2, Address) then begin
      WriteConverted(S1);
      WriteLink('mailto:' + Address, ConvertString(Address), '');
      WriteConverted(S2);
    end else if ExtractWebAddress(s, S1, S2, Address) then begin
      WriteConverted(S1);
      WriteLink('http://' + Address, ConvertString(Address), '');
      WriteConverted(S2);
    end else begin
      WriteConverted(s);
    end;

    WriteDirectLine('</li>');
  end;
  WriteDirectLine('</ul>');
end;

procedure TGenericHTMLDocGenerator.WriteCodeWithLinks(const p: TPasItem;
  const Code: string; WriteItemLink: boolean);
begin
  WriteCodeWithLinksCommon(p, Code, WriteItemLink, '<b>', '</b>');
end;

{ ---------------------------------------------------------------------------- }

procedure TGenericHTMLDocGenerator.WriteEndOfDocument;
begin
  WriteDirect('</body>');
  WriteDirectLine('</html>');
end;

procedure TGenericHTMLDocGenerator.WriteEndOfCode;
begin
  WriteDirect('</code>');
end;

procedure TGenericHTMLDocGenerator.WriteLink(const href, caption, CssClass: string);
begin
  WriteTargettedLink(href, caption, CssClass, '');
end;

function TGenericHTMLDocGenerator.MakeItemLink(
  const Item: TBaseItem;
  const LinkCaption: string;
  const LinkContext: TLinkContext): string;
var 
  CssClass: string;
begin
  if LinkContext = lcNormal then
    CssClass := 'normal' else
    CssClass := '';

  Result := MakeTargettedLink(Item.FullLink, ConvertString(LinkCaption),
    CssClass, '');
end;

function TGenericHTMLDocGenerator.MakeTargettedLink(
  const href, caption, CssClass, TargetFrame: string): string;
begin
  Result := Format('<a%s%s href="%s">%s</a>',
    [ifthen(CssClass = '', '', ' class="' + CssClass + '"'),
     ifthen(TargetFrame = '', '', ' target="' + TargetFrame + '"'),
     EscapeURL(href), caption]);
end;

procedure TGenericHTMLDocGenerator.WriteTargettedLink(
  const href, caption, CssClass, TargetFrame: string);
begin
  WriteDirect(MakeTargettedLink(href, caption, CssClass, TargetFrame));
end;

procedure TGenericHTMLDocGenerator.WriteEndOfParagraph;
begin
  WriteDirectLine('</p>');
end;

procedure TGenericHTMLDocGenerator.WriteEndOfTableCell;
begin
  WriteDirectLine('</td>');
end;

procedure TGenericHTMLDocGenerator.WriteEndOfTable;
begin
  WriteDirectLine('</table>');
end;

procedure TGenericHTMLDocGenerator.WriteEndOfTableRow;
begin
  WriteDirectLine('</tr>');
end;

{ ---------------------------------------------------------------------------- }

procedure TGenericHTMLDocGenerator.WriteFooter;
begin
  WriteDirect(Footer);
end;

{ ---------------------------------------------------------------------------- }

procedure TGenericHTMLDocGenerator.WriteItemTableRow(
  Item: TPasItem; ShowVisibility: boolean; 
  WriteItemLink: boolean; MakeAnchor: boolean);
begin
  if item = nil then
    exit;

  WriteStartOfTableRow('');

  if ShowVisibility then
    WriteVisibilityCell(Item);
  { todo: assign a class }
  WriteStartOfTableCell('itemcode');

  if MakeAnchor then WriteAnchor(Item.Name);

  WriteCodeWithLinks(Item, Item.FullDeclaration, WriteItemLink);

  WriteEndOfTableCell;
  WriteEndOfTableRow;
end;

procedure TGenericHTMLDocGenerator.WriteItemsSummary(
  Items: TPasItems; ShowVisibility: boolean; HeadingLevel: Integer;
  const SectionAnchor: string; SectionName: TTranslationId);
var 
  i: Integer;
begin
  if IsEmpty(Items) then Exit;

  WriteAnchor(SectionAnchor);

  WriteHeading(HeadingLevel + 1, 'summary', Language.Translation[SectionName]);

  WriteStartOfTable1Column('summary');

  for i := 0 to Items.Count - 1 do
    WriteItemTableRow(Items.PasItemAt[i], ShowVisibility, true, false);

  WriteEndOfTable;
end;

function TGenericHTMLDocGenerator.FormatHeading(HL: integer;
  const CssClass: string; const s: string;
  const AnchorName: string): string;
var
  c: string;
begin
  if (HL < 1) then
    c := '1'
  else if HL > 6 then begin
    DoMessage(2, pmtWarning, 'HTML generator cannot write headlines of level 7 or greater; will use 6 instead.', []);
    c := '6';
  end else
    c := IntToStr(HL);

  Result := ConvertString(S);
  if AnchorName <> '' then
    Result := '<a name="' + AnchorName + '"></a>' + Result;

  Result := '<h' + c + ' class="' + CssClass + '">' + Result +
    '</h' + c + '>' + LineEnding;
end;

procedure TGenericHTMLDocGenerator.WriteHeading(HL: integer; 
  const CssClass: string; const s: string; const anchor: string);
begin
  WriteDirect(FormatHeading(HL, CssClass, s, anchor));
end;

{ ---------------------------------------------------------------------------- }

function TGenericHTMLDocGenerator.FormatAnAnchor(
  const AName, Caption: string): string;
begin
  //result := Format('<a name="%s">%s</a>', [AName, Caption]);
  result := '<a name="' + AName + '">' + Caption + '</a>';
end;

procedure TGenericHTMLDocGenerator.WriteAnchor(const AName: string);
begin
  WriteAnchor(AName, '');
end;

procedure TGenericHTMLDocGenerator.WriteAnchor(const AName, Caption: string);
begin
  WriteDirect(FormatAnAnchor(AName, Caption));
end;

{ ---------------------------------------------------------------------------- }

procedure TGenericHTMLDocGenerator.WriteStartOfCode;
begin
  WriteDirect('<code>');
end;

{ ---------------------------------------------------------------------------- }

function TGenericHTMLDocGenerator.MetaContentType: string;
begin
  if Language.CharSet <> '' then
    Result := '<meta http-equiv="content-type" content="text/html; charset='
      + Language.CharSet + '">' + LineEnding
  else
    Result := '';
end;

procedure TGenericHTMLDocGenerator.WriteStartOfDocument(AName: string);
begin
  WriteDirectLine(DoctypeNormal);
  WriteDirectLine('<html>');
  WriteDirectLine('<head>');
  if GeneratorInfo then
    WriteDirectLine('<meta name="GENERATOR" content="' + PASDOC_NAME_AND_VERSION + '">');
  WriteDirect(MetaContentType);
  // Title
  WriteDirect('<title>');
  if Title <> '' then 
    WriteConverted(Title + ': ');
  WriteConverted(AName);
  WriteDirectLine('</title>');
  // StyleSheet
  WriteDirect('<link rel="StyleSheet" type="text/css" href="');
  WriteDirect(EscapeURL('pasdoc.css'));
  WriteDirectLine('">');

  WriteDirectLine('</head>');
  WriteDirectLine('<body bgcolor="#ffffff" text="#000000" link="#0000ff" vlink="#800080" alink="#FF0000">');

  if Length(Header) > 0 then begin
    WriteSpellChecked(Header);
  end;
end;

procedure TGenericHTMLDocGenerator.WriteStartOfParagraph(const CssClass: string);
begin
  if CssClass <> '' then
    WriteDirectLine('<p class="' + CssClass + '">')
  else
    WriteStartOfParagraph;
end;

procedure TGenericHTMLDocGenerator.WriteStartOfParagraph;
begin
  WriteDirectLine('<p>');
end;

procedure TGenericHTMLDocGenerator.WriteStartOfTable(const CssClass: string);
begin
  FOddTableRow := false;
  { Every table create by WriteStartOfTable has class wide_list }
  WriteDirectLine('<table class="' + CssClass + ' wide_list">');
end;

procedure TGenericHTMLDocGenerator.WriteStartOfTable1Column(const CssClass: string);
begin
  WriteStartOfTable(CssClass);
end;

procedure TGenericHTMLDocGenerator.WriteStartOfTable2Columns(const CssClass: string;
  const t1, t2: string);
begin
  WriteStartOfTable(CssClass);
  WriteDirectLine('<tr class="listheader">');
  WriteDirect('<th class="itemname">');
  WriteConverted(t1);
  WriteDirectLine('</th>');
  WriteDirect('<th class="itemdesc">');
  WriteConverted(t2);
  WriteDirectLine('</th>');
  WriteDirectLine('</tr>');
end;

procedure TGenericHTMLDocGenerator.WriteStartOfTable3Columns(
  const CssClass: string; const t1, t2, t3: string);
begin
  WriteStartOfTable(CssClass);
  WriteDirectLine('<tr class="listheader">');
  WriteDirect('<th class="itemname">');
  WriteConverted(t1);
  WriteDirectLine('</th>');
  WriteDirect('<th class="itemunit">');
  WriteConverted(t2);
  WriteDirectLine('</th>');
  WriteDirect('<th class="itemdesc">');
  WriteConverted(t3);
  WriteDirectLine('</th>');
  WriteDirectLine('</tr>');
end;

procedure TGenericHTMLDocGenerator.WriteStartOfTableCell(
  const CssClass: string);
var
  s: string;
begin
  if CssClass <> '' then
    s := '<td class="' + CssClass + '">'
  else
    s := '<td>';
  WriteDirect(s);
end;

procedure TGenericHTMLDocGenerator.WriteStartOfTableCell;
begin
  WriteStartOfTableCell('');
end;

procedure TGenericHTMLDocGenerator.WriteStartOfTableRow(const CssClass: string);
var
  s: string;
begin
  if CssClass <> '' then begin
    s := '<tr class="' + CssClass;
  end else begin
    s := '<tr class="list';
    if FOddTableRow then begin
      s := s + '2';
    end;
    FOddTableRow := not FOddTableRow;
  end;
  WriteDirectLine(s + '">');
end;

function TGenericHTMLDocGenerator.MakeImage(const src, alt, CssClass: string): string;
begin
  Result := Format('<img %s src="%s" alt="%s" title="%s">',
    [IfThen(CssClass = '', '', 'class="' + CssClass + '"'),
     src, alt, alt]);
end;

const
  VisibilityImageName: array[TVisibility] of string = (
    'published.gif',
    'public.gif',
    'protected.gif',
    'protected.gif',
    'private.gif',
    'private.gif',
    'automated.gif',
    { Implicit visibility uses published visibility image, for now }
    'published.gif'
  );
  VisibilityTranslation: array[TVisibility] of TTranslationID = (
    trPublished,
    trPublic,
    trProtected,
    trStrictProtected,
    trPrivate,
    trStrictPrivate,
    trAutomated,
    trImplicit
  );

procedure TGenericHTMLDocGenerator.WriteVisibilityCell(const Item: TPasItem);

  procedure WriteVisibilityImage(Vis: TVisibility);
  begin
    WriteLink('legend.html', MakeImage(VisibilityImageName[Vis],
      ConvertString(Language.Translation[
        VisibilityTranslation[Vis]]), ''), '');
  end;

begin
  WriteStartOfTableCell('visibility');
  WriteVisibilityImage(Item.Visibility);
  WriteEndOfTableCell;
end;

{ ---------------------------------------------------------------------------- }

procedure TGenericHTMLDocGenerator.WriteVisibilityLegendFile;

  procedure WriteLegendEntry(Vis: TVisibility);
  var VisTrans: string;
  begin
    VisTrans := Language.Translation[VisibilityTranslation[Vis]];
    WriteStartOfTableRow('');
    WriteStartOfTableCell('legendmarker');
    WriteDirect(MakeImage(VisibilityImageName[Vis],
      ConvertString(VisTrans), ''));
    WriteEndOfTableCell;
    WriteStartOfTableCell('legenddesc');
    WriteConverted(VisTrans);
    WriteEndOfTableCell;
    WriteEndOfTableRow;
  end;

const
  Filename = 'legend';
begin
  if CreateStream(Filename + GetFileextension, True) = csError then
    begin
      DoMessage(1, pmtError, 'Could not create output file "%s".',
        [Filename + GetFileExtension]);
      Abort;
    end;
  try
    WriteStartOfDocument(Language.Translation[trLegend]);

    WriteHeading(1, 'markerlegend', Language.Translation[trLegend]);

    WriteStartOfTable2Columns('markerlegend',
      Language.Translation[trMarker],
      Language.Translation[trVisibility]);

    { Order of entries below is important (because it is shown to the user),
      so we don't just write all TVisibility values in the order they
      were declared in TVisibility type. }
    WriteLegendEntry(viStrictPrivate);
    WriteLegendEntry(viPrivate);
    WriteLegendEntry(viStrictProtected);
    WriteLegendEntry(viProtected);
    WriteLegendEntry(viPublic);
    WriteLegendEntry(viPublished);
    WriteLegendEntry(viAutomated);
    WriteLegendEntry(viImplicit);
    WriteEndOfTable;

    WriteFooter;
    WriteAppInfo;
    WriteEndOfDocument;
  finally CloseStream; end;
end;

{ ---------------------------------------------------------------------------- }

procedure TGenericHTMLDocGenerator.WriteSpellChecked(const AString: string);

{ TODO -- this code is scheduled to convert it to some generic
  version like WriteSpellCheckedGeneric in TDocGenerator to be able
  to easily do the similar trick for other output formats like LaTeX
  and future output formats.
  
  Note: don't you dare to copy&paste this code to TTexDocGenerator !
  If you want to work on it, make it generic, i.e. copy&paste this code
  to TDocGenerator and make it "generic" there. *Then* create specialized
  version in TTexDocGenerator that calls the generic version. 
  
  Or maybe such generic version should be better inside PasDoc_Aspell ? 
  This doesn't really matter. }

var
  LErrors: TObjectVector;
  i, temp: Integer;
  LString, s: string;
begin
  LErrors := TObjectVector.Create(True);
  CheckString(AString, LErrors);
  if LErrors.Count = 0 then begin
    WriteDirect(AString);
  end else begin
    // build s
    s := '';
    LString := AString;
    for i := LErrors.Count-1 downto 0 do 
    begin
      // everything after the offending word
      temp := TSpellingError(LErrors.Items[i]).Offset+Length(TSpellingError(LErrors.Items[i]).Word) + 1;
      s := ( '">' + TSpellingError(LErrors.Items[i]).Word +  '</acronym>' + Copy(LString, temp, MaxInt)) + s; // insert into string
      if Length(TSpellingError(LErrors.Items[i]).Suggestions) > 0 then begin
        s := 'suggestions: '+TSpellingError(LErrors.Items[i]).Suggestions + s;
      end else begin
        s := 'no suggestions' + s;
      end;
      s := '<acronym class="mispelling" title="' + s;
      SetLength(LString, TSpellingError(LErrors.Items[i]).Offset);
    end;
    WriteDirect(LString);
    WriteDirect(s);
  end;
  LErrors.Free;
end;

procedure TGenericHTMLDocGenerator.WriteBinaryFiles;

  procedure WriteGifFile(const Img: array of byte; const Filename: string);
  begin
    if CreateStream(Filename, True) = csError 
      then begin
        DoMessage(1, pmtError, 'Could not create output file "%s".', [Filename]);
      Exit;
    end;
    CurrentStream.Write(img[0], High(img)+1);
    CloseStream;
  end;

var
  PasdocCssFileName: string;
begin
  WriteGifFile(img_automated, 'automated.gif');
  WriteGifFile(img_private, 'private.gif');
  WriteGifFile(img_protected, 'protected.gif');
  WriteGifFile(img_public, 'public.gif');
  WriteGifFile(img_published, 'published.gif');

  PasdocCssFileName := DestinationDirectory + 'pasdoc.css';
  StringToFile(PasdocCssFileName, CSS);
end;

procedure TGenericHTMLDocGenerator.WriteFramesetFiles;

  procedure LocalWriteLink(const Filename, Caption: string); overload;
  begin
    WriteDirect('<tr><td><a target="content" href="' + EscapeURL(Filename) + '" class="navigation">');
    WriteConverted(Caption);
    WriteDirectLine('</a></td></tr>');
  end;  

  procedure LocalWriteLink(const Filename: string; CaptionId: TTranslationID); overload;
  begin
    LocalWriteLink(Filename, Language.Translation[CaptionId]);
  end;

var
  Overview: TCreatedOverviewFile;
begin
  CreateStream('index.html', True);
  Options.MasterFile := FCurrentFileName;
  WriteDirectLine(DoctypeFrameset);
  WriteDirectLine('<html><head>');
  WriteDirect(MetaContentType);
  WriteDirectLine('<title>'+Title+'</title>');
  WriteDirectLine('</head><frameset cols="200,*">');
  WriteDirectLine('<frame src="navigation.html" frameborder="0">');
  if Introduction <> nil then begin
    WriteDirectLine('<frame src="' +
      Introduction.OutputFileName +
      '" frameborder="0" name="content">');
  end else begin
    WriteDirectLine('<frame src="AllUnits.html" frameborder="0" name="content">');
  end;
  WriteDirectLine('</frameset></html>');
  CloseStream;

  CreateStream('navigation.html', True);
  WriteDirectLine(DoctypeNormal);
  WriteDirectLine('<html><head>');
  WriteDirect('<link rel="StyleSheet" type="text/css" href="');
  WriteDirect(EscapeURL('pasdoc.css'));
  WriteDirectLine('">');
  WriteDirect(MetaContentType);
  WriteDirectLine('<title>Navigation</title>');
  if UseTipueSearch then
    WriteDirect(TipueSearchButtonHead);
  WriteDirectLine('</head>');
  WriteDirectLine('<body class="navigationframe">');
  WriteDirect('<h2>'+Title+'</h2>');

  WriteStartOfTable('navigation');

  if Introduction <> nil then begin
    if Introduction.ShortTitle = '' then begin
      LocalWriteLink(Introduction.OutputFileName, trIntroduction);
    end else begin
      LocalWriteLink(Introduction.OutputFileName, Introduction.ShortTitle)
    end;
  end;

  for Overview := LowCreatedOverviewFile to HighCreatedOverviewFile do
    LocalWriteLink(
      OverviewFilesInfo[Overview].BaseFileName + GetFileExtension,
      OverviewFilesInfo[Overview].TranslationId);

  if LinkGraphVizUses <> '' then
    LocalWriteLink(
      OverviewFilesInfo[ofGraphVizUses].BaseFileName + '.' + LinkGraphVizUses,
      OverviewFilesInfo[ofGraphVizUses].TranslationId);

  if LinkGraphVizClasses <> '' then
    LocalWriteLink(
      OverviewFilesInfo[ofGraphVizClasses].BaseFileName + '.' + LinkGraphVizClasses,
      OverviewFilesInfo[ofGraphVizClasses].TranslationId);

  if Conclusion <> nil then begin
    if Conclusion.ShortTitle = '' then begin
      LocalWriteLink(Conclusion.OutputFileName, trConclusion);
    end else begin
      LocalWriteLink(Conclusion.OutputFileName, Conclusion.ShortTitle)
    end;
  end;

  if UseTipueSearch then
    WriteDirect('<tr><td>' + Format(TipueSearchButton, [ConvertString(Language.Translation[trSearch])]) + '</td></tr>');

  WriteDirectLine('</table>');
  WriteDirectLine('</body></html>');
  CloseStream;
end;

function TGenericHTMLDocGenerator.ConvertString(const S: String): String;
const
  ReplacementArray: array[0..5] of TCharReplacement = (
    (cChar: '<'; sSpec: '&lt;'),
    (cChar: '>'; sSpec: '&gt;'),
    (cChar: '&'; sSpec: '&amp;'),
    (cChar: '"'; sSpec: '&quot;'),
    (cChar: '^'; sSpec: '&circ;'),
    (cChar: '~'; sSpec: '&tilde;')
  );
begin
  Result := StringReplaceChars(S, ReplacementArray);
end;

function TGenericHTMLDocGenerator.ConvertChar(c: char): String;
begin
  ConvertChar := ConvertString(c);
end;

function TGenericHTMLDocGenerator.EscapeURL(const AString: string): string;
var
  i: Integer;
begin
  Result := '';
  for i := 1 to Length(AString) do
  begin
    { Kambi: It's obvious that we must escape '&'.
      I don't know why, but escaping it using '%26' does not work
      (tested with Mozilla 1.7.7, Firefox 1.0.3, Konqueror 3.3.2, 
      and finally even IE, so it's certainly not a bug of some browser).
      But escaping it using '&amp;' works OK.
      
      On the other hand, escaping '~' using '&tilde;' does not work.
      (So EscapeURL function still *must* be something different than 
      ConvertString.) }
      
    if AString[i] = '&' then
      Result := Result + '&amp;'
    else if AString[i] in [Chr($21)..Chr($7E)] then
      Result := Result + AString[i]
    else
      Result := Result + '%' + IntToHex(Ord(AString[i]), 2);
  end;
end;

function TGenericHTMLDocGenerator.FormatPascalCode(const Line: string): string;
begin
  { Why these </p> and <p> are needed ?
    Well, basic idea is that pasdoc should always try to make closing
    and opening tags explicit, even though they can be omitted for paragraphs
    in html. And paragraph must end before <pre> and if there is any text after
    </pre> then a new paragraph must be opened.

    Besides the feeling of being "clean", specifying explicit paragraph
    endings is also important because IE sometimes reacts stupidly
    when paragraph is not explicitly closed, see
    [http://sourceforge.net/mailarchive/message.php?msg_id=11388479].
    In order to fix it, WriteItemLongDescription always wraps
    what it writes between <p> ... </p>

    This works perfectly except for the cases where @longcode
    is at the end of description, then we have
      <p>Some text <pre>Some Pascal code</pre></p>
    Because there is no text between "</pre>" and "</p>" this means
    that paragraph is not implicitly opened there. This, in turn,
    means that html validator complains that we have </p> without
    opening a paragraph.

    So the clean solution must be to mark explicitly that paragraph
    always ends before <pre> and always begins after </pre>. }

  result := '</p>' + LineEnding + LineEnding +
    '<pre class="longcode">' +
       inherited FormatPascalCode(Line) + '</pre>' +
     LineEnding + LineEnding + '<p>';
end;

function TGenericHTMLDocGenerator.Paragraph: string;
begin
  { LineEndings are inserted here only to make HTML sources look
    more readable (this makes life easier when looking for pasdoc's bugs,
    comparing generating two tests results etc.).
    They are of course meaningless for anything that interprets this HTML. }
  Result := LineEnding + LineEnding + '<p>';
end;

function TGenericHTMLDocGenerator.EnDash: string;
begin
  Result := '&ndash;';
end;

function TGenericHTMLDocGenerator.EmDash: string; 
begin
  Result := '&mdash;';
end;

function TGenericHTMLDocGenerator.LineBreak: string; 
begin
  Result := '<br>';
end;

function TGenericHTMLDocGenerator.URLLink(const URL: string): string;
begin
  Result := MakeTargettedLink(URL, ConvertString(URL), '', '_parent');
end;

function TGenericHTMLDocGenerator.FormatSection(HL: integer;
  const Anchor, Caption: string): string;
begin
  { We use `HL + 1' because user is allowed to use levels
    >= 1, and heading level 1 is reserved for section title. }
  result := FormatHeading(HL + 1, '', Caption, Anchor);
end;

function TGenericHTMLDocGenerator.FormatAnchor(
  const Anchor: string): string;
begin
  result := FormatAnAnchor(Anchor, '');
end;

function TGenericHTMLDocGenerator.FormatBold(const Text: string): string;
begin
  Result := '<b>' + Text + '</b>';
end;

function TGenericHTMLDocGenerator.FormatItalic(const Text: string): string;
begin
  Result := '<i>' + Text + '</i>';
end;

function TGenericHTMLDocGenerator.FormatPreformatted(
  const Text: string): string;
begin
  { See TGenericHTMLDocGenerator.FormatPascalCode
    for comments why these </p> and <p> are needed here.
    LineEndings are added only to make html source more readable. }
  Result := '</p>' + LineEnding + LineEnding +
    '<pre class="preformatted">' +
       inherited FormatPreformatted(Text) + '</pre>' +
     LineEnding + LineEnding + '<p>';
end;

function TGenericHTMLDocGenerator.FormatImage(FileNames: TStringList): string;
var
  ChosenFileName, OutputImageFileName: string;
  ImageId, I: Integer;
  CopyNeeded: boolean;
  ext: string;
begin
  { Calculate ChosenFileName, i.e. choose right image format for html.
    Anything other than eps or pdf is good. }
  ChosenFileName := '';
  for I := 0 to FileNames.Count - 1 do begin
    ext := LowerCase(ExtractFileExt(FileNames[I]));
    if (ext <> '.eps') and (ext <> '.pdf') then begin
      ChosenFileName := FileNames[I];
      Break;
    end;
  end;
  if ChosenFileName = '' then
    ChosenFileName := FileNames[0];

  { Calculate ImageId and CopyNeeded }
  ImageId := FImages.IndexOf(ChosenFileName);
  CopyNeeded := ImageId = -1;
  if CopyNeeded then
    ImageId := FImages.Add(ChosenFileName);

  OutputImageFileName :=
    'image_' + IntToStr(ImageId) + ExtractFileExt(ChosenFileName);

  if CopyNeeded then
    CopyFile(ChosenFileName, DestinationDirectory + OutputImageFileName);

  Result := Format('<img src="%s" alt="%s" />',
    [ OutputImageFileName,
      { Just use basename of chosen filename, that's the best
        alt text for the image as we can get... }
      DeleteFileExt(ExtractFileName(ChosenFileName))]);
end;

function TGenericHTMLDocGenerator.FormatList(ListData: TListData): string;
const
  ListTag: array[TListType]of string =
  ( 'ul', 'ol', 'dl' );
  ListClass: array[TListItemSpacing]of string =
  ( 'compact_spacing', 'paragraph_spacing' );
var
  i: Integer;
  ListItem: TListItemData;
  Attributes: string;
begin
  { We're explicitly marking end of previous paragraph and beginning
    of next one. This is required to always validate clearly.
    This also makes empty lists (no items) be handled correctly,
    i.e. they should produce paragraph break. }
  Result := '</p>' + LineEnding + LineEnding;
  
  { HTML requires that <ol> / <ul> contains at least one <li>. }
  if ListData.Count <> 0 then begin
    Result := Result + Format('<%s class="%s">',
      [ListTag[ListData.ListType], ListClass[ListData.ItemSpacing]]) + LineEnding;

    for i := 0 to ListData.Count - 1 do begin
      ListItem := ListData.Items[i] as TListItemData;

      if ListData.ListType = ltDefinition then begin
        { Note: We're not writing <p> .. </p> inside <dt>, because
          officially <dt> can't contain any paragraphs.

          Yes, this means that if user will use paragraphs inside
          @itemLabel then our output HTML will not be validated
          as correct HTML. I don't see any easy way to fix this?
          After all we don't want to "fake" <dl>, <dt> and <dd>
          using some other tags and complex css.

          So I guess that this should be blamed as an "unavoidable
          limitation of HTML output", if someone will ask :)

          -- Michalis }

        Result := Result +
          '  <dt>' + ListItem.ItemLabel + '</dt>' + LineEnding +
          '  <dd><p>' + ListItem.Text + '</p></dd>' + LineEnding;
      end else begin
        if ListData.ListType = ltOrdered then
          Attributes := Format(' value="%d"', [ListItem.Index])
        else
          Attributes := '';

        Result := Result + Format('  <li%s><p>%s</p></li>',
          [Attributes, ListItem.Text])  + LineEnding;
      end;
    end;

    Result := Result + Format('</%s>', [ListTag[ListData.ListType]]) +
      LineEnding + LineEnding;
  end;

  Result := Result + '<p>';
end;

function TGenericHTMLDocGenerator.FormatTable(Table: TTableData): string;

(*
  TODO: about html validity and enclosing cell content within <p>:

  We could enclose cell content (inside <td> and <th>) within <p></p>, 
  to be validatable, but this introduces the ugly effect of 
  adding additional margins between text and cell borders.
  
  We could get rid of this margin by using CSS below:
    table.table_tag p { margin-top: 0em; margin-bottom: 0em; }
  but this also makes gap between paragraphs within
  cells too small.
  
  So for now, we're not HTML valid.
*)

const
  CellTag: array[boolean]of string = ('td', 'th');
var
  RowNum, ColNum: Integer;
  Row: TRowData;
  NormalRowOdd: boolean;
  RowClass: string;
begin
  Result := '</p>' + LineEnding + LineEnding + 
    '<table class="table_tag">' + LineEnding;
  NormalRowOdd := true;
  for RowNum := 0 to Table.Count - 1 do
  begin
    Row := Table.Items[RowNum] as TRowData;
    
    if Row.Head then
      RowClass := 'head' else
    begin
      if NormalRowOdd then
        RowClass := 'odd' else
        RowClass := 'even';
      NormalRowOdd := not NormalRowOdd;
    end;
    
    Result := Result + '  <tr class="' + RowClass + '">' + LineEnding;
    
    for ColNum := 0 to Row.Cells.Count - 1 do
      Result := Result + Format('    <%s>%s</%0:s>%2:s',
        [CellTag[Row.Head], Row.Cells[ColNum], LineEnding]);
    
    Result := Result + '  </tr>' + LineEnding;
  end;
  Result := Result + '</table>' + LineEnding + LineEnding + '<p>';
end;

function TGenericHTMLDocGenerator.FormatTableOfContents(
  Sections: TDescriptionItem): string;
var
  i: Integer;
  item: TDescriptionItem;
begin
  if Sections.Count = 0 then begin
    Result := '';
    Exit;
  end;

  Result := '<ol>' + LineEnding;
  for i := 0 to Sections.Count - 1 do begin
    item := Sections.Items[i];
    Result := Result +
      '<li><a href="#' + item.Name + '">' + item.Value + '</a>' +
      LineEnding +
      FormatTableOfContents(item) + '</li>' +
      LineEnding;
  end;
  Result := Result + '</ol>' + LineEnding;
end;

{$IFDEF old}
{ THTMLDocGenerator }

function THTMLDocGenerator.CreateLink(const Item: TBaseItem): string;
var
  PasItem: TPasItem absolute Item;
  PasScope: TPasScope absolute Item;
  Extern: TExternalItem absolute item;
  Anchor: TAnchorItem absolute item;
const
  AnchorSeparator = '.'; //is '.' allowed in anchor names?
begin
(* Called from BuildLinks.
  Assign file names to the item itself?
*)
  Result := '';

  if (not Assigned(Item)) then Exit;

  if item is TPasUnit then begin
    Result := NewLink(Item.Name);
    PasScope.OutputFileName := Result;
  end else if Item is TPasCio then begin
  //read: Item has it's own doc file: unit.class.html
    Result := PasItem.MyOwner.OutputFileName;
    Result := ChangeFileExt(Result, '.' + Item.Name + GetFileExtension);
    PasScope.OutputFileName := Result;
  end else if Item is TPasItem then begin
  //the owner already has an valid file name.
  //nested members can NOT have anchors (unit.html#owner#item)
    Result := PasItem.MyOwner.FullLink;
    if Pos('#', Result) > 0 then
    //nested items shall have qualified link names
      Result := Result + AnchorSeparator + Item.Name
    else //create top level (unqualified) anchor
      Result := Result + '#' + Item.Name;
  end else if Item is TAnchorItem then begin
    Result := Anchor.ExternalItem.OutputFileName + '#' + Item.Name;
  end else if item is TExternalItem then begin
  //create file name
    Result := NewLink(Item.Name);
    Extern.OutputFileName := Result;
  end else begin
    DoError('Unhandled link item: %s.%s', [item.ClassName, item.Name], 3);
  end;
end;

procedure THTMLDocGenerator.WriteCIO(HL: integer; const CIO: TPasCio);
type
  TSections = (dsDescription, dsHierarchy, dsFields, dsMethods, dsProperties);
  TSectionSet = set of TSections;
  TSectionAnchors = array[TSections] of string;
const
  SectionAnchors: TSectionAnchors = (
    '%40Description',
    '%40Hierarchy',
    '%40Fields',
    '%40Methods',
    '%40Properties');

  procedure WriteMethodsSummary;
  begin
    WriteItemsSummary(CIO.Methods, CIO.ShowVisibility, HL + 1,
      SectionAnchors[dsMethods], trMethods);
  end;

  procedure WriteMethodsDetailed;
  begin
    WriteItemsDetailed(CIO.Methods, CIO.ShowVisibility, HL + 1, trMethods);
  end;

  procedure WritePropertiesSummary;
  begin
    WriteItemsSummary(CIO.Properties, CIO.ShowVisibility, HL + 1,
      SectionAnchors[dsProperties], trProperties);
  end;

  procedure WritePropertiesDetailed;
  begin
    WriteItemsDetailed(CIO.Properties, CIO.ShowVisibility, HL + 1, trProperties);
  end;

  procedure WriteFieldsSummary;
  begin
    WriteItemsSummary(CIO.Fields, CIO.ShowVisibility, HL + 1,
      SectionAnchors[dsFields], trFields);
  end;

  procedure WriteFieldsDetailed;
  begin
    WriteItemsDetailed(CIO.Fields, CIO.ShowVisibility, HL + 1, trFields);
  end;

  { writes all ancestors of the given item and the item itself }
  procedure WriteHierarchy(Name: string; Item: TBaseItem);
  var
    CIO: TPasCio;
  begin
    if not Assigned(Item) then begin
      WriteDirectLine('<li class="ancestor">' + Name + '</li>');
      { recursion ends here, when the item is an external class }
    end else if Item is TPasCio then begin
      CIO := TPasCio(Item);
      { first, write the ancestors }
      WriteHierarchy(CIO.FirstAncestorName, CIO.FirstAncestor);
      { then write itself }
      WriteDirectLine('<li class="ancestor">' +
        MakeItemLink(CIO, CIO.Name, lcNormal) + '</li>')
    end;
    { Is it possible that the item is assigned but is not a TPasCio ?
      Answer: type A = B; will result in an ordinary type A, even if B is a CIO.
      Type inheritance should be handled in the parser.
    }
  end;

var
  s: string;
  SectionsAvailable: TSectionSet;
  SectionHeads: array[TSections] of string;
  Section: TSections;
  AnyItem: boolean;
  //ancestor: TDescriptionItem;
begin //WriteCIO
  if not Assigned(CIO) then Exit;

  SectionHeads[dsDescription] := Language.Translation[trDescription];
  SectionHeads[dsHierarchy] := Language.Translation[trHierarchy];
  SectionHeads[dsFields ]:= Language.Translation[trFields];
  SectionHeads[dsMethods ]:= Language.Translation[trMethods];
  SectionHeads[dsProperties ]:= Language.Translation[trProperties];

  SectionsAvailable := [dsDescription];
  if Assigned(CIO.Ancestors) and (CIO.Ancestors.Count > 0) then
    Include(SectionsAvailable, dsHierarchy);
  if not ObjectVectorIsNilOrEmpty(CIO.Fields) then
    Include(SectionsAvailable, dsFields);
  if not ObjectVectorIsNilOrEmpty(CIO.Methods) then
    Include(SectionsAvailable, dsMethods);
  if not ObjectVectorIsNilOrEmpty(CIO.Properties) then
    Include(SectionsAvailable, dsProperties);

{$IFDEF old}
  s := GetCIOTypeName(CIO.MyType) + ' ' + CIO.Name;
{$ELSE}
  s := CIO.ShortDeclaration;
{$ENDIF}

  WriteStartOfDocument(CIO.MyUnit.Name + ': ' + s);

  WriteAnchor(CIO.Name);
  WriteHeading(HL, 'cio', s);

  WriteStartOfTable('sections');
  WriteDirectLine('<tr>');
  for Section := Low(TSections) to High(TSections) do
    begin
      WriteDirect('<td>');
      if Section in SectionsAvailable then
        WriteLink('#'+SectionAnchors[Section], SectionHeads[Section], 'section')
      else
        WriteConverted(SectionHeads[Section]);
      WriteDirect('</td>');
    end;
  WriteDirectLine('</tr></table>');

  WriteAnchor(SectionAnchors[dsDescription]);

  { write unit link }
  if True then begin
    WriteHeading(HL + 1, 'unit', Language.Translation[trUnit]);
    WriteStartOfParagraph('unitlink');
    WriteLink(CIO.MyUnit.FullLink, ConvertString(CIO.MyUnit.Name), '');
    WriteEndOfParagraph;
  end;

  { write declaration link }
  WriteHeading(HL + 1, 'declaration', Language.Translation[trDeclaration]);
  WriteStartOfParagraph('declaration');
  WriteStartOfCode;
  WriteConverted(CIO.FullDeclaration);
  WriteEndOfCode;
  WriteEndOfParagraph;

  { Write Description }
  WriteHeading(HL + 1, 'description', Language.Translation[trDescription]);
  WriteItemLongDescription(CIO);

  { Write Hierarchy }
  if not IsEmpty(CIO.Ancestors) then begin
    WriteAnchor(SectionAnchors[dsHierarchy]);
    WriteHeading(HL + 1, 'hierarchy', SectionHeads[dsHierarchy]);
    WriteDirect('<ul class="hierarchy">');
    WriteHierarchy(CIO.FirstAncestorName, CIO.FirstAncestor);
    WriteDirect('<li class="thisitem">' + CIO.Name + '</li>');
    WriteDirect('</ul>');
  end;

  AnyItem :=
    (not IsEmpty(CIO.Fields)) or
    (not IsEmpty(CIO.Methods)) or
    (not IsEmpty(CIO.Properties));

  { AnyItem is used here to avoid writing headers "Overview"
    and "Description" when there are no items. }
  if AnyItem then
  begin
    WriteHeading(HL + 1, 'overview', Language.Translation[trOverview]);
    WriteFieldsSummary;
    WriteMethodsSummary;
    WritePropertiesSummary;

    WriteHeading(HL + 1, 'description', Language.Translation[trDescription]);
    WriteFieldsDetailed;
    WriteMethodsDetailed;
    WritePropertiesDetailed;
  end;

  WriteAuthors(HL + 1, CIO.Authors);
  WriteDates(HL + 1, CIO.Created, CIO.LastMod);
  WriteFooter;
  WriteAppInfo;
  WriteEndOfDocument;
end;

procedure THTMLDocGenerator.WriteCIOs(HL: integer; c: TPasItems);
var
  i: Integer;
  p: TPasCio;
begin
  if c = nil then Exit;

  for i := 0 to c.Count - 1 do
  begin
    p := TPasCio(c.PasItemAt[i]);

    if (p.MyUnit <> nil) and
       p.MyUnit.FileNewerThanCache(DestinationDirectory + p.OutputFileName) then
    begin
      DoMessage(3, pmtInformation, 'Data for "%s" was loaded from cache, '+
        'and output file of this item exists and is newer than cache, '+
        'skipped.', [p.Name]);
      Continue;
    end;

    case CreateStream(p.OutputFileName, true) of
      csError: begin
          DoMessage(1, pmtError, 'Could not create Class/Interface/Object documentation file.', []);
          Continue;
        end;
      csCreated: begin
          DoMessage(3, pmtInformation, 'Creating Class/Interface/Object file for "%s"...', [p.Name]);
          WriteCIO(HL, p);
        end;
    end;
  end;
  CloseStream;
end;

{ ---------------------------------------------------------------------------- }

procedure THTMLDocGenerator.WriteCIOSummary(HL: integer; c: TPasItems);
var
  j: Integer;
  p: TPasCio;
begin
  if ObjectVectorIsNilOrEmpty(c) then Exit;

  WriteAnchor('%40Classes');

  WriteHeading(HL, 'cio', Language.Translation[trCio]);
  WriteStartOfTable2Columns('classestable', Language.Translation[trName], Language.Translation[trDescription]);
  for j := 0 to c.Count - 1 do begin
    p := TPasCio(c.PasItemAt[j]);
    WriteStartOfTableRow('');
    { name of class/interface/object and unit }
    WriteStartOfTableCell('itemname');
  {$IFDEF old}
    WriteConverted(GetCIOTypeName(p.MyType));
    WriteDirect('&nbsp;');
    WriteLink(p.FullLink, CodeString(p.Name), 'bold');
  {$ELSE}
    //WriteConverted(p.ShortDeclaration);
    WriteLink(p.FullLink, p.ShortDeclaration, 'bold');
  {$ENDIF}
    WriteEndOfTableCell;

    { Description of class/interface/object }
    WriteStartOfTableCell('itemdesc');
    WriteItemShortDescription(p);

    WriteEndOfTableCell;
    WriteEndOfTableRow;
  end;
  WriteEndOfTable;
end;

{ ---------------------------------------------------------------------------- }

procedure THTMLDocGenerator.WriteDates(const HL: integer;
  Created, LastMod: TDescriptionItem);
begin
  if assigned(Created) and (Created.Name <> '') then begin
    WriteHeading(HL, 'created', Language.Translation[trCreated]);
    WriteStartOfParagraph;
    WriteDirectLine(Created.Name);
    WriteEndOfParagraph;
  end;
  if assigned(LastMod) and (LastMod.Name <> '') then begin
    WriteHeading(HL, 'modified', Language.Translation[trLastModified]);
    WriteStartOfParagraph;
    WriteDirectLine(LastMod.Name);
    WriteEndOfParagraph;
  end;
end;

{ ---------------------------------------------------------------------------- }

procedure THTMLDocGenerator.WriteDocumentation;
begin
  StartSpellChecking('sgml');
  inherited WriteDocumentation;
  WriteUnits(1);
  WriteBinaryFiles;
  WriteOverviewFiles;
  WriteVisibilityLegendFile;
  WriteIntroduction;
  WriteConclusion;
  WriteFramesetFiles;
  if UseTipueSearch then begin
    DoMessage(2, pmtInformation,
      'Writing additional files for tipue search engine', []);
    TipueAddFiles(Units, Introduction, Conclusion, MetaContentType,
      DestinationDirectory);
  end;
  EndSpellChecking;
end;

procedure THTMLDocGenerator.WriteItemsDetailed(
  Items: TPasItems; ShowVisibility: boolean;
  HeadingLevel: Integer; SectionName: TTranslationId);
var
  Item: TPasItem;
  i: Integer;
  ColumnsCount: Cardinal;
begin
  if IsEmpty(Items) then Exit;

  WriteHeading(HeadingLevel + 1, 'detail', Language.Translation[SectionName]);

  for i := 0 to Items.Count - 1 do begin
    Item := Items.PasItemAt[i];

    { calculate ColumnsCount }
    ColumnsCount := 1;
    if ShowVisibility then Inc(ColumnsCount);

    WriteStartOfTable('detail');
    WriteItemTableRow(Item, ShowVisibility, false, true);

    { Using colspan="0" below would be easier, but Konqueror and IE
      can't handle it correctly. It seems that they treat it as colspan="1" ? }
    WriteDirectLine(Format('<tr><td colspan="%d">', [ColumnsCount]));
    WriteItemLongDescription(Item);
    WriteDirectLine('</td></tr>');

    WriteEndOfTable;
  end;
end;

procedure THTMLDocGenerator.WriteItemShortDescription(const AItem: TPasItem);
begin
  if AItem = nil then Exit;
  WriteSpellChecked(AItem.ShortDescription);
end;

procedure THTMLDocGenerator.WriteItemLongDescription(
  const AItem: TPasItem; OpenCloseParagraph: boolean);

  procedure WriteDescriptionSectionHeading(const Caption: TTranslationID);
  begin
    WriteHeading(6, 'description_section', Language.Translation[Caption]);
  end;

  { writes the parameters or exceptions list }
  procedure WriteParamsOrRaises(Func: TPasMethod; const Caption: TTranslationID;
    List: TDescriptionItem; LinkToParamNames: boolean;
    const CssListClass: string);

    procedure WriteParameter(const ParamName: string; const Desc: string);
    begin
      { Note that <dt> and <dd> below don't need any CSS class,
        they can be accessed via "dl.parameters dt" or "dl.parameters dd"
        (assuming that CssListClass = 'parameters'). }
      WriteDirect('<dt>');
      WriteDirect(ParamName);
      WriteDirectLine('</dt>');
      WriteDirect('<dd>');
      WriteSpellChecked(Desc);
      WriteDirectLine('</dd>');
    end;

  var
    i: integer;
    ParamName: string;
  begin
    if IsEmpty(List) then
      Exit;

    WriteDescriptionSectionHeading(Caption);
    WriteDirectLine('<dl class="' + CssListClass + '">');
    for i := 0 to List.Count - 1 do
    begin
      ParamName := List.Items[i].Name;

      if LinkToParamNames then
       ParamName := SearchLink(ParamName, Func, '', true);

      WriteParameter(ParamName, List.Items[i].Value);
    end;
    WriteDirectLine('</dl>');
  end;

  procedure WriteSeeAlso(SeeAlso: TDescriptionItem);
  var
    i: integer;
    SeeAlsoItem: TBaseItem;
    SeeAlsoLink: string;
  begin
    if IsEmpty(SeeAlso) then
      Exit;

    WriteDescriptionSectionHeading(trSeeAlso);
    WriteDirectLine('<dl class="see_also">');
    for i := 0 to SeeAlso.Count - 1 do
    begin
      SeeAlsoLink := SearchLink(SeeAlso.Items[i].Name, AItem,
        SeeAlso.Items[i].Value, true, SeeAlsoItem);
      WriteDirect('  <dt>');
      if SeeAlsoItem <> nil then
        WriteDirect(SeeAlsoLink) else
        WriteConverted(SeeAlso.Items[i].Name);
      WriteDirectLine('</dt>');

      WriteDirect('  <dd>');
      if (SeeAlsoItem <> nil) and (SeeAlsoItem is TPasItem) then
      {$IFDEF old}
      //direct write???
        WriteDirect(TPasItem(SeeAlsoItem).AbstractDescription);
      {$ELSE}
        //WriteConverted(TPasItem(SeeAlsoItem).AbstractDescription, False);
        WriteConverted(TPasItem(SeeAlsoItem).ShortDescription, False);
      {$ENDIF}
      WriteDirectLine('</dd>');
    end;
    WriteDirectLine('</dl>');
  end;

  procedure WriteReturnDesc(Func: TPasMethod; ReturnDesc: TDescriptionItem);
  begin
    if (ReturnDesc = nil) or (ReturnDesc.Text = '') then
      exit;
    WriteDescriptionSectionHeading(trReturns);
    WriteDirect('<p class="return">');
    WriteSpellChecked(ReturnDesc.Text);
    WriteDirect('</p>');
  end;

  procedure WriteHintDirective(const S: string);
  begin
    WriteDirect('<p class="hint_directive">');
    WriteConverted(Language.Translation[trWarning] + ': ' + S + '.');
    WriteDirect('</p>');
  end;

var
  Ancestor: TBaseItem;
  AItemMethod: TPasMethod;
  i: Integer;
begin //WriteItemLongDescription
  if not Assigned(AItem) then Exit;

  //if AItem.IsDeprecated then
  if AItem.HasAttribute[SD_DEPRECATED] then
    WriteHintDirective(Language.Translation[trDeprecated]);
  //if AItem.IsPlatformSpecific then
  if AItem.HasAttribute[SD_PLATFORM] then
    WriteHintDirective(Language.Translation[trPlatformSpecific]);
  //if AItem.IsLibrarySpecific then
  if AItem.HasAttribute[SD_LIBRARY_] then
    WriteHintDirective(Language.Translation[trLibrarySpecific]);

(* Write Abstract and Description, if not empty.
  If neither exists, give inherited description (CIOs only)
  The same for overloaded methods???
  Every description item should be inheritable!
*)
{$IFDEF old}
  if AItem.AbstractDescription <> '' then begin
    if OpenCloseParagraph then WriteStartOfParagraph;

    WriteSpellChecked(AItem.AbstractDescription);

    if AItem.DetailedDescription <> '' then begin
      if not AItem.AbstractDescriptionWasAutomatic then begin
        WriteEndOfParagraph; { always try to write closing </p>, to be clean }
        WriteStartOfParagraph;
      end;
      WriteSpellChecked(AItem.DetailedDescription);
    end;

    if OpenCloseParagraph then WriteEndOfParagraph;
  end else if AItem.DetailedDescription <> '' then begin
    if OpenCloseParagraph then WriteStartOfParagraph;

    WriteSpellChecked(AItem.DetailedDescription);

    if OpenCloseParagraph then WriteEndOfParagraph;

  end else if (AItem is TPasCio) and not IsEmpty(TPasCio(AItem).Ancestors) then begin
    Ancestor := TPasCio(AItem).FirstAncestor;
    if Assigned(Ancestor) then begin
      //AncestorName := TPasCio(AItem).FirstAncestorName;
      //AncestorName := Ancestor.Name;
      WriteDirect('<div class="nodescription">');
      WriteConverted(Format(
        'no description available, %s description follows', [Ancestor.Name]));
      WriteDirect('</div>');
      WriteItemLongDescription(TPasItem(Ancestor));
    end;
{$ELSE}
//search for non-empty description
  Ancestor := AItem;
  while assigned(Ancestor)
  and (Ancestor.AbstractDescription = '') and (Ancestor.DetailedDescription = '') do begin
    if Ancestor is TPasCio then
      Ancestor := TPasCio(Ancestor).FirstAncestor
    else
      Ancestor := nil;
  end;

  if (Ancestor <> nil) then begin
    if AItem <> Ancestor then begin
      WriteDirect('<div class="nodescription">');
      WriteConverted(Format(
        'no description available, %s description follows', [Ancestor.Name]));
      WriteDirect('</div>');
    end;

    if Ancestor.AbstractDescription <> '' then begin
      if OpenCloseParagraph then WriteStartOfParagraph;
      WriteSpellChecked(Ancestor.AbstractDescription);
      if OpenCloseParagraph then WriteEndOfParagraph;
    end;

    if Ancestor.DetailedDescription <> '' then begin
      if OpenCloseParagraph then WriteStartOfParagraph;
      WriteSpellChecked(Ancestor.DetailedDescription);
      if OpenCloseParagraph then WriteEndOfParagraph;
    end;
  end else begin
    //WriteDirect('&nbsp;'); //oops?
  end;
{$ENDIF}

  if AItem is TPasMethod then begin
    AItemMethod := TPasMethod(AItem);
    WriteParamsOrRaises(AItemMethod, trParameters,
      AItemMethod.Params, false, 'parameters');
    WriteReturnDesc(AItemMethod, AItemMethod.Returns);
    WriteParamsOrRaises(AItemMethod, trExceptionsRaised,
      AItemMethod.Raises, true, 'exceptions_raised');
  end;

  WriteSeeAlso(AItem.SeeAlso);

  if AItem is TPasEnum then begin
    WriteDescriptionSectionHeading(trValues);
    WriteDirectLine('<ul>');
    for i := 0 to TPasEnum(AItem).Members.Count - 1 do begin
      WriteDirectLine('<li>');
      WriteConverted(TPasEnum(AItem).Members.PasItemAt[i].FullDeclaration);
      WriteConverted(': ');
      WriteItemLongDescription(TPasEnum(AItem).Members.PasItemAt[i], false);
      WriteDirectLine('</li>');
    end;
    WriteDirectLine('</ul>');
  end;
end;

{ ---------- }

procedure THTMLDocGenerator.WriteOverviewFiles;

  function CreateOverviewStream(Overview: TCreatedOverviewFile): boolean;
  var
    BaseFileName, Headline: string;
  begin
    BaseFileName := OverviewFilesInfo[Overview].BaseFileName;
    Result := CreateStream(BaseFileName + GetFileExtension, True) <> csError;

    if not Result then
    begin
      DoMessage(1, pmtError, 'Error: Could not create output file "' +
        BaseFileName + '".', []);
      Exit;
    end;

    DoMessage(3, pmtInformation, 'Writing overview file "' +
      BaseFileName + '" ...', []);

    Headline := Language.Translation[
      OverviewFilesInfo[Overview].TranslationHeadlineId];
    WriteStartOfDocument(Headline);
    WriteHeading(1, 'allitems', Headline);
  end;

  { Creates an output stream that lists up all units and short descriptions. }
  procedure WriteUnitOverviewFile;
  var
    c: TPasItems;
    Item: TPasItem;
    j: Integer;
  begin
    c := Units;

    if not CreateOverviewStream(ofUnits) then
      Exit;

    if Assigned(c) and (c.Count > 0) then begin
      WriteStartOfTable2Columns('unitstable', Language.Translation[trName],
        Language.Translation[trDescription]);
      for j := 0 to c.Count - 1 do begin
        Item := c.PasItemAt[j];
        WriteStartOfTableRow('');
        WriteStartOfTableCell('itemname');
        WriteLink(Item.FullLink, Item.Name, 'bold');
        WriteEndOfTableCell;

        WriteStartOfTableCell('itemdesc');
        WriteItemShortDescription(Item);
        WriteEndOfTableCell;
        WriteEndOfTableRow;
      end;
      WriteEndOfTable;
    end;
    WriteFooter;
    WriteAppInfo;
    WriteEndOfDocument;
    CloseStream;
  end;

  { Writes a Hierarchy list - this is more useful than the simple class list }
  procedure WriteHierarchy;

    procedure WriteLevel(lst: TDescriptionItem);
    var
      i: integer;
      item: TDescriptionItem;
    begin
      if IsEmpty(lst) then
        exit;
      WriteDirectLine('<ul class="hierarchylevel">');
      for i := 0 to lst.Count - 1 do begin
        WriteDirect('<li>');
        item := lst.ItemAt(i);
        if Item.PasItem = nil then
          WriteConverted(item.Name)
        else
          WriteLink(Item.PasItem.FullLink, ConvertString(item.Name), 'bold');
        WriteLevel(item);
        WriteDirectLine('</li>');
      end;
      WriteDirectLine('</ul>');
    end;

  begin
    CreateClassHierarchy;

    if not CreateOverviewStream(ofClassHierarchy) then
      Exit;

    if IsEmpty(FClassHierarchy) then begin
      WriteStartOfParagraph;
      WriteConverted(Language.Translation[trNoCIOsForHierarchy]);
      WriteEndOfParagraph;
    end else begin
      WriteLevel(FClassHierarchy);
    end;

    WriteFooter;
    WriteAppInfo;
    WriteEndOfDocument;

    CloseStream;
  end;

  procedure WriteItemsOverviewFile(Overview: TCreatedOverviewFile;
    Items: TPasItems);
  var
    Item: TPasItem;
    j: Integer;
  begin
    if not CreateOverviewStream(Overview) then Exit;

    if not ObjectVectorIsNilOrEmpty(Items) then
    begin
      WriteStartOfTable3Columns('itemstable',
        Language.Translation[trName],
        Language.Translation[trUnit],
        Language.Translation[trDescription]);

      Items.SortShallow;

      for j := 0 to Items.Count - 1 do
      begin
        Item := Items.PasItemAt[j];
        WriteStartOfTableRow('');

        WriteStartOfTableCell('itemname');
        WriteLink(Item.FullLink, Item.Name, 'bold');
        WriteEndOfTableCell;

        WriteStartOfTableCell('itemunit');
        WriteLink(Item.MyUnit.FullLink, Item.MyUnit.Name, 'bold');
        WriteEndOfTableCell;

        WriteStartOfTableCell('itemdesc');
        WriteItemShortDescription(Item);
        WriteEndOfTableCell;

        WriteEndOfTableRow;
      end;
      WriteEndOfTable;
    end else
    begin
      WriteStartOfParagraph;
      WriteConverted(Language.Translation[
        OverviewFilesInfo[Overview].NoItemsTranslationId]);
      WriteEndOfParagraph;
    end;

    WriteFooter;
    WriteAppInfo;
    WriteEndOfDocument;
    CloseStream;
  end;

var
  ItemsToCopy: TPasItems;
  PartialItems: TPasItems;
  TotalItems: TPasItems; // Collect all Items for final listing.
  PU: TPasUnit;
  Overview: TCreatedOverviewFile;
  j: Integer;
begin //WriteOverviewFiles
  WriteUnitOverviewFile;
  WriteHierarchy;

  // Make sure we don't free the Items when we free the container.
  TotalItems := TPasItems.Create(False);
  try
    for Overview := ofCios to HighCreatedOverviewFile do begin
      // Make sure we don't free the Items when we free the container.
      PartialItems := TPasItems.Create(False);
      try
        for j := 0 to Units.Count - 1 do begin
          PU := Units.UnitAt[j];
          case Overview of
            ofCIos                  : ItemsToCopy := PU.CIOs;
            ofTypes                 : ItemsToCopy := PU.Types;
            ofVariables             : ItemsToCopy := PU.Variables;
            ofConstants             : ItemsToCopy := PU.Constants;
            ofFunctionsAndProcedures: ItemsToCopy := PU.FuncsProcs;
          else
            ItemsToCopy := nil;
          end;
          PartialItems.InsertItems(ItemsToCopy);
        end;

        WriteItemsOverviewFile(Overview, PartialItems);

        TotalItems.InsertItems(PartialItems);
      finally PartialItems.Free end;
    end;

    WriteItemsOverviewFile(ofIdentifiers, TotalItems);
  finally TotalItems.Free end;
end;

{ ---------------------------------------------------------------------------- }

procedure THTMLDocGenerator.WriteUnit(const HL: integer; const U: TPasUnit);
type
  TSections = (dsDescription, dsUses, dsClasses, dsFuncsProcs,
    dsTypes, dsConstants, dsVariables);
  TSectionSet = set of TSections;
  TSectionAnchors = array[TSections] of string;
const
  SectionAnchors: TSectionAnchors = (
    '%40Description',
    '%40Uses',
    '%40Classes',
    '%40FuncsProcs',
    '%40Types',
    '%40Constants',
    '%40Variables');

  procedure WriteUnitDescription(HL: integer; U: TPasUnit);
  begin
    WriteHeading(HL, 'description', Language.Translation[trDescription]);
    WriteItemLongDescription(U);
  end;

  procedure WriteUnitUses(const HL: integer; U: TPasUnit);
  var
    i: Integer;
    ULink: TPasItem;
  begin
    if WriteUsesClause and not IsEmpty(U.UsesUnits) then begin
      WriteHeading(HL, 'uses', Language.Translation[trUses]);
      WriteDirect('<ul class="useslist">');
      for i := 0 to U.UsesUnits.Count-1 do begin
        WriteDirect('<li>');
        ULink := u.UsesUnits.PasItemAt[i];
        if ULink <> nil then begin
          WriteLink(ULink.FullLink, U.UsesUnits.Items[i].Name, '');
        end else begin
          WriteConverted(U.UsesUnits.Items[i].Name);
        end;
        WriteDirect('</li>');
      end;
      WriteDirect('</ul>');
    end;
  end;

  procedure WriteFuncsProcsSummary;
  begin
    WriteItemsSummary(U.FuncsProcs, false, HL + 1, SectionAnchors[dsFuncsProcs],
      trFunctionsAndProcedures);
  end;

  procedure WriteFuncsProcsDetailed;
  begin
    WriteItemsDetailed(U.FuncsProcs, false, HL + 1,
      trFunctionsAndProcedures);
  end;

  procedure WriteTypesSummary;
  begin
    WriteItemsSummary(U.Types, false, HL + 1, SectionAnchors[dsTypes], trTypes);
  end;

  procedure WriteTypesDetailed;
  begin
    WriteItemsDetailed(U.Types, false, HL + 1, trTypes);
  end;

  procedure WriteConstantsSummary;
  begin
    WriteItemsSummary(U.Constants, false, HL + 1, SectionAnchors[dsConstants],
      trConstants);
  end;

  procedure WriteConstantsDetailed;
  begin
    WriteItemsDetailed(U.Constants, false, HL + 1, trConstants);
  end;

  procedure WriteVariablesSummary;
  begin
    WriteItemsSummary(U.Variables, false, HL + 1, SectionAnchors[dsVariables],
      trVariables);
  end;

  procedure WriteVariablesDetailed;
  begin
    WriteItemsDetailed(U.Variables, false, HL + 1, trVariables);
  end;

var
  SectionsAvailable: TSectionSet;
  SectionHeads: array[TSections] of string;
  Section: TSections;

  procedure ConditionallyAddSection(Section: TSections; Condition: boolean);
  begin
    if Condition then
      Include(SectionsAvailable, Section);
  end;

var
  AnyItemSummary, AnyItemDetailed: boolean;
begin
{$IFDEF old}
  if not Assigned(U) then begin
    DoMessage(1, pmtError, 'TGenericHTMLDocGenerator.WriteUnit: ' +
      'Unit variable has not been initialized.', []);
    Exit;
  end;

  if U.FileNewerThanCache(DestinationDirectory + U.OutputFileName) then
  begin
    DoMessage(3, pmtInformation, 'Data for unit "%s" was loaded from cache, '+
      'and output file of this unit exists and is newer than cache, '+
      'skipped.', [U.Name]);
    Exit;
  end;
{$ELSE}
  //already checked
{$ENDIF}

  if u.ToBeExcluded then
    exit; //skip excluded units

  case CreateStream(U.OutputFileName, true) of
    csError: begin
      DoMessage(1, pmtError, 'Could not create HTML unit doc file for unit %s.', [U.Name]);
      Exit;
    end;
  end;

  SectionHeads[dsDescription] := Language.Translation[trDescription];
  SectionHeads[dsUses] := Language.Translation[trUses];
  SectionHeads[dsClasses] := Language.Translation[trCio];
  SectionHeads[dsFuncsProcs]:= Language.Translation[trFunctionsAndProcedures];
  SectionHeads[dsTypes]:= Language.Translation[trTypes];
  SectionHeads[dsConstants]:= Language.Translation[trConstants];
  SectionHeads[dsVariables]:= Language.Translation[trVariables];

  SectionsAvailable := [dsDescription];
  ConditionallyAddSection(dsUses, WriteUsesClause and not IsEmpty(U.UsesUnits));
  ConditionallyAddSection(dsClasses, not IsEmpty(U.CIOs));
  ConditionallyAddSection(dsFuncsProcs, not IsEmpty(U.FuncsProcs));
  ConditionallyAddSection(dsTypes, not IsEmpty(U.Types));
  ConditionallyAddSection(dsConstants, not IsEmpty(U.Constants));
  ConditionallyAddSection(dsVariables, not IsEmpty(U.Variables));

  DoMessage(2, pmtInformation, 'Writing Docs for unit "%s"', [U.Name]);
  WriteStartOfDocument(U.Name);

  if U.IsUnit then
    WriteHeading(HL, 'unit', Language.Translation[trUnit] + ' ' + U.Name)
  else if U.IsProgram then
    WriteHeading(HL, 'program', Language.Translation[trProgram] + ' ' + U.Name)
  else
    WriteHeading(HL, 'library', Language.Translation[trLibrary] + ' ' + U.Name);

  WriteStartOfTable('sections');
  WriteDirectLine('<tr>');
  for Section := Low(TSections) to High(TSections) do
    begin
      WriteDirect('<td>');
      if Section in SectionsAvailable then
        WriteLink('#'+SectionAnchors[Section], SectionHeads[Section], 'section')
      else
        WriteConverted(SectionHeads[Section]);
      WriteDirect('</td>');
    end;
  WriteDirectLine('</tr></table>');

  WriteAnchor(SectionAnchors[dsDescription]);
  WriteUnitDescription(HL + 1, U);

  WriteAnchor(SectionAnchors[dsUses]);
  WriteUnitUses(HL + 1, U);

  AnyItemDetailed :=
    (not ObjectVectorIsNilOrEmpty(U.FuncsProcs)) or
    (not ObjectVectorIsNilOrEmpty(U.Types)) or
    (not ObjectVectorIsNilOrEmpty(U.Constants)) or
    (not ObjectVectorIsNilOrEmpty(U.Variables));

  AnyItemSummary := AnyItemDetailed or
    (not ObjectVectorIsNilOrEmpty(U.CIOs));

  { AnyItemSummary/Detailed are used here to avoid writing headers
    "Overview" and "Description" when there are no items. }
  if AnyItemSummary then
  begin
    WriteHeading(HL + 1, 'overview', Language.Translation[trOverview]);
    WriteCIOSummary(HL + 2, U.CIOs);
    WriteFuncsProcsSummary;
    WriteTypesSummary;
    WriteConstantsSummary;
    WriteVariablesSummary;
  end;

  if AnyItemDetailed then
  begin
    WriteHeading(HL + 1, 'description', Language.Translation[trDescription]);
    //CIOs reside in their own files!
    WriteFuncsProcsDetailed;
    WriteTypesDetailed;
    WriteConstantsDetailed;
    WriteVariablesDetailed;
  end;

  WriteAuthors(HL + 1, U.Authors);
  WriteDates(HL + 1, U.Created, U.LastMod);
  WriteFooter;
  WriteAppInfo;
  WriteEndOfDocument;
  CloseStream;
  WriteCIOs(HL, U.CIOs);
end;

procedure THTMLDocGenerator.WriteExternalCore(
  const ExternalItem: TExternalItem;
  const Id: TTranslationID);
var
  HL: integer;
begin
  case CreateStream(ExternalItem.OutputFileName, true) of
    csError: begin
      DoMessage(1, pmtError, 'Could not create HTML unit doc file '
        + 'for the %s file %s.', [Language.Translation[Id], ExternalItem.Name]);
      Exit;
    end;
  end;

  WriteStartOfDocument(ExternalItem.ShortTitle);

  HL := 1;

  WriteHeading(HL, 'externalitem', ExternalItem.Title);

  WriteSpellChecked(ExternalItem.DetailedDescription);

  WriteAuthors(HL + 1, ExternalItem.Authors);
  WriteDates(HL + 1, ExternalItem.Created, ExternalItem.LastMod);
  WriteFooter;
  WriteAppInfo;
  WriteEndOfDocument;
  CloseStream;
end;
{$ELSE}
  //use TFullHTMLgenerator
{$ENDIF}

end.
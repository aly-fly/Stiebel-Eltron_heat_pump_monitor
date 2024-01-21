unit Orodja;

interface
uses
  Windows, Forms, Graphics, pngimage, SysUtils, Dialogs, Classes, Vcl.ComCtrls, Winapi.Messages, Vcl.Clipbrd, Vcl.ExtCtrls,
{$IFDEF VER210} Chart;{$ENDIF}           // Delphi 2010
{$IFDEF VER260} VCLTee.Chart;{$ENDIF}    // Delphi XE5
{$IFDEF VER320} VCLTee.Chart;{$ENDIF}    // Delphi 10.2 Tokyo

(*
https://docwiki.embarcadero.com/RADStudio/Sydney/en/Compiler_Versions

VER340	Delphi 10.4 Sydney / C++Builder 10.4 Sydney	27	270	34.0
VER330	Delphi 10.3 Rio / C++Builder 10.3 Rio	26	260	33.0
VER320	Delphi 10.2 Tokyo / C++Builder 10.2 Tokyo	25	250	32.0
VER310	Delphi 10.1 Berlin / C++Builder 10.1 Berlin	24	240	31.0
VER300	Delphi 10 Seattle / C++Builder 10 Seattle	23	230	30.0
VER290	Delphi XE8 / C++Builder XE8	22	220	29.0
VER280	Delphi XE7 / C++Builder XE7	21	210	28.0
VER270	Delphi XE6 / C++Builder XE6	20	200	27.0
VER260	Delphi XE5 / C++Builder XE5	19	190	26.0
VER250	Delphi XE4 / C++Builder XE4	18	180	25.0
VER240	Delphi XE3 / C++Builder XE3	17	170	24.0
VER230	Delphi XE2 / C++Builder XE2	16	160161 is the version for the five FireMonkey packages at XE2 Update 2: fmi161.bpl, fmx161.bpl, fmxase161.bpl, fmxdae161.bpl, and fmxobj161.bpl.	23.0
VER220	Delphi XE / C++Builder XE	15	150	22.0
VER210	Delphi 2010 / C++Builder 2010	14	140	21.0
*)

type
  TLedBarva = (lOFF, lRdeca, lZelena);
  s8 = ShortInt;
  s16 = SmallInt;
  s32 = Integer;
  s64 = Int64;

  u8 = Byte;
  u16 = Word;
  u32 = LongWord; // Cardinal
  u64 = UInt64;

  TByteArr = array of byte;
  T2DRealPoint = record
    x,y:extended;
  end;
  TRealPointArray = array of T2DRealPoint;

const
  CR = #13;
  LF = #10;
  CRLF = #13#10;
  TAB = #9;
  clOrange   = $0000AAFF;
  clLightRed = $005B5BFF;
  clLightGreen = $00D7FFAE;
  clDarkYellow = clYellow - $003300;

  CPR_S01 =  187000;
  CPR_9B  =     512;
  CPR_14B =   16384;
  CPR_15B =   32768;
  CPR_16B =   65536;
  CPR_17B =  131072;
  CPR_18B =  262144;
  CPR_19B =  524288;
  CPR_20B = 1048576;
  CPR_21B = 2097152;
  CPR_22B = 4194304;
  CPR_100k = 100000;
  CPR_160k = 160000;
  CPR_200k = 200000;

{$IFDEF LOKALNO}
  PotShranjevanjaTestiranja_AksIM_Tester_def = 'D:\KOGEJ\RlsTesting\Rezultati\AksIM\';
  PotShranjevanjaTestiranja_AksIM_Ostali_def = 'D:\KOGEJ\RlsTesting\Proizvodnja\AksIM\CitalneGlave\';
{$ELSE}
  PotShranjevanjaTestiranja_AksIM_Tester_def = '\\rls\testing\Rezultati\AksIM\';
  PotShranjevanjaTestiranja_AksIM_Ostali_def = '\\rls\testing\Proizvodnja\AksIM\CitalneGlave\';
{$ENDIF}

  PotShranjevanjaTestiranja_Tester_def = '\\rls\testing\Rezultati\'; // + Product Line + '\'
  PotShranjevanjaTestiranja_Ostali_def = '\\rls\testing\Proizvodnja\';  // + Product Line + '\'

// -------------------------------------------------------------------------------------------------------------

  procedure Wait(ms : integer);
  procedure SaveFormScreenshotToPNGFile( AForm : TCustomForm; AFileName : string = '' );
  procedure SaveFormScreenshotWithREToPNGFile( AForm : TCustomForm; RE : TRichEdit; AFileName : string);
  procedure SaveFormBitmapToBMPFile( AForm : TCustomForm; AFileName : string = '' );
  function SaveChartToPng( AChart : Tchart; AFileName : string) : boolean;
  function SaveBitmapToPng( Bitmap : TBitmap; AFileName : string) : boolean;

  function u64ToBin (Value: u64; Digits: Integer ): AnsiString;
  function CalcCRC6(B: u64; N: Integer): Byte;

  function CalcCRC8(B: array of Byte): Byte; overload;
  function CalcCRC8(SA : ansistring): ansichar; overload;
  function CalcCRC8_hex_string(S: Ansistring): Byte;
  function CRC8Inverted(S: string): Byte;

  function CalculateChecksum8(PBuffer : Pointer; NumBytes : u16) : u8;

  procedure DivideString(const S: String; Delimiter: Char; var SL: TStringList); overload;

  procedure ReplaceSeparatorToDot(var S: AnsiString); overload;
  procedure ReplaceSeparatorToDot(var S: String); overload;

  procedure ReplaceSeparatorToComma(var S: AnsiString);  overload;
  procedure ReplaceSeparatorToComma(var S: String);  overload;

  procedure FixHex0xToDollar (var S : string); overload;
  procedure FixHex0xToDollar (var S : ansistring); overload;
  function Hex0xToInt (S : ansistring) : integer;

  function FindFileExists(StartDir, FileMask: string): boolean;

  function CountFilesInFolder (Path, FileMask: string ): integer;

  function ValidSingle(S: AnsiString; var R: Single): Boolean;

  function Endian_Swap (DataIn : u64; NumBytes : byte) : u64; overload;
  function Endian_Swap (DataIn : s32) : s32; overload;
  function Endian_Swap (DataIn : u32) : u32; overload;
  function Endian_Swap (DataIn : s16) : s16; overload;
  function Endian_Swap (DataIn : u16) : u16; overload;

  function TrimSp (StrIn : string) : string;
  function Trim2 (StrIn : string) : string; // Trim vse znake, ki niso v abacedi in èrke
  function TrimAlfaNum (StrIn : string) : string; // Trim vse znake, ki niso v abacedi in èrke, tudi brez loèil
  function TrimNumDotComma (StrIn : string) : string; // Trim vse znake, ki niso številke, vkljuèi pike in vejice
  function TrimNum (StrIn : string) : string; //  Trim vse znake, ki niso številke
  function TrimEmail (StrIn : string) : string;

  function ArrayToString(DataIn : pointer; NumBytes : byte) : AnsiString;

  procedure LinearLeastSquares(data: TRealPointArray; var M,B, R: extended);

  function FileSizeNO(fileName: wideString): Int64;

  function Crypt_Uncrypt(const s: AnsiString): AnsiString;
  function CryptH(const s: AnsiString): AnsiString;
  function UnCryptH(const EncrH: AnsiString): AnsiString;

  function GetFileTimeModified (const FileName: string) : string;

  function  LeadingZeroN(I, N: Integer): AnsiString;

  function StrToHexStr (Sin : ansistring; separator : ansistring) : string;

  function FindInArray(Parameter: String; var Arr : TStringList): integer;

  function NiceFileName(FileName: string): boolean;
  function GetFilesCount(Folder, WildCard: string): Integer;

  procedure FindFilesSingleDir(StartDir, FileMask: string; var FilesList : TStringList);

  procedure CopyToClipboard (var ClipBtxt : string); overload;
  procedure CopyToClipboard (var PaintBox : TPaintBox); overload;
  procedure CopyToClipboard (var RichEdit: TRichEdit); overload;

  function  LeadingZeros(I, N: Integer): AnsiString;
  
// -------------------------------------------------------------------------------------------------------------

implementation

procedure Wait(ms : integer);
var
  Tstart : cardinal;
begin
  Tstart := GetTickCount;
  repeat
    Application.ProcessMessages;
  until Application.Terminated OR (GetTickCount >= Tstart + ms);
end;


procedure SaveFormScreenshotToPNGFile( AForm : TCustomForm; AFileName : string);
var
  Bitmap: TBitMap;
  png : TPNGImage;

begin
  Bitmap := AForm.GetFormImage;
  png := TPNGImage.Create;
  try
    png.Assign(Bitmap);
    png.SaveToFile(AFileName);
  finally
    Bitmap.Free;
    png.Free;
  end;
end;

procedure SaveFormScreenshotWithREToPNGFile( AForm : TCustomForm; RE : TRichEdit; AFileName : string);
var
  Bitmap: TBitMap;
  png : TPNGImage;
  myRect: TRect;
  REbmp: TBitmap;

begin
  Bitmap := AForm.GetFormImage;
   // tu imamo cel form brez RichEdit-a

   // https://www.swissdelphicenter.ch/en/showcode.php?id=2171
  REbmp := TBitmap.Create;
  myRect := RE.ClientRect;
  // if you are using PRF_NONCLIENT parameter in myRTF.perform command
  // using this statement
  // myRect := Rect(0,0,MyRTF.Width,MyRTF.Height);

  REbmp.Width  := myRect.Right;
  REbmp.Height := myRect.Bottom;
  REbmp.Canvas.Lock;
  try
    RE.Perform(WM_PRINT, REbmp.Canvas.Handle, PRF_OWNED ); //PRF_CLIENT);
      (*
      PRF_CHECKVISIBLE Draws the window only if it is visible.
      PRF_CHILDREN Draws all visible children windows.
      PRF_CLIENT Draws the client area of the window.
      PRF_ERASEBKGND Erases the background before drawing the window.
      PRF_NONCLIENT Draws the nonclient area of the window.
      PRF_OWNED Draws all owned windows.
      *)
  finally
    REbmp.Canvas.Unlock;
  end;

  Bitmap.Canvas.Lock;
  Bitmap.Canvas.Draw(re.Left+10, re.Top+10, REbmp);
  Bitmap.Canvas.Unlock;
  REbmp.Free;







  png := TPNGImage.Create;
  try
    png.Assign(Bitmap);
    png.SaveToFile(AFileName);
  finally
    Bitmap.Free;
    png.Free;
  end;

// https://docs.microsoft.com/en-us/windows/win32/controls/printing-rich-edit-controls
// https://www.swissdelphicenter.ch/en/showcode.php?id=2146
end;

procedure SaveFormBitmapToBMPFile( AForm : TCustomForm; AFileName : string);
// Copies this form's bitmap to the specified file
var
  Bitmap: TBitMap;

begin
  Bitmap := AForm.GetFormImage;
  try
    Bitmap.SaveToFile( AFileName );
  finally
    Bitmap.Free;
  end;
end;

function SaveChartToPng( AChart : Tchart; AFileName : string) : boolean;
var
  Bitmap: TBitMap;
  png : TPNGImage;
  r: TRect;

begin
  Result := False;
  Bitmap := TBitmap.Create;
  r := AChart.BoundsRect;
  r.Right := r.Right - r.Left;
  r.Left := 0;
  r.Bottom := r.Bottom - r.Top;
  r.Top := 0;

  Bitmap.Width := r.Right;
  Bitmap.Height := r.Bottom;
  Bitmap.PixelFormat := pf16bit;

  AChart.Draw(Bitmap.Canvas,r);

  AFileName := ChangeFileExt(AFileName, '.png');
  png := TPNGImage.Create;
  try
    png.Assign(Bitmap);
//    png.SaveToFile(AFileName+'.png');
    png.SaveToFile(AFileName);
  finally
    Bitmap.Free;
    png.Free;
  end;

  if NOT FileExists(AFileName)
  then
    begin
    MessageDlg('Shranjevanje PNG slike ni bilo uspešno!', mtError, [mbOk], 0);
    end
  else
    begin
    Result := True;
    end;
end;

function SaveBitmapToPng( Bitmap : TBitmap; AFileName : string) : boolean;
var
  png : TPNGImage;

begin
  Result := False;

  AFileName := ChangeFileExt(AFileName, '.png');
  png := TPNGImage.Create;
  try
    png.Assign(Bitmap);
    png.SaveToFile(AFileName);
  finally
    png.Free;
  end;

  if NOT FileExists(AFileName)
  then
    begin
    MessageDlg('Shranjevanje PNG slike ni bilo uspešno!', mtError, [mbOk], 0);
    end
  else
    begin
    Result := True;
    end;
end;

(*
procedure TMainForm.ShraniSlikoGrafa(var Chart : Tchart);
var
  fn: string;
  ex: string;
  ok: boolean;
  exok: boolean;
begin
  ok := false;
  if SaveDialogSlika.FileName <> '' then
    SaveDialogSlika.FileName := ExtractFileName(SaveDialogSlika.FileName);
  if SaveDialogSlika.Execute then
  begin
    fn := SaveDialogSlika.FileName;
    ex := ExtractFileExt(fn);
    exok := false;
    if uppercase(ex) = '.PNG' then      exok := True;
    if uppercase(ex) = '.BMP' then      exok := True;
    if uppercase(ex) = '.WMF' then      exok := True;
    if uppercase(ex) = '.EMF' then      exok := True;

    if NOT exok then // konènica ni ustrezna
      case SaveDialogSlika.FilterIndex of
        1:          fn := ChangeFileExt(fn, '.png');
        2:          fn := ChangeFileExt(fn, '.bmp');
        3:          fn := ChangeFileExt(fn, '.wmf');
        4:          fn := ChangeFileExt(fn, '.emf');
      end;

    ex := ExtractFileExt(fn);
    ex := uppercase(ex);
    case ex[2] of
      'P':
        begin
          ok := SaveChartToPng(Chart, fn);
        end;
      'B':
        begin
          Chart.SaveToBitmapFile(fn);
          ok := True;
        end;
      'W':
        begin
          Chart.SaveToMetafile(fn);
          ok := True;
        end;
      'E':
        begin
          Chart.SaveToMetafileEnh(fn);
          ok := True;
        end;
    end;

  //  if ok then
    if NOT FileExists(fn) then
      MessageDlg('Shranjevanje slike ni bilo uspešno!', mtError, [mbOk], 0);
  end; // dialog ok
end;
*)

function u64ToBin (Value: u64; Digits: Integer ): AnsiString;
var i : integer;
begin
    Result := StringOfChar ( '0', Digits ) ;
    for i := 1 to Digits do
      begin
      if (Value and 1) = 1 then
        Result[Digits] := '1';
      Dec (Digits) ;
      Value := Value shr 1;
      if Value = 0 then Break;
      end;
end;

function CalcCRC6(B: u64; N: Integer): Byte;
var
  CRC6: Byte;
  I: Integer;
//procedure DoCRC8(X: Byte);
const
  Table: array[0..63] of Byte = (
    0, 3, 6, 5, 12, 15,
10, 9, 24, 27, 30, 29,
20, 23, 18, 17, 48, 51,
54, 53, 60, 63, 58, 57,
40, 43, 46, 45, 36, 39,
34, 33, 35, 32, 37, 38,
47, 44, 41, 42, 59, 56,
61, 62, 55, 52, 49, 50,
19, 16, 21, 22, 31, 28,
25, 26, 11, 8, 13, 14,
7, 4, 1, 2 );

begin
  CRC6 := 0;
{
  DoCRC8(C shr 24 and $FF);
  DoCRC8(C shr 16 and $FF);
  DoCRC8(C shr 8 and $FF);
  DoCRC8(C and $FF);
}

  for I := N downto 1 do
    CRC6 := Table[CRC6 xor ((B shr (6*(I-1))) and $3F)];
{
  CRC8 := Table[CRC8 xor C shr 24 and $FF];
  CRC8 := Table[CRC8 xor C shr 16 and $FF];
  CRC8 := Table[CRC8 xor C shr 8 and $FF];
  CRC8 := Table[CRC8 xor C and $FF];
}
  Result := CRC6;
end;

//----------------------------------------------------------------------------------------------------------------------



function CalcCRC8(B: array of Byte): Byte; overload;
var
  CRC8: Byte;
  I: Integer;

  const
  Table: array[0..255] of Byte = (
     0, 151, 185, 46, 229, 114, 92, 203,       93, 202, 228, 115, 184, 47, 1, 150,
     186, 45, 3, 148, 95, 200, 230, 113,    231, 112, 94, 201, 2, 149, 187, 44,
     227, 116, 90, 205, 6, 145, 191, 40,
    190, 41, 7, 144, 91, 204, 226, 117,    89, 206, 224, 119, 188, 43, 5, 146,
    4, 147, 189, 42, 225, 118, 88, 207,    81, 198, 232, 127, 180, 35, 13, 154,
    12, 155, 181, 34, 233, 126, 80, 199,    235, 124, 82, 197, 14, 153, 183, 32,
    182, 33, 15, 152, 83, 196, 234, 125,     178, 37, 11, 156, 87, 192, 238, 121,
    239, 120, 86, 193, 10, 157, 179, 36,     8, 159, 177, 38, 237, 122, 84, 195,
    85, 194, 236, 123, 176, 39, 9, 158,    162, 53, 27, 140, 71, 208, 254, 105,
    255, 104, 70, 209, 26, 141, 163, 52,     24, 143, 161, 54, 253, 106, 68, 211,
    69, 210, 252, 107, 160, 55, 25, 142,     65, 214, 248, 111, 164, 51, 29, 138,
    28, 139, 165, 50, 249, 110, 64, 215,     251, 108, 66, 213, 30, 137, 167, 48,
    166, 49, 31, 136, 67, 212, 250, 109,     243, 100, 74, 221, 22, 129, 175, 56,
    174, 57, 23, 128, 75, 220, 242, 101,     73, 222, 240, 103, 172, 59, 21, 130,
    20, 131, 173, 58, 241, 102, 72, 223,     16, 135, 169, 62, 245, 98, 76, 219,
    77, 218, 244, 99, 168, 63, 17, 134,    170, 61, 19, 132, 79, 216, 246, 97,
    247, 96, 78, 217, 18, 133, 171, 60
  );
begin
  CRC8 := 0;

  for I := 0 to Length(B)-1 do
    CRC8 := Table[CRC8 xor B[I]];

  Result := CRC8;
end;

function CalcCRC8(SA : ansistring): ansichar; overload;
var
  CRC8: Byte;
  I: Integer;

  const
  Table: array[0..255] of Byte = (
     0, 151, 185, 46, 229, 114, 92, 203,       93, 202, 228, 115, 184, 47, 1, 150,
     186, 45, 3, 148, 95, 200, 230, 113,    231, 112, 94, 201, 2, 149, 187, 44,
     227, 116, 90, 205, 6, 145, 191, 40,
    190, 41, 7, 144, 91, 204, 226, 117,    89, 206, 224, 119, 188, 43, 5, 146,
    4, 147, 189, 42, 225, 118, 88, 207,    81, 198, 232, 127, 180, 35, 13, 154,
    12, 155, 181, 34, 233, 126, 80, 199,    235, 124, 82, 197, 14, 153, 183, 32,
    182, 33, 15, 152, 83, 196, 234, 125,     178, 37, 11, 156, 87, 192, 238, 121,
    239, 120, 86, 193, 10, 157, 179, 36,     8, 159, 177, 38, 237, 122, 84, 195,
    85, 194, 236, 123, 176, 39, 9, 158,    162, 53, 27, 140, 71, 208, 254, 105,
    255, 104, 70, 209, 26, 141, 163, 52,     24, 143, 161, 54, 253, 106, 68, 211,
    69, 210, 252, 107, 160, 55, 25, 142,     65, 214, 248, 111, 164, 51, 29, 138,
    28, 139, 165, 50, 249, 110, 64, 215,     251, 108, 66, 213, 30, 137, 167, 48,
    166, 49, 31, 136, 67, 212, 250, 109,     243, 100, 74, 221, 22, 129, 175, 56,
    174, 57, 23, 128, 75, 220, 242, 101,     73, 222, 240, 103, 172, 59, 21, 130,
    20, 131, 173, 58, 241, 102, 72, 223,     16, 135, 169, 62, 245, 98, 76, 219,
    77, 218, 244, 99, 168, 63, 17, 134,    170, 61, 19, 132, 79, 216, 246, 97,
    247, 96, 78, 217, 18, 133, 171, 60
  );
begin
  CRC8 := 0;

  for I := 1 to Length(SA) do
    CRC8 := Table[CRC8 xor byte(SA[I])];

  Result := ansichar(CRC8);
end;


function CalcCRC8_hex_string(S: Ansistring): Byte;
var
  B: array of Byte;
  MS, BS: AnsiString;
begin
  SetLength(B,0);
  MS := S;
  while Length(MS) > 0 do begin
    BS := '$'+Copy(MS,1,2);
    SetLength(B,Length(B)+1);
    if Length(BS) < 3 then
      BS := BS + '0';
    B[Length(B)-1] := StrToIntDef(BS,0);
    Delete(MS,1,2);
  end;
  Result := CalcCRC8(B);
end;

function CRC8Inverted(S: string): Byte;
var
  B: array of Byte;
  MS, BS: AnsiString;
begin
  SetLength(B,0);
  MS := AnsiString(S);
  while Length(MS) > 0 do begin
    BS := '$'+Copy(MS,1,2);
    SetLength(B,Length(B)+1);
    if Length(BS) < 3 then
      BS := BS + '0';
    B[Length(B)-1] := StrToIntDef(BS,0);
    Delete(MS,1,2);
  end;
  Result := not CalcCRC8(B);   // CRC je po novem Invertiran
end;

//----------------------------------------------------------------------------------------------------------------------

function CalculateChecksum8(PBuffer : Pointer; NumBytes : u16) : u8;
var
  chksm : u32;
  Idx : u16;
  byt : u8;

begin
  chksm := 0;
  for Idx := 0 to (NumBytes-1) do
    begin
    byt := u8(Ptr(Integer(PBuffer)+Idx)^);
    chksm := chksm + byt;
    end;
  Result := chksm AND $FF;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure DivideString(const S: String; Delimiter: Char; var SL: TStringList);
const
  CitatChar = '"';
var
  I: Integer;
  ShS: ShortString;
  ShSIndex: Integer;
  Citat: Boolean;
begin
  SL.Clear;
  ShSIndex := 0;
  ShS := '';
  Citat := False;
  for I := 1 to Length(S) do
    begin
    if S[I] = CitatChar then
      begin
      Citat := Citat Xor True;
//      Continue;                              // Narekovaje odstranimo kasneje, tip pred obdelavo SL stringov
      end;
    if (S[I] <> Delimiter) or Citat then
      begin
      if ShSIndex < 255 then Shs := ShS+S[I];
      Inc(ShSIndex);
      end
    else
      begin
      if (Trim(ShS) <> '') or (Delimiter <> ' ') then  SL.Add(ShS);
      ShS := '';
      ShSIndex := 0;
      end;
    end;
  SL.Add(ShS);
end;

//----------------------------------------------------------------------------------------------------------------------

procedure ReplaceSeparatorToDot(var S: AnsiString); overload;
var
  i: integer;
begin
 for i := 1 to Length(S)-1 do
   if S[i] = ',' then S[i] := '.';
end;

procedure ReplaceSeparatorToDot(var S: String); overload;
var
  i: integer;
begin
 for i := 1 to Length(S)-1 do
   if S[i] = ',' then S[i] := '.';
end;

procedure ReplaceSeparatorToComma(var S: AnsiString);  overload;
var 
  i : integer;
begin
 for i := 1 to Length(S)-1 do
   if S[i] = '.' then S[i] := ',';
end;

procedure ReplaceSeparatorToComma(var S: String);  overload;
var 
  i : integer;
begin
 for i := 1 to Length(S)-1 do
   if S[i] = '.' then S[i] := ',';
end;

//----------------------------------------------------------------------------------------------------------------------

procedure FixHex0xToDollar (var S : string);
var
 i : integer;
begin
  i := pos('0x', S);
  if i > 0 then
  begin
    S[2] := '$';
    delete(S, i, 1);
  end;
end;

procedure FixHex0xToDollar (var S : ansistring);
var
 i : integer;
begin
  i := pos('0x', S);
  if i > 0 then
  begin
    S[2] := '$';
    delete(S, i, 1);
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

function Hex0xToInt (S : ansistring) : integer;
begin
  FixHex0xToDollar(S);
  result := StrToInt(S);
end;

//----------------------------------------------------------------------------------------------------------------------

function FindFileExists(StartDir, FileMask: string): boolean;
var
  SR: TSearchRec;
  IsFound: boolean;

begin
  if StartDir[Length(StartDir)] <> '\' then
    StartDir := StartDir + '\';

  { Build a list of the files in directory StartDir
    (not the directories!) }

  IsFound := FindFirst(StartDir + FileMask, faAnyFile - faDirectory, SR) = 0;
  (*
    while IsFound do begin
    FilesList.Add(StartDir + SR.Name);
    IsFound := FindNext(SR) = 0;
    end;
    *)
  FindClose(SR);
  Result := IsFound;
end;

//----------------------------------------------------------------------------------------------------------------------
// https://www.tek-tips.com/viewthread.cfm?qid=1097614

function CountFilesInFolder (Path, FileMask: string ): integer;
var
  tsr: TSearchRec;
begin
  path := IncludeTrailingPathDelimiter ( path );
  result := 0;
  if FindFirst ( path + FileMask, faAnyFile and not faDirectory, tsr ) = 0 then
  begin
    repeat
      inc ( result );
    until FindNext ( tsr ) <> 0;
    FindClose ( tsr );
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

function ValidSingle(S: AnsiString; var R: Single): Boolean;
var
  Koda : Integer;
  TS : AnsiString;
begin
  TS := S;
  //if Pos(DecimalSeparator,TS) <> 0 then
  //  TS[Pos(DecimalSeparator,TS)] := '.';
  Val(TS,R,Koda);
  Result := (Koda = 0);
end;

//----------------------------------------------------------------------------------------------------------------------

function Endian_Swap (DataIn : u64; NumBytes : byte) : u64; overload;
var
  i : integer;
  DataOut : u64;

begin
  DataOut := 0;
  for i := 0 to NumBytes-1 do
    begin
    DataOut := DataOut SHL 8;
    DataOut := DataOut OR (DataIn AND $FF);
    DataIn := DataIn SHR 8;
    end;
  Result := DataOut;
end;



function Endian_Swap (DataIn : u32) : u32; overload;
begin
  Result := u32(Endian_Swap(u32(DataIn), 4));
end;

function Endian_Swap (DataIn : u16) : u16; overload;
begin
  Result := u16(Endian_Swap(u16(DataIn), 2));
end;

function Endian_Swap (DataIn : s32) : s32; overload;
begin
  Result := s32(Endian_Swap(u32(DataIn), 4));
end;

function Endian_Swap (DataIn : s16) : s16; overload;
begin
  Result := s16(Endian_Swap(u16(DataIn), 2));
end;

//----------------------------------------------------------------------------------------------------------------------

function TrimSp (StrIn : string) : string; // Trim in odstrani še Space
var
  p : integer;

begin
  Result := Trim (StrIn);

  p := pos (' ', Result);
  while p > 0 do
    begin
    delete (Result, p, 1);
    p := pos (' ', Result);
    end;
end;

//----------------------------------------------------------------------------------------------------------------------
function Trim2 (StrIn : string) : string; // Trim vse znake, ki niso v abacedi ali številke
var
  i : integer;
  S : string;
  C : char;

begin
  S := Trim (StrIn);
  Result := '';

  for i := 1 to Length(S) do
    begin
      C := S[i];
      if (ord(C) > 31) AND (ord(C) < 127) then Result := Result + C;
    end;
end;

function TrimAlfaNum (StrIn : string) : string; // Trim vse znake, ki niso v abacedi in èrke, tudi brez loèil
var
  i : integer;
  S : string;
  C : char;

begin
  S := Trim (StrIn);
  Result := '';

  for i := 1 to Length(S) do
    begin
      C := S[i];
      if (C in ['A'..'Z']) OR (C in ['a'..'z']) OR (C in ['0'..'9']) then Result := Result + C;
    end;
end;

function TrimEmail (StrIn : string) : string;
var
  i : integer;
  S : string;
  C : char;

begin
  S := Trim (StrIn);
  Result := '';

  for i := 1 to Length(S) do
    begin
      C := S[i];
      if (C in ['A'..'Z']) OR (C in ['a'..'z']) OR (C in ['0'..'9']) OR (C = '@') OR (C = '.') then Result := Result + C;
    end;
end;

function TrimNumDotComma (StrIn : string) : string; // Trim vse znake, ki niso številke, vkljuèi pike in vejice
var
  i : integer;
  S : string;
  C : char;

begin
  S := Trim (StrIn);
  Result := '';

  for i := 1 to Length(S) do
    begin
      C := S[i];
      if (C in ['0'..'9']) OR (C in [',','.']) then Result := Result + C;
    end;
end;

function TrimNum (StrIn : string) : string; //  Trim vse znake, ki niso številke
var
  i : integer;
  S : string;
  C : char;

begin
  S := Trim (StrIn);
  Result := '';

  for i := 1 to Length(S) do
    begin
      C := S[i];
      if (C in ['0'..'9']) then Result := Result + C;
    end;
end;

//----------------------------------------------------------------------------------------------------------------------
function ArrayToString(DataIn : Pointer; NumBytes : byte) : AnsiString;
var
  S : ansistring;

begin
  SetLength(S, NumBytes);
  move(DataIn^, S[1], NumBytes);
  Result := S;
end;

//----------------------------------------------------------------------------------------------------------------------


{************* LinearLeastSquares *******************}
 procedure LinearLeastSquares(data: TRealPointArray; var M,B, R: extended);
 {Line "Y = mX + b" is linear least squares line for the input array, "data", of T2DRealPoint}
var
  SumX, SumY, SumX2, SumY2, SumXY: extended;
  Sx,Sy :extended;
  n, i: Integer;
begin
  n := Length(data); {number of points}
  SumX := 0.0;  SumY := 0.0;
  SumX2 := 0.0;  SumY2:=0.0;
  SumXY := 0.0;

  for i := 0 to n - 1 do
  with data[i] do
  begin
    SumX := SumX + X;
    SumY := SumY + Y;
    SumX2 := SumX2 + X*X;
    SumY2 := SumY2 + Y*Y;
    SumXY := SumXY + X*Y;
  end;

  if (n*SumX2=SumX*SumX) or (n*SumY2=SumY*SumY)
  then
  begin
//    showmessage('LeastSquares() Error - X or Y  values cannot all be the same');
    M:=0;
    B:=0;
  end
  else
  begin
    M:=((n * SumXY) - (SumX * SumY)) / ((n * SumX2) - (SumX * SumX));  {Slope M}
    B:=(sumy-M*sumx)/n;  {Intercept B}
    Sx:=sqrt(Sumx2-sqr(sumx)/n);
    Sy:=Sqrt(Sumy2-sqr(Sumy)/n);
    r:=(Sumxy-Sumx*sumy/n)/(Sx*sy);
    //RSquared:=r*r;
  end;
end;

// returns file size in bytes or -1 if not found.
function FileSizeNO(fileName: wideString): Int64;
var
  sr : TSearchRec;
begin
  if FindFirst(fileName, faAnyFile, sr ) = 0 then
     result := Int64(sr.FindData.nFileSizeHigh) shl Int64(32) + Int64(sr.FindData.nFileSizeLow)
  else
     result := -1;
  FindClose(sr);
end;


// will crypt A..Z, a..z, 0..9 characters by rotating
function Crypt_Uncrypt(const s: AnsiString): AnsiString;
var i: integer;
begin
  result := s;
  for i := 1 to length(s) do
    case ord(s[i]) of
    ord('A')..ord('M'),ord('a')..ord('m'): result[i] := ansichar(ord(s[i])+13);
    ord('N')..ord('Z'),ord('n')..ord('z'): result[i] := ansichar(ord(s[i])-13);
    ord('0')..ord('4'): result[i] := ansichar(ord(s[i])+5);
    ord('5')..ord('9'): result[i] := ansichar(ord(s[i])-5);
    end;
end;

function CryptH(const s: AnsiString): AnsiString;
var
  i: integer;
  Encr, H1, EncrH : AnsiString;
begin
  Encr := s; // nastavi dolžino
  EncrH := '';
  for i := 1 to length(s) do
    begin
      case ord(s[i]) of
      ord('A')..ord('M'),ord('a')..ord('m'): Encr[i] := ansichar(ord(s[i])+13);
      ord('N')..ord('Z'),ord('n')..ord('z'): Encr[i] := ansichar(ord(s[i])-13);
      ord('0')..ord('4'):                    Encr[i] := ansichar(ord(s[i])+5);
      ord('5')..ord('9'):                    Encr[i] := ansichar(ord(s[i])-5);
      end;
    H1 := IntToHex(ord(Encr[i]), 2);
    EncrH := EncrH + H1[2] + H1[1];
    end;

  result := EncrH;
end;

function UnCryptH(const EncrH: AnsiString): AnsiString;
var
  i: integer;
  H1, Decr : AnsiString;
  Encr : AnsiChar;
begin
  SetLength(Decr, length(EncrH) DIV 2); // nastavi dolžino
  for i := 1 to length(Decr) do
    begin
    H1 := EncrH[i*2] + EncrH[i*2-1];
    Encr := ansichar(StrToInt('$'+H1));
      case ord(Encr) of
      ord('A')..ord('M'),ord('a')..ord('m'): Decr[i] := ansichar(ord(Encr)+13);
      ord('N')..ord('Z'),ord('n')..ord('z'): Decr[i] := ansichar(ord(Encr)-13);
      ord('0')..ord('4'):                    Decr[i] := ansichar(ord(Encr)+5);
      ord('5')..ord('9'):                    Decr[i] := ansichar(ord(Encr)-5);
      else  Decr[i] := Encr; // za znake izven tega nabora
      end;
    end;
  result := Decr;
end;

function GetFileTimeModified (const FileName: string) : string;
var
  fad: TWin32FileAttributeData;
  SystemTime, LocalTime: TSystemTime;

begin
result := '';
  if not GetFileAttributesEx(PChar(FileName), GetFileExInfoStandard, @fad) then
    RaiseLastOSError;

  if not FileTimeToSystemTime(fad.ftLastWriteTime, SystemTime) then
    RaiseLastOSError;
  if not SystemTimeToTzSpecificLocalTime(nil, SystemTime, LocalTime) then
    RaiseLastOSError;
  result := DateTimeToStr(SystemTimeToDateTime(LocalTime));

//  ReportTime('Created', fad.ftCreationTime);
//  ReportTime('Modified', fad.ftLastWriteTime);
//  ReportTime('Accessed', fad.ftLastAccessTime);
end;


function  LeadingZeroN(I, N: Integer): AnsiString;
begin
  Str(I,Result);
  if (N < 5) and (N > 0) then
    while Length(Result) < N do
      Result := '0'+Result;
end;

function StrToHexStr (Sin : ansistring; separator : ansistring) : string;
var
  i : integer;
  s : string;
begin
  s := '';
  for i := 1 to Length(Sin) do
    s := s + separator + IntToHex(Ord(Sin[i]), 2);
  Result := s;
end;

function FindInArray(Parameter: String; var Arr : TStringList): integer;
var
  i : integer;
begin
  Result := -1;
  Parameter := UpperCase(Parameter);
  for i := 0 to Arr.Count-1 do
    begin
    if UpperCase(Arr[i]) = Parameter then
      begin
      Result := i;
      Break;
      end;
    end;
end;


function NiceFileName(FileName: string): boolean;
var
  I: Integer;
const
  WrongChars : string = '/\:*?"<>|';
begin
  Result := False;
  if FileName = '' then
    Exit;
  if Trim(FileName) = '' then
    Exit;
  for I := 1 to Length(FileName) do
    if Pos(FileName[I],WrongChars) > 0 then
      Exit;
  Result := True;
end;


function GetFilesCount(Folder, WildCard: string): Integer;
var
  intFound: Integer;
  SearchRec: TSearchRec;
begin
  Result := 0;
  if (Folder <> '') and (Folder[Length(Folder)] <> '\') then
    Folder := Folder + '\';
  intFound := FindFirst(Folder + WildCard, faAnyFile, SearchRec);
  while (intFound = 0) do
  begin
    if not (SearchRec.Attr and faDirectory = faDirectory) then
      Inc(Result);
    intFound := FindNext(SearchRec);
  end;
  FindClose(SearchRec);
end;



// poišèi datoteke znotraj podane mape, brez podmap

procedure FindFilesSingleDir(StartDir, FileMask: string; var FilesList : TStringList);
var
  SR: TSearchRec;
  IsFound: Boolean;

begin
   if StartDir[length(StartDir)] <> '\' then
    StartDir := StartDir + '\';

  // Build a list of the files in directory StartDir (not the directories!)

  IsFound := FindFirst(StartDir + FileMask, faAnyFile-faDirectory, SR) = 0;
  while IsFound AND (NOT Application.Terminated) do
    begin
    FilesList.Add(StartDir + SR.Name);
    IsFound := FindNext(SR) = 0;
    end;
  FindClose(SR);
end;



procedure CopyToClipboard (var ClipBtxt : string); overload;
begin
  ClipBtxt := ClipBtxt + #0;
  Clipboard.Clear;
  Clipboard.SetTextBuf(@ClipBtxt[1]);
end;

procedure CopyToClipboard (var PaintBox : TPaintBox); overload;
var
  Bitmap: TBitmap;
begin
  Bitmap := TBitmap.Create;
  Bitmap.Width := PaintBox.Height;
  Bitmap.Height := PaintBox.Height;

  BitBlt(Bitmap.Canvas.Handle,
    0,
    0,
    Bitmap.Width,
    Bitmap.Height,
    PaintBox.Canvas.Handle,
    0,
    0,
    SRCCOPY);

  Clipboard.Assign(Bitmap);
  Bitmap.Free;
end;

procedure CopyToClipboard (var RichEdit: TRichEdit); overload;
begin
  RichEdit.SelectAll;
  RichEdit.CopyToClipboard;
  RichEdit.SelStart := 0;
  RichEdit.SelLength := 0;
end;

function  LeadingZeros(I, N: Integer): AnsiString;
begin
  Result := IntToStr(I);
  if (N <= 6) and (N > 0) then
    while Length(Result) < N do
      Result := '0'+Result;
end;


end.
{
*****************************************************************************
*                                                                           *
*  This file is part of the ZCAD                                            *
*                                                                           *
*  See the file COPYING.modifiedLGPL.txt, included in this distribution,    *
*  for details about the copyright.                                         *
*                                                                           *
*  This program is distributed in the hope that it will be useful,          *
*  but WITHOUT ANY WARRANTY; without even the implied warranty of           *
*  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.                     *
*                                                                           *
*****************************************************************************
}
{
@author(Andrey Zubarev <zamtmn@yandex.ru>) 
}

unit uzeffttf;
{$INCLUDE def.inc}
interface
uses uzefontmanager,EasyLazFreeType,uzefontttf,geometry,
    uzefont,strproc,{$IFNDEF DELPHI}FileUtil,LCLProc,{$ENDIF}sysutils,
    UGDBOpenArrayOfByte,gdbasetypes,gdbase,memman;
type ptsyminfo=^tsyminfo;
     tsyminfo=packed record
                           number,size:word;
                     end;
function createnewfontfromttf(name:GDBString;var pf:PGDBfont):GDBBoolean;
implementation
uses
   uzcshared;
function CreateTTFFontInstance:PTTFFont;
begin
     GDBGetMem({$IFDEF DEBUGBUILD}'{638B5484-83D8-4FEA-AE47-918B8B0CBC08}',{$ENDIF}result,sizeof(TTFFont));
     result^.init;
end;
function createnewfontfromttf(name:GDBString;var pf:PGDBfont):GDBBoolean;
var
   i:integer;
   chcode:integer;
   //k:gdbdouble;
   pttf:PTTFFont;
   si:TTTFSymInfo;
   Iterator:TMapChar.TIterator;
begin
    initfont(pf,extractfilename(name));
    pf^.fontfile:=name;
    pf^.font:=CreateTTFFontInstance;
    //pf.ItFFT;
    pttf:=pointer(pf^.font);
    result:=true;
    pttf^.ftFont.Hinted:=false;
    pttf^.ftFont.Name := name;
    //pttf^.ftFont.SmallLinePadding:=false;
    //pf^.Internalname:=pttf^.ftFont.Information[ftiCopyrightNotice];
    pf^.family:=pttf^.ftFont.Information[ftiFamily];
    //pf^.Internalname:=pttf^.ftFont.Information[ftiStyle];
    //pf^.Internalname:=pttf^.ftFont.Information[ftiIdentifier];
    pf^.fullname:=pttf^.ftFont.Information[ftiFullName];
    //pf^.Internalname:=pttf^.ftFont.Information[ftiVersionString];
    //pf^.Internalname:=pttf^.ftFont.Information[ftiPostscriptName];
    //pf^.Internalname:=pttf^.ftFont.Information[ftiTrademark];
    //pf^.Internalname:=pttf^.ftFont.Information[ftiManufacturer];
    //pf^.Internalname:=pttf^.ftFont.Information[ftiDesigner];
    //pf^.Internalname:=pttf^.ftFont.Information[ftiVendorURL];
    //pf^.Internalname:=pttf^.ftFont.Information[ftiDesignerURL];
    //pf^.Internalname:=pttf^.ftFont.Information[ftiLicenseInfoURL];

    //pf^.Internalname:=pttf^.ftFont.Information[ftiFamily];


    pttf^.ftFont.TextWidth('');//It's just a guarantee font loading. I do not need to calculate the any width
    pttf^.ftFont.SizeInPoints:={pttf^.ftFont.SizeInPoints*10}10000;
    pf.font.unicode:=true;
    //k:=1;
    {$if FPC_FULlVERSION>=20701}
    //k:=1/pttf^.ftFont.CapHeight;
    {$ENDIF}
    for i:=0 to 65535 do
      begin
           chcode:=pttf^.ftFont.CharIndex[i];
           if chcode>0 then
                      begin
                           si.GlyphIndex:=chcode;
                           si.PSymbolInfo:=nil;
                           pttf^.MapChar.Insert(i,si);
                           //programlog.LogOutStr('TTF: Symbol index='+inttostr(si.GlyphIndex)+'; code='+inttostr(i),0);
                      end;
      end;
    {exit;}
    iterator:=pttf^.MapChar.Min;
    if assigned(iterator) then
    begin
    repeat
          si:=iterator.Value;
          chcode:=iterator.Key;

          cfeatettfsymbol(chcode,si,pttf);
          iterator.Value:=si;

    until {not iterator.next}true;
    iterator.Destroy;
    end;
end;
initialization
  RegisterFontLoadProcedure('ttf','TTF font',@createnewfontfromttf);
end.
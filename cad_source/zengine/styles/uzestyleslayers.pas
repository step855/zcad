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

unit uzestyleslayers;
{$INCLUDE def.inc}
interface
uses uzbtypesbase,sysutils,uzbtypes,uzegeometry,
     uzeconsts,UGDBNamedObjectsArray,uzbstrproc;
type
{REGISTEROBJECTTYPE GDBLayerArray}
{EXPORT+}
PPGDBLayerPropObjInsp=^PGDBLayerPropObjInsp;
PGDBLayerPropObjInsp={GDBPtrUInt}GDBPointer;
PGDBLayerProp=^GDBLayerProp;
GDBLayerProp={$IFNDEF DELPHI}packed{$ENDIF} object(GDBNamedObject)
               color:GDBByte;(*saved_to_shd*)(*'Color'*)
               lineweight:GDBSmallint;(*saved_to_shd*)(*'Line weight'*)
               LT:GDBPointer;(*saved_to_shd*)(*'Line type'*)
               _on:GDBBoolean;(*saved_to_shd*)(*'On'*)
               _lock:GDBBoolean;(*saved_to_shd*)(*'Lock'*)
               _print:GDBBoolean;(*saved_to_shd*)(*'Print'*)
               desk:GDBAnsiString;(*saved_to_shd*)(*'Description'*)
               constructor InitWithParam(N:GDBString; C: GDBInteger; LW: GDBInteger;oo,ll,pp:GDBBoolean;d:GDBString);
               function GetFullName:GDBString;virtual;
               procedure SetValueFromDxf(group:GDBInteger;value:GDBString);virtual;
               procedure SetDefaultValues;virtual;
               destructor done;virtual;
         end;
PGDBLayerPropArray=^GDBLayerPropArray;
GDBLayerPropArray=packed array [0..0] of PGDBLayerProp;
PGDBLayerArray=^GDBLayerArray;
GDBLayerArray={$IFNDEF DELPHI}packed{$ENDIF} object(GDBNamedObjectsArray{-}<PGDBLayerProp,GDBLayerProp>{//})(*OpenArrayOfData=GDBLayerProp*)
                    constructor init({$IFDEF DEBUGBUILD}ErrGuid:pansichar;{$ENDIF}m:GDBInteger;psyslt:GDBPointer);
                    constructor initnul;

                    function addlayer(name:GDBString;color:GDBInteger;lw:GDBInteger;oo,ll,pp:GDBBoolean;d:GDBString;lm:TLoadOpt):PGDBLayerProp;virtual;
                    function GetSystemLayer:PGDBLayerProp;
                    function createlayerifneed(_source:PGDBLayerProp):PGDBLayerProp;
                    function createlayerifneedbyname(lname:GDBString;_source:PGDBLayerProp):PGDBLayerProp;
              end;
{EXPORT-}
var
   DefaultErrorLayer:GDBLayerProp;
function GetLTName(LT:PGDBLayerProp):GDBString;
implementation
//uses
//    log;
function GetLTName(LT:PGDBLayerProp):GDBString;
begin
     if assigned(LT) then
                         result:=LT^.Name
                     else
                         result:='Continuous';
end;

function  GDBLayerArray.createlayerifneedbyname(lname:GDBString;_source:PGDBLayerProp):PGDBLayerProp;
begin
           result:=getAddres(lname);
           if result=nil then
           begin
                if _source<>nil then
                result:=addlayer(_source.Name,
                                        _source.color,
                                        _source.lineweight,
                                        _source._on,
                                        _source._lock,
                                        _source._print,
                                        _source.desk,
                                        TLOMerge);
           end;
end;
function  GDBLayerArray.createlayerifneed(_source:PGDBLayerProp):PGDBLayerProp;
begin
           result:=createlayerifneedbyname(_source.Name,_source);
           {result:=getAddres(_source.Name);
           if result=nil then
           begin
                if _source<>nil then
                result:=addlayer(_source.Name,
                                        _source.color,
                                        _source.lineweight,
                                        _source._on,
                                        _source._lock,
                                        _source._print,
                                        _source.desk,
                                        TLOMerge);
           end;}
end;
constructor GDBLayerArray.init;
begin
  inherited init({$IFDEF DEBUGBUILD}ErrGuid,{$ENDIF}m);
  addlayer(LNSysLayerName,CGDBWhile,lwgdbdefault,true,false,true,'',TLOLoad).LT:=psyslt;
  addlayer(LNMetricLayerName,CGDBWhile,lwgdbdefault,false,false,false,'',TLOLoad).LT:=psyslt;
end;
constructor GDBLayerArray.initnul;
begin
  inherited initnul;
  //objsizeof:=sizeof(GDBLayerProp);
  //size:=sizeof(GDBLayerProp);
end;
destructor GDBLayerProp.done;
begin
     inherited;
     self.desk:='';
end;

procedure GDBLayerProp.SetDefaultValues;
begin
     color:=7;
     lineweight:=-1;
     LT:=nil;
     _on:=true;
     _lock:=false;
     if uppercase(name)=LNSysDefpoints then
                                           _print:=false
                                       else
                                           _print:=true;
     desk:='';
end;
procedure GDBLayerProp.SetValueFromDxf(group:GDBInteger;value:GDBString);
var
   _color:integer;
begin
  case group of
          62:
            begin
              _color:=strtoint(value);
              color:=abs(_color);
              if _color<0 then begin
                                    self._on:=false;
                               end;
            end;
          370:
            begin
              self.lineweight:=strtoint(value);
            end;
          70:
            begin
                 if (strtoint(value)and 4)<>0 then
                                                   begin
                                                        self._lock:=true;
                                                   end;
             end;
          290:
            begin
                 if (strtoint(value))=0 then
                                              begin
                                                   self._print:=false;
                                              end;
             end;
        end;
end;

constructor GDBLayerProp.InitWithParam(N:GDBString; C: GDBInteger; LW: GDBInteger;oo,ll,pp:GDBBoolean;d:GDBString);
begin
    initnul;
    LT:=nil;
    SetName(n);
    color := c;
    lineweight := lw;
    _on:=oo;
    _lock:=ll;
    _print:=pp;
    desk:=d;
end;
function GDBLayerProp.GetFullName;
{const
     ls=24;}
//var ss:gdbstring;
begin
     result:=ansi2cp(getname);
     {  if _on then
                       ss:='[O'
                   else
                       ss:='[–';
       if _lock then
                       ss:=ss+'L'
                   else
                       ss:=ss+'–';
       if _print then
                       ss:=ss+'P] '
                   else
                       ss:=ss+'–] '; }
       result:={ss+}result;
end;
function GDBLayerArray.GetSystemLayer;
begin
     result:=getAddres(LNSysLayerName);
end;
function GDBLayerArray.addlayer;
var
  p:PGDBLayerProp;
      //ir:itrec;
begin
     case AddItem(name,pointer(p)) of
             IsFounded:
                       begin
                            if lm=TLOLoad then
                            begin
                                 p^.color:=color;
                                 p^.lineweight:=lw;
                                 p^._on:=oo;
                                 p^._lock:=ll;
                                 p^._print:=pp;
                                 p^.desk:=d;
                            end;
                       end;
             IsCreated:
                       begin
                            if uppercase(name)=LNSysDefpoints then
                                                               p^.initwithparam(Name,Color,LW,oo,ll,false,d)
                            else
                            p^.initwithparam(Name,Color,LW,oo,ll,pp,d);
                       end;
             IsError:
                       begin
                       end;
     end;
     result:=p;
end;
begin
  DefaultErrorLayer.Initwithparam('DefaultErrorLayer',200,0,true,false,true,'');
end.

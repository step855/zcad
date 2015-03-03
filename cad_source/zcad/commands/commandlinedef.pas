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

unit commandlinedef;
{$INCLUDE def.inc}
interface
uses gdbasetypes,gdbase{,UGDBOpenArrayOfPointer},oglwindowdef,log,UGDBOpenArrayOfPObjects,ugdbdrawingdef;
const
     CADWG=1;
     CASelEnt=2;
     CASelEnts=4;
     CACanUndo=8;
     CACanRedo=16;
     CADWGChanged=32;


     CEDeSelect=1;
     CEDWGNChanged=2;
type
TInteractiveProcObjBuild=procedure(const PInteractiveData:GDBPointer;Point:GDBVertex;Click:GDBBoolean);
{Export+}
    TGetPointMode=(TGPWait{point},TGPWaitEnt,TGPEnt,TGPPoint,TGPCancel,TGPOtherCommand, TGPCloseDWG,TGPCloseApp);
    TInteractiveData=packed record
                       GetPointMode:TGetPointMode;(*hidden_in_objinsp*)
                       GetPointValue:GDBVertex;(*hidden_in_objinsp*)
                       PInteractiveData:GDBPointer;
                       PInteractiveProc:{-}TInteractiveProcObjBuild{/GDBPointer/};
                    end;
    TCommandOperands={-}PAnsiChar{/GDBPointer/};
    TCommandResult=GDBInteger;
  TCStartAttr=GDBInteger;{атрибут разрешения\запрещения запуска команды}
    TCEndAttr=GDBInteger;{атрибут действия по завершению команды}
  PCommandObjectDef = ^CommandObjectDef;
  CommandObjectDef ={$IFNDEF DELPHI}packed{$ENDIF} object (GDBaseObject)
    CommandName:GDBString;(*hidden_in_objinsp*)
    CommandGDBString:GDBString;(*hidden_in_objinsp*)
    savemousemode: GDBByte;(*hidden_in_objinsp*)
    mouseclic: GDBInteger;(*hidden_in_objinsp*)
    dyn:GDBBoolean;(*hidden_in_objinsp*)
    overlay:GDBBoolean;(*hidden_in_objinsp*)
    CStartAttrEnableAttr:TCStartAttr;(*hidden_in_objinsp*)
    CStartAttrDisableAttr:TCStartAttr;(*hidden_in_objinsp*)
    CEndActionAttr:TCEndAttr;(*hidden_in_objinsp*)
    pdwg:GDBPointer;(*hidden_in_objinsp*)
    NotUseCommandLine:GDBBoolean;(*hidden_in_objinsp*)
    IData:TInteractiveData;(*hidden_in_objinsp*)
    procedure CommandStart(Operands:TCommandOperands); virtual; abstract;
    procedure CommandEnd; virtual; abstract;
    procedure CommandCancel; virtual; abstract;
    procedure CommandInit; virtual; abstract;
    procedure DrawHeplGeometry;virtual;
    destructor done;virtual;
    constructor init(cn:GDBString;SA,DA:TCStartAttr);
    function GetObjTypeName:GDBString;virtual;
    function IsRTECommand:GDBBoolean;virtual;
    procedure CommandContinue; virtual;
  end;
  CommandFastObjectDef ={$IFNDEF DELPHI}packed{$ENDIF} object(CommandObjectDef)
    procedure CommandInit; virtual;abstract;
    procedure CommandEnd; virtual;abstract;
  end;
  PCommandRTEdObjectDef=^CommandRTEdObjectDef;
  CommandRTEdObjectDef = {$IFNDEF DELPHI}packed{$ENDIF} object(CommandFastObjectDef)
    procedure CommandStart(Operands:pansichar); virtual;abstract;
    procedure CommandEnd; virtual;abstract;
    procedure CommandCancel; virtual;abstract;
    procedure CommandInit; virtual;abstract;
    procedure CommandContinue; virtual;
    function MouseMoveCallback(wc: GDBvertex; mc: GDBvertex2DI; button: GDBByte;osp:pos_record): GDBInteger; virtual;
    function BeforeClick(wc: GDBvertex; mc: GDBvertex2DI; button: GDBByte;osp:pos_record): GDBInteger; virtual;
    function AfterClick(wc: GDBvertex; mc: GDBvertex2DI; button: GDBByte;osp:pos_record): GDBInteger; virtual;
    function IsRTECommand:GDBBoolean;virtual;
  end;
  pGDBcommandmanagerDef=^GDBcommandmanagerDef;
  GDBcommandmanagerDef={$IFNDEF DELPHI}packed{$ENDIF} object(GDBOpenArrayOfPObjects)
                                  lastcommand:GDBString;
                                  pcommandrunning:PCommandRTEdObjectDef;
                                  function executecommand(const comm:string;pdrawing:PTDrawingDef;POGLWndParam:POGLWndtype): GDBInteger;virtual;abstract;
                                  procedure executecommandend;virtual;abstract;
                                  function executelastcommad(pdrawing:PTDrawingDef;POGLWndParam:POGLWndtype): GDBInteger;virtual;abstract;
                                  procedure sendpoint2command(p3d:gdbvertex; p2d:gdbvertex2di; mode:GDBByte;osp:pos_record;const drawing:TDrawingDef);virtual;abstract;
                                  procedure CommandRegister(pc:PCommandObjectDef);virtual;abstract;
                             end;
{Export-}
implementation
//uses oglwindow;
function CommandObjectDef.IsRTECommand:GDBBoolean;
begin
     result:=false;
end;
procedure CommandObjectDef.CommandContinue;
begin
end;
function CommandObjectDef.GetObjTypeName;
begin
     //pointer(result):=typeof(testobj);
     result:='CommandObjectDef';

end;
constructor CommandObjectDef.init;
begin
  CStartAttrEnableAttr:=SA or CADWG;
  CStartAttrDisableAttr:=DA;
  overlay:=false;
  CEndActionAttr:=CEDeSelect;
  NotUseCommandLine:=true;
  IData.GetPointMode:=TGPCancel;
end;

destructor CommandObjectDef.done;
begin
         //inherited;
         CommandName:='';
         CommandGDBString:='';
end;
procedure CommandObjectDef.DrawHeplGeometry;
begin
end;
function CommandRTEdObjectDef.BeforeClick;
begin
     result:=0;
end;
function CommandRTEdObjectDef.AfterClick;
begin
     if self.mouseclic=1 then
                             result:=0
                         else
                             result:=0;
end;
function CommandRTEdObjectDef.IsRTECommand:GDBBoolean;
begin
     result:=true;
end;
procedure CommandRTEdObjectDef.CommandContinue;
begin
end;
function CommandRTEdObjectDef.MouseMoveCallback;
begin
  //result:=0;
  {$IFDEF TOTALYLOG}programlog.logoutstr('CommandRTEdObjectDef.MouseMoveCallback',0);{$ENDIF}
     { if button =1  then
                        begin
                            button:=-button;
                            button:=-button;
                        end;}
                        if (button and MZW_LBUTTON)<>0 then
                                          begin
                                                button:=button;
                                          end;
    if mouseclic = 0 then
                         result := BeforeClick(wc, mc, button,osp)
                     else
                         result := AfterClick(wc, mc, button,osp);
    if ((button and MZW_LBUTTON)<>0)and(result<=0) then
                                         begin
                                               inc(self.mouseclic);
                                         end;
end;
begin
     {$IFDEF DEBUGINITSECTION}LogOut('commandlinedef.initialization');{$ENDIF}
end.
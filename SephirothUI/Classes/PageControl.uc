class PageControl extends COptionPage;

var int ViewType;			//3.½ÃÁ¡¼±ÅÃ
var int RotateView;
var int Turn180;
var bool bTurn180KeyOnly;
var float CameraTurnSpeed;
var int CameraTurnSpeedType;
var bool bUseEdgeTurn;


const CB_Turn180KeyOnly = 100;
const CB_UseEdgeTurn = 101;
const BN_ToggleRun=102;
const BN_ToggleArm=103;

function LoadOption()
{
	ViewType = int(ConsoleCommand("GETOPTIONI ViewType"));
	RotateView = int(ConsoleCommand("GETOPTIONI RotateView"));
	Turn180 = int(ConsoleCommand("GETOPTIONI Turn180"));
	bTurn180KeyOnly = bool(ConsoleCommand("GETOPTIONI Turn180KeyboardOnly"));
	CameraTurnSpeed = float(ConsoleCommand("GETOPTIONF CameraTurnSpeed"));
	CameraTurnSpeedType = clamp((int(CameraTurnSpeed) - 30) / 10, 0, 4);
	bUseEdgeTurn = bool(ConsoleCommand("GETOPTIONI UseEdgeTurn"));

	Super.LoadOption();
}

function SaveOption()
{	
	RotateView = GetComboBoxIndex(Components[2]);
	Turn180 = GetComboBoxIndex(Components[4]);
	ViewType = GetComboBoxIndex(Components[9]);

	CameraTurnSpeedType = GetComboBoxIndex(Components[7]);
	if (RotateView == Turn180 && !bTurn180KeyOnly)
		class'CMessageBox'.static.MessageBox(COption(Parent),"OptionHelp",Localize("Setting","SameControlAssigned","Sephiroth"),MB_Ok);
	ConsoleCommand("SETOPTIONI ViewType"@ViewType);
	ConsoleCommand("SETOPTIONI RotateView"@RotateView);
	ConsoleCommand("SETOPTIONI Turn180"@Turn180);
	ConsoleCommand("SETOPTIONB Turn180KeyboardOnly"@bTurn180KeyOnly);
	CameraTurnSpeed = CameraTurnSpeedType * 10.0 + 30.0;
	ConsoleCommand("SETOPTIONF CameraTurnSpeed"@CameraTurnSpeed);
	COnsoleCommand("SETOPTIONB UseEdgeTurn"@bUseEdgeTurn);

	Super.SaveOption();
}

function OnInit()
{
	AddDropDownMenu(Components[2],Localize("Setting","RotateControlSet_0","Sephiroth"));
	AddDropDownMenu(Components[2],Localize("Setting","RotateControlSet_1","Sephiroth"));
	AddDropDownMenu(Components[2],Localize("Setting","RotateControlSet_2","Sephiroth"));
	AddDropDownMenu(Components[4],Localize("Setting","Turn180ControlSet_0","Sephiroth"));
	AddDropDownMenu(Components[4],Localize("Setting","Turn180ControlSet_1","Sephiroth"));
	AddDropDownMenu(Components[4],Localize("Setting","Turn180ControlSet_2","Sephiroth"));
	AddDropDownMenu(Components[7],Localize("Setting","CameraTurnSpeed_Slowest","Sephiroth"));
	AddDropDownMenu(Components[7],Localize("Setting","CameraTurnSpeed_Slow","Sephiroth"));
	AddDropDownMenu(Components[7],Localize("Setting","CameraTurnSpeed_Normal","Sephiroth"));
	AddDropDownMenu(Components[7],Localize("Setting","CameraTurnSpeed_Fast","Sephiroth"));
	AddDropDownMenu(Components[7],Localize("Setting","CameraTurnSpeed_Fastest","Sephiroth"));

	AddDropDownMenu(Components[9],Localize("Setting","FirstPersonCameraView","Sephiroth"));
	AddDropDownMenu(Components[9],Localize("Setting","FreeCameraView","Sephiroth"));
	AddDropDownMenu(Components[9],Localize("Setting","AutoCameraView","Sephiroth"));

	Components[5].NotifyId = CB_Turn180KeyOnly;
}

function UpdateComponents()
{
	SetComboBoxCurrent(Components[2],RotateView);
	SetComboBoxCurrent(Components[4],Turn180);
	SetComboBoxCurrent(Components[7],CameraTurnSpeedType);
	Components[4].bDisabled = bTurn180KeyOnly;

	SetComboBoxCurrent(Components[9],ViewType);
}

function OnFlush()
{
	EmptyComboBox(Components[2]);
	EmptyComboBox(Components[4]);
	EmptyComboBox(Components[7]);

	EmptyComboBox(Components[9]);
}

function OnPreRender(Canvas C)
{
	local Texture txInputBack;

	txInputBack = Texture(DynamicLoadObject("UI_2011.input_op_bg",class'Texture'));

	C.SetRenderStyleAlpha();

	Super.OnPreRender(C);

	// ¹¹³Ä --;; const °¡ ¾È¸ÔÇô

	C.SetPos(Components[2].X-5, Components[2].Y-5);
	C.DrawTile(txInputBack,
		Components[2].XL,Components[2].YL,0,0,Components[2].XL,Components[2].YL);

	C.SetPos(Components[4].X-5, Components[4].Y-5);
	C.DrawTile(txInputBack,
		Components[4].XL,Components[4].YL,0,0,Components[4].XL,Components[4].YL);

	C.SetPos(Components[7].X-5, Components[7].Y-5);
	C.DrawTile(txInputBack,
		Components[7].XL,Components[7].YL,0,0,Components[7].XL,Components[7].YL);

	C.SetPos(Components[9].X-5, Components[9].Y-5);
	C.DrawTile(txInputBack,
		Components[9].XL,Components[9].YL,0,0,Components[9].XL,Components[9].YL);

}

function bool PushComponentBool(int CmpId)
{

	return false;
}


function NotifyComponent(int CmpId,int NotifyId,optional string Command)
{
	Apply();
}

function OnComboUpdate(int CmpId)
{
	Apply();
}

defaultproperties
{
     Components(1)=(Id=1,Caption="RotateViewMenu",Type=RES_Text,XL=124.000000,YL=20.000000,PivotDir=PVT_Copy,OffsetXL=33.000000,OffsetYL=133.000000,TextColor=(B=113,G=215,R=241,A=255),LocType=LCT_Setting)
     Components(2)=(Id=2,Type=RES_TextButton,XL=150.000000,YL=24.000000,PivotId=1,PivotDir=PVT_Down,OffsetYL=4.000000)
     Components(3)=(Id=3,Caption="Turn180Menu",Type=RES_Text,XL=124.000000,YL=20.000000,PivotDir=PVT_Copy,OffsetXL=213.000000,OffsetYL=133.000000,TextColor=(B=113,G=215,R=241,A=255),LocType=LCT_Setting)
     Components(4)=(Id=4,Type=RES_TextButton,XL=150.000000,YL=24.000000,PivotId=3,PivotDir=PVT_Down,OffsetYL=4.000000)
     Components(6)=(Id=6,Caption="CameraTurnSpeedMenu",Type=RES_Text,XL=124.000000,YL=20.000000,PivotDir=PVT_Copy,OffsetXL=213.000000,OffsetYL=78.000000,TextColor=(B=113,G=215,R=241,A=255),LocType=LCT_Setting)
     Components(7)=(Id=7,Type=RES_TextButton,XL=150.000000,YL=24.000000,PivotId=6,PivotDir=PVT_Down,OffsetYL=4.000000)
     Components(8)=(Id=8,Caption="CameraViewMenu",Type=RES_Text,XL=124.000000,YL=20.000000,PivotDir=PVT_Copy,OffsetXL=33.000000,OffsetYL=78.000000,TextColor=(B=113,G=215,R=241,A=255),LocType=LCT_Setting)
     Components(9)=(Id=9,Type=RES_TextButton,XL=150.000000,YL=24.000000,PivotId=8,PivotDir=PVT_Down,OffsetYL=4.000000)
}

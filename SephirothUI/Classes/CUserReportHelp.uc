class CUserReportHelp extends CMultiInterface;

// consts
const BN_OK		= 1;
const BN_Cancel	= 2;

// data
var string HelpText;

// ui component
var CTextPool HelpTextControl;
const IDC_BG		= 0;
const IDC_TITLE		= 1;
const IDC_TEXTPOOL	= 2;
const IDC_OKBTN		= 3;
const IDC_CANCELBTN	= 4;


// notifytarget
var CInterface NotifyTarget;
var int NotifyValue;

///////////////////////////////
// Interface overrides
function OnInit()
{
	SetComponentText(Components[IDC_TITLE], "ReportHelpTitle");
	SetComponentTextureId(Components[IDC_OKBTN],1,-1,2,3);
	SetComponentTextureId(Components[IDC_CANCELBTN],1,-1,2,3);
	Components[IDC_OKBTN].NotifyId		= BN_OK;
	Components[IDC_CANCELBTN].NotifyId	= BN_Cancel;

	SetComponentText(Components[IDC_OKBTN],"ReportComplain");
	SetComponentText(Components[IDC_CANCELBTN],"Cancel");
	SetComponentHotkey(Components[IDC_OKBTN],IK_Enter);
	SetComponentHotkey(Components[IDC_CANCELBTN],IK_Escape);

	HelpTextControl = Spawn(class'Interface.CTextPool');
	HelpTextControl.InterfaceController = Controller;
	HelpTextControl.AllowedLines = 8;

	// add helptext lines
	AddText(HelpText);
}

function OnFlush()
{
	if(HelpTextControl != None) 
	{
		HelpTextControl.Destroy();
		HelpTextControl = None;
	}
}


function OnPostRender(HUD H, Canvas C)
{
	HelpTextControl.DrawMessage(C,
		Components[IDC_TEXTPOOL].X, Components[IDC_TEXTPOOL].Y + HelpTextControl.EndLineIndex * 14,
		Components[IDC_TEXTPOOL].XL*Components[IDC_TEXTPOOL].ScaleX);
}


function Layout(Canvas C)
{
	local int i;
	MoveComponent(Components[IDC_BG],true,
		(C.ClipX-Components[IDC_BG].XL*Components[IDC_BG].ScaleX)/2,(C.ClipY-Components[IDC_BG].YL*Components[IDC_BG].ScaleY)/2);
	for (i=1;i<Components.Length;i++)
		MoveComponent(Components[i]);
}


function NotifyComponent(int CmpId,int NotifyId,optional string Command)
{
	switch (NotifyId) 
	{
	case BN_OK:
		Close(NotifyValue);
		break;
	case BN_Cancel:
		Close(-1*NotifyValue);
		break;
	}
}

/////////////////////////////
// internal functions
function AddText(string text)
{
	local int nlpos;
	local string line;

	while(text != "")
	{
		nlpos = InStr(text, "\\n");
		if(nlpos != -1)
		{
			line = Left(text, nlpos);
			text = Mid(text, nlpos+2);
		}
		else
		{
			line = text;
			text = "";
		}

		HelpTextControl.AddMessage(line, 
			class'Canvas'.static.MakeColor(255,255,255),
			12,
			ETextAlign.TA_MiddleLeft);
	}
}


/////////////////////////////
// external interface
static function CUserReportHelp Show(CMultiInterface Parent, int noti_id)
{
	local CUserReportHelp dlg;
	dlg = CUserReportHelp(Parent.Controller.HudInterface.AddInterface("SephirothUI.CUserReportHelp",true));
	if (dlg != None) 
	{
		dlg.HelpText		= Localize("Information","UserReportHelp","Sephiroth");
		dlg.NotifyTarget	= Parent;
		dlg.NotifyValue		= noti_id;

		dlg.ShowInterface();

		Parent.bIgnoreKeyEvents = true;
	}
	return dlg;
}

function Close(int Value)
{
	HideInterface();

	CMultiInterface(Parent).RemoveInterface(Self);
	NotifyTarget.NotifyInterface(Self,INT_Close,Value);
	NotifyTarget.bIgnoreKeyEvents = false;
	Parent.bIgnoreKeyEvents = false;
}

defaultproperties
{
     Components(0)=(Type=RES_Image,XL=246.000000,YL=200.000000)
     Components(1)=(Id=1,Type=RES_Text,XL=210.000000,YL=15.000000,PivotDir=PVT_Copy,OffsetXL=18.000000,OffsetYL=16.000000,TextAlign=TA_MiddleCenter,TextColor=(B=174,G=201,R=229,A=255),LocType=LCT_Information)
     Components(2)=(Id=2,XL=210.000000,YL=97.000000,PivotDir=PVT_Copy,OffsetXL=18.000000,OffsetYL=40.000000)
     Components(3)=(Id=3,Type=RES_PushButton,XL=89.000000,YL=29.000000,PivotDir=PVT_Copy,OffsetXL=28.000000,OffsetYL=155.000000,TextAlign=TA_MiddleCenter,LocType=LCT_Commands)
     Components(4)=(Id=4,Type=RES_PushButton,XL=89.000000,YL=29.000000,PivotDir=PVT_Copy,OffsetXL=128.000000,OffsetYL=155.000000,TextAlign=TA_MiddleCenter,LocType=LCT_Commands)
     TextureResources(0)=(Package="UI_2011",Path="win_pop_s",Style=STY_Alpha)
     TextureResources(1)=(Package="UI_2011_btn",Path="btn_brw_n",Style=STY_Alpha)
     TextureResources(2)=(Package="UI_2011_btn",Path="btn_brw_c",Style=STY_Alpha)
     TextureResources(3)=(Package="UI_2011_btn",Path="btn_brw_o",Style=STY_Alpha)
}

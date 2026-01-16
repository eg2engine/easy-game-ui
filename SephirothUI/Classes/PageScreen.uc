/*
	Change Option page components to Radio Button, to improve user-convenience.
	2009.10.21.Sinhyub.
*/
class PageScreen extends COptionPage;

// RadioButton Notify ID	2009.10.21.Sinhyub
const RB_Screen	=1;
const Check_Sky	=2;
const RB_Shadow	=3;
const Check_Cursor	=4;
const RB_Effect	=5;
const RB_Font	=6;
const RB_UItype	=7;
const PB_OptimalFullscreen = 8;
const CMP_EFFECT = 12;
const CB_ShowDeadEffect = 13;

var array<string> EffectOptionList;

const Type1 = 0;
const Type2 = 1;
// Options
var string Resolution;
var bool bFullscreen;
var bool bOptimalFullscreen;	// -2009.11.10.Sinhyub
var bool bRenderSky;
var int ShadowType;
var bool bUseGraphicCursor;
var float FogRatio;
var float Brightness;
var int Distance;
var int EffectDetail;
var string Font;			//modified by yj
var int UItype;				//modified by yj

var bool bShowDeadEffect;	//add neive : ��� ����Ʈ ����

struct _SlideData
{
	var float fMin;
	var float fMax;
	var float fCur;
};

var CSlide DistanceSlide;
var _SlideData DistanceData;
var CSlide BrightnessSlide;
var _SlideData BrightnessData;
var CSlide FogRatioSlide;
var _SlideData FogRatioData;



function LoadOption()
{
	Resolution = ConsoleCommand("GETOPTIONS Resolution");
	bFullscreen = bool(ConsoleCommand("GETOPTIONI Fullscreen"));
	bOptimalFullscreen = bool(ConsoleCommand("GETOPTIONI OptimalFullscreen")); //-2009.11.10.Sinhyub
	ShadowType = int(ConsoleCommand("GETOPTIONI ShadowType"));
	bRenderSky = bool(ConsoleCommand("GETOPTIONI RenderSky"));
	bUseGraphicCursor = bool(ConsoleCommand("GETOPTIONI UseGraphicCursor"));
	FogRatio = float(ConsoleCommand("GETOPTIONF FogRatio"));
	Distance = float(ConsoleCommand("GETOPTIONF FilterDistance"));
	Brightness = float(ConsoleCommand("get ini:Engine.Engine.ViewportManager Brightness"));
	if( 0 > Brightness || Brightness > 1 )
		Brightness = 0.5f;
	EffectDetail = int(ConsoleCommand("get ini:Engine.Engine.ViewportManager EffectDetail"));
	Font = Parent.Controller.HudInterface.LastFont;		//modified by yj
	UItype = int(ConsoleCommand("GETOPTIONI UIType"));
	bShowDeadEffect = bool(ConsoleCommand("GETOPTIONI ShowDeadEffect"));
	Super.LoadOption();
}

function DebugLog(string message)
{
	SephirothInterface(SephirothPlayer(PlayerOwner).myHUD).AddMessage(1,"DebugLog PageScreen: "@message,class'Canvas'.Static.MakeColor(128,255,255));
}

function ApplyEffect()
{
	local float FrameRateValue;
	
	ConsoleCommand("set ini:Engine.Engine.ViewportManager Brightness"@Brightness);
	ConsoleCommand("set ini:Engine.Engine.ViewportManager EffectDetail"@EffectDetail);
	if( EffectDetail == 0 )
	{
		FrameRateValue = 200.0;
		ConsoleCommand("set ini:Engine.Engine.GameEngine MaxEffectProjectors"@10);
	}
	else if(EffectDetail == 1)
	{
		FrameRateValue = 90.0;
		ConsoleCommand("set ini:Engine.Engine.GameEngine MaxEffectProjectors"@6);
	}
	else if(EffectDetail == 2)
	{
		FrameRateValue = 60.0;
		ConsoleCommand("set ini:Engine.Engine.GameEngine MaxEffectProjectors"@2);
	}
	else
	{
		FrameRateValue = 30.0;
		ConsoleCommand("set ini:Engine.Engine.GameEngine MaxEffectProjectors"@0);
	}
	
	// 设置实例值（立即生效）
	PlayerOwner.Level.MaxClientFrameRate = FrameRateValue;
	// 设置类的默认值（用于保存）
	class'LevelInfo'.Default.MaxClientFrameRate = FrameRateValue;
	// 立即保存帧率值到配置文件
	class'LevelInfo'.Static.StaticSaveConfig();
}

function SaveOption()
{
	local string temp_resolution;

	temp_resolution = GetComponentText(Components[2]);
	if( temp_resolution != "Optimal Fullscreen" )	//"Optimal Fullscreen" String�� Resolution�� ���� ����� �ȵ�
		Resolution = temp_resolution;

	//EffectDetail = EffectDetail;
	ApplyEffect();

	if( font != Parent.Controller.HudInterface.LastFont )		//���߿� ��ĥ��
		Parent.Controller.HudInterface.ChageFont_modified(font);
	

	SephirothInterface(SephirothPlayer(PlayerOwner).myHUD).ChangeUIType(UIType);  //modified by yj
	ConsoleCommand("SETOPTIONB ShowDeadEffect"@bShowDeadEffect);			//add neive : ��� ����Ʈ ����
	ConsoleCommand("SETOPTIONI UIType"@UIType);
	ConsoleCommand("SETOPTIONB OptimalFullscreen"@bOptimalFullscreen);	//2009.11.10.Sinhyub
	ConsoleCommand("SETOPTIONB Fullscreen"@bFullscreen);
	ConsoleCommand("SETOPTIONS Resolution"@Resolution);
	ConsoleCommand("SETOPTIONI ShadowType"@ShadowType);
	ConsoleCommand("SETOPTIONB RenderSky"@bRenderSky);
	ConsoleCommand("SETOPTIONB UseGraphicCursor"@bUseGraphicCursor);
		//@by wj(02/04) 
	if( bUseGraphicCursor )
		PlayerOwner.ConsoleCommand("USEGRAPHICCURSOR 1");
	else
		PlayerOwner.ConsoleCommand("USEGRAPHICCURSOR 0");

	ConsoleCommand("SETOPTIONF FogRatio"@FogRatio);
	ConsoleCommand("SETOPTIONF FilterDistance"@Distance);

	Super.SaveOption();
}

function OnInit()
{
	local int i;

	AddDropDownMenu(Components[2],"1024x768");
	AddDropDownMenu(Components[2],"1280x1024");
	AddDropDownMenu(Components[2],"1400x840"); //add neive : ���̵� ���
	AddDropDownMenu(Components[2],"1600x1024"); //add neive : ���̵� ���
	AddDropDownMenu(Components[2],"1920x1080");

	EffectOptionList[3] = Localize("Setting","EffectBad","Sephiroth");
	EffectOptionList[2] = Localize("Setting","EffectNormal","Sephiroth");
	EffectOptionList[1] = Localize("Setting","EffectGood","Sephiroth");
	EffectOptionList[0] = Localize("Setting","EffectExcellent","Sephiroth");
	for( i = 0; i < EffectOptionList.Length; i++ )
		AddDropDownMenu(Components[12],EffectOptionList[i]);//AddDropDownMenu(Components[21],EffectOptionList[i]);

	//Screen Mode
	SetComponentNotify(Components[4],RB_Screen,Self);
	SetComponentNotify(Components[5],RB_Screen,Self);
	//Sky Rendering Option
	SetComponentNotify(Components[6],Check_Sky,Self);

	//Shadow Rendering Option
	SetComponentNotify(Components[8],RB_Shadow,Self);
	SetComponentNotify(Components[9],RB_Shadow,Self);
	SetComponentNotify(Components[10],RB_Shadow,Self);

	SetComponentNotify(Components[13],CB_ShowDeadEffect,Self);

	//Cursor Rendering Option
	SetComponentNotify(Components[14],Check_Cursor,Self);

	//Font Style Option
	SetComponentNotify(Components[26],RB_Font,Self);
	SetComponentNotify(Components[27],RB_Font,Self);
	SetComponentNotify(Components[28],RB_Font,Self);
	SetComponentNotify(Components[29],RB_Font,Self);

	//UI Style Option
	SetComponentNotify(Components[37],RB_UItype,Self);
	SetComponentNotify(Components[38],RB_UItype,Self);
//	SetComponentNotify(Components[39],PB_OptimalFullscreen,Self);	//-2009.11.10.Sinhyub

	DistanceSlide = CSlide(AddInterface("Interface.CSlide"));
	if( DistanceSlide != None )
	{
		DistanceSlide.ShowInterface();
		DistanceSlide.SetSlide(Components[18].X, -100,115,20, DistanceData.fMin, Distance ,DistanceData.fMax);
	}
	BrightnessSlide = CSlide(AddInterface("Interface.CSlide"));
	if( BrightnessSlide != None )
	{
		BrightnessSlide.ShowInterface();
		BrightnessSlide.SetSlide(Components[32].X, -100,115,20, BrightnessData.fMin, Brightness, BrightnessData.fMax);
	}
	FogRatioSlide = CSlide(AddInterface("Interface.CSlide"));
	if( FogRatioSlide != None )
	{
		FogRatioSlide.ShowInterface();
		FogRatioSlide.SetSlide(Components[16].X, -100,115,20, FogRatioData.fMin, FogRatio, FogRatioData.fMax);
	}
}

function OnFlush()
{
	if( BrightnessSlide != None )
		RemoveInterface(BrightnessSlide);

	if( DistanceSlide != None )
		RemoveInterface(DistanceSlide);

	if( FogRatioSlide != None )
		RemoveInterface(FogRatioSlide);

	EmptyComboBox(Components[2]);

	EmptyComboBox(Components[12]);
}

function UpdateComponents()
{
	local int VendorId, DeviceId; // jjh

	// �����ػ� ��带 ����� ���, �ػ� ���� ����Ʈ �޺��ڽ��� Disabled�� �����մϴ�.
	// ��üȭ�� ���� ��ư�� Disabled�� �����մϴ�.
	if( bOptimalFullscreen )
	{			
		//2009.11.10.Sinhyub
		Components[2].Caption = "Optimal Fullscreen";
//		Components[39].Caption=Localize("Setting", "OptimalFullscreenOff", "Sephiroth");
		Components[2].bDisabled = True;
		Components[4].bDisabled = True;
		Components[5].bDisabled = True;
	}
	else
	{
//		Components[39].Caption=Localize("Setting", "OptimalFullscreen", "Sephiroth");
		Components[2].bDisabled = False;
		Components[4].bDisabled = False;
		Components[5].bDisabled = False;
		if ( Resolution == "800x600" || Resolution == "1024x768" )
			SetComboBoxCurrent(Components[2],0);
		else if (Resolution == "1280x1024")
			SetComboBoxCurrent(Components[2],1);
		else if ((Resolution == "1400x840 beta") || (Resolution == "1400x840")) //add neive : ���̵� ���	//2009.11.16.Sinhyub
			SetComboBoxCurrent(Components[2],2);
		else if ((Resolution == "1600x1024 beta") || (Resolution == "1600x1024")) //add neive : ���̵� ���
			SetComboBoxCurrent(Components[2],3);
		else if ((Resolution == "1920x1080")) //add neive : ���̵� ���
			SetComboBoxCurrent(Components[2],4);
		else
			SetComboBoxCurrent(Components[2],0);
	}
	


	SetComboBoxCurrent(Components[12], EffectDetail);

/*
	if (bFullscreen)
		SetComboBoxCurrent(Components[4],1);
	else
		SetComboBoxCurrent(Components[4],0);
*/
/*
	switch(font){			//modified by yj
		case("Dotum"):
			SetComboBoxCurrent(Components[21],0);
			break;
		case("Gungsuh"):
			SetComboBoxCurrent(Components[21],1);
			break;
		case("Batang"):
			SetComboBoxCurrent(Components[21],2);
			break;
		case("Gulim"):
			SetComboBoxCurrent(Components[21],3);
			break;
	}
*/

	// jjh --- Option configuration
	VendorId = int(PlayerOwner.ConsoleCommand("GETDEVICE VENDOR"));
	DeviceId = int(PlayerOwner.ConsoleCommand("GETDEVICE DEVICE"));

	if ( VendorId == 4634 // voodoo
		|| VendorId == 4139 // matrox
		|| VendorId == 4318 && DeviceId <= 0x2d // tnt
	) 
	{
		Components[2].bDisabled = True;
	}

	Components[14].bDisabled = True;
	// --- jjh
	if( bool(ConsoleCommand("GETOPTIONI UseD3DCursor")) )
	{
		Components[15].bDisabled = True;
	}

	BrightnessSlide.SetPos(Components[32].X + 15, Components[32].Y + 18);
	FogRatioSlide.SetPos(Components[16].X + 15, Components[16].Y + 18);
	DistanceSlide.SetPos(Components[18].X + 15, Components[18].Y + 18);


	bNeedLayoutUpdate = True;		//2010.3.3.Sinhyub
}

function bool PushComponentBool(int CmpId)
{
	switch(CmpId)
	{
	//â���
		case 4:	//ON
			return !bFullScreen;		break;
		case 5:	//Off
			return bFullScreen;	break;
	// �ϴ� ǥ��
		case 6:
			return bRenderSky;
			break;
	//�׸���ǥ��
		case 8:	//�ּ�
			return shadowtype == 0;		break;
		case 9:	//�߰�
			return shadowtype == 1;		break;
		case 10:	//�ִ�
			return shadowtype == 2;		break;
		case 13:
			return bShowDeadEffect;
			break;
	//Ŀ�� ǥ��
		case 14:	//On
			return bUseGraphicCursor;		break;
	//�۲�(�ü�ü�� ������ "Gungsu")
		case 26:	//����
			return font == "Gulim";	break;
		case 27:	//����
			return font == "Dotum";	break;
		case 28:	//����
			return font == "Batang";	break;
		case 29:	//�ü�
			return font == "Gungsuh";	break;
	//UIŸ��
		case 37:	//AŸ��
			return UItype == 0;		break;
		case 38:	//BŸ��
			return UItype == 1;		break;

		default:
			return False;
	}
}

function NotifyInterface(CInterface Interface,EInterfaceNotifyType NotifyType,optional coerce string Command)
{

}

function NotifyComponent(int CmpId,int NotifyId,optional string Command)
{
	//Log("NotifyComponents " $ CmpId);

	if( NotifyID == RB_Screen )
	{	
		//ScreenMode Option
		switch(CmpId)
		{
			case 4:
				bFullScreen = False;		break;
			case 5:
				bFullScreen = True;	break;
		}
	}
	else if(NotifyID == Check_Sky)
	{	
		//Sky rendering Option
		if( Command == "Checked" )
			bRenderSky = True;
		else
			bRenderSky = False;
	}
	else if(NotifyID == RB_Shadow)
	{	
		//Shadow rendering Option
		switch(CmpId)
		{
			case 8:		//�ּ�
				shadowtype = 0;	break;
			case 9:		//�߰�
				shadowtype = 1;	break;
			case 10:		//�ִ�
				shadowtype = 2; break;
		}
	}
	else if(NotifyID == CB_ShowDeadEffect)
		bShowDeadEffect = !bShowDeadEffect;
	else if(NotifyID == Check_Cursor)
	{	
		//Cursor rendering Option
		if( Command == "Checked" )
			bUseGraphicCursor = True;
		else
			bUseGraphicCursor = False;
	}
	else if(NotifyId == RB_Font)
	{	
		//Font style Option
		switch(CmpId)
		{
			case 26:
				font = "Gulim";	break;
			case 27:
				font = "Dotum";	break;
			case 28:
				font = "Batang"; break;
			case 29:
				font = "Gungsuh"; break;
		}
	}
	else if(notifyID == RB_UItype)
	{	
		//UI style Option
		switch(CmpId)
		{
			case 37:
				UItype = 0;	break;
			case 38:
				UItype = 1;	break;
		}
	}
	if ( NotifyID == PB_OptimalFullscreen )		//Optimal Fullscreen Mode -2009.11.10.Sinhyub
	{
		if( bOptimalFullscreen )
		{
			//Components[39].Caption=Localize("Setting", "OptimalFullscreen", "Sephiroth");
			SetComponentText(Components[2],"1024x768");
			bOptimalFullscreen = False;
			bFullscreen = False;
		}
		else
		{
			//Components[39].Caption=Localize("Setting", "OptimalFullscreenOff", "Sephiroth");
			bOptimalFullscreen = True;
			if( !bFullscreen )
				bFullscreen = True;
			else
			{
				ConsoleCommand("SETOPTIONB OptimalFullscreen True");
				ConsoleCommand("SETOPTIONB Fullscreen False True");
				ConsoleCommand("APPLYOPTION");
				ConsoleCommand("SETOPTIONB OptimalFullscreen True");
				ConsoleCommand("SETOPTIONB Fullscreen True True");
				ConsoleCommand("APPLYOPTION");
			}
		}
	}
	Apply();

	if( NotifyID == PB_OptimalFullscreen )		//modified by yj		//�ӽ÷� �̷��� �д�.
		Reposition();
}

function OnComboUpdate(int CmpId)
{
	Apply();
	// Update Layout of the CMainInterface and CChannelManager.
	if( CmpId == 2 )
	{  
		//modified by yj
		Reposition();
	}
	if( CmpId == 12 )
	{
		// ����Ʈ ���� ����
		EffectDetail = GetComboBoxIndex(Components[12]);
		Components[12].Caption = EffectOptionList[EffectDetail];
		SetComboBoxCurrent(Components[12], EffectDetail);

		ApplyEffect();
	}
}

function OnPreRender(Canvas C)
{
//	local float X,Y,W,H;
	local float fTemp;
	local int nTemp;
	local Texture txInputBack;

	txInputBack = Texture(DynamicLoadObject("UI_2011.input_op_bg",class'Texture'));

	C.SetRenderStyleAlpha();

	Super.OnPreRender(C);

	fTemp = BrightnessSlide.GetCalcedSlideValue(BrightnessData.fMax, BrightnessData.fMin);
	if( Brightness != fTemp )
	{
		Brightness = fTemp;
		ConsoleCommand("BRIGHTNESS "$Brightness);
	}

	fTemp = FogRatioSlide.GetCalcedSlideValue(FogRatioData.fMax, FogRatioData.fMin);
	if( FogRatio != fTemp )
	{
		FogRatio = fTemp;
		ConsoleCommand("SETOPTIONF FogRatio"@FogRatio);
	}


	nTemp = DistanceSlide.GetCalcedSlideValue(DistanceData.fMax, DistanceData.fMin);
	if( Distance != nTemp )
	{
		Distance = nTemp;
		ConsoleCommand("SETOPTIONF FilterDistance"@Distance);
	}

	// ���� --;; const �� �ȸ���

	C.SetPos(Components[2].X - 5, Components[2].Y - 5);
//	C.DrawTile(Texture(DynamicLoadObject("UI_2011.input_bg",class'Texture')),
//		Components[21].XL,Components[21].YL,0,0,Components[21].XL,Components[21].YL);

	C.DrawTile(txInputBack,
		Components[2].XL,Components[2].YL,0,0,Components[2].XL,Components[2].YL);

	C.SetPos(Components[12].X - 5, Components[12].Y - 5);
	C.DrawTile(txInputBack,
		Components[12].XL,Components[12].YL,0,0,Components[12].XL,Components[12].YL);
}

function RePosition()
{
	SephirothInterface(SephirothPlayer(PlayerOwner).myHUD).SetDefaultUIPosition();
}

defaultproperties
{
	DistanceData=(FMin=6000.000000,FMax=16000.000000)
	BrightnessData=(FMax=1.000000)
	FogRatioData=(FMin=0.500000,FMax=2.000000)
	PageWidth=391.000000
	PageHeight=423.000000
	Components(0)=(XL=391.000000,YL=423.000000)
	Components(1)=(Id=1,Caption="ResolutionMenu",Type=RES_Text,XL=100.000000,YL=20.000000,PivotDir=PVT_Copy,OffsetXL=33.000000,OffsetYL=78.000000,TextColor=(B=113,G=215,R=241,A=255),LocType=LCT_Setting)
	Components(2)=(Id=2,Type=RES_TextButton,XL=150.000000,YL=24.000000,PivotId=1,PivotDir=PVT_Down,OffsetYL=4.000000)
	Components(3)=(Id=3,Caption="WindowModeMenu",Type=RES_Text,XL=100.000000,YL=20.000000,PivotDir=PVT_Copy,OffsetXL=213.000000,OffsetYL=78.000000,TextColor=(B=113,G=215,R=241,A=255),LocType=LCT_Setting)
	Components(4)=(Id=4,Caption="On",Type=RES_RadioButton,YL=20.000000,PivotId=3,PivotDir=PVT_Down,OffsetYL=4.000000,TextColor=(B=112,G=158,R=211,A=255),LocType=LCT_Setting)
	Components(5)=(Id=5,Caption="Off",Type=RES_RadioButton,YL=20.000000,PivotId=4,PivotDir=PVT_Right,OffsetXL=20.000000,TextColor=(B=112,G=158,R=211,A=255),LocType=LCT_Setting)
	Components(6)=(Id=6,Caption="SkyMenu",Type=RES_CheckButton,XL=26.000000,YL=23.000000,PivotDir=PVT_Copy,OffsetXL=27.000000,OffsetYL=374.000000,TextColor=(B=112,G=158,R=211,A=255),LocType=LCT_Setting)
	Components(7)=(Id=9,Caption="ShadowMenu",Type=RES_Text,XL=124.000000,YL=14.000000,PivotDir=PVT_Copy,OffsetXL=33.000000,OffsetYL=133.000000,TextColor=(B=113,G=215,R=241,A=255),LocType=LCT_Setting)
	Components(8)=(Id=8,Caption="Low",Type=RES_RadioButton,XL=146.000000,YL=24.000000,PivotId=7,PivotDir=PVT_Down,OffsetYL=4.000000,TextColor=(B=112,G=158,R=211,A=255),LocType=LCT_Setting)
	Components(9)=(Id=9,Caption="Mid",Type=RES_RadioButton,YL=20.000000,PivotId=8,PivotDir=PVT_Right,OffsetXL=20.000000,TextColor=(B=112,G=158,R=211,A=255),LocType=LCT_Setting)
	Components(10)=(Id=10,Caption="High",Type=RES_RadioButton,YL=20.000000,PivotId=9,PivotDir=PVT_Right,OffsetXL=20.000000,TextColor=(B=112,G=158,R=211,A=255),LocType=LCT_Setting)
	Components(11)=(Id=11,Caption="EffectDetailMenu",Type=RES_Text,XL=100.000000,YL=20.000000,PivotDir=PVT_Copy,OffsetXL=213.000000,OffsetYL=133.000000,TextColor=(B=113,G=215,R=241,A=255),LocType=LCT_Setting)
	Components(12)=(Id=12,Caption="EffectBad",Type=RES_TextButton,XL=150.000000,YL=24.000000,PivotId=11,PivotDir=PVT_Down,OffsetYL=4.000000,LocType=LCT_Setting)
	Components(13)=(Id=13,Caption="DeadEffect",Type=RES_CheckButton,XL=26.000000,YL=23.000000,PivotDir=PVT_Copy,OffsetXL=27.000000,OffsetYL=353.000000,TextColor=(B=112,G=158,R=211,A=255),LocType=LCT_Setting)
	Components(14)=(Id=14,Caption="UseGraphicCursorMenu",Type=RES_CheckButton,XL=26.000000,YL=23.000000,PivotDir=PVT_Copy,OffsetXL=208.000000,OffsetYL=374.000000,TextColor=(B=112,G=158,R=211,A=255),LocType=LCT_Setting)
	Components(16)=(Id=16,Caption="FogRatio",Type=RES_Text,XL=124.000000,YL=14.000000,PivotDir=PVT_Copy,OffsetXL=33.000000,OffsetYL=253.000000,TextColor=(B=113,G=215,R=241,A=255),LocType=LCT_Setting)
	Components(18)=(Id=18,Caption="FilterDistanceMenu",Type=RES_Text,XL=100.000000,YL=14.000000,PivotDir=PVT_Copy,OffsetXL=213.000000,OffsetYL=253.000000,TextColor=(B=113,G=215,R=241,A=255),LocType=LCT_Setting)
	Components(32)=(Id=32,Caption="BrightnessMenu",Type=RES_Text,XL=140.000000,YL=20.000000,PivotDir=PVT_Copy,OffsetXL=33.000000,OffsetYL=293.000000,TextColor=(B=113,G=215,R=241,A=255),LocType=LCT_Setting)
	Components(36)=(Id=36,Caption="UITypeMenu",Type=RES_Text,XL=124.000000,YL=14.000000,PivotDir=PVT_Copy,OffsetXL=33.000000,OffsetYL=187.000000,TextColor=(B=113,G=215,R=241,A=255),LocType=LCT_Setting)
	Components(37)=(Id=37,Caption="AType",Type=RES_RadioButton,XL=100.000000,YL=20.000000,PivotId=36,PivotDir=PVT_Down,OffsetYL=4.000000,TextColor=(B=112,G=158,R=211,A=255),LocType=LCT_Setting)
	Components(38)=(Id=38,Caption="BType",Type=RES_RadioButton,YL=20.000000,PivotId=37,PivotDir=PVT_Right,OffsetXL=20.000000,TextColor=(B=112,G=158,R=211,A=255),LocType=LCT_Setting)
	bNeedLayoutUpdate=False
}

class ChannelMenu extends CInterface;

var float VLine;
var string SelectedChannel;
var array<string> ChannelList;
const BN_Ok = 1;
const BN_Cancel = 2;
const BN_Channel = 3;

function OnInit()
{
	local int i;
	SetComponentTextureId(Components[1],1,0,0,2);
	SetComponentTextureId(Components[2],1,0,0,2);
	Components[1].NotifyId = BN_Ok;
	Components[2].NotifyId = BN_Cancel;
	ParseIntoArray(Localize("Information","ChannelList","Sephiroth"), "|", ChannelList);
	Components[5].YL = ChannelList.Length * 14;
	for (i=0;i<ChannelList.Length;i++)
		Components[i+6].NotifyId = BN_Channel+i;
}

function Layout(Canvas C)
{
	local int i;
	MoveComponentId(0,true,0,(C.ClipY-Components[0].YL)/2);
	MoveComponentId(1);
	MoveComponentId(2);
	MoveComponentId(3);
	MoveComponentId(4);
	MoveComponentId(5,true,Components[3].X,Components[3].Y-VLine);
	for (i=0;i<ChannelList.Length;i++)
		MoveComponentId(i+6);
}

function OnPreRender(Canvas C)
{
	local int i;
	local float X,Y;

	for (i=0;i<ChannelList.Length;i++)
		Components[i+6].Caption = ChannelList[i];
	for (i=6+ChannelList.Length;i<Components.Length;i++) {
		Components[i].bVisible = false;
	}
	Components[1].bDisabled = SelectedChannel == "";

	X = Components[3].X;
	Y = Components[3].Y;

	if (Components[6].bSizeCalced && Components[6].bLayout) {
		for (i=0;i<ChannelList.Length;i++) {
			if (Components[i+6].Y < Y || Components[i+6].Y > Y+80)
				Components[i+6].bVisible = false;
			else
				Components[i+6].bVisible = true;
		}
	}
}

function int ParseIntoArray(string Source, string pchDelim, out array<string> InArray)
{
	local int i;
	local string S;

	S = Source;
	i = InStr(S,pchDelim);
	while (i > 0) {
		InArray[InArray.Length] = Caps(Left(S,i));
		S = Mid(S,i+1,Len(S));
		i = InStr(S,pchDelim);
	}
	InArray[InArray.Length] = Caps(S);
	return InArray.Length;
}

function OnPostRender(HUD H, Canvas C)
{
	local float X,Y;
	X = Components[0].X;
	Y = Components[0].Y;
	C.KTextFormat = ETextAlign.TA_MiddleCenter;
	C.SetDrawColor(255,255,0);
	C.DrawKoreanText(Localize("Information","SelectChannel","Sephiroth"),X,Y+27,178,14);

	if (SelectedChannel != "") {
		C.DrawKoreanText(SelectedChannel,X,Y+139,178,15);
	}
}

function NotifyScrollUp(int CmpId,int Amount)
{
	VLine -= Amount*14;
	if (VLine < 0)
		VLine = 0;
}

function NotifyScrollDown(int CmpId,int Amount)
{
	VLine += Amount*14;
	if (VLine >= Components[5].YL - 84)
		VLine = Components[5].YL - 84;
}

function Plane PushComponentPlane(int CmpId)
{
	local Plane P;
	if (CmpId == 4) {
		P.X = ChannelList.Length*14;
		P.Y = 84;
		P.Z = 14;
		P.W = VLine;
	}
	return P;
}

function NotifyComponent(int CmpId,int NotifyId,optional string Command)
{
	if (NotifyId == BN_Cancel)
		Parent.NotifyInterface(Self,INT_Close);
	else if (NotifyId == BN_Ok) {
		if (SelectedChannel != "")
			Parent.NotifyInterface(Self,INT_Command,"SetChannel " $ SelectedChannel);
		Parent.NotifyInterface(Self,INT_Close);
	}
	else if (NotifyId >= BN_Channel && NotifyId < BN_Channel + ChannelList.Length)
		SelectedChannel = ChannelList[NotifyId-BN_Channel];
}

function bool OnKeyEvent(Interaction.EInputKey Key,Interaction.EInputAction Action,float Delta)
{
	if (Action == IST_Press) {
		if (Key == IK_MouseWheelUp) {
			NotifyScrollUp(-1,1);
			return true;
		}
		if (Key == IK_MouseWheelDown) {
			NotifyScrollDown(-1,1);
			return true;
		}
	}
}

defaultproperties
{
     Components(0)=(Type=RES_Image,XL=178.000000,YL=200.000000)
     Components(1)=(Id=1,Caption="Apply",Type=RES_PushButton,XL=67.000000,YL=23.000000,PivotDir=PVT_Copy,OffsetXL=17.000000,OffsetYL=163.000000,TextAlign=TA_MiddleCenter,LocType=LCT_Commands,HotKey=IK_Enter)
     Components(2)=(Id=2,Caption="Close",Type=RES_PushButton,XL=67.000000,YL=23.000000,PivotDir=PVT_Copy,OffsetXL=95.000000,OffsetYL=163.000000,TextAlign=TA_MiddleCenter,LocType=LCT_Commands,HotKey=IK_Escape)
     Components(3)=(Id=3,XL=128.000000,YL=84.000000,PivotDir=PVT_Copy,OffsetXL=18.000000,OffsetYL=49.000000)
     Components(4)=(Id=4,Type=RES_ScrollBar,XL=15.000000,YL=84.000000,PivotId=3,PivotDir=PVT_Right)
     Components(5)=(Id=5,XL=128.000000)
     Components(6)=(Id=6,Type=RES_TextButton,bCalcSize=True,bCalcWidthOnly=True,YL=14.000000,PivotId=5,PivotDir=PVT_Copy,TextAlign=TA_MiddleLeft)
     Components(7)=(Id=7,Type=RES_TextButton,bCalcSize=True,bCalcWidthOnly=True,YL=14.000000,PivotId=6,PivotDir=PVT_Down,TextAlign=TA_MiddleLeft)
     Components(8)=(Id=8,Type=RES_TextButton,bCalcSize=True,bCalcWidthOnly=True,YL=14.000000,PivotId=7,PivotDir=PVT_Down,TextAlign=TA_MiddleLeft)
     Components(9)=(Id=9,Type=RES_TextButton,bCalcSize=True,bCalcWidthOnly=True,YL=14.000000,PivotId=8,PivotDir=PVT_Down,TextAlign=TA_MiddleLeft)
     Components(10)=(Id=10,Type=RES_TextButton,bCalcSize=True,bCalcWidthOnly=True,YL=14.000000,PivotId=9,PivotDir=PVT_Down,TextAlign=TA_MiddleLeft)
     Components(11)=(Id=11,Type=RES_TextButton,bCalcSize=True,bCalcWidthOnly=True,YL=14.000000,PivotId=10,PivotDir=PVT_Down,TextAlign=TA_MiddleLeft)
     Components(12)=(Id=12,Type=RES_TextButton,bCalcSize=True,bCalcWidthOnly=True,YL=14.000000,PivotId=11,PivotDir=PVT_Down,TextAlign=TA_MiddleLeft)
     Components(13)=(Id=13,Type=RES_TextButton,bCalcSize=True,bCalcWidthOnly=True,YL=14.000000,PivotId=12,PivotDir=PVT_Down,TextAlign=TA_MiddleLeft)
     Components(14)=(Id=14,Type=RES_TextButton,bCalcSize=True,bCalcWidthOnly=True,YL=14.000000,PivotId=13,PivotDir=PVT_Down,TextAlign=TA_MiddleLeft)
     Components(15)=(Id=15,Type=RES_TextButton,bCalcSize=True,bCalcWidthOnly=True,YL=14.000000,PivotId=14,PivotDir=PVT_Down,TextAlign=TA_MiddleLeft)
     TextureResources(0)=(Package="UI",Path="Etc.Anim_S00",Style=STY_Alpha)
     TextureResources(1)=(Package="UI",Path="Common.MsgBoxButtonNormal",Style=STY_Alpha)
     TextureResources(2)=(Package="UI",Path="Common.MsgBoxButtonOver",Style=STY_Alpha)
}

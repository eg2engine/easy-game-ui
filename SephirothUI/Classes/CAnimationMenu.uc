class CAnimationMenu extends CInterface;

const AnimSize = 13;
const BN_Anim = 1;
const BN_EXIT = 100;

var float VLine;
var array<name> Anims;

function OnInit()
{
	local int i;
	for (i=0;i<AnimSize;i++)
		Components[i+3].NotifyId = BN_Anim+i;
	Components[1].YL = AnimSize*18;

	SetComponentTextureId(Components[16],1,-1,1,2);
	SetComponentNotify(Components[16], BN_EXIT, Self);
}

function Layout(Canvas C)
{
	local int i;
	MoveComponentId(0,true,C.ClipX-180,C.ClipY-202);
	MoveComponentId(2);
	MoveComponentId(1,true,Components[0].X+15,Components[0].Y+10-VLine);
	for (i=0;i<AnimSize;i++)
		MoveComponentId(i+3);

	MoveComponentId(16);
}

function bool OnKeyEvent(Interaction.EInputKey Key,Interaction.EInputAction Action,float Delta)
{
	if (Key == IK_Escape && Action == IST_Press) {
		Parent.NotifyInterface(Self,INT_Close);
		return true;
	}
/*
	if (Key == IK_LeftMouse && !IsCursorInsideComponent(Components[0])) {		//modified by yj  //없는게 나을 듯
		Parent.NotifyInterface(Self,INT_Close);
		return false;
	}
*/
	
	if (Action == IST_Press && IsCursorInsideComponent(Components[0])) {
		if (Key == IK_MouseWheelUp) {
			NotifyScrollUp(-1,1);
			return true;
		}
		if (Key == IK_MouseWheelDown) {
			NotifyScrollDown(-1,1);
			return true;
		}
	}
	if (Key == IK_LeftMouse && IsCursorInsideComponent(Components[0]))
		return true;
}

function NotifyScrollUp(int CmpId,int Amount)
{
	VLine -= Amount*18;
	if (VLine < 0)
		VLine = 0;
}

function NotifyScrollDown(int CmpId,int Amount)
{
	VLine += Amount*18;
	if (VLine >= Components[1].YL - 162)
		VLine = Components[1].YL - 162;
}

function Plane PushComponentPlane(int CmpId)
{
	local Plane P;
	if (CmpId == 2) {
		P.X = AnimSize*18;
		P.Y = 162;
		P.Z = 18;
		P.W = VLine;
	}
	return P;
}

function OnPreRender(Canvas C)
{
	local int i;
	local float X,Y;

	X = Components[0].X;
	Y = Components[0].Y;

	if (Components[3].bSizeCalced && Components[3].bLayout) {
		for (i=0;i<AnimSize;i++) {
			if (Components[i+3].Y < Y+27 || Components[i+3].Y > Y+27+162)
				Components[i+3].bVisible = false;		//Sephiroth가 안 보일 때, \키가 안먹는 이유.
			else
				Components[i+3].bVisible = true;
		}
	}
}
function OnPostRender(HUD H, Canvas C)
{
	local int X,Y;
	local color OldColor;
	OldColor = C.DrawColor;

	X = Components[0].X;
	Y = Components[0].Y;

	C.KTextFormat = ETextAlign.TA_MiddleCenter;
	C.SetDrawColor(229,231,174);
	C.DrawKoreanText(Localize("AnimationMenuUI","AnimationMenu","SephirothUI"),X,Y+2,Components[0].XL,20);
	
	C.DrawColor = OldColor;
}

function NotifyComponent(int CmpId,int NotifyId,optional string Command)
{
	if (NotifyId >= BN_Anim && NotifyId < BN_Anim + AnimSize)
		SephirothPlayer(PlayerOwner).PlaySocialAnim(Anims[NotifyID-BN_Anim],1,0.3);

	else if(NotifyId == BN_EXIT)
		Parent.NotifyInterface(Self,INT_Close);
}

defaultproperties
{
     Anims(0)="Hi"
     Anims(1)="CharmingHi"
     Anims(2)="YesSir"
     Anims(3)="Smile"
     Anims(4)="Cry"
     Anims(5)="YooHoo"
     Anims(6)="Sorry"
     Anims(7)="DullTime"
     Anims(8)="Anger"
     Anims(9)="Kiss"
     Anims(10)="LoveYou"
     Anims(11)="Rush"
     Anims(12)="Sephiroth"
     Components(0)=(Type=RES_Image,XL=184.000000,YL=206.000000)
     Components(1)=(Id=1,XL=184.000000,YL=206.000000)
     Components(2)=(Id=2,Type=RES_ScrollBar,XL=16.000000,YL=162.000000,PivotDir=PVT_Copy,OffsetXL=157.000000,OffsetYL=28.000000)
     Components(3)=(Id=3,Caption="Hi",Type=RES_TextButton,bCalcSize=True,PivotId=1,PivotDir=PVT_Copy,LocType=LCT_User,LocalizeSection="SocialAnimation",HotKey=IK_1)
     Components(4)=(Id=4,Caption="CharmingHi",Type=RES_TextButton,bCalcSize=True,PivotId=3,PivotDir=PVT_Down,OffsetYL=3.000000,LocType=LCT_User,LocalizeSection="SocialAnimation",HotKey=IK_2)
     Components(5)=(Id=5,Caption="YesSir",Type=RES_TextButton,bCalcSize=True,PivotId=4,PivotDir=PVT_Down,OffsetYL=3.000000,LocType=LCT_User,LocalizeSection="SocialAnimation",HotKey=IK_3)
     Components(6)=(Id=6,Caption="Smile",Type=RES_TextButton,bCalcSize=True,PivotId=5,PivotDir=PVT_Down,OffsetYL=3.000000,LocType=LCT_User,LocalizeSection="SocialAnimation",HotKey=IK_4)
     Components(7)=(Id=7,Caption="Cry",Type=RES_TextButton,bCalcSize=True,PivotId=6,PivotDir=PVT_Down,OffsetYL=3.000000,LocType=LCT_User,LocalizeSection="SocialAnimation",HotKey=IK_5)
     Components(8)=(Id=8,Caption="YooHoo",Type=RES_TextButton,bCalcSize=True,PivotId=7,PivotDir=PVT_Down,OffsetYL=3.000000,LocType=LCT_User,LocalizeSection="SocialAnimation",HotKey=IK_6)
     Components(9)=(Id=9,Caption="Sorry",Type=RES_TextButton,bCalcSize=True,PivotId=8,PivotDir=PVT_Down,OffsetYL=3.000000,LocType=LCT_User,LocalizeSection="SocialAnimation",HotKey=IK_7)
     Components(10)=(Id=10,Caption="DullTime",Type=RES_TextButton,bCalcSize=True,PivotId=9,PivotDir=PVT_Down,OffsetYL=3.000000,LocType=LCT_User,LocalizeSection="SocialAnimation",HotKey=IK_8)
     Components(11)=(Id=11,Caption="Anger",Type=RES_TextButton,bCalcSize=True,PivotId=10,PivotDir=PVT_Down,OffsetYL=3.000000,LocType=LCT_User,LocalizeSection="SocialAnimation",HotKey=IK_9)
     Components(12)=(Id=12,Caption="Kiss",Type=RES_TextButton,bCalcSize=True,PivotId=11,PivotDir=PVT_Down,OffsetYL=3.000000,LocType=LCT_User,LocalizeSection="SocialAnimation",HotKey=IK_0)
     Components(13)=(Id=13,Caption="LoveYou",Type=RES_TextButton,bCalcSize=True,PivotId=12,PivotDir=PVT_Down,OffsetYL=3.000000,LocType=LCT_User,LocalizeSection="SocialAnimation",HotKey=IK_Minus)
     Components(14)=(Id=14,Caption="Rush",Type=RES_TextButton,bCalcSize=True,PivotId=13,PivotDir=PVT_Down,OffsetYL=3.000000,LocType=LCT_User,LocalizeSection="SocialAnimation",HotKey=IK_Equals)
     Components(15)=(Id=15,Caption="Sephiroth",Type=RES_TextButton,bCalcSize=True,PivotId=14,PivotDir=PVT_Down,OffsetYL=3.000000,LocType=LCT_User,LocalizeSection="SocialAnimation",HotKey=IK_Backslash)
     Components(16)=(Id=16,Type=RES_PushButton,XL=14.000000,YL=13.000000,PivotDir=PVT_Copy,OffsetXL=158.000000,OffsetYL=6.000000,HotKey=IK_Escape)
     TextureResources(0)=(Package="UI_2011",Path="win_action",Style=STY_Alpha)
     TextureResources(1)=(Package="UI_2011_btn",Path="btn_x_n",Style=STY_Alpha)
     TextureResources(2)=(Package="UI_2011_btn",Path="btn_x_o",Style=STY_Alpha)
}

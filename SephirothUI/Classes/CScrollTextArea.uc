class CScrollTextArea extends CTextArea;

var float VLine;
var float PageX, PageY;

function SetPosition(float Sx,float Sy)
{
	PageX = Sx;
	PageY = Sy;
}

function CopyTexts(array<string> InTexts)
{
	Super.CopyTexts(InTexts);
	Components[2].YL = 14 * Texts.Length;
	Components[0].XL= PageWidth;
	Components[0].YL = PageHeight;
	Components[1].YL = PageHeight;
	VLine = 0;
}

function Layout(Canvas C)
{
	MoveComponentId(0,true,PageX,PageY);
	MoveComponentId(1);
	MoveComponentId(2,true,Components[0].X,Components[0].Y-VLine);
}

function OnPreRender(Canvas C)
{
	Components[1].bVisible = Texts.Length > 0;
}

function OnPostRender(HUD H, Canvas C)
{
	local int i;
	local float X,Y,Y2;
	C.KTextFormat = ETextAlign.TA_MiddleLeft;
	X = Components[2].X;
	Y = Components[2].Y;
	Y2 = Components[0].Y;
	for (i=0;i<Texts.Length;i++)
		if (Y+i*14 >= Y2 && Y+i*14 < Y2+PageHeight)
			C.DrawKoreanText(Texts[i],X,Y+i*14,460,13);


}

function NotifyScrollUp(int CmpId,int Amount)
{
	VLine -= Amount*14;
	if (VLine < 0)
		VLine = 0;
}

function NotifyScrollDown(int CmpId,int Amount)
{
	if (Texts.Length < PageHeight / 14)
		return;
	VLine += Amount*14;
	if (VLine >= Components[2].YL - PageHeight)
		VLine = Components[2].YL - PageHeight;
}

function Plane PushComponentPlane(int CmpId)
{
	local Plane P;
	P.X = Texts.Length*14;
	P.Y = PageHeight;
	P.Z = 14;
	P.W = VLine;
	return P;
}

function bool OnKeyEvent(Interaction.EInputKey Key,Interaction.EInputAction Action,float Delta)
{
	if (Action == IST_Press) {
		if (IsCursorInsideComponent(Components[0])) {
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
}

defaultproperties
{
     PageWidth=450.000000
     PageHeight=290.000000
     Components(0)=(XL=450.000000,YL=270.000000)
     Components(1)=(Id=1,Type=RES_ScrollBar,XL=15.000000,YL=270.000000,PivotDir=PVT_Right,OffsetXL=1.000000)
     Components(2)=(Id=2,XL=450.000000)
}

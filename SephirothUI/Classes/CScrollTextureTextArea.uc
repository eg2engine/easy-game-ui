class CScrollTextureTextArea extends CScrollTextArea;

var array<Texture> Textures;
var int TextureHeight;
var int TextureU;
var int TextureV;
var array<Texture> DynamicTextures;
var int ScrollBarOffsetXL;	//스크롤바를 변수를 통해 이동시키기 위해 사용합니다. 2009.10.27.Sinhyub

//여러 texture를 로드해서 붙여 넣기 위해서 아래와 같이 놔두었지만, 하나의 texture만을 사용하는 것으로 정해진다면 굳이 이렇게 할 필요는 없습니다.
final function Texture LoadDynamicTexture(string TextureName)
{
	local Texture T;
	local int i;
	T = Texture(DynamicLoadObject(TextureName,class'Texture'));
	if (T != None) {
		for (i=0;i<DynamicTextures.Length;i++)
			if (T == DynamicTextures[i])
				break;
		if (i == DynamicTextures.Length) {
			T.AddReference();
			DynamicTextures[i] = T;
		}
	}
	return T;
}
final function FlushDynamicTextures()
{
	local int i,count;

	count = DynamicTextures.Length;
	for (i=0;i<DynamicTextures.Length;i++) {
		if (DynamicTextures[i] != None) {
			UnloadTexture(Viewport(PlayerOwner.Player),DynamicTextures[i]);
		}
	}
	DynamicTextures.Remove(0,count);
}

function LoadTexture(string name)
{
	local Texture TextureSegment;

	Textures.Remove(0,Textures.Length);
	TextureSegment = LoadDynamicTexture(name);

	if(TextureSegment != None)
		Textures[Textures.Length] = TextureSegment;

/*
	while (TextureSegment != None) {
		Index++;
		Textures[Textures.Length] = TextureSegment;
		TextureSegment = LoadDynamicTexture("UI_Example.EX001");
	}
*/

	TextureU = 0;
	TextureV = 0;

}

function SetPosition(float Sx,float Sy)
{
	PageX = Sx;
	PageY = Sy;
}

function SetTextArea(int Width, int Height)
{
	PageWidth = Width;
	PageHeight = Height;
}

function CopyTexts(array<string> InTexts)
{
	Super.CopyTexts(InTexts);
	Components[3].YL = 14 * Texts.Length;

	Components[0].XL= PageWidth;
	Components[0].YL = PageHeight;
	Components[2].YL= PageHeight;
//	Components[1].YL = PageHeight;

	VLine = 0;
	TextureV = 0;
}

function WrapText(string InText)		//modified by yj    //override시킨다.(MaxWidth를 조절)
{
	local float MaxWidth;
	local int WrapPos;
	local string InRow,OutRow;

	MaxWidth = Components[3].XL;
	InRow = InText;
	WrapPos = GetWrapPos(InRow,MaxWidth);
	while (WrapPos != -1) {
		OutRow = SplitRowAt(InRow,WrapPos);
		Texts[Texts.Length] = InRow;
		MaxWidth = Components[3].XL;
		WrapPos = GetWrapPos(OutRow,MaxWidth);
		InRow = OutRow;
	}
	Texts[Texts.Length] = InRow;
}

function Layout(Canvas C)
{
	MoveComponentId(0,true,PageX,PageY);
	MoveComponentId(1);
	MoveComponentId(2);
	MoveComponentId(3,true,Components[0].X+10,Components[0].Y-VLine);
//	Components[1].OffsetXL = ScrollBarOffsetXL;	//스크롤바를 변수를 통해 이동시키기 위해 사용합니다. 2009.10.27.Sinhyub
}

function OnPreRender(Canvas C)
{
	local color OldColor;

	local int i;
	local float YL;
	local float BufferStart, BufferLength;
	local float DrawStart, DrawLength;	
	local InterfaceRegion Frame;

	Oldcolor=C.DrawColor;
		
	Frame.X = Components[2].X;
	Frame.Y = Components[2].Y;
	Frame.W = Components[2].XL;
	Frame.H = Components[2].YL;

	BufferStart = Frame.Y - TextureV;
	BufferLength = TextureHeight;

	C.SetRenderStyleAlpha();
	for (i=0;i<Textures.Length;i++) {
		DrawStart = BufferStart + i * 350;
		DrawLength = min(350, Frame.Y+Frame.H - DrawStart);
		C.SetPos(Frame.X, max(DrawStart, Frame.Y));
		if (DrawStart < Frame.Y)
			YL = DrawLength - (Frame.Y - DrawStart);
		else
			YL = DrawLength;
		if (YL > 0)
			C.DrawTile(Textures[i], 380, YL, TextureU, DrawLength - YL, 380, YL);
	}
	
//	Components[1].bVisible = Texts.Length > 0;
	Components[1].bVisible = false;
	Components[1].bActive = false;


	C.DrawColor=Oldcolor;


}

function OnPostRender(HUD H, Canvas C)
{
	local int i;
	local float X,Y,Y2;
	local color OldColor;

	Oldcolor=C.DrawColor;
	C.SetDrawColor(255, 255, 255);
	C.KTextFormat = ETextAlign.TA_MiddleLeft;
	X = Components[3].X;
	Y = Components[3].Y;
	Y2 = Components[0].Y;
	for (i=0;i<Texts.Length;i++)
		if (Y+i*14 >= Y2 && Y+i*14 < Y2+PageHeight)
			C.DrawKoreanText(Texts[i],X,Y+i*14,PageWidth,14);

	C.DrawColor=Oldcolor;
}

function NotifyScrollUp(int CmpId,int Amount)
{
	VLine -= Amount*14;
	if (VLine < 0)
		VLine = 0;
	TextureV -= Amount*14;
	if (TextureV < 0)
		TextureV = 0;
}

function NotifyScrollDown(int CmpId,int Amount)
{
	if (Texts.Length < PageHeight / 14)
		return;
	VLine += Amount*14;
	if (VLine >= Components[3].YL - PageHeight)
		VLine = Components[3].YL - PageHeight;
	TextureV += Amount*14;
	if (TextureV >= Components[3].YL - PageHeight)
		TextureV = Components[3].YL - PageHeight;
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

function OnFlush()
{
	FlushDynamicTextures();
}

defaultproperties
{
     ScrollBarOffsetXL=-15
     PageWidth=380.000000
     PageHeight=340.000000
     Components(0)=(XL=380.000000,YL=350.000000)
     Components(2)=(XL=380.000000,YL=350.000000,PivotDir=PVT_Copy)
     Components(3)=(Id=3,XL=360.000000)
}

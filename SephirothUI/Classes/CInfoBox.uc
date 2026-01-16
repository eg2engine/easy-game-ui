class CInfoBox extends CAlignTextList;

#exec TEXTURE IMPORT NAME=TextBlackBg FILE=Textures/Black90Alpha.tga

var Object Source;
var float PivotSpace, LeftSpace, RightSpace;
var array<color> EdgeColors;
var Object RefObject;	// keios - 어떤놈이 Info를 세팅했는지 참조용

delegate OnSourceChange(Object Obj);

function OnInit()
{
	OnDrawBackground = InternalDrawBackground;
	OnDrawText = InternalDrawText;
}

function SetInfo(Object Obj, optional float X, optional float Y, optional bool bClipCheck, optional float ClipX, optional float ClipY)
{
	local int i;
	local float LXL, LYL, RXL, RYL, XL, YL, MaxXL, TempYL;
	local array<string> Columns;
	local string LeftStr, RightStr;

	if ( Obj != None && Source != Obj )	{

		Source = Obj;
		LeftSpace = 0;
		RightSpace = 0;
		OnSourceChange(Obj);
		ShowInterface();

		for ( i = 0 ; i < Elements.Length ; i++ )	{

			Columns.Remove(0, Columns.Length);
			class'CNativeInterface'.static.WrapStringToArray(Elements[i].strText, Columns, 10000, ":");

			if ( Columns.Length > 1 )	{

				LeftStr = Columns[0];
				RightStr = Columns[1];

				if ( LeftStr != "" )
					class'CNativeInterface'.static.TextSize(LeftStr, LXL, LYL);

				if ( RightStr != "" )
					class'CNativeInterface'.static.TextSize(RightStr, RXL, RYL);

				if ( LeftSpace < LXL)
					LeftSpace = LXL;

				if (RightSpace < RXL)
					RightSpace = RXL;

				if ( MaxXL < LeftSpace + PivotSpace + RightSpace)
					MaxXL = LeftSpace + PivotSpace + RightSpace;
			}
			else	{

//				class'CNativeInterface'.static.TextSize(Elements[i].strText, XL, YL);
				class'CNativeInterface'.static.TextSize(Elements[i].strText, XL, TempYL);

				if( TempYL != 0 )
					YL = TempYL;

				if ( MaxXL < XL )
					MaxXL = XL;
			}
		}

		ItemsPerPage = Elements.Length;
		ItemHeight = YL;

		SetSize(MaxXL + MarginWidth * 2, Elements.Length * ItemHeight + MarginHeight * 2);

		if ( bClipCheck )	{

			if ( X + WinWidth > ClipX )
				X = ClipX - WinWidth;

			if ( Y + WinHeight > ClipY )
				Y = ClipY - WinHeight;
		}

		SetPos(X, Y);
	}
	else if ( Obj == None )	{

		Source = None;
		HideInterface();	//Check Later
	}
}

function InternalDrawText(Canvas C, int Index, string Item, float X, float Y, float Width, float Height, bool bSelected)
{
	local array<string> Columns;
	local string LeftStr, RightStr;

	C.WrapStringToArray(Item, Columns, 10000, ":");
	if (Columns.Length > 1) {
		LeftStr = Columns[0];
		RightStr = Columns[1];
		if (LeftStr != "")
			C.DrawTextJustified(LeftStr, 2, X, Y, X+LeftSpace, Y+Height);
		if (RightStr != "")
			C.DrawTextJustified(RightStr, 0, X+LeftSpace+PivotSpace, Y, X+Width, Y+Height);
	}
	else
		C.DrawTextJustified(Item, 1, X, Y, X+Width, Y+Height);
}

function DrawRaisedRectangle(float X, float Y, float W, float H, int LineWidth, array<color> Colors)
{
	local int i;
	for (i=0;i<LineWidth;i++)
		class'CNativeInterface'.static.DrawLine(X+i, Y+i, X+i, Y+i+H, Colors[i]);
	for (i=0;i<LineWidth;i++)
		class'CNativeInterface'.static.DrawLine(X+i, Y+i, X+i+W, Y+i, Colors[i]);
	for (i=0;i<LineWidth;i++)
		class'CNativeInterface'.static.DrawLine(X+i, Y+i+H, X+i+W, Y+i+H, Colors[i]);
	for (i=0;i<LineWidth;i++)
		class'CNativeInterface'.static.DrawLine(X+i+W, Y+i, X+i+W, Y+i+H, Colors[i]);
}

function InternalDrawBackground(Canvas C)
{
	C.SetRenderStyleAlpha();
	C.SetPos(WinX, WinY);
	C.DrawTile(Texture'TextBlackBg',WinWidth, WinHeight,0,0,4,4);

	DrawRaisedRectangle(WinX, WinY, WinWidth, WinHeight, EdgeColors.Length, EdgeColors);
}

defaultproperties
{
     PivotSpace=10.000000
     EdgeColors(0)=(B=113,G=113,R=114,A=255)
     EdgeColors(1)=(B=48,G=50,R=55,A=255)
     EdgeColors(2)=(B=16,G=19,R=20,A=255)
     MarginWidth=4.000000
     MarginHeight=6.000000
     TextColor=(B=128,G=128,R=128)
     bWrapText=False
     bNoWheelScroll=True
     bTopmost=True
}

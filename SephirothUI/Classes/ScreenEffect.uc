class ScreenEffect	extends CMultiInterface;

var Color BgColor;
var int TickCount;
var int MaxCount;
var byte FadeRange;
var float StartTime;
var float ShowTime;
var ConstantColor BgMaterial;
var FinalBlend BgBlend;
var byte StartAlpha;

function OnInit()
{
	StartTime = PlayerOwner.Level.TimeSeconds;
	BgMaterial = new(none) class'ConstantColor';
	BgBlend = new(none) class'FinalBlend';

	BgBlend.Material = BgMaterial;
	BgBlend.FrameBufferBlending = BgBlend.EFrameBufferBlending.FB_AlphaBlend;
}

function OnFlush()
{
	if(BgMaterial != None)
	{
		DynamicUnloadObject(BgMaterial);
		BgMaterial = None;
	}
	if(BgBlend != None)
	{
		DynamicUnloadObject(BgBlend);
		BgBlend = None;
	}
}

event Destroyed()
{
	Super.Destroyed();
	if(BgMaterial != None)
	{
		DynamicUnloadObject(BgMaterial);
		BgMaterial = None;
	}
	if(BgBlend != None)
	{
		DynamicUnloadObject(BgBlend);
		BgBlend = None;
	}
}

function SetScreenEffect(byte R, byte G, byte B, byte A, optional int Count, optional float Time, optional byte Range)
{
	//BgColor = EffectColor;
	BgColor.R = R; BgColor.G = G; BgColor.B = B; BgColor.A = A;
	StartAlpha = A;
	MaxCount = Count;
	ShowTime = Time;
	TickCount = 0;
	FadeRange = Range;
}

event Tick(float DeltaSecond)
{
	local float CurTime;
	Super.Tick(DeltaSecond);
	CurTime = PlayerOwner.Level.TimeSeconds;
	if(ShowTime != 0 && CurTime - StartTime >= ShowTime){
		Parent.NotifyInterface(Self, INT_Close);
	}
	if(MaxCount != 0 && TickCount == MaxCount)
		Parent.NotifyInterface(Self, INT_Close);
}

function OnPostRender(HUD H, Canvas C)
{
	local float CurTime;
	local byte Alpha;

	CurTime = PlayerOwner.Level.TimeSeconds;
	BgMaterial.Color = BgColor;
	C.SetPos(0,0);
	C.DrawTile(BgBlend,C.ClipX,C.ClipY,0,0,0,0);
	if(FadeRange != 0){
		if(ShowTime != 0){
			Alpha = StartAlpha - byte(FadeRange * (((CurTime - StartTime)* 100) / (ShowTime * 100)));
		}
		else if(MaxCount != 0){
			Alpha = StartAlpha - byte(FadeRange * (TickCount / MaxCount));
		}
		else
			Alpha = StartAlpha - 1;
		BgColor.A = Clamp(Alpha, 0, 255);
	}
	TickCount++;
}

defaultproperties
{
     BgColor=(B=255,G=255,R=255,A=255)
}

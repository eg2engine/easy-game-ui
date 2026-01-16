class CEventAlarmDlg extends CInterface;

var float m_fStartTime;
var float m_fLifeTime;
var string m_sDesc;
var array<string> m_sMsg;
var color m_color;

var int m_nHeight;
var const float m_fLifeSec;
var const float m_fScrOffX;
var const float m_fScrOffY;

static function CEventAlarmDlg OnDlg(CMultiInterface Parent, string sMsg, color color)
{
	local CEventAlarmDlg dlg;

	dlg = CEventAlarmDlg(Parent.Controller.HudInterface.AddInterface("SephirothUI.CEventAlarmDlg", false));
	if(dlg != None)
	{
		dlg.ShowInterface();
		dlg.SetData(sMsg, color);
	}

	return dlg;
}

function CloseDlg()
{
	HideInterface();
	CMultiInterface(Parent).RemoveInterface(Self);
}

function SetData(string sMsg, color color)
{
    m_fStartTime = Level.TimeSeconds;
    m_fLifeTime = m_fStartTime + m_fLifeSec;
    m_sDesc = sMsg;
    m_color = color;
}

function Layout(Canvas C)
{
    if(m_sMsg.Length == 0)
    {
   	    //C.WrapStringToArray(m_sDesc, m_sMsg, Components[0].XL, "|");
		C.WrapStringToArray(m_sDesc, m_sMsg, Components[0].XL, "|");
   	    m_nHeight = m_sMsg.Length * 16 + 10;
   	}

    Components[0].YL = m_sMsg.Length * 16;
	MoveComponent(Components[0], true, (C.ClipX - Components[0].XL - m_fScrOffX), (C.ClipY - Components[0].YL) - m_fScrOffY);
}

function Tick(float DeltaTime)
{
    if(Level.TimeSeconds > m_fLifeTime)
        CloseDlg();
}

function OnPostRender(HUD H, Canvas C)
{
	local int i, X, Y, nAlpha;
	
	X = Components[0].X;
	Y = Components[0].Y;
	
	nAlpha = Min(155 * (Level.TimeSeconds - m_fStartTime), 155);
    C.SetDrawColor(255,255,255,nAlpha);
    C.SetPos(X, Y);
    C.DrawTile(TextureResources[0].Resource,246,m_nHeight,0,0,246,200);

    C.SetDrawColor(m_color.R,m_color.G,m_color.B,nAlpha);
	for(i=0; i<m_sMsg.Length; i++)
		C.DrawKoreanText(m_sMsg[i], X+5, Y+(i*16)+5, Components[0].XL, 16);

	C.SetDrawColor(255,255,255);
}

defaultproperties
{
     m_fLifeSec=30.000000
     m_fScrOffX=4.000000
     m_fScrOffY=110.000000
     Components(0)=(XL=246.000000,YL=100.000000)
     TextureResources(0)=(Package="UI_2011",Path="win_pop_s",Style=STY_Alpha)
}

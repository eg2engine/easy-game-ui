class CColorTextArea extends CTextArea;

var int m_nPosX, m_nPosY;
var bool m_bKeywordChecked;
var int m_nKeyWordCnt;

struct KWData
{
	var string sKeyWord;
	var int ColorIdx;
};

var array<KWData> KeyWords;

function SetTextArea(int nX, int nY, int nWidth, int nHeight)
{
	m_nPosX = nX;
	m_nPosY = nY;
	PageWidth = nWidth;
	PageHeight = nHeight;

	Components[1].XL = nWidth;
}

function CopyTexts(array<string> InTexts)
{
	Super.CopyTexts(InTexts);

	Components[0].XL= PageWidth;
	Components[0].YL = PageHeight;
	Components[1].YL = 14 * Texts.Length;
}

function Layout(Canvas C)
{
	MoveComponentId(0,true,m_nPosX,m_nPosY);
	MoveComponentId(1,true,Components[0].X,Components[0].Y);
}

function OnPreRender(Canvas C)
{
/*
	// Ű���� ����
	if(!m_bKeywordChecked) // Ű���尡 �ƿ� ������ ��� �� ���ɼ��� �ִ�
	{
		sKey = "RGB@";

		X = Components[1].X;
		Y = Components[1].Y;
		Y2 = Components[0].Y;

		for (i=0;i<Texts.Length;i++)
		{
			if (Y+i*14 >= Y2 && Y+i*14 < Y2+PageHeight)
			{
				if(InStr(Texts[i], sKey) != -1) // Ű���� �߰�!
				{
					sTemp = Mid(Texts[i], Len(sKey) + 2, Len(Texts[i]));
// �ؽ�Ʈ�� ���� �ٲٴ� Ű�� �ֱ�
//					//Log("neive : check Get Key Word " $ sTemp);

					KeyWords[m_nKeyWordCnt].sKeyWord = sTemp;
					KeyWords[m_nKeyWordCnt].ColorIdx = m_nKeyWordCnt;
					m_nKeyWordCnt++;

					Texts[i] = "";
				}
			}
		}
	}

	if(m_nKeyWordCnt > 0)
		m_bKeywordChecked = true;
*/
}

function OnPostRender(HUD H, Canvas C)
{
	local int i;
	local float X,Y,Y2;


	C.KTextFormat = ETextAlign.TA_MiddleLeft;
	X = Components[1].X;
	Y = Components[1].Y;
	Y2 = Components[0].Y;
	for (i=0;i<Texts.Length;i++)
	{
		if (Y+i*14 >= Y2 && Y+i*14 < Y2+PageHeight)
		{
			C.SetDrawColor(255, 255, 255, 255);
			C.DrawKoreanText(Texts[i],X,Y+i*14,460,13);
/*
			for(j=0; j<=KeyWords.Length; j++)
			{
				ln = InStr(Texts[i], KeyWords[j].sKeyWord);
				if(ln != -1)
				{
					switch(KeyWords[j].ColorIdx)
					{
					case 1:
						C.SetDrawColor(255, 0, 255, 255);
						break;
					case 2:
						C.SetDrawColor(255, 255, 0, 255);
						break;
					case 3:
						C.SetDrawColor(255, 0, 0, 255);
						break;
					}	
					C.DrawKoreanText(KeyWords[j].sKeyWord,X+ln*4,Y+i*14,460,13);
				}
			}

*/
		}
	}

	C.SetDrawColor(255, 255, 255, 255);
}

defaultproperties
{
     PageWidth=463.000000
     PageHeight=270.000000
     Components(0)=(XL=460.000000,YL=270.000000)
     Components(1)=(Id=1,XL=460.000000)
}

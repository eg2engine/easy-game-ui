class CQuestBrowser extends CInterface;

const MAX_SHOW_NUM = 5;

var int bAlphaDir;				// 알파값이 커지는 중 (0) or 작아지는 중 (1)
var int nPointAlpha;			// 맵창에 띄워질 포인트의 알파 (깜빡이 효과를 위해 만듬)

var bool bOnTimeClear;

function OnInit()
{

}

function OnFlush()
{

}

function OnPreRender(Canvas C)
{
	local int i;

	if(bOnTimeClear)
	{
		for(i=0; i<SephirothPlayer(PlayerOwner).LiveQuests.Length; i++)
			if(SephirothPlayer(PlayerOwner).LiveQuests[i].bShowMain)
				SephirothPlayer(PlayerOwner).LiveQuests[i].bShowMain = false;

		bOnTimeClear = false;
	}
}

function OnPostRender(HUD H, Canvas C)
{
	local int i, nAlpha;
	local float X,Y,XL,YL,YLine, AddY;
	local string sDesc, sTemp;
	local int nShowNum;

	X = Components[0].X;
	Y = Components[0].Y;
	XL = Components[0].XL;
	YL = Components[0].YL;

//	C.SetPos(X, Y);
//	C.DrawRect1fix(XL, YL);

	C.KTextFormat = ETextAlign.TA_MiddleLeft;

	// 알파 깜빡이게 ------------------------------------------------------
	if(bAlphaDir == 1)
	{
		if(nPointAlpha > 235)
			nPointAlpha -= 1;
		else		
			bAlphaDir = 0;
	}
	else
	{
		if(nPointAlpha < 255)
			nPointAlpha += 1;
		else
			bAlphaDir = 1;
	}
	//---------------------------------------------------------------------


	if(SephirothPlayer(PlayerOwner).LiveQuests.Length != 0)
	{
		YLine = 0;
		for(i=0; i<SephirothPlayer(PlayerOwner).LiveQuests.Length; i++)
		{
			if(nShowNum > MAX_SHOW_NUM)	// 보여질 갯수 오버하면 패스
				break;
				
			if(SephirothPlayer(PlayerOwner).LiveQuests[i].bShowMain)
			{
				if(SephirothPlayer(PlayerOwner).LiveQuests[i].nStepValue == 0)
					SephirothPlayer(PlayerOwner).LiveQuests[i].bShowMain = false;

				if(Level.TimeSeconds - SephirothPlayer(PlayerOwner).LiveQuests[i].nLastUpdateTime < 1)
					nAlpha = 155 + (nPointAlpha*20);
				else
					nAlpha = 255;

				// 심플 제목
				C.SetDrawColor(245,197,71,nAlpha);
				//sTemp = SephirothPlayer(PlayerOwner).LiveQuests[i].strHudTitle;
				sTemp = SephirothPlayer(PlayerOwner).LiveQuests[i].Name; //cs changed
				if(sTemp == ""){
					//SephirothPlayer(PlayerOwner).Net.NotiQuestInfo();   //삿혤훨蛟榴檄 cs changed
					//sTemp = "None Desc";
				}
				AddY = DrawKoreanTextMultiLine(C,X,Y+YLine,XL,14,0,18,sTemp);
				//PlayerOwner.myHud.AddMessage(1,"quest strHudTitle:"@SephirothPlayer(PlayerOwner).LiveQuests[i].strHudTitle,class'Canvas'.static.MakeColor(200,100,200));
				//C.DrawKoreanText(sTemp,X,Y+YLine,XL,14);
				YLine += AddY + 14;

				// 심플 설명
				//C.DrawKoreanText(SephirothPlayer(PlayerOwner).LiveQuests[i].strHudTitle, X, Y+YLine, XL, 14); YLine += 15;
				C.SetDrawColor(148,194,230,nAlpha);
				//sDesc = SephirothPlayer(PlayerOwner).LiveQuests[i].strHudDesc;
				//sDesc = SephirothPlayer(PlayerOwner).LiveQuests[i].CurrentStep;//cs changed
				sDesc = SephirothPlayer(PlayerOwner).LiveQuests[i].NextStep;
//				nCur = SephirothPlayer(PlayerOwner).LiveQuests[i].nProgessCount - 1; // sd 상의 정의에 의해 -1 해줘야 숫자가 맞다
//				nMax = SephirothPlayer(PlayerOwner).LiveQuests[i].nHudMax;
//				if(nMax > 0 && nCur != -1 && nCur < 200)
//y					sDesc = sDesc $ " (" $ nCur $ "/" $ nMax $ ")";
				//C.DrawKoreanText(">" $ sDesc $ " (" $ nCur $ "/" $ nMax $ ")", X, Y+YLine, XL, 14);
				AddY = DrawKoreanTextMultiLine(C,X,Y+YLine,XL,14,0,18,">" $ sDesc);
				YLine += AddY + 14 + 7;
				
				++nShowNum;
			}

			if(YLine > YL)
				break;
		}
	}

	C.DrawColor.A = 255;
}

function bool PointCheck()
{
//	if(IsCursorInsideAt(Components[1].X, Components[1].Y, 32, 32))
//		return true;

	return false;
}

function Layout(Canvas C)
{
	MoveComponent(Components[0],true,C.ClipX-Components[0].XL-45,C.ClipY-Components[0].YL-100);

}

function bool IsCursorInsideInterface()
{
	return false;
//	return IsCursorInsideAt(Components[3].X, Components[3].Y, SephirothPlayer(PlayerOwner).PSI.EnchantMagics.Length * 35, 34);
}

defaultproperties
{
     nPointAlpha=235
     bOnTimeClear=True
     Components(0)=(XL=175.000000,YL=450.000000)
}

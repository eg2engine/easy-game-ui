class BuffIcon extends CInterface
	config(SephirothUI);

var string TransToMonsterName;
var string TransToMonsterAniName;
var int nPCBangMode; // PC�� ���;; (0: �ƴ� 1: ������ 2: �����̾�)
var int nOriginalIndex; // �������� �޾ƿ� ���� �ε��� (77, 78, 79)
var bool bUpAlpha; // ���İ� ��� or �϶�
var int nAlpha;   // ����� ���� ǥ�ÿ� ���İ�

var bool bOnGameGrade;   // ���� ��� ǥ�� on / off
var int nGameGradeAlpha; // ���� ��� ǥ�� ���� ���İ�


var array<Texture> DynamicTextures;
#exec OBJ LOAD FILE=..\Textures\FontKor.utx PACKAGE=FontKor

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

function OnInit()
{
	nPCBangMode = -1;
	nOriginalIndex = -1;
	bUpAlpha = true;
	nAlpha = 100;
}

function OnFlush()
{
	FlushDynamicTextures();
}

function OnPreRender(Canvas C)
{
	local int i, nBuffNum;
	local string sBuffName, sBuffTip;

	if(bUpAlpha)
	{
		if(nAlpha < 255)
			nAlpha += 5;
		else
			bUpAlpha = false;
	}
	else
	{
		if(nAlpha > 100)
			nAlpha -= 5;
		else
			bUpAlpha = true;
	}

	SetAcountMode(SephirothPlayer(PlayerOwner).PSI.userAccountType);

	//add neive : Ư�� ������ ���� ǥ�� --------------------------
	nBuffNum = 0;

	if ( SephirothInterface(PlayerOwner.myHud).ITopOnCursor == Self )	{
//	if ( IsCursorInsideAt(Components[3].X, Components[3].Y, 600, 70))	{

		for(i=0; i<SephirothPlayer(PlayerOwner).PSI.EnchantMagics.Length; i++)
		{
			sBuffName = SephirothPlayer(PlayerOwner).PSI.EnchantMagics[i];

			if(sBuffName == "NULL_ENCHANT")
				continue;

			if(sBuffName == "QuestTime")
				continue;

			if ( IsCursorInsideAt(Components[3].X + (nBuffNum*35), Components[3].Y, 34, 34)) // �� ������δ� ������ 2���� ������ ������ �ִ�
			{
				sBuffTip = Localize("Buff", sBuffName, "Sephiroth");
				if(Mid(sBuffTip, 0, 1) != "<")
					Controller.SetTooltip(Localize("Buff", sBuffName, "Sephiroth"));
			}

			++nBuffNum;
		}
	}
	//-----------------------------------------------------------
}

function OnPostRender(HUD H, Canvas C)
{
	local int i;
	local int count, BuffMin, BuffSec, QuestMin, QuestSec;
	local string strTemp;
	local float TW, TH;
	local PlayerServerInfo PSI;

//	local CBuffIconData	BuffIconData;
	local Texture Image;
//	local int nIdx;      // ����Ʈ �ε���
//	local bool bBuff;    // ����? �����?
//	local int nText;     // ���� �ؽ�Ʈ �ε���

	local Font OldFont;

	local int CurSec;    // ���� �� ���ڸ�

    local byte A;
	local color OldClr;

	C.DrawColor.A = 200;
	C.SetRenderStyleAlpha();

	// PC�� ������ ǥ��
	if(nPCBangMode > 0) // 0 �� �ƴ϶��
	{
		C.SetPos(Components[0].X, Components[0].Y);

		if(nPCBangMode == 79)      // ���� PC���� ���
			C.DrawTile(TextureResources[0].Resource,64,64,0,0,64,64);
		else if(nPCBangMode == 80) // �����̾� PC���� ���
			C.DrawTile(TextureResources[1].Resource,64,64,0,0,64,64);
		else
			nPCBangMode = 78;
	}

	// ���� ��� ǥ�� ---------------------------------------------------------
	CurSec = Level.TimeSeconds % 3600;

//	strTemp = "Sec :" $ CurSec ;
//	C.DrawKoreanText(strTemp, C.ClipX - 135, 57, 32, 32);

	if(CurSec == 3)
	{
		bOnGameGrade = true;
		nGameGradeAlpha = 0;
	}

	if(bOnGameGrade)
	{
		if(CurSec > 6)
			bOnGameGrade = false;

		C.DrawColor.A = 200;
		C.SetPos(C.ClipX - 135, 7);
		if(TextureResources.Length > 54)
			C.DrawTile(TextureResources[54].Resource,128,128,0,0,128,128);
	}
	//-------------------------------------------------------------------------

	// ���� �ý��� ������ ǥ��
	if(SephirothPlayer(PlayerOwner).PSI.TransToMonsterName != "")
	{
		if(TransToMonsterName != "")
			C.DrawColor.A = 150;
		else
			C.DrawColor.A = 255;

		C.SetPos(Components[1].X, Components[1].Y);
		C.DrawTile(TextureResources[2].Resource,32,32,0,0,32,32);
	}

	// ���� ǥ��
	count = 0;

	OldFont = C.Font;
	C.Font = Font'FontKor.Gulim7';
	PSI = SephirothPlayer(PlayerOwner).PSI;

	//Log("buff icon:begin.list length"@string(PSI.BuffList.Length));

	for(i=0; i<PSI.BuffList.Length; i++)
	{
		//Log("buff icon:"@PSI.BuffList[i].sName);

		if(PSI.BuffList[i].sName == "NULL_ENCHANT"){
			continue;
		}

		if(PSI.BuffList[i].sName == "QuestTime")
		{
			TW = 1.4;
			TH = 1.4;

			QuestMin = ((PSI.EnchantMagicTimes[i] - PSI.nCurTime) - 1)/60;
			QuestSec = ((PSI.EnchantMagicTimes[i] - PSI.nCurTime) - 1)%60;

			if(QuestSec + QuestMin > 0)
			{
				C.DrawColor.A = 255;
				C.KTextFormat = ETextAlign.TA_MiddleCenter;

				if(QuestMin > 0)
				{
					if(QuestMin > 9)
					{
						if(QuestSec > 9)
							strTemp = QuestMin $ ":" $ QuestSec;
						else
							strTemp = QuestMin $ ":0" $ QuestSec;
					}
					else
					{
						if(QuestSec > 9)
							strTemp = "0" $ QuestMin $ ":" $ QuestSec;
						else
							strTemp = "0" $ QuestMin $ ":0" $ QuestSec;
					}
				}
				else
				{
					C.SetDrawColor(255 - QuestSec, QuestSec, 0);
					if(QuestSec > 9)
						strTemp = "" $ QuestSec;
					else
					{
						if(QuestSec < 6)
						{
							C.DrawColor.A = nAlpha;
							strTemp = "Hurry Up";
						}
						else
							strTemp = "0" $ QuestSec;
					}
				}

				C.Font = Font'FontEx.TrebLarge';
				C.TextSize(strTemp, TW, TH);
				if(QuestMin > 0)
					C.SetPos(C.ClipX - 245, 15);		// ���� ������ ���
				else
					C.SetPos(C.ClipX/2-45, 100);	// 1�� ������ �� ��� ���

				if(strTemp == "Hurry Up")
					C.SetPos(C.ClipX/2-138, 100);

				C.DrawTextScaled(strTemp, false, 3.0, 3.0);

				strTemp = Localize("BuffIcon", "CurTime", "SephirothUI"); //"���� �ð�";

				if(QuestMin > 0)
					C.DrawKoreanText(strTemp, C.ClipX - 200, 5, 16, 15);
				//else
				//	C.DrawKoreanText(strTemp, C.ClipX/2-15, 100, 16, 15);

				C.DrawColor.A = 150;
				C.SetDrawColor(255, 255, 255);
				C.Font = Font'FontKor.Gulim7';
			}

			continue;
		}

		// �������� ���� �ð�
		BuffMin = ((PSI.BuffList[i].nTime - PSI.nCurTime) - 1)/60;
		BuffSec = ((PSI.BuffList[i].nTime - PSI.nCurTime) - 1)%60;


		// ��׶��� ---------------------------------------------------------
		C.SetPos(Components[3].X + (count*35) - 1, Components[3].Y - 1);

		if(BuffMin == 0 && BuffSec < 10) // 10 �� ���Ϸ� ������
		{
			C.SetDrawColor(255, 255, 255, 100);

			if(PSI.BuffList[i].nFlag == 0) // ���� ��׶���
				C.DrawTile(TextureResources[4].Resource,34,34,0,0,34,34);
			else              // ����� ��׶���
				C.DrawTile(TextureResources[5].Resource,34,34,0,0,34,34);

			if(nAlpha%6 != 0)
				C.SetDrawColor(128, 255, 0, 255);

			C.SetPos(Components[3].X + (count*35) - 1, Components[3].Y);
			C.DrawRect1Fix(35, 35);
		}
		else
		{
			C.SetDrawColor(255, 255, 255, 200);

			if(PSI.BuffList[i].nFlag == 0) // ���� ��׶���
				C.DrawTile(TextureResources[4].Resource,34,34,0,0,34,34);
			else              // ����� ��׶���
				C.DrawTile(TextureResources[5].Resource,34,34,0,0,34,34);
		}
		//---------------------------------------------------------------------

		if(BuffMin == 0)
		{
			if(BuffSec < 10)
				C.SetDrawColor(255, 255, 255, 150);
			else
				C.SetDrawColor(255, 255, 255, nAlpha);
		}
		else
			C.SetDrawColor(255, 255, 255, 200);

		C.SetPos(Components[3].X + (count*35), Components[3].Y);
		Image = LoadDynamicTexture(PSI.BuffList[i].sPath);
		C.DrawTile(Image,32,32,0,0,32,32);

		//Log("buff icon:"@PSI.BuffList[i].sPath);

		C.KTextFormat = ETextAlign.TA_MiddleCenter;
		DrawBuffDesc(C, PSI.BuffList[i].sDesc, count);


		if(BuffMin > 0 && PSI.BuffList[i].sName != "RewardReputation_IO" )	//if(BuffMin > 0)
		{
			OldClr = C.DrawColor;
	
			C.SetDrawColor(128, 255, 0, 255);

			if(BuffMin > 1440)
			{
				BuffMin = BuffMin / 1440;
				if(BuffMin < 30)
					C.DrawKoreanText(BuffMin $ "D", Components[3].X + (count*35) + 23, Components[3].Y + 7, 0, 0);
			}
			else if(60 < BuffMin && BuffMin < 1440)
			{
				BuffMin = BuffMin / 60; // �� ���� �ð� ������ ���� ���� �ð��� ���Ѵ�
				C.DrawKoreanText(BuffMin $ " H", Components[3].X + (count*35) + 23, Components[3].Y + 7, 0, 0);				
			}
			else
				C.DrawKoreanText(BuffMin, Components[3].X + (count*35) + 25, Components[3].Y + 7, 0, 0);

			C.SetDrawColor(OldClr.R, OldClr.G, OldClr.B, OldClr.A);
		}

		++count;
	}
	//Log("buff icon:end");

	C.Font = OldFont;
	C.DrawColor.A = 255;
}

function DrawBuffDesc(Canvas C, string sDesc, int count)
{
	local color OldClr;
	OldClr = C.DrawColor;
	C.SetDrawColor(128, 255, 0, 255);
	C.SetPos(Components[3].X + (count*35) - 1, Components[3].Y + 22);
	C.DrawTextScaled(sDesc, true, 1.0f, 1.0f);
	C.SetDrawColor(OldClr.R, OldClr.G, OldClr.B, OldClr.A);
}

function DrawBuffDescShort(Canvas C, string sDesc, int count)
{
	C.DrawKoreanText(sDesc, Components[3].X + (count*35) + 19, Components[3].Y + 27, 0, 0);
}


function bool OnKeyEvent(Interaction.EInputKey Key, Interaction.EInputAction Action, float Delta)
{
//	�� �� ������ ��???? ??????????
//
// 	if (Key == IK_LeftMouse && IsCursorInsideAt(Components[1].X, Components[1].Y, 16, 24))
// 	{
// /*
// 		if(TransToMonsterName == "")
// 		{
// 			TransToMonsterName = SephirothPlayer(PlayerOwner).PSI.TransToMonsterName;
// 			SephirothPlayer(PlayerOwner).PSI.TransToMonsterName = "";
// 		}
// 		else
// 		{
// 			SephirothPlayer(PlayerOwner).PSI.TransToMonsterName = TransToMonsterName;
// 			TransToMonsterName = "";
// 		}*/
// 		
// 	}

	return false;
}

function bool PointCheck()
{
	if(IsCursorInsideAt(Components[1].X, Components[1].Y, 32, 32))
		return true;

	return false;
}

function Layout(Canvas C)
{

}

// ���� ��带 ����
function SetAcountMode(int i)
{
	if(i > 77 && i < 81)
	{
		nPCBangMode = i;
		nOriginalIndex = i;
	}
}


function bool IsCursorInsideInterface()	{

	return IsCursorInsideAt(Components[3].X, Components[3].Y, SephirothPlayer(PlayerOwner).PSI.EnchantMagics.Length * 35, 34);
}

defaultproperties
{
     TransToMonsterAniName="None"
     nPCBangMode=-1
     nOriginalIndex=-1
     Components(0)=(X=125.000000,Y=5.000000)
     Components(1)=(Id=1,X=152.000000,Y=40.000000)
     Components(2)=(Id=2,X=172.000000,Y=40.000000)
     Components(3)=(Id=3,X=210.000000,Y=5.000000)
     TextureResources(0)=(Package="UI_Remodel",Path="Main.PCEntry_N",Style=STY_Alpha)
     TextureResources(1)=(Package="UI_Remodel",Path="Main.PCEntry_P",Style=STY_Alpha)
     TextureResources(2)=(Package="ItemSpritesM",Path="Market_TC_N00",Style=STY_Alpha)
     TextureResources(3)=(Package="SecondSkillUI",Path="SkillIcons.TransformationS",Style=STY_Alpha)
     TextureResources(4)=(Package="Marks",Path="BuffBack",Style=STY_Alpha)
     TextureResources(5)=(Package="Marks",Path="DeBuffBack",Style=STY_Alpha)
     TextureResources(6)=(Package="UI_Remodel",Path="WorldMap.SlotMF_Button_X",Style=STY_Alpha)
     IsBottom=True
}

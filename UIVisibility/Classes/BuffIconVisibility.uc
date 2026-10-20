class BuffIconVisibility extends BuffIcon;

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

	if (!class'VisibilitySettings'.default.bHideBuffUI)
    {
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

	if (!class'VisibilitySettings'.default.bHideBuffUI)
    {
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
    }
	//Log("buff icon:end");

	C.Font = OldFont;
	C.DrawColor.A = 255;
}

defaultproperties
{
}

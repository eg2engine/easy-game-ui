class CMainInterface_type2 extends CMainInterface;


function OnInit()
{
	local int i;

	QuickSlotColumns = class 'QuickKeyConst'.Default.QuickSlotColumns;  
	QuickSlotRows = class 'QuickKeyConst'.Default.QuickSlotRows;
	SkillBasicOffsetX = class 'QuickKeyConst'.Default.SkillBasicOffsetX_type2;
	SkillBasicOffsetY = class 'QuickKeyConst'.Default.SkillBasicOffsetY_type2;
	SkillComboOffsetX = class 'QuickKeyConst'.Default.SkillComboOffsetX_type2;
	SkillComboOffsetY = class 'QuickKeyConst'.Default.SkillComboOffsetY_type2;
	SkillMagicOffsetX = class 'QuickKeyConst'.Default.SkillMagicOffsetX_type2;
	SkillMagicOffsetY = class 'QuickKeyConst'.Default.SkillMagicOffsetY_type2;
	QuickSlotStartX = class 'QuickKeyConst'.Default.QuickSlotStartX_type2;
	QuickSlotStartY = class 'QuickKeyConst'.Default.QuickSlotStartY_type2;
	QuickSlotOffsetXPerBox =	class 'QuickKeyConst'.Default.QuickSlotOffsetXPerBox_type2;
	QuickSlotOffsetYPerBox = class 'QuickKeyConst'.Default.QuickSlotOffsetYPerBox_type2;

	HotkeyArray.Length = QuickSlotColumns;
	for( i = 0; i < HotkeyArray.Length; i++ )
	{
		HotkeyArray[i].HotkeySprites.Length = QuickSlotRows;
	}


	SetComponentTextureId(Components[3],1, -1,3,2);
	SetComponentTextureId(Components[4],4, -1,6,5);
	SetComponentNotify(Components[3],BN_HotKeyUp,Self);
	SetComponentNotify(Components[4],BN_HotKeyDown,Self);


	SetComponentTextureId(Components[7],7, -1,9,8);
	SetComponentNotify(Components[7],BN_MainMenuButton,Self);

	SetComponentTextureId(Components[8],10, -1,12,11);
	SetComponentnotify(Components[8],BN_ShopButton,Self);

	SetComponentTextureId(Components[10],14, -1, -1,22);
	SetComponentTextureId(Components[11],15, -1, -1,23);
	SetComponentTextureId(Components[12],16, -1, -1,24);
	SetComponentTextureId(Components[13],17, -1, -1,25);
	SetComponentTextureId(Components[14],18, -1, -1,26);

	SetComponentNotify(Components[10],BN_Info,Self);
	SetComponentNotify(Components[11],BN_Bag,Self);
	SetComponentNotify(Components[12],BN_Skill,Self);
	SetComponentNotify(Components[13],BN_Portal,Self);
	SetComponentNotify(Components[14],BN_Quest,Self);

	BgColor = new(None) class'ConstantColor';
	BgBlend = new(None) class'FinalBlend';

	BgBlend.Material = BgColor;
	BgBlend.FrameBufferBlending = BgBlend.EFrameBufferBlending.FB_AlphaBlend;
	BgColor.Color = class'Canvas'.Static.MakeColor(0,0,255,100);

	nLevelUpColor = 0;
	bOnUp = False;
	nUpExp = -100;
	fTempExp = -100;
	bOnUpExp = False;
	nPointAlpha = 155;
	bAlphaDir = 0;
	GotoState('Nothing');
}

function DrawObject(Canvas C)
{
	local float X,Y,XL,YL;
	local SephirothPlayer PC;
	local int i, j,k;
	local int Amount;
	local color OldColor;
	local byte OldStyle;
	local Skill Skill;
	local SephirothItem ISI;
	local string ModelName, TypeName;
	local array<SephirothItem> Items;
	local string LevelStr;
	local bool bSecondSkillInfo, bSkillInfo, bItemInfo;	
	local float ChargeOffset;
	local int MailCount, HelperCount;
	local float ChargeRate;		// 用于倒计时计算
	local float RemainingSeconds;	// 剩余冷却时间
	local string TimeText;		// 倒计时文本

	local string sIndex;

	local int HotKeyPos;
	local int QuickSlotIndex;
	
	local int QuickSlotOffsetX_Between_GaugeHud;

	QuickSlotIndex = SephirothInterface(Parent).QuickSlotIndex;

	PC = SephirothPlayer(PlayerOwner);
	if ( PC == None || PC.PSI == None )
		return;

	X = Components[0].X;
	Y = Components[0].Y;

	if ( PC.GetHotSkill(0) != "" && SkillSprites[0] == None ) SetSkillSprite(PC,0,True);
	if ( PC.GetHotSkill(1) != "" && SkillSprites[1] == None ) SetSkillSprite(PC,1,True);
	if ( PC.GetHotSkill(2) != "" && SkillSprites[2] == None ) SetSkillSprite(PC,2,True);

	if ( SkillSprites[0] != None ) 
	{
		C.SetPos(X + SkillBasicOffsetX,Y + SkillBasicOffsetY);
		C.DrawTile(SkillSprites[0], 32, 32, 0, 0, 32, 32);
	}
	if ( SkillSprites[1] != None ) 
	{
		C.SetPos(X + SkillComboOffsetX,Y + SkillComboOffsetY);
		C.DrawTile(SkillSprites[1], 32, 32, 0, 0, 32, 32);
	}
	if ( SkillSprites[2] != None ) 
	{
		C.SetPos(X + SkillMagicOffsetX,Y + SkillMagicOffsetY);
		C.DrawTile(SkillSprites[2], 32, 32, 0, 0, 32, 32);
	}

	if ( NewSkill != None ) 
	{
		if ( Level.TimeSeconds - LearnSkillTime < 30 ) 
		{
			if ( Level.TimeSeconds - int(Level.TimeSeconds) < 0.5 ) 
			{
				OldStyle = C.Style;
				OldColor = C.DrawColor;
				C.Style = ERenderStyle.STY_Alpha;
				C.SetDrawColor(255,255,255);
				if ( NewSkill.IsCombo() )
					C.SetPos(X + SkillBasicOffsetX - 2,Y + SkillBasicOffsetY - 2);
				else if (NewSkill.IsFinish())
					C.SetPos(X + SkillComboOffsetX - 2,Y + SkillComboOffsetY - 2);
				else if (NewSkill.IsMagic())
					C.SetPos(X + SkillMagicOffsetX - 2,Y + SkillMagicOffsetY - 2);
				C.DrawTile(TextureResources[19].Resource,36,37,0,0,36,37);
				C.DrawColor = OldColor;
				C.Style = OldStyle;
			}
		}
		else
			NewSkill = None;
	}

	OldColor = C.DrawColor;

	for ( i = 0;i < QuickSlotRows;i++ )
	{
		if( i >= 6 )
			QuickSlotOffsetX_Between_GaugeHud = class 'QuickKeyConst'.Default.QuickSlotOffsetX_Between_GaugeHud;
		else
			QuickSlotOffsetX_Between_GaugeHud = 0;

		HotKeyPos = QuickSlotIndex * QuickSlotRows + i;
		TypeName = PC.GetHotkey(HotKeyPos);
		if ( TypeName == "" )
			continue;
		C.DrawColor = OldColor;
		if ( HotKeyArray[QuickSlotIndex].HotkeySprites[i].HotkeySprite == None ) 
			SetHotkeySprite(PC, QuickSlotIndex, i, True);

		if ( HotKeyArray[QuickSlotIndex].HotkeySprites[i].HotkeySprite != None ) 
		{
			if ( PC.PSI.QuickKeys[HotKeyPos].Type == class'GConst'.Default.BTSkill ) 
			{
				Skill = PC.QuerySkillByName(PC.PSI.QuickKeys[HotKeyPos].KeyName);
				if( Skill != None && Skill.IsA('SecondSkill') && SecondSkill(Skill).SkillType == 6 )
				{
					if( Skill.bEnabled )
						HotKeyArray[QuickSlotIndex].HotkeySprites[i].HotkeySprite = Texture(DynamicLoadObject("SecondSkillUI.SkillIcons.TransformationS",class'Texture'));
					else
						HotKeyArray[QuickSlotIndex].HotkeySprites[i].HotkeySprite = Texture(DynamicLoadObject("SecondSkillUI.SkillIcons.TransformationSD",class'Texture'));
				}
				C.Style = ERenderStyle.STY_Normal;
				C.SetPos(X + QuickSlotStartX + i * QuickSlotOffsetXPerBox + QuickSlotOffsetX_Between_GaugeHud, Y + QuickSlotStartY);
				
				if( Skill.IsA('SecondSkill') )
				{
					if( Skill.bEnabled && SecondSkill(Skill).bCharged || SecondSkill(Skill).SkillType == 6 )
						C.SetDrawColor(255, 255, 255, 255);
					else
						C.SetDrawColor(100, 100, 100, 255);
				}
				else
					C.SetDrawColor(255, 255, 255, 255);
				C.DrawTile(HotKeyArray[QuickSlotIndex].HotkeySprites[i].HotkeySprite, 32, 32, 0, 0, 32, 32);

				if ( Skill != None )
					if( Skill.IsA('SecondSkill') && SecondSkill(Skill).SkillType != 6 )
					{
						if( !SecondSkill(Skill).bCharged )
						{							

							SephirothPlayer(PlayerOwner).PSI.SetSetItemLevel();
							ChargeRate = SecondSkill(Skill).GetChargeRate(SephirothPlayer(PlayerOwner).PSI.SetAvilityLevel, PC.Level.TimeSeconds);
							ChargeOffset = 32 * ChargeRate;
							if( ChargeOffset >= 0 && ChargeOffset < 32 )
							{
								C.SetPos(X + QuickSlotStartX + i * QuickSlotOffsetXPerBox + QuickSlotOffsetX_Between_GaugeHud, Y + QuickSlotStartY);
								C.DrawTile(BgBlend,32,32 - ChargeOffset,0,0,0,0);
							}
							
							// 显示倒计时文本（复用 ChargeRate）
							if( ChargeRate >= 0 && ChargeRate < 1.0 )
							{
								RemainingSeconds = GetRemainingCooldownFromRate(
									SecondSkill(Skill), 
									ChargeRate, 
									SephirothPlayer(PlayerOwner).PSI.SetAvilityLevel
								);
								
								if( RemainingSeconds > 0 )
								{
									TimeText = FormatCooldownText(RemainingSeconds);
									C.SetDrawColor(255, 255, 255);
									C.SetKoreanTextAlign(ETextAlign.TA_MiddleCenter);
									C.DrawKoreanText(TimeText, 
										X + QuickSlotStartX + i * QuickSlotOffsetXPerBox + QuickSlotOffsetX_Between_GaugeHud, 
										Y + QuickSlotStartY, 
										32, 32);
								}
							}
						}
					}
			}

			else if (PC.PSI.QuickKeys[HotKeyPos].Type == class'GConst'.Default.BTMenu) 
			{		
				C.Style = ERenderStyle.STY_Alpha;
				C.SetPos(X + QuickSlotStartX + i * QuickSlotOffsetXPerBox + QuickSlotOffsetX_Between_GaugeHud, Y + QuickSlotStartY);
				C.DrawTile(HotKeyArray[SephirothInterface(Parent).QuickSlotIndex].HotkeySprites[i].HotkeySprite, 32, 32, 0, 0, 32, 32);
			}

			else 
			{	
				Amount = PC.PSI.QuickKeys[HotKeyPos].Amount;
				if ( Amount >= 0 ) 
				{
					C.Style = ERenderStyle.STY_Alpha;
					C.SetPos(X + QuickSlotStartX + i * QuickSlotOffsetXPerBox + QuickSlotOffsetX_Between_GaugeHud, Y + QuickSlotStartY);
					if ( Amount == 0 )
						C.SetDrawColor(128,128,128);
					C.DrawTile(HotKeyArray[SephirothInterface(Parent).QuickSlotIndex].HotkeySprites[i].HotkeySprite, 24, 24, 0, 0, 24, 24);
					C.SetKoreanTextAlign(ETextAlign.TA_TopLeft);
					C.DrawKoreanText(Amount, X + QuickSlotStartX + i * QuickSlotOffsetXPerBox + QuickSlotOffsetX_Between_GaugeHud, Y + QuickSlotStartY, 32, 32);
				}

				if( Amount == -99 )
				{
					C.Style = ERenderStyle.STY_Alpha;
					C.SetPos(X + QuickSlotStartX + i * QuickSlotOffsetXPerBox + QuickSlotOffsetX_Between_GaugeHud, Y + QuickSlotStartY);
					C.SetDrawColor(255,255,0);
					C.DrawTile(HotKeyArray[SephirothInterface(Parent).QuickSlotIndex].HotkeySprites[i].HotkeySprite, 24, 24, 0, 0, 24, 24);
					C.SetKoreanTextAlign(ETextAlign.TA_TopLeft);
					C.DrawKoreanText("�Ⱓ", X + QuickSlotStartX + i * QuickSlotOffsetXPerBox + QuickSlotOffsetX_Between_GaugeHud, Y + QuickSlotStartY, 32, 32);
				}
			}			
			
		}
	}

	for ( i = 0;i < QuickSlotRows;i++ )
	{
		if( i >= 6 )
			QuickSlotOffsetX_Between_GaugeHud = class 'QuickKeyConst'.Default.QuickSlotOffsetX_Between_GaugeHud;
		else
			QuickSlotOffsetX_Between_GaugeHud = 0;
			
				
		HotKeyPos = QuickSlotIndex_for_F1 * QuickSlotRows + i;
		TypeName = PC.GetHotkey(HotKeyPos);
		if ( TypeName == "" )
			continue;
		C.DrawColor = OldColor;
		if ( HotKeyArray[QuickSlotIndex_for_F1].HotkeySprites[i].HotkeySprite == None ) 		
			SetHotkeySprite(PC, QuickSlotIndex_for_F1, i, True);

		if ( HotKeyArray[QuickSlotIndex_for_F1].HotkeySprites[i].HotkeySprite != None ) 
		{			
			if ( PC.PSI.QuickKeys[HotKeyPos].Type == class'GConst'.Default.BTSkill ) 
			{
				Skill = PC.QuerySkillByName(PC.PSI.QuickKeys[HotKeyPos].KeyName);
				if( Skill != None && Skill.IsA('SecondSkill') && SecondSkill(Skill).SkillType == 6 )
				{
					if( Skill.bEnabled )
						HotKeyArray[QuickSlotIndex_for_F1].HotkeySprites[i].HotkeySprite = Texture(DynamicLoadObject("SecondSkillUI.SkillIcons.TransformationS",class'Texture'));
					else
						HotKeyArray[QuickSlotIndex_for_F1].HotkeySprites[i].HotkeySprite = Texture(DynamicLoadObject("SecondSkillUI.SkillIcons.TransformationSD",class'Texture'));
				}
				C.Style = ERenderStyle.STY_Normal;
				C.SetPos(X + QuickSlotStartX + i * QuickSlotOffsetXPerBox + QuickSlotOffsetX_Between_GaugeHud, Y + QuickSlotStartY - QuickSlotOffsetYPerBox);
				
				if( Skill.IsA('SecondSkill') )
				{
					if( Skill.bEnabled && SecondSkill(Skill).bCharged || SecondSkill(Skill).SkillType == 6 )
						C.SetDrawColor(255, 255, 255, 255);
					else
						C.SetDrawColor(100, 100, 100, 255);
				}
				else
					C.SetDrawColor(255, 255, 255, 255);
				C.DrawTile(HotKeyArray[QuickSlotIndex_for_F1].HotkeySprites[i].HotkeySprite, 32, 32, 0, 0, 32, 32);

				if ( Skill != None )
					if( Skill.IsA('SecondSkill') && SecondSkill(Skill).SkillType != 6 )
					{
						if( !SecondSkill(Skill).bCharged )
						{							
							
							SephirothPlayer(PlayerOwner).PSI.SetSetItemLevel();
							ChargeRate = SecondSkill(Skill).GetChargeRate(SephirothPlayer(PlayerOwner).PSI.SetAvilityLevel, PC.Level.TimeSeconds);
							ChargeOffset = 32 * ChargeRate;
							if( ChargeOffset >= 0 && ChargeOffset < 32 )
							{
								C.SetPos(X + QuickSlotStartX + i * QuickSlotOffsetXPerBox + QuickSlotOffsetX_Between_GaugeHud, Y + QuickSlotStartY - QuickSlotOffsetYPerBox);
								C.DrawTile(BgBlend,32,32 - ChargeOffset,0,0,0,0);
							}
							
							// 显示倒计时文本（复用 ChargeRate）
							if( ChargeRate >= 0 && ChargeRate < 1.0 )
							{
								RemainingSeconds = GetRemainingCooldownFromRate(
									SecondSkill(Skill), 
									ChargeRate, 
									SephirothPlayer(PlayerOwner).PSI.SetAvilityLevel
								);
								
								if( RemainingSeconds > 0 )
								{
									TimeText = FormatCooldownText(RemainingSeconds);
									C.SetDrawColor(255, 255, 255);
									C.SetKoreanTextAlign(ETextAlign.TA_MiddleCenter);
									C.DrawKoreanText(TimeText, 
										X + QuickSlotStartX + i * QuickSlotOffsetXPerBox + QuickSlotOffsetX_Between_GaugeHud, 
										Y + QuickSlotStartY - QuickSlotOffsetYPerBox, 
										32, 32);
								}
							}
						}
					}
			}

			else if (PC.PSI.QuickKeys[HotKeyPos].Type == class'GConst'.Default.BTMenu) 
			{		
				C.Style = ERenderStyle.STY_Alpha;
				C.SetPos(X + QuickSlotStartX + i * QuickSlotOffsetXPerBox + QuickSlotOffsetX_Between_GaugeHud, Y + QuickSlotStartY - QuickSlotOffsetYPerBox);
				C.DrawTile(HotKeyArray[QuickSlotIndex_for_F1].HotkeySprites[i].HotkeySprite, 32, 32, 0, 0, 32, 32);

			}

			else 
			{		
				// 获取快捷栏中该位置的道具数量
				// Amount >= 0 表示正常道具数量，Amount == -99 表示道具处于冷却状态
				Amount = PC.PSI.QuickKeys[HotKeyPos].Amount;
				
				// 处理正常状态的道具（数量 >= 0）
				if ( Amount >= 0 ) 
				{
					// 设置渲染样式为Alpha混合，支持透明效果
					C.Style = ERenderStyle.STY_Alpha;
					
					// 计算并设置道具图标的绘制位置
					// QuickSlotStartX: 快捷栏起始X坐标
					// i * QuickSlotOffsetXPerBox: 根据索引计算水平偏移
					// QuickSlotOffsetX_Between_GaugeHud: 当i>=6时，在GaugeHud之间的额外偏移
					// QuickSlotStartY - QuickSlotOffsetYPerBox: F1快捷栏的Y坐标（比主快捷栏高一行）
					C.SetPos(X + QuickSlotStartX + i * QuickSlotOffsetXPerBox + QuickSlotOffsetX_Between_GaugeHud, Y + QuickSlotStartY - QuickSlotOffsetYPerBox);
					
					// 如果道具数量为0，设置为灰色（表示道具已用完但快捷栏仍保留）
					if ( Amount == 0 )
						C.SetDrawColor(128,128,128);
					
					// 绘制道具图标（24x24像素）
					// 从HotkeySprite纹理的(0,0)位置开始，绘制24x24的区域
					C.DrawTile(HotKeyArray[QuickSlotIndex_for_F1].HotkeySprites[i].HotkeySprite, 24, 24, 0, 0, 24, 24);
					
					// 设置文本对齐方式为左上角对齐
					C.SetKoreanTextAlign(ETextAlign.TA_TopLeft);
					
					// 在道具图标上绘制数量文本
					// 文本显示在32x32的区域内（比图标稍大，留出边距）
					C.DrawKoreanText(Amount, X + QuickSlotStartX + i * QuickSlotOffsetXPerBox + QuickSlotOffsetX_Between_GaugeHud, Y + QuickSlotStartY - QuickSlotOffsetYPerBox, 32, 32);
					//C.DrawKoreanText(Amount, X + QuickSlotStartX + i * QuickSlotOffsetXPerBox + QuickSlotOffsetX_Between_GaugeHud, Y + QuickSlotStartY, 32, 32);
				}

				
				// 处理冷却状态的道具（Amount == -99 表示道具正在冷却中）
				if( Amount == -99 )
				{
					// 设置渲染样式为Alpha混合
					C.Style = ERenderStyle.STY_Alpha;
					
					// 设置绘制位置（与正常状态相同）
					C.SetPos(X + QuickSlotStartX + i * QuickSlotOffsetXPerBox + QuickSlotOffsetX_Between_GaugeHud, Y + QuickSlotStartY - QuickSlotOffsetYPerBox);
					
					// 设置绘制颜色为黄色(255,255,0)，用于突出显示冷却状态
					C.SetDrawColor(255,255,0);
					
					// 绘制道具图标（24x24像素，黄色显示）
					C.DrawTile(HotKeyArray[QuickSlotIndex_for_F1].HotkeySprites[i].HotkeySprite, 24, 24, 0, 0, 24, 24);
					
					// 设置文本对齐方式为左上角对齐
					C.SetKoreanTextAlign(ETextAlign.TA_TopLeft);
					C.DrawKoreanText("�Ⱓ", X + QuickSlotStartX + i * QuickSlotOffsetXPerBox + QuickSlotOffsetX_Between_GaugeHud, Y + QuickSlotStartY - QuickSlotOffsetYPerBox, 32, 32);
				}
			}
			
		}
	}

	
	C.SetDrawColor(222, 210, 63);
	
	for( i = 0; i < QuickSlotRows; i++ )
	{
		if( i >= 6 )
			QuickSlotOffsetX_Between_GaugeHud = class 'QuickKeyConst'.Default.QuickSlotOffsetX_Between_GaugeHud;
		else
			QuickSlotOffsetX_Between_GaugeHud = 0;

		C.SetKoreanTextAlign(ETextAlign.TA_MiddleCenter);
		if( i == 9 )
			sIndex = "0";
		else if(i == 10)
			sIndex = "-";
		else if(i == 11)
			sIndex = "=";
		else
			sIndex = ""$(i + 1);

		C.DrawKoreanText(sIndex, 157 + (i * 37) + (C.ClipX / 2 - Components[1].XL / 2) + QuickSlotOffsetX_Between_GaugeHud, C.ClipY - 27, 0, 0);
		C.DrawKoreanText("F"$(i + 1), 157 + (i * 37) - 4 + (C.ClipX / 2 - Components[1].XL / 2) + QuickSlotOffsetX_Between_GaugeHud, C.ClipY - 27 - QuickSlotOffsetYPerBox, 0, 0);	}

	if( nUpExp == -100 )
	{
		fTempExp = SephirothPlayer(PlayerOwner).PSI.ExpDisplay;
		nUpExp = 0;
	}

	if( SephirothPlayer(PlayerOwner).PSI.ExpDisplay != fTempExp )
	{
		nUpExp = SephirothPlayer(PlayerOwner).PSI.ExpDisplay - fTempExp;
		fTempExp = SephirothPlayer(PlayerOwner).PSI.ExpDisplay;
	}

	sIndex = "�ƢƢƢƢƢƢƢ�";
	C.SetDrawColor(0, 0, 0, 50);
	C.DrawKoreanText(sIndex, C.ClipX / 2, C.ClipY - 8, 0, 0);
	sIndex = "LV "$(SephirothPlayer(PlayerOwner).PSI.PlayLevel)$"   ("$(SephirothPlayer(PlayerOwner).PSI.ExpDisplay)$"%)";
	C.SetDrawColor(255, 255, 255);
	C.DrawKoreanText(sIndex, C.ClipX / 2 - 1, C.ClipY - 7, 0, 0);

	if( nUpExp != 0 && nUpExp != -100 && nUpExp > -3 )
	{
		if( nUpExp > 0 )
		{
			sIndex = "(+"$nUpExp$"%)";
			C.SetDrawColor(192, 192, 192);
		}
		else
		{
			sIndex = "("$nUpExp$"%)";
			C.SetDrawColor(250, 0, 0);
		}
		
		if( bOnUpExp )
			C.DrawKoreanText(sIndex, C.ClipX / 2 + 74, C.ClipY - 7, 0, 0);
	}

	if( SephirothPlayer(PlayerOwner).PSI.ExpDisplay > 90 )
	{	
		sIndex = "Level Up Soon";
		if( SephirothPlayer(PlayerOwner).PSI.ExpDisplay > 95 )
			C.SetDrawColor(253, 231, 34, nLevelUpColor);
		else
			C.SetDrawColor(201, 254, 129, nLevelUpColor);
		
		C.DrawKoreanText(sIndex, C.ClipX / 2 + 235, C.ClipY - 7, 0, 0);

		if( bOnUp )
		{
			if( nLevelUpColor < 255 )
				nLevelUpColor+=155 / 20;
			else
				bOnUp = False;
		}
		else
		{
			if( nLevelUpColor > 100 )
				nLevelUpColor-=155 / 20;
			else
				bOnUp = True;
		}
	}
	C.DrawColor = OldColor;

	MailX = C.ClipX / 2 + 325;
	MailY = C.ClipY - MailMY - 5;

	if( IsCursorInsideInterface() ) 
	{		
		X = Components[0].X;
		Y = Components[0].Y;
		YL = Components[0].YL - 5;
		if ( SkillSprites[0] != None && IsCursorInsideAt(X + SkillBasicOffsetX,Y + SkillBasicOffsetY,32,32) ) 
		{
			SephirothInterface(Parent).SkillInfo.SetInfo(PC.PSI.Combo, X + SkillBasicOffsetX, Controller.MouseY, True, C.ClipX, C.ClipY - YL);
			bSkillInfo = True;
		}
		else if (SkillSprites[1] != None && IsCursorInsideAt(X + SkillComboOffsetX,Y + SkillComboOffsetY,32,32)) 
		{
			SephirothInterface(Parent).SkillInfo.SetInfo(PC.PSI.Finish, X + SkillComboOffsetX, Controller.MouseY, True, C.ClipX, C.ClipY - YL);
			bSkillInfo = True;
		}
		else if (SkillSprites[2] != None && IsCursorInsideAt(X + SkillMagicOffsetX,Y + SkillMagicOffsetY,32,32)) 
		{
			SephirothInterface(Parent).SkillInfo.SetInfo(PC.PSI.Magic, X + SkillMagicOffsetX, Controller.MouseY, True, C.ClipX, C.ClipY - YL);
			bSkillInfo = True;
		}
		else
			bSkillInfo = False;

		for ( i = 0;i < QuickSlotRows;i++ ) 
		{

			if( i >= 6 )
				QuickSlotOffsetX_Between_GaugeHud = class 'QuickKeyConst'.Default.QuickSlotOffsetX_Between_GaugeHud;
			else
				QuickSlotOffsetX_Between_GaugeHud = 0;

			HotKeyPos = QuickSlotIndex * QuickSlotRows + i;

			if ( HotKeyArray[QuickSlotIndex].HotkeySprites[i].HotkeySprite != None 
				&& IsCursorInsideAt(X + QuickSlotStartX + i * QuickSlotOffsetXPerBox + QuickSlotOffsetX_Between_GaugeHud,Y + QuickSlotStartY,32,32) )
			{
				if ( PC.PSI.QuickKeys[HotKeyPos].Type == class'GConst'.Default.BTSkill )
				{
					Skill = PC.QuerySkillByName(PC.PSI.QuickKeys[HotKeyPos].KeyName);
					if ( Skill != None ) 
					{
						if( Skill.IsA('SecondSkill') ) 
						{
							SephirothInterface(Parent).InfoBox.SetInfo(Skill, X + QuickSlotStartX + i * QuickSlotOffsetXPerBox + QuickSlotOffsetX_Between_GaugeHud, Controller.MouseY, True, C.ClipX, C.ClipY - YL);
							bSecondSkillInfo = True;
						}
						else 
						{
							SephirothInterface(Parent).SkillInfo.SetInfo(Skill, X + QuickSlotStartX + i * QuickSlotOffsetXPerBox + QuickSlotOffsetX_Between_GaugeHud, Controller.MouseY, True, C.ClipX, C.ClipY - YL);
							bSkillInfo = True;
						}
					}
				}
				else
				{
					SephirothPlayer(PlayerOwner).PSI.SepInventory.FindItemToArray(0, PC.GetHotkey(HotKeyPos), Items);
					if ( Items.Length > 0 ) 
					{
						SephirothInterface(Parent).ItemInfo.SetInfo(Items[0], X + QuickSlotStartX + i * QuickSlotOffsetXPerBox + QuickSlotOffsetX_Between_GaugeHud, Controller.MouseY, True, C.ClipX, C.ClipY - YL);
						bItemInfo = True;
					}
				}
			}

			HotKeyPos = QuickSlotIndex_for_F1 * QuickSlotRows + i;

			if ( HotKeyArray[QuickSlotIndex_for_F1].HotkeySprites[i].HotkeySprite != None
				&& IsCursorInsideAt(X + QuickSlotStartX + i * QuickSlotOffsetXPerBox + QuickSlotOffsetX_Between_GaugeHud,Y + QuickSlotStartY - QuickSlotOffsetYPerBox,32,32) )
			{	
				if ( PC.PSI.QuickKeys[HotKeyPos].Type == class'GConst'.Default.BTSkill )
				{
					Skill = PC.QuerySkillByName(PC.PSI.QuickKeys[HotKeyPos].KeyName);
					if ( Skill != None ) 
					{
						if( Skill.IsA('SecondSkill') ) 
						{
							SephirothInterface(Parent).InfoBox.SetInfo(Skill, X + QuickSlotStartX + i * QuickSlotOffsetXPerBox + QuickSlotOffsetX_Between_GaugeHud, Controller.MouseY - QuickSlotOffsetYPerBox, True, C.ClipX, C.ClipY - YL - QuickSlotOffsetYPerBox);
							bSecondSkillInfo = True;
						}
						else 
						{
							SephirothInterface(Parent).SkillInfo.SetInfo(Skill, X + QuickSlotStartX + i * QuickSlotOffsetXPerBox + QuickSlotOffsetX_Between_GaugeHud, Controller.MouseY - QuickSlotOffsetYPerBox, True, C.ClipX, C.ClipY - YL - QuickSlotOffsetYPerBox);
							bSkillInfo = True;
						}
					}
				}
				else
				{
					SephirothPlayer(PlayerOwner).PSI.SepInventory.FindItemToArray(0, PC.GetHotkey(HotKeyPos), Items);
					if ( Items.Length > 0 ) 
					{
						SephirothInterface(Parent).ItemInfo.SetInfo(Items[0], X + QuickSlotStartX + i * QuickSlotOffsetXPerBox + QuickSlotOffsetX_Between_GaugeHud, Controller.MouseY - QuickSlotOffsetYPerBox, True, C.ClipX, C.ClipY - YL - QuickSlotOffsetYPerBox);
						bItemInfo = True;
					}
				}
			}

		}
	}

	if ( !bSecondSkillInfo )
		SephirothInterface(Parent).InfoBox.SetInfo(None);
	if ( !bSkillInfo )
		SephirothInterface(Parent).SkillInfo.SetInfo(None);
	if ( !bItemInfo )
		SephirothInterface(Parent).ItemInfo.SetInfo(None);

	if( IsCursorInsideComponent(Components[6]) )
		Controller.SetTooltip("Lv "$SephirothPlayer(PlayerOwner).PSI.PlayLevel$"   "$SephirothPlayer(PlayerOwner).PSI.ExpDisplay$"%");
	
	Components[5].Caption = string(QuickSlotIndex);
	
	MailCount = 0;
	if ( SephirothInterface(Parent).messenger == None )
	{	
		for( i = 0; i < SephirothPlayer(PlayerOwner).InBoxNotes.Length; i++ )
		{
			if( !SephirothPlayer(PlayerOwner).InBoxNotes[i].bRead ) 
			{				
				if( InStr(SephirothPlayer(PlayerOwner).InBoxNotes[i].From, "SYS@") == -1 ) 
				{
					MailCount++;
					break;
				}
			}
		}

		if( MailCount != 0 )
		{
			MakeBlinked();
			bOnMail = True;
			C.Style = ERenderStyle.STY_Alpha;
			C.DrawColor.A = nPointAlpha;
			C.SetPos(MailX, MailY);
			C.DrawTile(TextureResources[20].Resource,32,32,0,0,32,32);
			C.DrawColor.A = 255;
			if ( IsCursorInsideAt(MailX,MailY,32,32) ) 
			{
				Controller.SetTooltip(Localize("Inbox","NoteReceived","Sephiroth"));
			}
		}
		else
			bOnMail = False;
	}

	HelperCount = 0;


	if ( SephirothInterface(Parent).Inbox_Helper == None )
	{	
		for( i = 0; i < SephirothPlayer(PlayerOwner).InBoxNotes.Length; i++ )
		{
			if( !SephirothPlayer(PlayerOwner).InBoxNotes[i].bRead ) 
			{				
				if( InStr(SephirothPlayer(PlayerOwner).InBoxNotes[i].From, "SYS@") != -1 ) 
				{
					HelperCount++;
					break;
				}
			}
		}
		if( HelperCount != 0 )
		{
			if( !bOnMail ) 
			{		
				MakeBlinked();
			}			
			bOnHelperMail = True;
			C.Style = ERenderStyle.STY_Alpha;
			C.DrawColor.A = nPointAlpha;
			C.SetPos(MailX, MailY);
			C.DrawTile(TextureResources[21].Resource,32,32,0,0,32,32);
			C.DrawColor.A = 255;

			if ( IsCursorInsideAt(MailX,MailY,32,32) ) 
			{			
				Controller.SetTooltip(Localize("HelperUI","HelperReceived","SephirothUI"));
			}
		}
		else
			bOnHelperMail = False;		
	}
}


function bool OnKeyEvent(Interaction.EInputKey Key,Interaction.EInputAction Action,float Delta)
{
	local float X,Y;
	local SephirothPlayer PC;
	local int i;
	local Skill Skill;

	local int HotKeyPos;
	local int QuickSlotIndex;
	local int QuickSlotOffsetX_Between_GaugeHud;

	if( IsCursorInsideAt(0, 0, 5, 5) && Key == IK_RightMouse && Controller.bCtrlPressed && SephirothInterface(Parent).QuickSlotIndex == 1 )
		bOnUpExp = True;

	if( !IsCursorInsideInterface() )
		return False;

	QuickSlotIndex = SephirothInterface(Parent).QuickSlotIndex;


	if( bOnHelperMail == True && IsCursorInsideCircleAt(MailX, MailY, 32, 32) )
	{
		if ( Key == IK_LeftMouse && Action == IST_Release ) 
		{
			Parent.NotifyInterface(Self,INT_Command,"Helper");
			return True;
		}
	}

	if( bOnMail == True && IsCursorInsideCircleAt(MailX, MailY, 32, 32) )
	{
		if ( Key == IK_LeftMouse && Action == IST_Release ) 
		{
			Parent.NotifyInterface(Self,INT_Command,"Note");
			return True;
		}
	}
	if ( !(Key == IK_LeftMouse && Action == IST_Press) && !(Key == IK_RightMouse && Action == IST_Release) )
		return False;

	X = Components[0].X;
	Y = Components[0].Y;
	PC = SephirothPlayer(PlayerOwner);

	if ( IsCursorInsideAt(X + SkillBasicOffsetX,Y + SkillBasicOffsetY,32,32) ) 
	{
		if ( Key == IK_RightMouse && PC.PSI.Combo != None ) 
		{
			PC.SetHotSkill(0,"");
			SetSkillSprite(PC,0,False);
		}
		else if (Key == IK_LeftMouse && NewSkill != None && NewSkill.IsCombo()) 
		{
			PC.SetHotSkill(0,NewSkill.SkillName);
			NewSkill = None;
		}
		return True;
	}
	if ( IsCursorInsideAt(X + SkillComboOffsetX,Y + SkillComboOffsetY,32,32) ) 
	{
		if ( Key == IK_RightMouse && PC.PSI.Finish != None ) 
		{
			PC.SetHotSkill(1,"");
			SetSkillSprite(PC,1,False);
		}
		else if (Key == IK_LeftMouse && NewSkill != None && NewSkill.IsFinish()) 
		{
			PC.SetHotSkill(1,NewSkill.SkillName);
			NewSkill = None;
		}
		return True;
	}
	if ( IsCursorInsideAt(X + SkillMagicOffsetX,Y + SkillMagicOffsetY,32,32) ) 
	{
		if ( Key == IK_RightMouse && PC.PSI.Magic != None ) 
		{
			PC.SetHotSkill(2,"");
			SetSkillSprite(PC,3,False);
		}
		else if (Key == IK_LeftMouse && NewSkill != None && NewSkill.IsMagic()) 
		{
			PC.SetHotSkill(2,NewSkill.SkillName);
			NewSkill = None;
		}
		return True;
	}

	if( Controller.DragSource != None && Controller.DragSource.IsInState('Dragging') )
		return False;

	if( Controller.DragSource == None )
	{
		X = Components[0].X;
		Y = Components[0].Y;

		for ( i = 0;i < QuickSlotRows;i++ ) 
		{
			if( i >= 6 )
				QuickSlotOffsetX_Between_GaugeHud = class 'QuickKeyConst'.Default.QuickSlotOffsetX_Between_GaugeHud;
			else
				QuickSlotOffsetX_Between_GaugeHud = 0;

			if ( IsCursorInsideAt(X + QuickSlotStartX + i * QuickSlotOffsetXPerBox + QuickSlotOffsetX_Between_GaugeHud,Y + QuickSlotStartY,32,32) ) 
			{
				HotKeyPos = QuickSlotIndex * QuickSlotRows + i;
				if ( PC.GetHotkey(HotKeyPos) != "" ) 
				{
					if ( Key == IK_RightMouse ) 
					{
						PC.SetHotkey(HotKeyPos, class'GConst'.Default.BTNone,"");
						SetHotkeySprite(PC, QuickSlotIndex, i, False);
						PC.Net.NotiSaveShortcut();
					}
					else if (Key == IK_LeftMouse)
					{
						if( PC.PSI.QuickKeys[HotKeyPos].Type == class'GConst'.Default.BTSkill )
						{
							Skill = PC.QuerySkillByName(PC.PSI.QuickKeys[HotKeyPos].KeyName);
							if( Skill != None && Skill.IsA('SecondSkill') )
								return True;
						}
						Parent.NotifyInterface(Self,INT_Command,"ApplyHotKey"@HotKeyPos);
					}
				}
				return True;
			}
			else if(IsCursorInsideAt(X + QuickSlotStartX + i * QuickSlotOffsetXPerBox + QuickSlotOffsetX_Between_GaugeHud,Y + QuickSlotStartY - QuickSlotOffsetYPerBox,32,32)) 
			{	
				HotKeyPos = QuickSlotIndex_for_F1 * QuickSlotRows + i;
				if ( PC.GetHotkey(HotKeyPos) != "" ) 
				{
					if ( Key == IK_RightMouse ) 
					{
						PC.SetHotkey(HotKeyPos, class'GConst'.Default.BTNone,"");
						SetHotkeySprite(PC, QuickSlotIndex, i, False);
						PC.Net.NotiSaveShortcut();
					}
					else if (Key == IK_LeftMouse)
					{
						if( PC.PSI.QuickKeys[HotKeyPos].Type == class'GConst'.Default.BTSkill )
						{
							Skill = PC.QuerySkillByName(PC.PSI.QuickKeys[HotKeyPos].KeyName);
							if( Skill != None && Skill.IsA('SecondSkill') )
								return True;
						}
						Parent.NotifyInterface(Self,INT_Command,"ApplyHotKey"@HotKeyPos);
					}
				}
				return True;
			}


		}
	}

}


function bool IsCursorInsideInterface()
{	
	return ( IsCursorInsideComponent(Components[1]) || IsCursorInsideComponent(Components[2]) || IsCursorInsideComponent(Components[9]) || IsCursorInsideAt(MailX,MailY,32,32) );
}

function bool Drop()
{
	local SephirothItem ISI;
	local Skill Skill;
	local int i,j,k;
	local string ModelName;
	local SephirothPlayer PC;
	local SephirothItem Item;
	local float X,Y;
	local int SelectedNum;

	local int HotKeyPos;
	local int QuickSlotIndex;

	local int QuickSlotOffsetX_Between_GaugeHud;

	QuickSlotIndex = SephirothInterface(Parent).QuickSlotIndex;		

	if( Controller.SelectedList.Length > 1 )
		return False;

	ISI = SephirothItem(Controller.SelectedList[0]);
	Skill = Skill(Controller.SelectedList[0]);

	PC = SephirothPlayer(PlayerOwner);

	if ( Controller.DragSource != None && Controller.DragSource.IsA('MenuList') ) 
	{			
		X = Components[0].X;
		Y = Components[0].Y;

		for( i = 0 ; i < QuickSlotRows ; i++ )
		{
			if( i >= 6 )
				QuickSlotOffsetX_Between_GaugeHud = class 'QuickKeyConst'.Default.QuickSlotOffsetX_Between_GaugeHud;
			else
				QuickSlotOffsetX_Between_GaugeHud = 0;
			if( IsCursorInSideAt(X + QuickSlotStartX + i * QuickSlotOffsetXPerBox + QuickSlotOffsetX_Between_GaugeHud,Y + QuickSlotStartY,32,32) )
			{
				HotKeyPos = QuickSlotIndex * QuickSlotRows + i;

				switch(MenuList(Controller.selectedlist[0]).icon) 
				{
					case class'MenuList'.Default.Info:
						PC.SetHotKey(HotKeyPos, class'GConst'.Default.BTMenu,"Info");
						break;						
					case class'MenuList'.Default.WorldMap:	
						PC.SetHotKey(HotKeyPos, class'GConst'.Default.BTMenu,"WorldMap");
						break;
					case class'MenuList'.Default.PetUI:
						PC.SetHotKey(HotKeyPos, class'GConst'.Default.BTMenu,"PetUI");
						break;
					case class'MenuList'.Default.InventoryBag:
						PC.SetHotKey(HotKeyPos, class'GConst'.Default.BTMenu,"InventoryBag");									
						break;
					case class'MenuList'.Default.Party:
						PC.SetHotKey(HotKeyPos, class'GConst'.Default.BTMenu,"Party");
						break;
					case class'MenuList'.Default.PetBag:
						PC.SetHotKey(HotKeyPos, class'GConst'.Default.BTMenu,"PetBag");
						break;
					case class'MenuList'.Default.Portal:
						PC.SetHotKey(HotKeyPos, class'GConst'.Default.BTMenu,"Portal");
						break;
					case class'MenuList'.Default.ClanInterface:
						PC.SetHotKey(HotKeyPos, class'GConst'.Default.BTMenu,"ClanInterface");
						break;
					case class'MenuList'.Default.Booth:
						PC.SetHotKey(HotKeyPos, class'GConst'.Default.BTMenu,"Booth");
						break;
					case class'MenuList'.Default.SkillTree:
						PC.SetHotKey(HotKeyPos, class'GConst'.Default.BTMenu,"SkillTree");						
						break;
					case class'MenuList'.Default.Friend:
						PC.SetHotKey(HotKeyPos, class'GConst'.Default.BTMenu,"Friend");
						break;
					case class'MenuList'.Default.Animation:
						PC.SetHotKey(HotKeyPos, class'GConst'.Default.BTMenu,"Animation");
						break;
					case class'MenuList'.Default.Quest:
						PC.SetHotKey(HotKeyPos, class'GConst'.Default.BTMenu,"Quest");
						break;
					case class'MenuList'.Default.MenuListMessage:
						PC.SetHotKey(HotKeyPos, class'GConst'.Default.BTMenu,"message");
						break;
					case class'MenuList'.Default.BattleInfo:
						PC.SetHotKey(HotKeyPos, class'GConst'.Default.BTMenu,"BattleInfo");
						break;
					case class'MenuList'.Default.Option:
						PC.SetHotKey(HotKeyPos, class'GConst'.Default.BTMenu,"Option");
						break;
					case class'MenuList'.Default.Help:
						PC.SetHotKey(HotKeyPos, class'GConst'.Default.BTMenu,"Help");
						break;
				}
				SetHotkeySprite(PC, QuickSlotIndex, i, True);
				PC.Net.NotiSaveShortcut();
				return True;

			}


			else if(IsCursorInSideAt(X + QuickSlotStartX + i * QuickSlotOffsetXPerBox + QuickSlotOffsetX_Between_GaugeHud,Y + QuickSlotStartY - QuickSlotOffsetYPerBox,32,32))
			{
				HotKeyPos = QuickSlotIndex_for_F1 * QuickSlotRows + i;				

				switch(MenuList(Controller.selectedlist[0]).icon) 
				{
					case class'MenuList'.Default.Info:
						PC.SetHotKey(HotKeyPos, class'GConst'.Default.BTMenu,"Info");
						break;						
					case class'MenuList'.Default.WorldMap:	
						PC.SetHotKey(HotKeyPos, class'GConst'.Default.BTMenu,"WorldMap");
						break;
					case class'MenuList'.Default.PetUI:
						PC.SetHotKey(HotKeyPos, class'GConst'.Default.BTMenu,"PetUI");
						break;
					case class'MenuList'.Default.InventoryBag:
						PC.SetHotKey(HotKeyPos, class'GConst'.Default.BTMenu,"InventoryBag");									
						break;
					case class'MenuList'.Default.Party:
						PC.SetHotKey(HotKeyPos, class'GConst'.Default.BTMenu,"Party");
						break;
					case class'MenuList'.Default.PetBag:
						PC.SetHotKey(HotKeyPos, class'GConst'.Default.BTMenu,"PetBag");
						break;
					case class'MenuList'.Default.Portal:
						PC.SetHotKey(HotKeyPos, class'GConst'.Default.BTMenu,"Portal");
						break;
					case class'MenuList'.Default.ClanInterface:
						PC.SetHotKey(HotKeyPos, class'GConst'.Default.BTMenu,"ClanInterface");
						break;
					case class'MenuList'.Default.Booth:
						PC.SetHotKey(HotKeyPos, class'GConst'.Default.BTMenu,"Booth");
						break;
					case class'MenuList'.Default.SkillTree:
						PC.SetHotKey(HotKeyPos, class'GConst'.Default.BTMenu,"SkillTree");						
						break;
					case class'MenuList'.Default.Friend:
						PC.SetHotKey(HotKeyPos, class'GConst'.Default.BTMenu,"Friend");
						break;
					case class'MenuList'.Default.Animation:
						PC.SetHotKey(HotKeyPos, class'GConst'.Default.BTMenu,"Animation");
						break;
					case class'MenuList'.Default.Quest:
						PC.SetHotKey(HotKeyPos, class'GConst'.Default.BTMenu,"Quest");
						break;
					case class'MenuList'.Default.MenuListMessage:
						PC.SetHotKey(HotKeyPos, class'GConst'.Default.BTMenu,"message");
						break;
					case class'MenuList'.Default.BattleInfo:
						PC.SetHotKey(HotKeyPos, class'GConst'.Default.BTMenu,"BattleInfo");
						break;
					case class'MenuList'.Default.Option:
						PC.SetHotKey(HotKeyPos, class'GConst'.Default.BTMenu,"Option");
						break;
					case class'MenuList'.Default.Help:
						PC.SetHotKey(HotKeyPos, class'GConst'.Default.BTMenu,"Help");
						break;
				}
				SetHotkeySprite(PC, QuickSlotIndex_for_F1, i, True);
				return True;
				
			}
		}
	
	}

	else if (ISI != None && Controller.DragSource != None) 
	{

		if ( Controller.DragSource.IsA('CBag') ) 
		{
			X = Components[0].X;
			Y = Components[0].Y;


			for ( i = 0;i < QuickSlotRows;i++ )
			{
				if( i >= 6 )
					QuickSlotOffsetX_Between_GaugeHud = class 'QuickKeyConst'.Default.QuickSlotOffsetX_Between_GaugeHud;
				else
					QuickSlotOffsetX_Between_GaugeHud = 0;

				if ( IsCursorInsideAt(X + QuickSlotStartX + i * QuickSlotOffsetXPerBox + QuickSlotOffsetX_Between_GaugeHud,Y + QuickSlotStartY,32,32) )
				{					
					HotKeyPos = QuickSlotIndex * QuickSlotRows + i;

					if ( PC.GetHotkey(HotKeyPos) != "" )
					{
						Item = SephirothPlayer(PlayerOwner).PSI.SepInventory.FirstMatched(0, PC.GetHotkey(HotKeyPos));

						if ( Item != None && Item.TypeName == ISI.TypeName )
							return True;
					}

					if ( ISI.IsPotion() || ISI.IsEvent() ) 
					{
						PC.SetHotkey(HotKeyPos, class'GConst'.Default.BTPotion,ISI.TypeName);
						SetHotkeySprite(PC, QuickSlotIndex, i, True);
						SephirothInterface(Parent).CacheHotkey(ISI.TypeName, ISI.ModelName);
						PC.Net.NotiSaveShortcut();
					}
					else if (ISI.IsUse() && ISI.Amount != -1 && ISI.DetailType != ISI.IDT_Gem && ISI.Width * ISI.Height == 1) 
					{
						PC.SetHotkey(HotKeyPos, class'GConst'.Default.BTScroll,ISI.TypeName);
						SetHotkeySprite(PC, QuickSlotIndex, i, True);
						SephirothInterface(Parent).CacheHotkey(ISI.TypeName, ISI.ModelName);
						PC.Net.NotiSaveShortcut();
					}
					else
						PC.myHud.AddMessage(2,Localize("Warnings","NoProperHotkeyItem","Sephiroth"),class'Canvas'.Static.MakeColor(255,255,255));
				
					return True;
				}

			
				else if (IsCursorInsideAt(X + QuickSlotStartX + i * QuickSlotOffsetXPerBox + QuickSlotOffsetX_Between_GaugeHud,Y + QuickSlotStartY - QuickSlotOffsetYPerBox,32,32))
				{
					HotKeyPos = QuickSlotIndex_for_F1 * QuickSlotRows + i;

					if ( PC.GetHotkey(HotKeyPos) != "" )
					{
						Item = SephirothPlayer(PlayerOwner).PSI.SepInventory.FirstMatched(0, PC.GetHotkey(HotKeyPos));

						if ( Item != None && Item.TypeName == ISI.TypeName )
							return True;
					}

					if ( ISI.IsPotion() || ISI.IsEvent() ) 
					{
						PC.SetHotkey(HotKeyPos, class'GConst'.Default.BTPotion,ISI.TypeName);
						SetHotkeySprite(PC, QuickSlotIndex_for_F1, i, True);
						SephirothInterface(Parent).CacheHotkey(ISI.TypeName, ISI.ModelName);
						PC.Net.NotiSaveShortcut();
					}
					else if (ISI.IsUse() && ISI.Amount != -1 && ISI.DetailType != ISI.IDT_Gem && ISI.Width * ISI.Height == 1) 
					{
						PC.SetHotkey(HotKeyPos, class'GConst'.Default.BTScroll,ISI.TypeName);
						SetHotkeySprite(PC, QuickSlotIndex_for_F1, i, True);
						SephirothInterface(Parent).CacheHotkey(ISI.TypeName, ISI.ModelName);
						PC.Net.NotiSaveShortcut();
					}
					else
						PC.myHud.AddMessage(2,Localize("Warnings","NoProperHotkeyItem","Sephiroth"),class'Canvas'.Static.MakeColor(255,255,255));
				
					return True;
				}
			}
		}
	}

	else if (Skill != None && Controller.DragSource != None) 
	{
		if ( Controller.DragSource.IsA('CSkillTree') ) 
		{
			X = Components[0].X;
			Y = Components[0].Y;
			if ( Skill.IsCombo() && IsCursorInsideAt(X + SkillBasicOffsetX,Y + SkillBasicOffsetY,32,32) ) 
			{
				PC.SetHotSkill(0,Skill.SkillName);
				return True;
			}
			if ( Skill.IsFinish() && IsCursorInsideAt(X + SkillComboOffsetX,Y + SkillComboOffsetY,32,32) ) 
			{
				PC.SetHotSkill(1,Skill.SkillName);
				return True;
			}
			if ( Skill.IsMagic() && IsCursorInsideAt(X + SkillMagicOffsetX,Y + SkillMagicOffsetY,32,32) ) 
			{
				PC.SetHotSkill(2,Skill.SkillName);
				return True;
			}
			for ( i = 0;i < QuickSlotRows;i++ ) 
			{	
				if( i >= 6 )
					QuickSlotOffsetX_Between_GaugeHud = class 'QuickKeyConst'.Default.QuickSlotOffsetX_Between_GaugeHud;
				else
					QuickSlotOffsetX_Between_GaugeHud = 0;		
				

				if ( IsCursorInsideAt(X + QuickSlotStartX + i * QuickSlotOffsetXPerBox + QuickSlotOffsetX_Between_GaugeHud,Y + QuickSlotStartY,32,32) ) 
				{
					HotKeyPos = QuickSlotIndex * QuickSlotRows + i;
					PC.SetHotkey(HotKeyPos, class'GConst'.Default.BTSkill,Skill.SkillName);
					SetHotkeySprite(PC, QuickSlotIndex, i, True);
					PC.Net.NotiSaveShortcut();
					return True;
				}
				else if (IsCursorInsideAt(X + QuickSlotStartX + i * QuickSlotOffsetXPerBox + QuickSlotOffsetX_Between_GaugeHud,Y + QuickSlotStartY - QuickSlotOffsetYPerBox,32,32)) 
				{
					HotKeyPos = QuickSlotIndex_for_F1 * QuickSlotRows + i;
					PC.SetHotkey(HotKeyPos, class'GConst'.Default.BTSkill,Skill.SkillName);
					SetHotkeySprite(PC, QuickSlotIndex_for_F1, i, True);
					Skill = PC.QuerySkillByName(PC.PSI.QuickKeys[HotKeyPos].KeyName);
					PC.Net.NotiSaveShortcut();
					return True;					
				}
				
			}

		}
		if( Skill.IsA('SecondSkill') )
		{
			X = Components[0].X;
			Y = Components[0].Y;
			for( i = 0 ; i < QuickSlotRows ; i++ )
			{
				if( i >= 6 )
					QuickSlotOffsetX_Between_GaugeHud = class 'QuickKeyConst'.Default.QuickSlotOffsetX_Between_GaugeHud;
				else
					QuickSlotOffsetX_Between_GaugeHud = 0;
				if( IsCursorInSideAt(X + QuickSlotStartX + i * QuickSlotOffsetXPerBox + QuickSlotOffsetX_Between_GaugeHud,Y + QuickSlotStartY,32,32) )
				{
					HotKeyPos = QuickSlotIndex * QuickSlotRows + i;
					PC.SetHotKey(HotKeyPos, class'GConst'.Default.BTSkill,Skill.SkillName);
					SetHotkeySprite(PC, QuickSlotIndex, i, True);
					PC.Net.NotiSaveShortcut();
					return True;
				}

				else if (IsCursorInsideAt(X + QuickSlotStartX + i * QuickSlotOffsetXPerBox + QuickSlotOffsetX_Between_GaugeHud,Y + QuickSlotStartY - QuickSlotOffsetYPerBox,32,32)) 
				{
					HotKeyPos = QuickSlotIndex_for_F1 * QuickSlotRows + i;
					PC.SetHotKey(HotKeyPos, class'GConst'.Default.BTSkill,Skill.SkillName);
					SetHotkeySprite(PC, QuickSlotIndex_for_F1, i, True);
					PC.Net.NotiSaveShortcut();
					return True;
				}
			}
		}
	}
	return False;
}

defaultproperties
{
	Components(1)=(XL=800.000000,YL=120.000000,OffsetYL=-47.000000)
	Components(2)=(XL=540.000000,YL=40.000000,OffsetXL=125.000000)
	Components(3)=(OffsetXL=665.000000)
	Components(7)=(OffsetXL=685.000000,OffsetYL=14.000000)
	Components(9)=(OffsetYL=-41.000000)
	TextureResources(0)=(Path="SlotS1")
	TextureResources(27)=(Path="Gauge_ExpS",UL=668.000000)
	TextureResources(28)=(Path="SlotS2")
}

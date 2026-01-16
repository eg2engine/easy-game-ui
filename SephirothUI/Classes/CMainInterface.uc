class CMainInterface extends CSelectable;

const BN_Menu = 1;
const BN_Info = 2;
const BN_Bag = 3;
const BN_Skill = 4;
const BN_Party = 5;
const BN_Portal = 6;
const BN_Quest = 7;
const BN_Anim = 8;
const BN_HotKeyUp = 9;
const BN_HotKeyDown = 10;
const BN_MainMenuButton = 11;
const BN_ShopButton = 12;

//modified by yj	F1~F12������ ����Ű�� index
const QuickSlotIndex_for_F1 = 2;


var Texture SkillSprites[3];


// --------------------------------------------------------------------
// ����Ű ������ ǥ���ϱ� ���ؼ� ���ǵ� ������.
// OnInit()�Լ����� array�� ������ �ʱ�ȭ�ȴ�.
struct HotKeySpriteContainer
{
	var Texture HotkeySprite;
};
struct HotKeyStruct
{
	var array<HotKeySpriteContainer> HotkeySprites;
};
var array<HotKeyStruct> HotkeyArray;

// ����Ű ���Կ� ���õ� ������. QuickKeyConstŬ�������� �޾ƿ´�.
var int QuickSlotColumns;			// ������ �� �ٿ� Ű�� ������ �� ������ ������ ����
var int QuickSlotRows;				// ������ �� ���� ������ ����

var int SkillBasicOffsetX;			// �⺻ ��ų������ ���� ��ġ x ��ǥ
var int SkillBasicOffsetY;			// �⺻ ��ų������ ���� ��ġ y ��ǥ
var int SkillComboOffsetX;			// �޺� ��ų������ ���� ��ġ x ��ǥ
var int SkillComboOffsetY;			// �޺� ��ų������ ���� ��ġ y ��ǥ
var int SkillMagicOffsetX;			// ���� ��ų������ ���� ��ġ x ��ǥ
var int SkillMagicOffsetY;			// ���� ��ų������ ���� ��ġ y ��ǥ

var int QuickSlotStartX;			// ����Ű ������ ù��°�� x��ǥ
var int QuickSlotStartY;			// ����Ű ������ ù��°�� y��ǥ
var int QuickSlotOffsetXPerBox;		// ���� �������� �Űܰ��µ� �־ �ʿ��� ������



//**********
var int QuickSlotOffsetYPerBox;

//******


// --------------------------------------------------------------------

//add neive : ����ġ�������� Level Up Soon ���� ������ ��� -----------
var int nLevelUpColor;
var bool bOnUp;
var float fTempExp;
var float nUpExp; // ����ġ ��µ��� �����ش�~
var bool bOnUpExp; // ����ġ ��µ��� �����ֱ� on off
//---------------------------------------------------------------------

var bool bJustLevelUp;
var float LevelUpTime;
var float LearnSkillTime;
var Skill NewSkill;
var Texture SkillMark;

//@by wj(08/23)
var ConstantColor BgColor;
var FinalBlend BgBlend;

//add neive : �˸��̿� --------------------------------------------------------
var bool bOnMail;
var bool bOnHelperMail;
var int MailMX, MailMY;
var int MailX, MailY;
var int HelperX, HelperY;

var int bAlphaDir;       // ���İ��� Ŀ���� �� (0) or �۾����� �� (1)
var int nPointAlpha;

var int LastFontSizeCheckLevel;
var float m_sLvExpSizeXL;
var float m_sLvExpSizeYL;

var string m_sLimit;

function OnInit()
{
	local int i;

	QuickSlotColumns = class 'QuickKeyConst'.Default.QuickSlotColumns;
	QuickSlotRows = class 'QuickKeyConst'.Default.QuickSlotRows;
	SkillBasicOffsetX = class 'QuickKeyConst'.Default.SkillBasicOffsetX;
	SkillBasicOffsetY = class 'QuickKeyConst'.Default.SkillBasicOffsetY;
	SkillComboOffsetX = class 'QuickKeyConst'.Default.SkillComboOffsetX;
	SkillComboOffsetY = class 'QuickKeyConst'.Default.SkillComboOffsetY;
	SkillMagicOffsetX = class 'QuickKeyConst'.Default.SkillMagicOffsetX;
	SkillMagicOffsetY = class 'QuickKeyConst'.Default.SkillMagicOffsetY;
	QuickSlotStartX = class 'QuickKeyConst'.Default.QuickSlotStartX;
	QuickSlotStartY = class 'QuickKeyConst'.Default.QuickSlotStartY;
	QuickSlotOffsetXPerBox =	class 'QuickKeyConst'.Default.QuickSlotOffsetXPerBox;
	QuickSlotOffsetYPerBox = class 'QuickKeyConst'.Default.QuickSlotOffsetYPerBox;		//modified by yj

	HotkeyArray.Length = QuickSlotColumns;
	for( i = 0; i < HotkeyArray.Length; i++ )
		HotkeyArray[i].HotkeySprites.Length = QuickSlotRows;
	
	// ����Ű ���� ��ư
	SetComponentTextureId(Components[3],1, -1,3,2);
	SetComponentTextureId(Components[4],4, -1,6,5);
	SetComponentNotify(Components[3],BN_HotKeyUp,Self);
	SetComponentNotify(Components[4],BN_HotKeyDown,Self);

	// �޴� ��ư
	SetComponentTextureId(Components[7],7, -1,9,8);
	SetComponentNotify(Components[7],BN_MainMenuButton,Self);
	// ���� ��ư
	SetComponentTextureId(Components[8],10, -1,12,11);
	SetComponentnotify(Components[8],BN_ShopButton,Self);

	// Menu icons
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


	//@by wj(08/18)------
	BgColor = new(None) class'ConstantColor';
	BgBlend = new(None) class'FinalBlend';

	BgBlend.Material = BgColor;
	BgBlend.FrameBufferBlending = BgBlend.EFrameBufferBlending.FB_AlphaBlend;
	BgColor.Color = class'Canvas'.Static.MakeColor(0,0,255,100);
	//-------------------


	//add neive : ����ġ ������ ������ ��� -----------------------------------
	nLevelUpColor = 0;
	bOnUp = False;
	nUpExp = -100;
	fTempExp = -100;
	bOnUpExp = False;
	//-------------------------------------------------------------------------

	nPointAlpha = 155;
	bAlphaDir = 0;
	
	m_sLimit = Localize("CItemInfoBox", "S_Limit", "SephirothUI");

	GotoState('Nothing');
}

event Tick(float DeltaTime)
{
}

function OnFlush()
{
	SephirothInterface(Parent).ItemInfo.SetInfo(None);
	SephirothInterface(Parent).SkillInfo.SetInfo(None);
	SephirothInterface(Parent).InfoBox.SetInfo(None);
	DynamicUnloadObject(BgColor);
	DynamicUnloadObject(BgBlend);
	Super.OnFlush();
}

function Layout(Canvas C)
{
	local int i;

	MailX = C.ClipX / 2 + 325;
	MailY = C.ClipY - MailMY - 5;

	if( bNeedLayoutUpdate )	
	{
		MoveComponentId(0,True,C.ClipX / 2 - Components[1].XL / 2 + 3,C.ClipY - Components[0].YL);
		for ( i = 1;i < Components.Length;i++ )
			MoveComponentId(i);	
		bNeedLayoutUpdate = False;
	}
	Super.Layout(C);
}

function UpdateLayout()
{
	bNeedLayoutUpdate = True;
}

function vector PushComponentVector(int CmpId)
{
	local vector V;
	switch (CmpId) 
	{
		case 6: // Exp
			V.X = 0;
			V.Y = SephirothPlayer(PlayerOwner).PSI.ExpDisplay;
			V.Z = 100.0;
			break;
	}
	return V;
}


function NotifyComponent(int CmpId,int NotifyId,optional string Command)
{
	switch (NotifyId) 
	{
		case BN_Menu:
			Parent.NotifyInterface(Self,INT_Command,"MainMenu");
			break;
		case BN_Info:
			bJustLevelUp = False;
			Parent.NotifyInterface(Self,INT_Command,"Info");
			break;
		case BN_Bag:
			Parent.NotifyInterface(Self,INT_Command,"InventoryBag");
			break;
		case BN_Skill:
			NewSkill = None;
			Parent.NotifyInterface(Self,INT_Command,"SkillTree");
			break;
		case BN_Party:
			Parent.NotifyInterface(Self,INT_Command,"Party");
			break;
		case BN_Portal:
			Parent.NotifyInterface(Self,INT_Command,"Portal");
			break;
		case BN_Quest:
			Parent.NotifyInterface(Self,INT_Command,"Quest");
			break;
		case BN_Anim:
			Parent.NotifyInterface(Self,INT_Command,"AnimationMenu");
			break;
		case BN_HotKeyUp:
			Parent.NotifyInterface(Self,INT_Command,"HotKeyUp");
			break;
		case BN_HotKeyDown:
			Parent.NotifyInterface(Self,INT_Command,"HotKeyDown");
			break;
		case BN_MainMenuButton:
			Parent.NotifyInterface(Self,INT_Command,"MainMenuButton");
			break;
		case BN_ShopButton:
			Parent.NotifyInterface(Self,INT_Command,"ShopButton");
			break;
	}
}

function SetHotkeySprite(SephirothPlayer PC, int SlotIndex, int BoxIndex, bool bSet)
{
	local Skill Skill;
	local SephirothItem ISI;
	local string TextureName;
	local string HotkeyName;
	local byte HotkeyType;

	local int HotKeyPos;
	HotKeyPos = SlotIndex * QuickSlotRows + BoxIndex;

	HotkeyName = PC.PSI.QuickKeys[HotKeyPos].KeyName;
	HotkeyType = PC.PSI.QuickKeys[HotKeyPos].Type;
	if ( !bSet )
	{
		HotkeyArray[SlotIndex].HotkeySprites[BoxIndex].HotkeySprite = None;
	}
	else if (HotkeyName != "")
	{
		switch (HotkeyType)
		{
			case class'GConst'.Default.BTSkill:						
				Skill = PC.QuerySkillByName(HotkeyName);
				if ( Skill != None ) 
				{
								//@by wj(08/16)------
					if( Skill.IsA('SecondSkill') )
					{
						if( Skill.bLearned )
							TextureName = "SecondSkillUI.SkillIcons."$Skill.SkillName$"S";
					}
				//-------------------
					else if (Skill.bEnabled && Skill.bLearned)
						TextureName = "SkillSprites."$Skill.BookName$"."$Skill.SkillName$"N";
					else
						TextureName = "SkillSprites."$Skill.BookName$"."$Skill.SkillName$"D";
				}
				break;

			case class'GConst'.Default.BTMenu:		//modified by yj
				switch(HotkeyName) 
				{
					case "Info" :
						TextureName = "UI_2009.Icon_Win01L_";
						break;			
					case "WorldMap" :
						TextureName = "UI_2009.Icon_Win07L_";
						break;
					case "PetUI":
						TextureName = "UI_2009.Icon_Win13L_";	
						break;				
					case "InventoryBag" :
						TextureName = "UI_2009.Icon_Win02L_";
						break;				
					case "Party":
						TextureName = "UI_2009.Icon_Win08L_";			
						break;
					case "PetBag":
						TextureName = "UI_2009.Icon_Win14L_";		
						break;
					case "Portal":
						TextureName = "UI_2009.Icon_Win03L_";			
						break;
					case "ClanInterface":
						TextureName = "UI_2009.Icon_Win09L_";
						break;
					case "Booth":
						TextureName = "UI_2009.Icon_Win15L_";		
						break;
					case "SkillTree" :
						TextureName = "UI_2009.Icon_Win04L_";
						break;		
					case "Friend":
						TextureName = "UI_2009.Icon_Win10L_";		
						break;
					case "Animation":
						TextureName = "UI_2009.Icon_Win16L_";
						break;
					case "Quest":
						TextureName = "UI_2009.Icon_Win05L_";			
						break;
					case "message":
						TextureName = "UI_2009.Icon_Win11L_";
						break;
					case "BattleInfo":
						TextureName = "UI_2009.Icon_Win17L_";
						break;
					case "Option":
						TextureName = "UI_2009.Icon_Win06L_";		
						break;
					case "Help":
						TextureName = "UI_2009.Icon_Win12L_";	
						break;	
				}
				break;
				
				break;
		//------------------------------------


			case class'GConst'.Default.BTPotion:
			case class'GConst'.Default.BTScroll:
				ISI = SephirothPlayer(PlayerOwner).PSI.SepInventory.FirstMatched(0, HotkeyName);
				if ( ISI != None )
				{
					if( ISI.IsMarket() )
						TextureName = "ItemSpritesM."$ISI.ModelName;
					else
						TextureName = "ItemSprites."$ISI.ModelName;
				
		
					if( ISI.IsEvent() )
						PC.PSI.QuickKeys[HotKeyPos].Amount = -99; //add neive : �Ⱓ�� ������ ����â ǥ��
					else
						PC.PSI.QuickKeys[HotKeyPos].Amount = PC.PSI.SepInventory.GetItemAmountSum(ISI.TypeName); //@by wj(12/02)

				//!@ ��Ű ĳ��, 2004.1.28,jhjung
					SephirothInterface(Parent).CacheHotkey(ISI.TypeName, ISI.ModelName);
				}
				else //�������� ��� ������� �κ��丮�� �������� ĳ���� ��Ű�������� �ҷ�����.2004.1.28,jhjung
				{
					HotkeyName = SephirothInterface(Parent).GetHotkeyModelName(HotkeyName);
					if ( HotkeyName != "" ) 
					{
						if( IsMarketItem(HotkeyName) )
							TextureName = "ItemSpritesM."$HotkeyName;
						else
							TextureName = "ItemSprites."$HotkeyName;
						PC.PSI.QuickKeys[HotKeyPos].Amount = 0;
					}
				}
				break;
		}	

		if ( TextureName != "" )
		{
			HotkeyArray[SlotIndex].HotkeySprites[BoxIndex].HotkeySprite = Texture(DynamicLoadObject(TextureName, class'Texture'));
		}
		else
		{
			PC.SetHotKey(HotKeyPos,class'GConst'.Default.BTNone,"");
		}
	}
}

function bool IsMarketItem(string sName)
{
	local string sTemp;
	sTemp = Mid(sName, 0, 7);

	if( sTemp == "Market_" )
		return True;

	return False;
}

function MakeBlinked()	//�����̰� �ϱ�
{
	if( bAlphaDir == 1 )
	{
		if( nPointAlpha > 55 )
			nPointAlpha -= 10;
		else
			bAlphaDir = 0;
	}
	else
	{
		if( nPointAlpha < 255 )
			nPointAlpha += 10;
		else
			bAlphaDir = 1;
	}
}

// 从 ChargeRate 计算剩余冷却时间（复用现有计算逻辑）
function float GetRemainingCooldownFromRate(SecondSkill SS, float ChargeRate, int iAvilityLevel)
{
	local float decCoolTime, TotalCooldownMS;
	
	if( SS == None || ChargeRate >= 1.0 || ChargeRate < 0 )
		return 0;
	
	// 计算减CD（与 GetChargeRate 中的逻辑一致）
	decCoolTime = 0;
	if( iAvilityLevel >= 3 && iAvilityLevel <= 5 )
	{
		if( SS.SkillName == "DeathHand" )
			decCoolTime = 15000;
		else if(SS.SkillName == "BlindMaker")
			decCoolTime = 10000;
	}
	
	// 计算总冷却时间（毫秒）
	TotalCooldownMS = SS.CoolTime * 1000 - decCoolTime + 500;
	
	// 从 ChargeRate 反推剩余时间（秒）
	return (TotalCooldownMS * (1.0 - ChargeRate)) / 1000;
}

// 快捷栏倒计时显示（入参单位：毫秒 ms）
// >= 60s   -> "分:秒"（秒两位）
// 10s~59s  -> "整数秒"
// < 10s    -> "秒.一位小数"（始终 1 位，且最小显示 0.1）
// <= 0     -> ""
function string FormatCooldownText(float RemainingSeconds)
{
	local float RemainingMs;
	local float RemainingSec;

	local int TotalSeconds;
	local int Minutes, Seconds;

	local int Tenths;
	local int SecPart, TenthPart;
	local float Epsilon;

	Epsilon = 0.0001;

	// 兼容你现有签名：RemainingSeconds 实际按毫秒解释
	RemainingMs = RemainingSeconds;

	if ( RemainingMs <= 0.0 )
		return "";

	RemainingSec = RemainingMs / 1000.0;

	// >= 60s：分:秒（用向下取整，避免 60.1s 显示成 1:01）
	if ( RemainingSec >= 60.0 )
	{
		TotalSeconds = int(RemainingSec + Epsilon);
		if ( TotalSeconds < 1 )
			TotalSeconds = 1;

		Minutes = TotalSeconds / 60;
		Seconds = TotalSeconds % 60;

		if ( Seconds < 10 )
			return string(Minutes)$":0"$string(Seconds);

		return string(Minutes)$":"$string(Seconds);
	}

	// 10s ~ <60s：显示整数秒（同样用向下取整，但最小夹到 1）
	if ( RemainingSec >= 10.0 )
	{
		TotalSeconds = int(RemainingSec + Epsilon);
		if ( TotalSeconds < 1 )
			TotalSeconds = 1;

		return string(TotalSeconds);
	}

	// < 10s：显示 1 位小数（使用十分之一秒离散化，降低 float 抖动）
	Tenths = int(RemainingSec * 10.0 + Epsilon);
	if ( Tenths < 1 )
		Tenths = 1; // 仍有剩余时，最小显示 0.1，避免出现 0.0 或提前消失

	SecPart = Tenths / 10;
	TenthPart = Tenths % 10;

	return string(SecPart)$"."$string(TenthPart);
}



function bool IsInsideCombo()
{
	local float X,Y;

	X = Components[1].X;
	Y = Components[1].Y;

	if( IsCursorInsideAt(X + SkillBasicOffsetX,Y + SkillBasicOffsetY,32,32) )
	{
		return True;
	}

	return False;
}

function bool IsInsideFinish()
{
	local float X,Y;

	X = Components[1].X;
	Y = Components[1].Y;

	if( IsCursorInsideAt(X + SkillComboOffsetX,Y + SkillComboOffsetY,32,32) )
	{
		return True;
	}

	return False;
}

function bool IsInsideMagic()
{
	local float X,Y;

	X = Components[1].X;
	Y = Components[1].Y;

	if( IsCursorInsideAt(X + SkillMagicOffsetX,Y + SkillMagicOffsetY,32,32) )
	{
		return True;
	}

	return False;
}


function DrawObject(Canvas C)
{
	local float X,Y,YL;
	local SephirothPlayer PC;
	local int i;//modified by yj
	local int Amount;
	local color OldColor;
	local byte OldStyle;
	local Skill Skill;
	local string TypeName;
	local array<SephirothItem> Items;
	local bool bSecondSkillInfo, bSkillInfo, bItemInfo;	
	local float ChargeOffset;	//@by wj(08/18)
	local float ChargeRate;		// 用于倒计时计算
	local float RemainingSeconds;	// 剩余冷却时间
	local string TimeText;		// 倒计时文本

	//add neive : �ε��� ��ο�� ---------------------------------------------
	local string sIndex;
	//-------------------------------------------------------------------------

	local int HotKeyPos;
	local int QuickSlotIndex;
	local CInterface TopInterface;

	TopInterface = SephirothInterface(Parent).ITopOnCursor;
	QuickSlotIndex = SephirothInterface(Parent).QuickSlotIndex;

	PC = SephirothPlayer(PlayerOwner);
	if ( PC == None || PC.PSI == None )
		return;

	X = Components[1].X;    //
	Y = Components[1].Y;    //

	// �⺻ ��ų 3��
	if ( PC.GetHotSkill(0) != "" && SkillSprites[0] == None ) SetSkillSprite(PC,0,True);		//skillsprite�� ���ʿ� �� �� ����� �� �ִ� ��ų
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
				C.SetRenderStyleAlpha();
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

	X = Components[1].X;
	Y = Components[1].Y;

	for ( i = 0;i < QuickSlotRows;i++ )
	{
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
				//@by wj(040809)------
				if( Skill != None && Skill.IsA('SecondSkill') && SecondSkill(Skill).SkillType == 6 )
				{
					if( Skill.bEnabled )
						HotKeyArray[QuickSlotIndex].HotkeySprites[i].HotkeySprite = Texture(DynamicLoadObject("SecondSkillUI.SkillIcons.TransformationS",class'Texture'));
					else
						HotKeyArray[QuickSlotIndex].HotkeySprites[i].HotkeySprite = Texture(DynamicLoadObject("SecondSkillUI.SkillIcons.TransformationSD",class'Texture'));
				}
				//---------------------
				C.Style = ERenderStyle.STY_Normal;
				C.SetPos(X + QuickSlotStartX + i * QuickSlotOffsetXPerBox, Y + QuickSlotStartY);
				//add neive : ��Ÿ���� 2�� �迭 ��ų ������ ��Ӱ� ǥ�� -------
				if( Skill.IsA('SecondSkill') )
				{
					if( Skill.bEnabled && SecondSkill(Skill).bCharged || SecondSkill(Skill).SkillType == 6 )
						C.SetDrawColor(255, 255, 255, 255);
					else
						C.SetDrawColor(100, 100, 100, 255);
				}
				else
					C.SetDrawColor(255, 255, 255, 255);
				//-------------------------------------------------------------
				C.DrawTile(HotKeyArray[QuickSlotIndex].HotkeySprites[i].HotkeySprite, 32, 32, 0, 0, 32, 32);

				if ( Skill != None )
					if( Skill.IsA('SecondSkill') && SecondSkill(Skill).SkillType != 6 )
					{
						if( !SecondSkill(Skill).bCharged )
						{							
							//add neive : 12�� ������ ��Ʈ ȿ�� ---------------------------------------
							SephirothPlayer(PlayerOwner).PSI.SetSetItemLevel();
							//-------------------------------------------------------------------------
							ChargeRate = SecondSkill(Skill).GetChargeRate(SephirothPlayer(PlayerOwner).PSI.SetAvilityLevel, PC.Level.TimeSeconds);
							ChargeOffset = 32 * ChargeRate;
							if( ChargeOffset >= 0 && ChargeOffset < 32 )
							{
								C.SetPos(X + QuickSlotStartX + i * QuickSlotOffsetXPerBox, Y + QuickSlotStartY);
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
										X + QuickSlotStartX + i * QuickSlotOffsetXPerBox, 
										Y + QuickSlotStartY, 
										32, 32);
								}
							}
						}
					}
			}

			else if (PC.PSI.QuickKeys[HotKeyPos].Type == class'GConst'.Default.BTMenu) 
			{		
		//modified by yj
				C.SetRenderStyleAlpha();
				C.SetPos(X + QuickSlotStartX + i * QuickSlotOffsetXPerBox, Y + QuickSlotStartY);
				C.DrawTile(HotKeyArray[SephirothInterface(Parent).QuickSlotIndex].HotkeySprites[i].HotkeySprite, 32, 32, 0, 0, 32, 32);

			}

			else 
			{	
				Amount = PC.PSI.QuickKeys[HotKeyPos].Amount;	//@by wj(12/02)			
				if ( Amount >= 0 ) 
				{
					C.SetRenderStyleAlpha();
					C.SetPos(X + QuickSlotStartX + i * QuickSlotOffsetXPerBox, Y + QuickSlotStartY);
					if ( Amount == 0 )
						C.SetDrawColor(128,128,128);
					C.DrawTile(HotKeyArray[SephirothInterface(Parent).QuickSlotIndex].HotkeySprites[i].HotkeySprite, 24, 24, 0, 0, 24, 24);
					
                    //C.SetKoreanTextAlign(ETextAlign.TA_BottomRight); //ETextAlign.TA_TopLeft);
					C.SetKoreanTextAlign(ETextAlign.TA_TopLeft);
					C.DrawKoreanText(Amount, X + QuickSlotStartX + i * QuickSlotOffsetXPerBox, Y + QuickSlotStartY, 32, 32);
				}

				//add neive : �Ⱓ�� ������ ����â ǥ�� -----------------------
				if( Amount == -99 )
				{
					C.SetRenderStyleAlpha();
					C.SetPos(X + QuickSlotStartX + i * QuickSlotOffsetXPerBox, Y + QuickSlotStartY);
					C.SetDrawColor(255,255,0);
					C.DrawTile(HotKeyArray[SephirothInterface(Parent).QuickSlotIndex].HotkeySprites[i].HotkeySprite, 24, 24, 0, 0, 24, 24);
					C.SetKoreanTextAlign(ETextAlign.TA_BottomRight); //ETextAlign.TA_TopLeft);
					C.DrawKoreanText(m_sLimit, X + QuickSlotStartX + i * QuickSlotOffsetXPerBox, Y + QuickSlotStartY, 32, 32);
				}
				//-------------------------------------------------------------
			}				
		}
	}

	for ( i = 0;i < QuickSlotRows;i++ )		//modified by yj    F1��		���Ŀ� �� ����� ����.
	{	
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
				//@by wj(040809)------
				if( Skill != None && Skill.IsA('SecondSkill') && SecondSkill(Skill).SkillType == 6 )
				{
					if( Skill.bEnabled )
						HotKeyArray[QuickSlotIndex_for_F1].HotkeySprites[i].HotkeySprite = Texture(DynamicLoadObject("SecondSkillUI.SkillIcons.TransformationS",class'Texture'));
					else
						HotKeyArray[QuickSlotIndex_for_F1].HotkeySprites[i].HotkeySprite = Texture(DynamicLoadObject("SecondSkillUI.SkillIcons.TransformationSD",class'Texture'));
				}
				//---------------------
				C.Style = ERenderStyle.STY_Normal;
				C.SetPos(X + QuickSlotStartX + i * QuickSlotOffsetXPerBox, Y + QuickSlotStartY - QuickSlotOffsetYPerBox);
				//add neive : ��Ÿ���� 2�� �迭 ��ų ������ ��Ӱ� ǥ�� -------
				if( Skill.IsA('SecondSkill') )
				{
					if( Skill.bEnabled && SecondSkill(Skill).bCharged || SecondSkill(Skill).SkillType == 6 )
						C.SetDrawColor(255, 255, 255, 255);
					else
						C.SetDrawColor(100, 100, 100, 255);
				}
				else
					C.SetDrawColor(255, 255, 255, 255);
				//-------------------------------------------------------------
				C.DrawTile(HotKeyArray[QuickSlotIndex_for_F1].HotkeySprites[i].HotkeySprite, 32, 32, 0, 0, 32, 32);

				if ( Skill != None )
					if( Skill.IsA('SecondSkill') && SecondSkill(Skill).SkillType != 6 )
					{
						if( !SecondSkill(Skill).bCharged )
						{							
							//add neive : 12�� ������ ��Ʈ ȿ�� ---------------------------------------
							SephirothPlayer(PlayerOwner).PSI.SetSetItemLevel();
							//-------------------------------------------------------------------------
							ChargeRate = SecondSkill(Skill).GetChargeRate(SephirothPlayer(PlayerOwner).PSI.SetAvilityLevel, PC.Level.TimeSeconds);
							ChargeOffset = 32 * ChargeRate;
							if( ChargeOffset >= 0 && ChargeOffset < 32 )
							{
								C.SetPos(X + QuickSlotStartX + i * QuickSlotOffsetXPerBox, Y + QuickSlotStartY - QuickSlotOffsetYPerBox);
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
										X + QuickSlotStartX + i * QuickSlotOffsetXPerBox, 
										Y + QuickSlotStartY - QuickSlotOffsetYPerBox, 
										32, 32);
								}
							}
						}
					}
			}

			else if (PC.PSI.QuickKeys[HotKeyPos].Type == class'GConst'.Default.BTMenu) 
			{		
		//modified by yj
				C.SetRenderStyleAlpha();
				C.SetPos(X + QuickSlotStartX + i * QuickSlotOffsetXPerBox, Y + QuickSlotStartY - QuickSlotOffsetYPerBox);
				C.DrawTile(HotKeyArray[QuickSlotIndex_for_F1].HotkeySprites[i].HotkeySprite, 32, 32, 0, 0, 32, 32);

			}

			else 
			{		
				Amount = PC.PSI.QuickKeys[HotKeyPos].Amount;	//@by wj(12/02)			
				if ( Amount >= 0 ) 
				{
					C.SetRenderStyleAlpha();
					C.SetPos(X + QuickSlotStartX + i * QuickSlotOffsetXPerBox, Y + QuickSlotStartY - QuickSlotOffsetYPerBox);
					if ( Amount == 0 )
						C.SetDrawColor(128,128,128);
					C.DrawTile(HotKeyArray[QuickSlotIndex_for_F1].HotkeySprites[i].HotkeySprite, 24, 24, 0, 0, 24, 24);
					C.SetKoreanTextAlign(ETextAlign.TA_TopLeft);
					C.DrawKoreanText(Amount, X + QuickSlotStartX + i * QuickSlotOffsetXPerBox, Y + QuickSlotStartY - QuickSlotOffsetYPerBox, 32, 32);
				}

				//add neive : �Ⱓ�� ������ ����â ǥ�� -----------------------
				if( Amount == -99 )
				{
					C.SetRenderStyleAlpha();
					C.SetPos(X + QuickSlotStartX + i * QuickSlotOffsetXPerBox, Y + QuickSlotStartY - QuickSlotOffsetYPerBox);
					C.SetDrawColor(255,255,0);
					C.DrawTile(HotKeyArray[QuickSlotIndex_for_F1].HotkeySprites[i].HotkeySprite, 24, 24, 0, 0, 24, 24);
					C.SetKoreanTextAlign(ETextAlign.TA_TopLeft);
					C.DrawKoreanText(m_sLimit, X + QuickSlotStartX + i * QuickSlotOffsetXPerBox, Y + QuickSlotStartY - QuickSlotOffsetYPerBox, 32, 32);
				}
				//-------------------------------------------------------------
			}
			
		}
	}

	//add neive : ����Űâ�� ���� �ε����� �׷��ش� ---------------------------
	C.SetDrawColor(222, 210, 63);
	
	for( i = 0; i < QuickSlotRows; i++ )
	{
		C.SetKoreanTextAlign(ETextAlign.TA_MiddleCenter);
		if( i == 9 )
			sIndex = "0";
		else if(i == 10)
			sIndex = "-";
		else if(i == 11)
			sIndex = "=";
		else
			sIndex = ""$(i + 1);

		C.DrawKoreanText(sIndex, 170 + (i * 37) + (C.ClipX / 2 - 727 / 2), C.ClipY - 25, 0, 0);  //modified by yj		//�Ѱ��� ������� �����ȰŶ�
		C.DrawKoreanText("F"$(i + 1), 168 + (i * 37) - 3 + (C.ClipX / 2 - 727 / 2), C.ClipY - 22 - 48, 0, 0);  //modified by yj

	}


	//add neive : ����ġ �������� ������ ����ġ % �� ���ش� -------------------
	if( nUpExp == -100 )
	{
		fTempExp = SephirothPlayer(PlayerOwner).PSI.ExpDisplay;
		nUpExp = 0;
	}

	if( SephirothPlayer(PlayerOwner).PSI.ExpDisplay != fTempExp )
	{
		nUpExp = SephirothPlayer(PlayerOwner).PSI.ExpDisplay - fTempExp; // ȹ�����ġ
		fTempExp = SephirothPlayer(PlayerOwner).PSI.ExpDisplay;
	}

	//sIndex = "�ƢƢƢƢƢƢƢ�";
	//C.SetDrawColor(0, 0, 0, 50);
	//C.DrawKoreanText(sIndex, C.ClipX/2, C.ClipY-8, 0, 0);
	sIndex = "Lv "$(SephirothPlayer(PlayerOwner).PSI.PlayLevel)$"   ("$(SephirothPlayer(PlayerOwner).PSI.ExpDisplay)$"%)";
	C.SetDrawColor(255, 255, 255);
	if( LastFontSizeCheckLevel != SephirothPlayer(PlayerOwner).PSI.PlayLevel )
	{
		LastFontSizeCheckLevel = SephirothPlayer(PlayerOwner).PSI.PlayLevel;
		C.TextSize(sIndex, m_sLvExpSizeXL, m_sLvExpSizeYL);
	}
	//C.DrawKoreanText(sIndex, (C.ClipX-m_sLvExpSizeXL) / 2, C.ClipY-m_sLvExpSizeYL, m_sLvExpSizeXL, m_sLvExpSizeYL);
	C.DrawText_s(sIndex, m_sLvExpSizeXL, m_sLvExpSizeYL, (C.ClipX - m_sLvExpSizeXL) / 2, C.ClipY - m_sLvExpSizeYL, m_sLvExpSizeXL, m_sLvExpSizeYL);

	if( nUpExp != 0 && nUpExp != -100 && nUpExp > -3 ) // �ѹ��� 3% ���Ϸ� ���������� ����. �����ϸ� - 98% �� �׸� �Ǵ�..
	{
		if( nUpExp > 0 )
		{
			sIndex = "(+"$nUpExp$"%)";
			C.SetDrawColor(0, 128, 255);
		}
		else
		{
			sIndex = "("$nUpExp$"%)";
			C.SetDrawColor(250, 0, 0);
		}
		
		if( bOnUpExp )
			C.DrawKoreanText(sIndex, C.ClipX / 2 + 74, C.ClipY - 7, 0, 0);
	}
/*
	if(SephirothPlayer(PlayerOwner).PSI.ExpDisplay > 90)
	{	
		sIndex = "Level Up Soon";
		if(SephirothPlayer(PlayerOwner).PSI.ExpDisplay > 95)
			C.SetDrawColor(253, 231, 34, nLevelUpColor);
		else
			C.SetDrawColor(201, 254, 129, nLevelUpColor);
		
		C.DrawKoreanText(sIndex, C.ClipX/2+195, C.ClipY-7, 0, 0);		//modified by yj


		if(bOnUp) // ���İ� ��� ��
		{
			if(nLevelUpColor < 255)
				nLevelUpColor+=155/20;
			else
				bOnUp = false;        // �ִ�� ����ߴٸ� �϶�			
		}
		else      // ���İ� �϶� ��
		{
			if(nLevelUpColor > 100)
				nLevelUpColor-=155/20;
			else
				bOnUp = true;         // �ִ�� �϶��ߴٸ� ���
		}
	}
	//-------------------------------------------------------------------------
*/
	C.DrawColor = OldColor;

//	if ( IsCursorInsideInterface() )	{		//Ŀ���� CMainInterface ���ο� ���ٸ�, ���� �ʿ� ���� ��.		//����� �ʿ���!!!!!!
	if ( TopInterface == Self )	
	{				
		// Xelloss :  �������̽��� ������ ���� ǥ������ ���� ��.

		// �޺� �ǴϽ� ����
		X = Components[1].X;
		Y = Components[1].Y;
		YL = Components[1].YL - 5;
		if ( SkillSprites[0] != None && IsInsideCombo() ) 
		{
			SephirothInterface(Parent).SkillInfo.SetInfo(PC.PSI.Combo, X + SkillBasicOffsetX, Controller.MouseY, True, C.ClipX, C.ClipY - YL);
			bSkillInfo = True;
		}
		else if (SkillSprites[1] != None && IsInsideFinish()) 
		{
			SephirothInterface(Parent).SkillInfo.SetInfo(PC.PSI.Finish, X + SkillComboOffsetX, Controller.MouseY, True, C.ClipX, C.ClipY - YL);
			bSkillInfo = True;
		}
		else if (SkillSprites[2] != None && IsInsideMagic()) 
		{
			SephirothInterface(Parent).SkillInfo.SetInfo(PC.PSI.Magic, X + SkillMagicOffsetX, Controller.MouseY, True, C.ClipX, C.ClipY - YL);
			bSkillInfo = True;
		}
		else
			bSkillInfo = False;

		// ����Ű
		X = Components[1].X;
		Y = Components[1].Y;
		YL = Components[1].YL - 5;
		for ( i = 0;i < QuickSlotRows;i++ ) 
		{
			HotKeyPos = QuickSlotIndex * QuickSlotRows + i;

			if ( HotKeyArray[QuickSlotIndex].HotkeySprites[i].HotkeySprite != None 
				&& IsCursorInsideAt(X + QuickSlotStartX + i * QuickSlotOffsetXPerBox,Y + QuickSlotStartY,32,32) )
			{
				if ( PC.PSI.QuickKeys[HotKeyPos].Type == class'GConst'.Default.BTSkill )
				{
					Skill = PC.QuerySkillByName(PC.PSI.QuickKeys[HotKeyPos].KeyName);
					if ( Skill != None ) 
					{
						if( Skill.IsA('SecondSkill') ) 
						{
							SephirothInterface(Parent).InfoBox.SetInfo(Skill, X + QuickSlotStartX + i * QuickSlotOffsetXPerBox, Controller.MouseY, True, C.ClipX, C.ClipY - YL);
							bSecondSkillInfo = True;
						}
						else 
						{
							SephirothInterface(Parent).SkillInfo.SetInfo(Skill, X + QuickSlotStartX + i * QuickSlotOffsetXPerBox, Controller.MouseY, True, C.ClipX, C.ClipY - YL);
							bSkillInfo = True;
						}
					}
				}
				else if(PC.PSI.QuickKeys[HotKeyPos].Type == class'GConst'.Default.BTMenu)		//modified by yj   �̰����� infobox�� ����� �� ���մϴ�.
				{
					
				}
				else
				{
					SephirothPlayer(PlayerOwner).PSI.SepInventory.FindItemToArray(0, PC.GetHotkey(HotKeyPos), Items);
					if ( Items.Length > 0 ) 
					{
						SephirothInterface(Parent).ItemInfo.SetInfo(Items[0], X + QuickSlotStartX + i * QuickSlotOffsetXPerBox, Controller.MouseY, True, C.ClipX, C.ClipY - YL);
						bItemInfo = True;
					}
				}
			}

			HotKeyPos = QuickSlotIndex_for_F1 * QuickSlotRows + i;		//F1~F12 ����

			if ( HotKeyArray[QuickSlotIndex_for_F1].HotkeySprites[i].HotkeySprite != None		//modified by yj  //F1���ε� tooptip�� �ߵ���
				&& IsCursorInsideAt(X + QuickSlotStartX + i * QuickSlotOffsetXPerBox,Y + QuickSlotStartY - QuickSlotOffsetYPerBox,32,32) )
			{
				if ( PC.PSI.QuickKeys[HotKeyPos].Type == class'GConst'.Default.BTSkill )
				{
					Skill = PC.QuerySkillByName(PC.PSI.QuickKeys[HotKeyPos].KeyName);
					if ( Skill != None ) 
					{
						if( Skill.IsA('SecondSkill') ) 
						{
							SephirothInterface(Parent).InfoBox.SetInfo(Skill, X + QuickSlotStartX + i * QuickSlotOffsetXPerBox, Controller.MouseY - QuickSlotOffsetYPerBox, True, C.ClipX, C.ClipY - YL - QuickSlotOffsetYPerBox);
							bSecondSkillInfo = True;
						}
						else 
						{
							SephirothInterface(Parent).SkillInfo.SetInfo(Skill, X + QuickSlotStartX + i * QuickSlotOffsetXPerBox, Controller.MouseY - QuickSlotOffsetYPerBox, True, C.ClipX, C.ClipY - YL - QuickSlotOffsetYPerBox);
							bSkillInfo = True;
						}
					}
				}
				else
				{
					SephirothPlayer(PlayerOwner).PSI.SepInventory.FindItemToArray(0, PC.GetHotkey(HotKeyPos), Items);
					if ( Items.Length > 0 ) 
					{
						SephirothInterface(Parent).ItemInfo.SetInfo(Items[0], X + QuickSlotStartX + i * QuickSlotOffsetXPerBox, Controller.MouseY - QuickSlotOffsetYPerBox, True, C.ClipX, C.ClipY - YL - QuickSlotOffsetYPerBox);
						bItemInfo = True;
					}
				}
			}

		}

		if ( IsCursorInsideComponent(Components[6]) )
			Controller.SetTooltip("Lv "$SephirothPlayer(PlayerOwner).PSI.PlayLevel$"   "$SephirothPlayer(PlayerOwner).PSI.ExpDisplay$"%");
	}

	if ( !bSecondSkillInfo )
		SephirothInterface(Parent).InfoBox.SetInfo(None);

	if ( !bSkillInfo )
		SephirothInterface(Parent).SkillInfo.SetInfo(None);

	if ( !bItemInfo )
		SephirothInterface(Parent).ItemInfo.SetInfo(None);

/*	//���� �ö��� ��, �׸� �ߴ� �� �ʿ� �� �ٵ�;;
	if (bJustLevelUp && Components[10].bVisible)
	{
		if (Level.TimeSeconds - LevelupTime < 30) {
			if (Level.TimeSeconds - int(Level.TimeSeconds) < 0.5) {
				C.SetRenderStyleAlpha();
				C.DrawColor = Controller.InterfaceSkin;
				C.SetPos(Components[10].X,Components[10].Y);
				C.DrawTile(TextureResources[22].Resource,22,22,0,0,22,22);
			}
		}
		else
			bJustLevelUp = false;
	}

	if (NewSkill != None && Components[12].bVisible)
	{
		if (Level.TimeSeconds - LearnSkillTime < 30) {
			if (Level.TimeSeconds-int(Level.TimeSeconds) < 0.5) {
				C.SetRenderStyleAlpha();
				C.DrawColor = Controller.InterfaceSkin;
				C.SetPos(Components[12].X,Components[12].Y);
				C.DrawTile(TextureResources[24].Resource,22,22,0,0,22,22);
			}
		}
		else
			NewSkill = None;
	}
*/
//	Components[5].Caption = string(QuickSlotIndex);

	// Xelloss - ���� ���� ���� ���� üũ ���� ����
	if ( SephirothInterface(Parent).messenger == None )	
	{	

		if ( SephirothPlayer(PlayerOwner).nNoteUnread > 0 )	
		{

			MakeBlinked();
			bOnMail = True;

			C.SetRenderStyleAlpha();
			C.DrawColor.A = nPointAlpha;
			C.SetPos(MailX, MailY);
			C.DrawTile(TextureResources[20].Resource, 32, 32, 0, 0, 32, 32);
			C.DrawColor.A = 255;

			if ( TopInterface == Self && IsCursorInsideAt(MailX, MailY, 32, 32) )	
			{

				Controller.SetTooltip(Localize("Inbox", "NoteReceived", "Sephiroth")@SephirothPlayer(PlayerOwner).nNoteUnread@Localize("Inbox", "Unread", "Sephiroth"));
			}
		}
		else
			bOnMail = False;
	}

	if ( SephirothInterface(Parent).Inbox_Helper == None )	
	{
		
		if ( SephirothPlayer(PlayerOwner).nHelperUnread > 0 )	
		{

			if ( !bOnMail )
				MakeBlinked();
			
			bOnHelperMail = True;

			C.SetRenderStyleAlpha();
			C.DrawColor.A = nPointAlpha;
			C.SetPos(HelperX, HelperY);
			C.DrawTile(TextureResources[21].Resource, 32, 32, 0, 0, 32, 32);
			C.DrawColor.A = 255;

			if ( TopInterface == Self && IsCursorInsideAt(HelperX, HelperY, 32, 32) )	
			{

				Controller.SetTooltip(Localize("HelperUI", "HelperReceived", "SephirothUI")@SephirothPlayer(PlayerOwner).nHelperUnread@Localize("Inbox", "Unread", "Sephiroth"));
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
	local Skill Skill;//@by wj(08/18)

	local int HotKeyPos;
	local int QuickSlotIndex;

	if( !IsCursorInsideInterface() )		//modified by yj	//Ŀ���� CMainInterface �ܺο� ���� ���� OnKeyEvent�� �ʿ� ����.
		return False;


	if ( bOnHelperMail == True && IsCursorInsideAt(HelperX, HelperY, 32, 32) )	
	{

		if ( Key == IK_LeftMouse && Action == IST_Release )	
		{

			Parent.NotifyInterface(Self, INT_Command, "Helper");
			return True;
		}
	}

	if ( bOnMail == True && IsCursorInsideAt(MailX, MailY, 32, 32) )	
	{

		if ( Key == IK_LeftMouse && Action == IST_Release )	
		{

			Parent.NotifyInterface(Self, INT_Command, "Note");
			return True;
		}
	}

	if ( !(Key == IK_LeftMouse && Action == IST_Press) && !(Key == IK_RightMouse && Action == IST_Release) )
		return False;

	PC = SephirothPlayer(PlayerOwner);

	if ( IsInsideCombo() ) 
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
	if ( IsInsideFinish() ) 
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
	if ( IsInsideMagic() ) 
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

	QuickSlotIndex = SephirothInterface(Parent).QuickSlotIndex;

	if( Controller.DragSource == None )
	{
		X = Components[1].X;
		Y = Components[1].Y;
		for ( i = 0;i < QuickSlotRows;i++ ) 
		{
			if ( IsCursorInsideAt(X + QuickSlotStartX + i * QuickSlotOffsetXPerBox,Y + QuickSlotStartY,32,32) ) 
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
					if ( Key == IK_LeftMouse )
					{
						//@by wj(08/18)------
						if( PC.PSI.QuickKeys[HotKeyPos].Type == class'GConst'.Default.BTSkill )
						{
							Skill = PC.QuerySkillByName(PC.PSI.QuickKeys[HotKeyPos].KeyName);
							if( Skill != None && Skill.IsA('SecondSkill') )
								return True;
						}
						//-------------------
						Parent.NotifyInterface(Self,INT_Command,"ApplyHotKey"@HotKeyPos);
					}
				}
				return True;
			}
			
			//************
			else if (IsCursorInsideAt(X + QuickSlotStartX + i * QuickSlotOffsetXPerBox,Y + QuickSlotStartY - QuickSlotOffsetYPerBox,32,32)) 
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
					if ( Key == IK_LeftMouse )
					{
						//@by wj(08/18)------
						if( PC.PSI.QuickKeys[HotKeyPos].Type == class'GConst'.Default.BTSkill )
						{
							Skill = PC.QuerySkillByName(PC.PSI.QuickKeys[HotKeyPos].KeyName);
							if( Skill != None && Skill.IsA('SecondSkill') )
								return True;
						}
						//-------------------
						Parent.NotifyInterface(Self,INT_Command,"ApplyHotKey"@HotKeyPos);
					}
				}
				return True;
			}
			//*********
		}
	}

	// ����Ű Ŭ�� Xelloss
	if ( Key == IK_LeftMouse )	
	{

		for ( i = 0 ; i < HotKeyArray.Length ; i++ )	
		{

//			if ( IsCursorInsideAt(Components[0].X + QuickSlotStartX + i * QuickSlotOffsetXPerBox + QuickSlotOffsetX_Between_GaugeHud, Components[0].Y + QuickSlotStartY, 32, 32)	{

//			}
		}
	}
}

function JustSkillLearned(Skill Skill)
{
	LearnSkillTime = Level.TimeSeconds;
	NewSkill = Skill;
}

function JustLevelUp()
{
	bJustLevelUp = True;
	LevelUpTime = Level.TimeSeconds;
}

function SetSkillSprite(SephirothPlayer PC, int Index, bool bSet)
{
	local Skill Skill;
	local string TextureName;

	if ( !bSet )
		SkillSprites[Index] = None;
	else if (PC.GetHotSkill(Index) != "") 
	{
		Skill = PC.QuerySkillByName(PC.GetHotSkill(Index));
		if ( Skill != None ) 
		{
			if ( Skill.bLearned && Skill.bEnabled )
				TextureName = "SkillSprites."$Skill.BookName$"."$Skill.SkillName$"N";
			else
				TextureName = "SkillSprites."$Skill.BookName$"."$Skill.SkillName$"D";
			SkillSprites[Index] = Texture(DynamicLoadObject(TextureName, class'Texture'));
		}
	}
}


function bool IsCursorInsideInterface()
{
	return ( IsCursorInsideComponent(Components[1]) || IsCursorInsideComponent(Components[2]) || IsCursorInsideComponent(Components[7]) ||
		IsCursorInsideComponent(Components[9]) ||
		(bOnMail && IsCursorInsideAt(MailX, MailY, 32, 32)) || (bOnHelperMail && IsCursorInsideAt(HelperX, HelperY, 32, 32)) );
}

function bool IsCursorInsideMainFrame()
{
	return ( IsCursorInsideComponent(Components[1]) || IsCursorInsideComponent(Components[2]) || IsCursorInsideComponent(Components[7]) ||
		IsCursorInsideComponent(Components[9]) ||
		(bOnMail && IsCursorInsideAt(MailX, MailY, 32, 32)) || (bOnHelperMail && IsCursorInsideAt(HelperX, HelperY, 32, 32)) );
}

function bool Drop()
{
	local SephirothItem ISI;
	local Skill Skill;
	local int i;
	local SephirothPlayer PC;
	local SephirothItem Item;
	local float X,Y;

	local int HotKeyPos;
	local int QuickSlotIndex;
	QuickSlotIndex = SephirothInterface(Parent).QuickSlotIndex;	

	if( Controller.SelectedList.Length > 1 )
		return False;

	ISI = SephirothItem(Controller.SelectedList[0]);
	Skill = Skill(Controller.SelectedList[0]);

	PC = SephirothPlayer(PlayerOwner);
	
	if ( Controller.DragSource != None && Controller.DragSource.IsA('MenuList') ) 
	{
	
		X = Components[1].X;
		Y = Components[1].Y;

		for( i = 0 ; i < QuickSlotRows ; i++ )
		{
			if( IsCursorInSideAt(X + QuickSlotStartX + i * QuickSlotOffsetXPerBox,Y + QuickSlotStartY,32,32) )
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

			else if(IsCursorInSideAt(X + QuickSlotStartX + i * QuickSlotOffsetXPerBox,Y + QuickSlotStartY - QuickSlotOffsetYPerBox,32,32))
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
				SetHotkeySprite(PC,QuickSlotIndex_for_F1,i,True);
				PC.Net.NotiSaveShortcut();
				return True;				
			}
		}
	
	}


	else if (ISI != None && Controller.DragSource != None) 
	{

		if ( Controller.DragSource.IsA('CBag') ) 
		{
			X = Components[1].X;
			Y = Components[1].Y;


			for ( i = 0;i < QuickSlotRows;i++ )
			{
				if ( IsCursorInsideAt(X + QuickSlotStartX + i * QuickSlotOffsetXPerBox,Y + QuickSlotStartY,32,32) )
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
						SephirothInterface(Parent).CacheHotkey(ISI.TypeName, ISI.ModelName); //!@ ��Ű ĳ��, 2004.1.28, jhjung
						PC.Net.NotiSaveShortcut();
					}
					else if (ISI.IsUse() && ISI.Amount != -1 && ISI.DetailType != ISI.IDT_Gem && ISI.Width * ISI.Height == 1) 
					{
						PC.SetHotkey(HotKeyPos, class'GConst'.Default.BTScroll,ISI.TypeName);
						SetHotkeySprite(PC, QuickSlotIndex, i, True);
						SephirothInterface(Parent).CacheHotkey(ISI.TypeName, ISI.ModelName); //!@ ��Ű ĳ��, 2004.1.28, jhjung
						PC.Net.NotiSaveShortcut();
					}
					else
						PC.myHud.AddMessage(2,Localize("Warnings","NoProperHotkeyItem","Sephiroth"),class'Canvas'.Static.MakeColor(255,255,255));
				
					return True;
				}

			
				else if (IsCursorInsideAt(X + QuickSlotStartX + i * QuickSlotOffsetXPerBox,Y + QuickSlotStartY - QuickSlotOffsetYPerBox,32,32))
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
						SephirothInterface(Parent).CacheHotkey(ISI.TypeName, ISI.ModelName); //!@ ��Ű ĳ��, 2004.1.28, jhjung
						PC.Net.NotiSaveShortcut();
					}
					else if (ISI.IsUse() && ISI.Amount != -1 && ISI.DetailType != ISI.IDT_Gem && ISI.Width * ISI.Height == 1) 
					{
						PC.SetHotkey(HotKeyPos, class'GConst'.Default.BTScroll,ISI.TypeName);
						SetHotkeySprite(PC, QuickSlotIndex_for_F1, i, True);
						SephirothInterface(Parent).CacheHotkey(ISI.TypeName, ISI.ModelName); //!@ ��Ű ĳ��, 2004.1.28, jhjung
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
			if ( Skill.IsCombo() && IsInsideCombo() ) 
			{
				PC.SetHotSkill(0,Skill.SkillName);
				return True;
			}
			if ( Skill.IsFinish() && IsInsideFinish() ) 
			{
				PC.SetHotSkill(1,Skill.SkillName);
				return True;
			}
			if ( Skill.IsMagic() && IsInsideMagic() ) 
			{
				PC.SetHotSkill(2,Skill.SkillName);
				return True;
			}
			
			X = Components[1].X;
			Y = Components[1].Y;
			for ( i = 0;i < QuickSlotRows;i++ ) 
			{			
				if ( IsCursorInsideAt(X + QuickSlotStartX + i * QuickSlotOffsetXPerBox,Y + QuickSlotStartY,32,32) ) 
				{
					HotKeyPos = QuickSlotIndex * QuickSlotRows + i;
					PC.SetHotkey(HotKeyPos, class'GConst'.Default.BTSkill,Skill.SkillName);
					SetHotkeySprite(PC, QuickSlotIndex, i, True);
					PC.Net.NotiSaveShortcut();
					return True;
				}				
				else if (IsCursorInsideAt(X + QuickSlotStartX + i * QuickSlotOffsetXPerBox,Y + QuickSlotStartY - QuickSlotOffsetYPerBox,32,32)) 
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
		//@by wj(08/16)------		
		if( Skill.IsA('SecondSkill') )
		{
			X = Components[1].X;
			Y = Components[1].Y;
			for( i = 0 ; i < QuickSlotRows ; i++ )
			{
				if( IsCursorInSideAt(X + QuickSlotStartX + i * QuickSlotOffsetXPerBox,Y + QuickSlotStartY,32,32) )
				{
					HotKeyPos = QuickSlotIndex * QuickSlotRows + i;
					PC.SetHotKey(HotKeyPos, class'GConst'.Default.BTSkill,Skill.SkillName);
					SetHotkeySprite(PC, QuickSlotIndex, i, True);
					PC.Net.NotiSaveShortcut();
					return True;
				}

				else if (IsCursorInsideAt(X + QuickSlotStartX + i * QuickSlotOffsetXPerBox,Y + QuickSlotStartY - QuickSlotOffsetYPerBox,32,32)) 
				{
					HotKeyPos = QuickSlotIndex_for_F1 * QuickSlotRows + i;
					PC.SetHotKey(HotKeyPos, class'GConst'.Default.BTSkill,Skill.SkillName);
					SetHotkeySprite(PC, QuickSlotIndex_for_F1, i, True);
					PC.Net.NotiSaveShortcut();
					return True;
				}
			}
		}
		//-------------------
	}

	return False;
}


function RenderDragging(Canvas C)	
{
	local SephirothItem ISI;
	local Skill Skill;
	local Material Sprite;

	if ( Controller.Modal() )
		return;
	
	if( Controller.SelectedList.Length < 1 )
		return;

	if( Controller.SelectedList.Length == 1 )
	{
		ISI = SephirothItem(Controller.SelectedList[0]);
		Skill = Skill(Controller.SelectedList[0]);

		if ( ISI != None )
		{
			Sprite = ISI.GetMaterial(SephirothPlayer(PlayerOwner).PSI);

			if ( Sprite != None )
			{
				C.SetPos(Controller.MouseX - ISI.Width * 12, Controller.MouseY - ISI.Height * 12);
				C.SetRenderStyleAlpha();
				C.DrawTile(Sprite, ISI.Width * 24, ISI.Height * 24, 0, 0, ISI.WIdth * 24, ISI.Height * 24);
			}
			
			if ( ISI.HasAmount() )
			{           
				C.SetPos(Controller.MouseX + 12, Controller.MouseY - 14);
				C.SetDrawColor(255,255,255);
				C.DrawText(ISI.Amount);
			}
		}
		else if (Skill != None)
		{
			if ( Skill.IsA('SecondSkill') )
				Sprite = Texture(DynamicLoadObject("SecondSkillUI.SkillIcons."$Skill.SkillName$"S", class'Texture'));
			else
				Sprite = Texture(DynamicLoadObject("SkillSprites."$Skill.BookName$"."$Skill.SkillName$"N", class'Texture'));

			if ( Sprite != None )
			{
				C.SetPos(Controller.MouseX - 16, Controller.MouseY - 16);
				C.Style = ERenderStyle.STY_Normal;
				C.DrawTile(Sprite, 32, 32, 0, 0, 32, 32);
			}
		}
	}
	else if(Controller.SelectedList.Length > 1)
	{
		ShowSelectionItemList(C, Controller.SelectedList);
	}
}


/*
function RenderDragging(Canvas C)
{
	local SephirothItem ISI;
	local Skill Skill;
	local Material Sprite;
	local int i;

	if (Controller.Modal())
		return;
	
	if (Controller.SelectedList.Length < 1)
		return;

	if (Controller.SelectedList.Length == 1)
	{
		Skill = Skill(Controller.SelectedList[0]);

		if ( Skill != None )
		{
			if ( Skill.IsA('SecondSkill') )
				Sprite = Texture(DynamicLoadObject("SecondSkillUI.SkillIcons."$Skill.SkillName$"S", class'Texture'));
			else
				Sprite = Texture(DynamicLoadObject("SkillSprites." $ Skill.BookName $ "." $ Skill.SkillName $ "N", class'Texture'));

			if ( Sprite != None )
			{
				C.SetPos(Controller.MouseX - 16, Controller.MouseY - 16);
				C.Style = ERenderStyle.STY_Normal;
				C.DrawTile(Sprite, 32, 32, 0, 0, 32, 32);
			}
		}
	}
}
*/

function ShowSelectionItemList(Canvas C, Array<Object> ObjList)
{
	local float XXL,YYL;
	local float MaxXL, MaxYL;
	local array<string> ItemStringArr;
	local string LocalizedAmountStr, TempStr;
	local int i;
	local SephirothItem ISI;
	local float X, Y, XL, YL;

	if( ObjList.Length > 1 || IsInState('Selecting') )
	{
		MaxXL = 0;
		MaxYL = 0;
		LocalizedAmountStr = Localize("Terms", "ItemSize", "Sephiroth");

		for ( i = 0; i < ObjList.Length; i++ ) 
		{
			ISI = SephirothItem(ObjList[i]);

			TempStr = ISI.LocalizedDescription;
			if ( ISI.HasAmount() )
				TempStr = TempStr$" "$ISI.Amount$" "$LocalizedAmountStr;

			C.TextSize(TempStr, XXL, YYL);
			MaxXL = max(MaxXL, XXL);
			MaxYL = MaxYL + YYL;

			switch ( ISI.Rareness )
			{
				case class'GConst'.Default.IRNormal :

					TempStr = MakeColorCodeEx(207, 207, 207)$TempStr;
					break;

				case class'GConst'.Default.IRMagic :

					TempStr = MakeColorCodeEx(23, 255, 12)$TempStr;
					break;

				case class'GConst'.Default.IRRare :

					TempStr = MakeColorCodeEx(255, 255, 0)$TempStr;
					break;

				case class'GConst'.Default.IRUnique :

					TempStr = MakeColorCodeEx(229, 212, 140)$TempStr;
					break;

				case class'GConst'.Default.IRPlatinum :

					TempStr = MakeColorCodeEx(174, 51, 249)$TempStr;
					break;

				default :

					TempStr = MakeColorCodeEx(255, 255, 255)$TempStr;
					break;
			}

			ItemStringArr[i] = TempStr;
		}

		if ( ItemStringArr.Length > 0 ) 
		{
			X = Controller.MouseX + 32;
			Y = Controller.MouseY + 24;
			XL = MaxXL + 10;
			YL = MaxYL + 10;

			if ( X < 0 )
				X = 0;
			if ( X + XL > C.ClipX )
				X = C.ClipX - XL;
			if ( Y < 0 )
				Y = 0;
			if ( Y + YL > C.ClipY )
				Y = C.ClipY - YL;

			C.SetPos(X, Y);
			C.SetRenderStyleAlpha();
			C.DrawTile(Texture'TextBlackBg',XL,YL,0,0,0,0);
			class'CNativeInterface'.Static.DrawRect(X,Y,X + XL,Y + YL,class'Canvas'.Static.MakeColor(128,128,128));

			for ( i = 0;i < ItemStringArr.Length;i++ )
				C.DrawTextJustified(ItemStringArr[i],0,X + 4,Y + 5 + i * YYL,X + XL,Y + 5 + i * YYL + YYL);
		}
	}
}

function bool PointCheck()
{
	local int i;
	for ( i = 1;i < Components.Length;i++ )
	{
		if ( IsCursorInsideComponent(Components[i]) && (Components[i].bVisible == True) )		
			return True;		
	}

	if ( bOnMail && IsCursorInsideAt(MailX, MailY, 32, 32) ) //add neive : �˸���. ������ Ŭ���ص� �̵� ���ϰ� 
		return True;

	if ( bOnHelperMail && IsCursorInsideAt(HelperX, HelperY, 32, 32) ) //add neive : �˸���. ������ Ŭ���ص� �̵� ���ϰ� 
		return True;

	return False;
}

function ResetDefaultPosition()		//2009.10.27.Sinhyub
{
	bNeedLayoutUpdate = True;
}

defaultproperties
{
	MailMX=150
	MailMY=130
	Components(0)=(YL=67.000000)
	Components(1)=(Id=1,Type=RES_Image,XL=720.000000,YL=67.000000,PivotDir=PVT_Copy)
	Components(2)=(Id=2,ResId=28,Type=RES_Image,XL=446.000000,YL=38.000000,PivotDir=PVT_Copy,OffsetXL=137.000000,OffsetYL=-31.000000)
	Components(3)=(Id=3,Type=RES_PushButton,XL=13.000000,YL=12.000000,PivotDir=PVT_Copy,OffsetXL=586.000000,OffsetYL=13.000000,ToolTip="HotKeyUp")
	Components(4)=(Id=4,Type=RES_PushButton,XL=13.000000,YL=12.000000,PivotId=3,PivotDir=PVT_Copy,OffsetYL=25.000000,ToolTip="HotKeyDown")
	Components(5)=(Id=5,Caption="0",Type=RES_Text,XL=12.000000,YL=12.000000,PivotId=3,PivotDir=PVT_Copy,OffsetYL=13.000000,TextAlign=TA_MiddleCenter,TextColor=(B=255,G=255,R=255,A=255),ToolTip="HotKeyNum")
	Components(6)=(Id=6,ResId=27,Type=RES_Gauge,XL=668.000000,YL=16.000000,PivotDir=PVT_Copy,OffsetXL=9.000000,OffsetYL=55.000000,GaugeDir=GDT_Right)
	Components(7)=(Id=7,Type=RES_PushButton,XL=50.000000,YL=50.000000,PivotDir=PVT_Copy,OffsetXL=605.000000,OffsetYL=11.000000)
	Components(8)=(Id=8,Type=RES_PushButton,XL=50.000000,YL=50.000000,PivotId=7,PivotDir=PVT_Right,OffsetXL=4.000000)
	Components(9)=(Id=9,ResId=13,Type=RES_Image,XL=116.000000,YL=24.000000,PivotId=7,PivotDir=PVT_Copy,OffsetXL=-5.000000,OffsetYL=-38.000000)
	Components(10)=(Id=10,Type=RES_PushButton,XL=22.000000,YL=22.000000,PivotId=9,PivotDir=PVT_Copy,OffsetXL=1.000000,OffsetYL=1.000000,ToolTip="ToggleInfo")
	Components(11)=(Id=11,Type=RES_PushButton,XL=22.000000,YL=22.000000,PivotId=10,PivotDir=PVT_Right,OffsetXL=1.000000,ToolTip="ToggleBag")
	Components(12)=(Id=12,Type=RES_PushButton,XL=22.000000,YL=22.000000,PivotId=11,PivotDir=PVT_Right,OffsetXL=1.000000,ToolTip="ToggleSkill")
	Components(13)=(Id=13,Type=RES_PushButton,XL=22.000000,YL=22.000000,PivotId=12,PivotDir=PVT_Right,OffsetXL=1.000000,ToolTip="TogglePortal")
	Components(14)=(Id=14,Type=RES_PushButton,XL=22.000000,YL=22.000000,PivotId=13,PivotDir=PVT_Right,OffsetXL=1.000000,ToolTip="ToggleQuest")
	TextureResources(0)=(Package="UI_2009",Path="SlotN1",Style=STY_Normal)
	TextureResources(1)=(Package="UI_2009",Path="BTN10_01_N",Style=STY_Alpha)
	TextureResources(2)=(Package="UI_2009",Path="BTN10_01_O",Style=STY_Alpha)
	TextureResources(3)=(Package="UI_2009",Path="BTN10_01_P",Style=STY_Alpha)
	TextureResources(4)=(Package="UI_2009",Path="BTN10_02_N",Style=STY_Alpha)
	TextureResources(5)=(Package="UI_2009",Path="BTN10_02_O",Style=STY_Alpha)
	TextureResources(6)=(Package="UI_2009",Path="BTN10_02_P",Style=STY_Alpha)
	TextureResources(7)=(Package="UI_2009",Path="BTN11_01_N",Style=STY_Alpha)
	TextureResources(8)=(Package="UI_2009",Path="BTN11_01_O",Style=STY_Alpha)
	TextureResources(9)=(Package="UI_2009",Path="BTN11_01_P",Style=STY_Alpha)
	TextureResources(10)=(Package="UI_2009",Path="BTN11_02_N",Style=STY_Alpha)
	TextureResources(11)=(Package="UI_2009",Path="BTN11_02_O",Style=STY_Alpha)
	TextureResources(12)=(Package="UI_2009",Path="BTN11_02_P",Style=STY_Alpha)
	TextureResources(13)=(Package="UI_2009",Path="SlotI1",Style=STY_Alpha)
	TextureResources(14)=(Package="UI_2009",Path="Icon_Win01BTN_N",Style=STY_Alpha)
	TextureResources(15)=(Package="UI_2009",Path="Icon_Win02BTN_N",Style=STY_Alpha)
	TextureResources(16)=(Package="UI_2009",Path="Icon_Win04BTN_N",Style=STY_Alpha)
	TextureResources(17)=(Package="UI_2009",Path="Icon_Win03BTN_N",Style=STY_Alpha)
	TextureResources(18)=(Package="UI_2009",Path="Icon_Win05BTN_N",Style=STY_Alpha)
	TextureResources(19)=(Package="UI",Path="Main.SkillMark",Style=STY_Alpha)
	TextureResources(20)=(Package="UI_2009",Path="Icon_Win11L",Style=STY_Alpha)
	TextureResources(21)=(Package="UI_2009",Path="Icon_Mark01_N",Style=STY_Alpha)
	TextureResources(22)=(Package="UI_2009",Path="Icon_Win01BTN_O",Style=STY_Alpha)
	TextureResources(23)=(Package="UI_2009",Path="Icon_Win02BTN_O",Style=STY_Alpha)
	TextureResources(24)=(Package="UI_2009",Path="Icon_Win04BTN_O",Style=STY_Alpha)
	TextureResources(25)=(Package="UI_2009",Path="Icon_Win03BTN_O",Style=STY_Alpha)
	TextureResources(26)=(Package="UI_2009",Path="Icon_Win05BTN_O",Style=STY_Alpha)
	TextureResources(27)=(Package="UI_2009",Path="Gauge_Exp",UL=594.000000,VL=10.000000,Style=STY_Alpha)
	TextureResources(28)=(Package="UI_2009",Path="SlotN2",Style=STY_Alpha)
	IsBottom=True
}

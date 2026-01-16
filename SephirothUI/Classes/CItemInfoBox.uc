class CItemInfoBox extends CInfoBox;

const ForDefault=0;
const ForSale=1;
const ForRepair=2;
const ForBuy=3;
const ForBooth=4;

const FOR_OtherEquip=98;
const FOR_COMPARE=99;

var byte DisplayMethod;

// tf ������ 
var color NormalColor, MagicColor, DivineColor, UniqueColor, PlatinumColor;
var color AbilityColor, ExtAbilityColor;
var color SufficientColor, DeficientColor, SpecialAffixesColor, LimitTimeItemColor;
var string ColorCode, AbilityColorCode;

var color UnableColor; //add neive : ������ �䱸ġ ���� ǥ�� ������

var color SetAvilityColor; //add neive : 12�� ��Ʈ ȿ�� �䱸ġ ǥ��
var color SetAvilityColorX;
var color DisableSetAvilityColor;
var color SetAvilityTitleColor;

var localized string S_Durability;
var localized string S_Requirement;
var localized string S_Level;		// keios - ���� �䱸ġ
var localized string S_Str;
var localized string S_Dex;
var localized string S_Vigor;
var localized string S_MagicPower;
var localized string S_White;
var localized string S_Red;
var localized string S_Blue;
var localized string S_Yellow;
var localized string S_Black;
var localized string S_Consume;
var localized string S_Attack, S_MagicAttack, S_OptionalEffect;
var localized string S_PerRace[7];
var localized string S_ChannelEmpty;
var localized string S_DefenseEffect,S_DefenseRate;
var localized string S_Health,S_Mana;
var localized string S_BasicDamageRate;
var localized string S_PlrRace[3], S_JobType[10];
var localized string S_BuyPrice, S_SellPrice, S_RepairPrice, S_Leni, S_BoothPrice;
var localized string S_PetType, S_PetName, S_PetLevel;	//@by wj(10/07)
var localized string S_PetHPPoint, S_PetManaPoint, S_PetAttackPoint, S_PetInventoryPoint, S_PetPoint, S_PetColor;	// kcman pet�����߰� 
// tf ������ 
var localized string S_LimitTimeItem;
var bool bMatch;

var PlayerServerInfo ItemOwner;

function SetItemOwner(PlayerServerInfo pOwner)
{
	ItemOwner = pOwner;
}

function SetDisplayMethod(byte Method)
{
	DisplayMethod = Method;
}

function OnSourceChange(Object Obj)
{
	local SephirothItem Item;

	Item = SephirothItem(Obj);
	if (Item == None)
		return;

	if (!Item.CanEquip())
		ColorCode = MakeColorCode(SufficientColor);
	else if (SephirothPlayer(PlayerOwner).PSI.CanEquip(Item))
		ColorCode = MakeColorCode(SufficientColor);
	else
		ColorCode = MakeColorCode(DeficientColor);
	AbilityColorCode = MakeColorCode(AbilityColor);

	Clear();

	AddTitle();
	AddNameInfo(Item);
	AddPriceInfo(Item);
	AddAbilityInfo(Item);
	AddDemandInfo(Item);
	AddEtcInfo(Item);
	AddAmountInfo(Item);
	AddTooltipInfo(Item);
	// AddMagicInfo(Item);
	AddAffixInfo(Item);
	AddPetInfo(Item);	//@by wj(10/07)

	// ���߷�, �л�� ǥ��
	AddExtAbility(Item);
	AddSetAvilityInfo(Item); //add neive : 12�� ������ ��Ʈ ȿ�� ǥ��
}


function AddTitle()
{
	if ( DisplayMethod == FOR_COMPARE )
		Add(MakeColorCode(DisableSetAvilityColor) $ localize("Terms", "MyEquip", "Sephiroth"), ETextAlign.TA_MiddleLeft);
}


function AddNameInfo(SephirothItem Item)
{
	switch ( Item.Rareness )
	{
	case class'GConst'.default.IRMagic :		// ���� ������ - ���

		Add(MakeColorCode(MagicColor) $ Item.LocalizedDescription);
		break;

	case class'GConst'.default.IRRare :			// ����� ������ - ���

		Add(MakeColorCode(DivineColor) $ Item.LocalizedDescription);
		break;

	case class'GConst'.default.IRUnique :		// ����ũ ������ ����?

		Add(MakeColorCode(UniqueColor) $ Item.LocalizedDescription);
		break;

	case class'GConst'.default.IRPlatinum :		// �÷�Ƽ�� ������

		Add(MakeColorCode(PlatinumColor) $ Item.LocalizedDescription);
		break;

	default :

		Add(MakeColorCode(NormalColor) $ Item.LocalizedDescription);
		break;
	}

	// Xelloss - ����(�ŷ�����)���� ǥ��
	if(DisplayMethod != FOR_OtherEquip){    //@cs added for �鿴�Է�װ��ʱȥ���ɽ���״̬
		if ( Item.xSealFlag == Item.eSEALFLAG.SF_USED )
			Add(MakeColorCode(UnableColor) $ localize("Terms", "NonTrade", "Sephiroth"));
		else
			Add(MakeColorCode(NormalColor) $ localize("Terms", "Tradable", "Sephiroth")); 
	}else{
		Add(" "); //@cs added for ����
	}
}

//字符串替换
function string ReplaceTextEx(string S, string A, string B)
{
    local int i;
    local string Result;
 
    i = InStr(S, A);
    if (i != -1)
    {
        Result = Left(S, i);
        Result $= B;
        Result $= ReplaceTextEx(Mid(S, i + Len(A)), A, B);
    }
    else
    {
        Result = S;
    }
 
    return Result;
}
 
//获取货币描述
//此处接管了道具 UntilTime 字段
//实现根据不同配置显示不同货币类型
function string GetLeniDesc(SephirothItem Item){

	local string KeyStr;
	//默认显示金币
	if(Item.UntilTime <= 0)
	{
		return S_Leni;
	}
	//这里使用的道具过期时间替代的货币类型，需要减去1295978085
	//CustomLeni 拼接 Item.UntilTime 得到 CustomLeni1
	KeyStr = "CustomLeni"@String(Item.UntilTime - 1295978095);
	KeyStr = ReplaceTextEx(KeyStr, " ", "");
	return MakeColorCodeEx(23, 255, 12) $ localize("Terms", KeyStr, "Sephiroth");
}



function AddPriceInfo(SephirothItem Item)
{
	local string Desc;
	local string Price;	//@by wj(040206)
	//货币名称
	local string LeniDesc;

	Price = "";
	LeniDesc = S_Leni;

	if (DisplayMethod == ForSale && Item.SellPrice > 0) {
		Desc = S_SellPrice;
		Price = ClientController(PlayerOwner).GetItemSellPriceString(Item.strSellPrice);
	}
	else if (DisplayMethod == ForRepair && Item.RepairPrice > 0) {
		Desc = S_RepairPrice;
		Price = ClientController(PlayerOwner).GetItemRepairPriceString(Item.strRepairPrice);
	}
	else if (DisplayMethod == ForBuy && Item.BuyPrice > 0) {
		Desc = S_BuyPrice;
		Price = Item.strBuyPrice;
		//当购买时获取自定义货币类型
		LeniDesc = GetLeniDesc(Item);
	}
	else if( DisplayMethod == ForBooth ){
		Desc = S_BoothPrice;
		Price = Item.strBoothPrice;
	}
	if (Price != "") {
		Add(" ");
		if( Item.bPricePerEach )
			Add(MakeColorCodeEx(200,200,30) $ Desc $ "  " $ localize("Terms", "PerEach", "Sephiroth") $ " " $ Controller.MoneyColoredString(Price) $ " " $ LeniDesc);
		else if( Item.IsMaterial() || Item.IsRefined() )
			Add(MakeColorCodeEx(200,200,30) $ Desc $ "  " $ localize("Terms", "Bunch", "Sephiroth") $ " " $ Controller.MoneyColoredString(Price) $ " " $ LeniDesc);
		else
			Add(MakeColorCodeEx(200,200,30) $ Desc $ " " $ Controller.MoneyColoredString(Price) $ " " $ LeniDesc);

		Add(" ");
	}
}

function AddAbilityInfo(SephirothItem Item)
{
	local int i, k, def;
	local string Str;

	switch (Item.UsageType)
	{
	case class'GConst'.default.IUAttack :
	case class'GConst'.default.IUSetWeapon : //add neive : ��Ʈ ���

		Str = AbilityColorCode $ S_Attack $ ":" $ Item.AttackDamage.Min $ "~" $ Item.AttackDamage.Max;

		if (Item.Quality >= 0) 
			//Str = Str $ " (" $ int(Item.Quality * 100) $ "%)";
			Str = Str $ " (" $ int(Round(Item.Quality * 100)) $ ")";    //@cs changed

		Add(Str);

		if (Item.MagicDamage.Min != 0 && Item.MagicDamage.Max != 0)
		{
			Str = AbilityColorCode $ S_MagicAttack $ ":" $ Item.MagicDamage.Min $ "~" $ Item.MagicDamage.Max;
			if (Item.Quality >= 0)
				Str = Str $ " (" $ int(Round(Item.Quality * 100)) $ ")";  //@cs changed
			Add(Str);
		}
		for (i=0;i<Item.RaceAttackPower.Length;i++)
			if (Item.RaceAttackPower[i].Min != 0 && Item.RaceAttackPower[i].Max != 0)
				break;
		if (i < Item.RaceAttackPower.Length)
			Add(AbilityColorCode $ S_OptionalEffect $ ":" $ S_PerRace[i] $ " " $ Item.RaceAttackPower[i].Min $ "~" $ Item.RaceAttackPower[i].Max);
		for (k=i+1;k<Item.RaceAttackPower.Length;k++) {
			if (Item.RaceAttackPower[k].Min != 0 && Item.RaceAttackPower[k].Max != 0)
				Add(AbilityColorCode $ ":" $ S_PerRace[k] $ " " $ Item.RaceAttackPower[k].Min $ "~" $ Item.RaceAttackPower[k].Max);
		}
		break;
	case class'GConst'.default.IUArrow:
		Add(AbilityColorCode $ S_BasicDamageRate $ ":" $ int(Item.BasicDamageRate * 100) $ "%");
		for (i=0;i<Item.RaceAttackRate.Length;i++)
			if (Item.RaceAttackRate[i] != 0)
				break;
		if (i < Item.RaceAttackRate.Length)
			Add(AbilityColorCode $ S_OptionalEffect $ ":" $ S_PerRace[i] $ " " $ int(Item.RaceAttackRate[i] * 100) $ "%");
		for (k=i+1;k<Item.RaceAttackRate.Length;k++)
			if (Item.RaceAttackRate[k] != 0)
				Add(AbilityColorCode $ ":" $ S_PerRace[k] $ ":" $ int(Item.RaceAttackRate[k] * 100) $ "%");
		break;
	case class'GConst'.default.IUDefenseEffect:
	case class'GConst'.default.IUSetArmor: //add neive : ��Ʈ ��� ����
		Str = AbilityColorCode $ S_DefenseEffect $ ":" $ Item.DefenseEffect;
		if (Item.Quality >= 0)
			Str = Str $ " (" $ int(Round(Item.Quality * 100)) $ ")";  //@cs changed
		Add(Str);
		break;
	case class'GConst'.default.IUDefenseRate:
	case class'GConst'.default.IUSetShield:		//add neive : ��Ʈ ��� ����
		Str = AbilityColorCode $ S_DefenseRate $ ":" $ Item.DefenseRate;
		if (Item.Quality >= 0)
			Str = Str $ " (" $ int(Round(Item.Quality * 100)) $ ")";  //@cs changed
		Add(Str);
		break;
	case class'GConst'.default.IUFillAdd:
	case class'GConst'.default.IUFillDirect:
		if (Item.Health > 0 && Item.Mana > 0) {
			Add(AbilityColorCode $ S_Health $ " " $ int(Item.Health));
			Add(AbilityColorCode $ S_Mana $ " " $ int(Item.Mana));
		}
		else if (Item.Health > 0 && Item.Mana == 0)
			Add(AbilityColorCode $ S_Health $ " " $ int(Item.Health));
		else if (Item.Health == 0 && Item.Mana > 0)
			Add(AbilityColorCode $ S_Mana $ " " $ int(Item.Mana));
		break;
	case class'GConst'.default.IUFillRate:
	case class'GConst'.default.IUFillDirectRate:
		if (Item.Health > 0 && Item.Mana > 0) {
			Add(AbilityColorCode $ S_Health $ " " $ int(Item.Health) $ "%");
			Add(AbilityColorCode $ S_Mana $ " " $ int(Item.Mana) $ "%");
		}
		else if (Item.Health > 0 && Item.Mana == 0)
			Add(AbilityColorCode $ S_Health $ " " $ int(Item.Health) $ "%");
		else if (Item.Health == 0 && Item.Mana > 0)
			Add(AbilityColorCode $ S_Mana $ " " $ int(Item.Mana) $ "%");
		break;
	case class'GConst'.default.IUDefenseRace: //add neive : ���� �Ӽ� ���
	case class'GConst'.default.IUSetArmorRace: //add neive : ��Ʈ ���
		Str = AbilityColorCode $ S_DefenseEffect $ ":" $ Item.DefenseEffect;
		if (Item.Quality >= 0)
			Str = Str $ " (" $ int(Round(Item.Quality * 100)) $ ")";  //@cs changed
		Add(Str);
		for (i=0; i<Item.RaceAttackPower.Length; i++)
		{
			def = Item.RaceAttackPower[i].Min;
			if (def != 0)
				Add(AbilityColorCode $ ":" $ S_PerRace[i] $ " " $ def $ "+0");
		}
		break;
	}

	// ���� �� �� �ִ� �������̸� �������� ��� ǥ�� �Ѵ�
	//if (Item.CanEquip() && Item.Level < 11)
	if (Item.CanEquip() && Item.CanDisplayDurability())// && Item.Level < 11)
	{	
		if (Item.IsDisposable())
			Add(AbilityColorCode $ S_Durability $ ":" $ int(Item.Durability));
		else if (Item.IsRecyclable())
			Add(AbilityColorCode $ S_Durability $ ":" $ int(Item.Durability) $ "/" $ int(Item.MaxDurability));
//		else
//			Add(AbilityColorCode $ S_Durability $ ":" $ "Invalid");
	}
	//else
	//	Add(AbilityColorCode $ S_Durability $ ":" $ "Cannot Equip");
}

function AddEtcInfo(SephirothItem Item)
{
	if (Item.UsageType == class'GConst'.default.IUShell) {
		if (Item.Channel != "")
			Add(AbilityColorCode $ Item.Channel);
		else
			Add(AbilityColorCode $ S_ChannelEmpty);
	}
}

function AddDemandInfo(SephirothItem Item)
{
	local int i;
	local string Info;
	local string DemandStr, RaceStr, JobStr;
	local bool bHasDemand;

	//add neive : ��� �䱸ġ ���� ǥ�� ---------------------------------------
	local int nLV, nStr, nDex, nVig, nRed, nBlu, nBla, nWhi, nYel, nMag;
	nLV  = SephirothPlayer(PlayerOwner).PSI.PlayLevel;
	nStr = SephirothPlayer(PlayerOwner).PSI.Str;
	nDex = SephirothPlayer(PlayerOwner).PSI.Dex;
	nVig = SephirothPlayer(PlayerOwner).PSI.Vigor;
	nWhi = SephirothPlayer(PlayerOwner).PSI.White; 
	nRed = SephirothPlayer(PlayerOwner).PSI.Red;
	nBlu = SephirothPlayer(PlayerOwner).PSI.Blue; 
	nYel = SephirothPlayer(PlayerOwner).PSI.Yellow; 
	nBla = SephirothPlayer(PlayerOwner).PSI.Black;
	nMag = nRed + nBlu + nBla + nWhi + nYel;

	if(SephirothPlayer(PlayerOwner).PSI.CanUse(Item)) // ������ �� �ִ� �������� üũ
		bMatch = true;
	else
		bMatch = false;

	if (Item.ItemDemands.Length > 0) {
		for (i=0;i<Item.ItemDemands.Length;i++) {
			switch (Item.ItemDemands[i].Type) {
			case 0: 
				if(Item.ItemDemands[i].Value <= nLV || bMatch == false) // ��� ����
					Info = ColorCode $ S_Level $ " " $ Item.ItemDemands[i].Value; 
				else
					Info = MakeColorCode(UnableColor) $ S_Level $ " " $ Item.ItemDemands[i].Value; 
				break;
			case 1: 
				if(Item.ItemDemands[i].Value <= nStr || bMatch == false) // ��� ����
					Info = ColorCode $ S_Str $ " " $ Item.ItemDemands[i].Value;
				else
					Info = MakeColorCode(UnableColor) $ S_Str $ " " $ Item.ItemDemands[i].Value;
				break;
			case 2: 
				if(Item.ItemDemands[i].Value <= nDex || bMatch == false) // ��� ����
					Info = ColorCode $ S_Dex $ " " $ Item.ItemDemands[i].Value; 
				else
					Info = MakeColorCode(UnableColor) $ S_Dex $ " " $ Item.ItemDemands[i].Value;
				break;
			case 3: 
				if(Item.ItemDemands[i].Value <= nVig || bMatch == false) // ��� ����
					Info = ColorCode $ S_Vigor $ " " $ Item.ItemDemands[i].Value; 
				else
					Info = MakeColorCode(UnableColor) $ S_Vigor $ " " $ Item.ItemDemands[i].Value;
				break;
			case 4: 
				if(Item.ItemDemands[i].Value <= nMag || bMatch == false) // ��� ����
					Info = ColorCode $ S_MagicPower $ " " $ Item.ItemDemands[i].Value;
				else
					Info = MakeColorCode(UnableColor) $ S_MagicPower $ " " $ Item.ItemDemands[i].Value;
				break;
			case 5:
				if(Item.ItemDemands[i].Value <= nWhi || bMatch == false) // ��� ����
					Info = ColorCode $ S_White $ " " $ Item.ItemDemands[i].Value; 
				else
					Info = MakeColorCode(UnableColor) $ S_White $ " " $ Item.ItemDemands[i].Value; 
				break;
			case 6: 
				if(Item.ItemDemands[i].Value <= nRed || bMatch == false) // ��� ����
					Info = ColorCode $ S_Red $ " " $ Item.ItemDemands[i].Value;
				else
					Info = MakeColorCode(UnableColor) $ S_Red $ " " $ Item.ItemDemands[i].Value;
				break;
			case 7: 
				if(Item.ItemDemands[i].Value <= nBlu || bMatch == false) // ��� ����
					Info = ColorCode $ S_Blue $ " " $ Item.ItemDemands[i].Value;
				else
					Info = MakeColorCode(UnableColor) $ S_Blue $ " " $ Item.ItemDemands[i].Value;
				break;
			case 8: 
				if(Item.ItemDemands[i].Value <= nYel || bMatch == false) // ��� ����
					Info = ColorCode $ S_Yellow $ " " $ Item.ItemDemands[i].Value;
				else
					Info = MakeColorCode(UnableColor) $ S_Yellow $ " " $ Item.ItemDemands[i].Value;
				break;
			case 9: 
				if(Item.ItemDemands[i].Value <= nBla || bMatch == false) // ��� ����
					Info = ColorCode $ S_Black $ " " $ Item.ItemDemands[i].Value; 
				else
					Info = MakeColorCode(UnableColor) $ S_Black $ " " $ Item.ItemDemands[i].Value; 
				break;
			}
			if (Info != "") {
				if (DemandStr == "")
					DemandStr = Info;
				else
					DemandStr = DemandStr $ " " $ Info;
			}
		}

		if (DemandStr != "") {
			bHasDemand = true;
			Add(ColorCode $ S_Requirement $ ":" $ DemandStr);
		}
	}

	if (Item.AttachPlace != Item.ITEM_ISNOT_ATTACHABLE) {
		if (Item.AttachRaceMask < class'GConst'.default.EPR_All) {
			i = 0;
			while (i < class'GConst'.default.EPR_NUM) {
				if ((Item.AttachRaceMask & int(2**i)) == int(2**i)) {
					Info = S_PlrRace[i];
					if (RaceStr == "")
						RaceStr = Info;
					else
						RaceStr = RaceStr $ ", " $ Info;
				}
				i++;
			}
			if (RaceStr != "") {
				if (bHasDemand)
					Add(ColorCode $ ":" $ RaceStr);
				else
					Add(ColorCode $ S_Requirement $ ":" $ RaceStr);
				bHasDemand = true;
			}
		}
		if (Item.AttachJobMask < class'GConst'.default.EJT_All) {
			i = 0;
			while (i < class'GConst'.default.EJT_NUM) {
				if ((Item.AttachJobMask & int(2**i)) == int(2**i)) {
					Info = S_JobType[i];
					if (JobStr == "")
						JobStr = Info;
					else
						JobStr = JobStr $ ", " $ Info;
				}
				i++;
			}
			if (JobStr != "") {
				if (bHasDemand)
					Add(ColorCode $ ":" $ JobStr);
				else
					Add(ColorCode $ S_Requirement $ ":" $ JobStr);
			}
		}
	}
}

function AddTooltipInfo(SephirothItem Item)
{
	local array<string> TooltipString;
	local int i;

	if (Item.Tooltip != "") {
		class'CNativeInterface'.static.WrapStringToArray(Item.Tooltip, TooltipString, 10000, "|");
		for (i=0;i<TooltipString.Length;i++)
			Add(ColorCode $ TooltipString[i]);
	}
}

/* no longer used
function AddMagicInfo(SephirothItem Item)
{
	local int i;
	for (i=0;i<Item.InnateMagics.Length;i++)
		Add(ColorCode $ Item.InnateMagics[i]);
}
*/

function AddAffixInfo(SephirothItem Item)
{
	//add neive : �Ⱓ�� ������ ���� ��¥ ǥ�� --------------------------------
	local int nYear, nMonth, nDay, nHour, nMin;
	local string sDays;
	local int i;
	//-------------------------------------------------------------------------

	switch (Item.Rareness)
	{
	case class'GConst'.default.IRMagic :

		for ( i = 0 ; i < Item.Affixes.Length ; i++ )
			Add(MakeColorCode(MagicColor) $ Item.Affixes[i].Display);

		break;

	case class'GConst'.default.IRRare :

		for ( i = 0 ; i < Item.Affixes.Length ; i++ )
			Add(MakeColorCode(DivineColor) $ Item.Affixes[i].Display);

		break;

	case class'GConst'.default.IRUnique :

		for ( i = 0 ; i < Item.Affixes.Length ; i++ )
			Add(MakeColorCode(UniqueColor) $ Item.Affixes[i].Display);

		break;

	case class'GConst'.default.IRPlatinum :

		for ( i = 0 ; i < Item.Affixes.Length ; i++ )
			Add(MakeColorCode(PlatinumColor) $ Item.Affixes[i].Display);

		break;
	}
	//@by wj(040312)------
	//for(i = 0 ; i < Item.SpecialAffixes.Length ; i++)
	//	Add(MakeColorCode(SpecialAffixesColor) $ Item.SpecialAffixes[i]);
	//--------------------

	// tf ������
	//add neive : �Ⱓ�� ������ ���� ��¥ ǥ�� --------------------------------
	// ������ ���� 2009 ������� �� �ڵ尡 �����ϴٴ� �� �Ѥ�; 10�� �Ǹ� 010 ����
	// ǥ�ð� �Ǵ� �ٶ������� �ʴ�~
	/* 
	if( Item.UntilTime > 0 )
	{
		nYear = Item.UntilTime / 100000000; 
		nMonth = Item.UntilTime / 1000000 % 100;
		nDay = Item.UntilTime / 10000 % 100;
		nHour = Item.UntilTime / 100 % 100;
		nMin = Item.UntilTime - (nYear*100000000) - (nMonth*1000000) - (nDay*10000) - (nHour*100);

		
		Add(MakeColorCode(LimitTimeItemColor) $ S_LimitTimeItem);
		sDays = "20" $ nYear $ "/" $ nMonth $ "/" $ nDay $ " " $ nHour $ "��" $ nMin $"��" ;
		//sDays = "0" $ Item.UntilTime ;
		Add(MakeColorCode(LimitTimeItemColor) $ "" $ sDays $ " ����");
	}*/
	//-------------------------------------------------------------------------
}

function AddAmountInfo(SephirothItem Item)
{
	if (Item.Amount > -1 && (Item.IsMaterial() || Item.IsRefined()) && DisplayMethod != ForBuy)
		Add(AbilityColorCode $ S_Consume $ " " $ Item.Amount);
}

function AddPetInfo(SephirothItem Item)
{
	if(Item.IsPetCage()) {
		Add(MakeColorCode(AbilityColor) $ S_PetName $ ":" $ Item.PetName);
		Add(MakeColorCode(AbilityColor) $ S_PetType $ ":" $ Localize("PetUI",Item.PetType,"SephirothUI"));
		Add(MakeColorCode(AbilityColor) $ S_PetColor $ ":" $ Item.PetColor);
		Add(MakeColorCode(AbilityColor) $ S_PetAttackPoint $ ":" $ Item.PetAttackPoint $ "  Point"); // kcman pet�����߰� 
		Add(MakeColorCode(AbilityColor) $ S_PetInventoryPoint $ ":" $ Item.PetInventoryPoint $ "  Point");
		Add(MakeColorCode(AbilityColor) $ S_PetHPPoint $ ":" $ Item.PetHPPoint $ "  Point");
		Add(MakeColorCode(AbilityColor) $ S_PetManaPoint $ ":" $ Item.PetManaPoint $ "  Point");
		Add(MakeColorCode(AbilityColor) $ S_PetPoint $ ":" $ Item.PetPoint $ "  Point");		
		Add(MakeColorCode(DivineColor) $ S_PetLevel $ " " $ Item.PetLevel);
	}
}

// ���߷�, �л�� ǥ��
function AddExtAbility(SephirothItem Item)
{
	if ( Item.iDamageConcentration > 0 )
		Add(MakeColorCode(ExtAbilityColor) $ localize("CItemInfoBox", "S_Concentration", "SephirothUI") @ (Item.iDamageConcentration), ETextAlign.TA_MiddleLeft);

	if ( Item.iDamageDistribution > 0 )
		Add(MakeColorCode(ExtAbilityColor) $ localize("CItemInfoBox", "S_Distribution", "SephirothUI") @ (Item.iDamageDistribution), ETextAlign.TA_MiddleLeft);
}


//add neive : 12�� ������ ��Ʈ ȿ�� ǥ��
function AddSetAvilityInfo(SephirothItem Item)
{
	local int i, Type, SetAvilityLv, SetWeaponLv, nMaxSetLevel;
	local string JobName;
	local string strSetAvility;
	local int nSetIndex;

	if ( ItemOwner != None )
		return;

	//add neive : ��Ʈ ������ ȿ�� ǥ�� ----------------------------------------------
	if ( Item.UsageType == class'GConst'.default.IUSetArmorRace || Item.UsageType == class'GConst'.default.IUSetArmor)
	{
		nSetIndex = Item.m_nSetIndex;

		if (bMatch) // ���� ������ �����̸� ��Ʈȿ�� �ܰ� ǥ��
			SetAvilityLv = SephirothPlayer(PlayerOwner).PSI.GetSetArmorLevel(nSetIndex);
		else
			SetAvilityLv = 0;

		for(i=2; i<=5; i++)
		{
			if(i <= SetAvilityLv)
				Add( MakeColorCode(SetAvilityColor) $ localize("SETARMOR" $ nSetIndex, "Level" $ i, "SephirothUI"), ETextAlign.TA_MiddleLeft);
			else
				Add( MakeColorCode(DisableSetAvilityColor) $ localize("SETARMOR" $ nSetIndex, "Level" $ i, "SephirothUI"), ETextAlign.TA_MiddleLeft);
		}

		//Log("Xelloss : <Armor> name="$Item.Name);
	}
	else if (Item.UsageType == class'GConst'.default.IUSetWeapon || Item.UsageType == class'GConst'.default.IUSetShield)
	{
		nSetIndex = Item.m_nSetIndex;

		if(bMatch) // ���� ������ �����̸� ��Ʈȿ�� �ܰ� ǥ��
			SetWeaponLv = SephirothPlayer(PlayerOwner).PSI.GetSetWeaponLevel(nSetIndex);
		else
			SetWeaponLv = 0;

		Type = Item.DetailType; // �������� ������ �˾ƿ´�

		if (Type == class'GConst'.default.IDT_OneHand || Type == class'GConst'.default.IDT_Shield || 
			Type == class'GConst'.default.IDT_Glove || Type == class'GConst'.default.IDT_Protector) // ���� ���� ��Ʈ
			nMaxSetLevel = 2;
		else
			nMaxSetLevel = 1;

		//if(SetWeaponLv != 0 && SetWeaponLv == nMaxSetLevel)
		//	Add( MakeColorCode(SetAvilityColor) $ localize("SETABILITY" $ nSetIndex, "Level", "SephirothUI"), ETextAlign.TA_MiddleLeft);
		//else
		//	Add( MakeColorCode(DisableSetAvilityColor) $ localize("SETABILITY" $ nSetIndex, "Level", "SephirothUI"), ETextAlign.TA_MiddleLeft);

		strSetAvility = localize("SETABILITY" $ nSetIndex, "Level", "SephirothUI");

		if ( strSetAvility != "")
		{
			if(SetWeaponLv != 0 && SetWeaponLv == nMaxSetLevel)
				Add( MakeColorCode(SetAvilityColor) $ strSetAvility, ETextAlign.TA_MiddleLeft);
			else
				Add( MakeColorCode(DisableSetAvilityColor) $ strSetAvility, ETextAlign.TA_MiddleLeft);
		}

		//Log("Xelloss : <Weapon> name="$Item.Name);
	}
	else if (Item.Level == 14) // 12�� ������ ���� üũ
	{
		Type = Item.DetailType; // �������� ������ �˾ƿ´�

		switch(Item.AttachJobMask) // Ŭ������ ���ö����� �� ������ �˾ƿ´�
		{
			case class'GConst'.default.EJT_OneHand: JobName = "OneHandSetAvility"; break;
			case class'GConst'.default.EJT_Bare:    JobName = "BareSetAvility"; break;
			case class'GConst'.default.EJT_Red:     JobName = "RedSetAvility"; break;
			case class'GConst'.default.EJT_Bow:     JobName = "BowSetAvility"; break;
			case class'GConst'.default.EJT_Blue:    JobName = "BlueSetAvility"; break;
		}

		Add(" ");

		if(bMatch) // ���� ������ �����̸� ��Ʈȿ�� �ܰ� ǥ��
			SetWeaponLv = SephirothPlayer(PlayerOwner).PSI.SetWeaponLevel;
		else
			SetWeaponLv = 0;

		// ��� ���� �ٸ��� ǥ��
		if(Type == class'GConst'.default.IDT_Glove || Type == class'GConst'.default.IDT_Protector) // ���� ���� ����
		{
			if(SetWeaponLv == 2)
				Add( MakeColorCode(SetAvilityColor) $ localize(JobName, "Weapon", "SephirothUI"), ETextAlign.TA_MiddleLeft);
			else
				Add( MakeColorCode(DisableSetAvilityColor) $ localize(JobName, "Weapon", "SephirothUI"), ETextAlign.TA_MiddleLeft);
		}
		else if(Type == class'GConst'.default.IDT_OneHand || Type == class'GConst'.default.IDT_Shield) // �˻� ���� ����
		{
			if(SetWeaponLv == 2)
				Add( MakeColorCode(SetAvilityColor) $ localize(JobName, "Weapon", "SephirothUI"), ETextAlign.TA_MiddleLeft);
			else
				Add( MakeColorCode(DisableSetAvilityColor) $ localize(JobName, "Weapon", "SephirothUI"), ETextAlign.TA_MiddleLeft);
		}
		else if(Type == class'GConst'.default.IDT_Staff) // ���� ������
		{
			if(SetWeaponLv == 1)
				Add( MakeColorCode(SetAvilityColor) $ localize(JobName, "Weapon", "SephirothUI"), ETextAlign.TA_MiddleLeft);
			else
				Add( MakeColorCode(DisableSetAvilityColor) $ localize(JobName, "Weapon", "SephirothUI"), ETextAlign.TA_MiddleLeft);
		}
		else if(Type == class'GConst'.default.IDT_Stick) // ���� ��ƽ
		{
			if(SetWeaponLv == 1)
				Add( MakeColorCode(SetAvilityColor) $ localize(JobName, "Weapon", "SephirothUI"), ETextAlign.TA_MiddleLeft);
			else
				Add( MakeColorCode(DisableSetAvilityColor) $ localize(JobName, "Weapon", "SephirothUI"), ETextAlign.TA_MiddleLeft);
		}
		else if(Type == class'GConst'.default.IDT_Bow) // Ȱ
		{
			if(SetWeaponLv == 1)
				Add( MakeColorCode(SetAvilityColor) $ localize(JobName, "Weapon", "SephirothUI"), ETextAlign.TA_MiddleLeft);
			else
				Add( MakeColorCode(DisableSetAvilityColor) $ localize(JobName, "Weapon", "SephirothUI"), ETextAlign.TA_MiddleLeft);
		}
		else  // �� Ŭ���� ��
		{
			if(bMatch) // ���� ������ �����̸� ��Ʈȿ�� �ܰ� ǥ��
				SetAvilityLv = SephirothPlayer(PlayerOwner).PSI.SetAvilityLevel; // 2�����ʹϱ� -1
			else
				SetAvilityLv = 0;
			
			Add( MakeColorCode(SetAvilityTitleColor) $ localize("SetItem", "Title", "SephirothUI"), ETextAlign.TA_MiddleLeft);

			if(SetAvilityLv > 1)	
				Add( MakeColorCode(SetAvilityColor) $ localize(JobName, "Level2", "SephirothUI"), ETextAlign.TA_MiddleLeft);
			else
				Add( MakeColorCode(DisableSetAvilityColor) $ localize(JobName, "Level2", "SephirothUI"), ETextAlign.TA_MiddleLeft);
			
			if(SetAvilityLv > 2)
				Add( MakeColorCode(SetAvilityColor) $ localize(JobName, "Level3", "SephirothUI"), ETextAlign.TA_MiddleLeft);
			else
				Add( MakeColorCode(DisableSetAvilityColor) $ localize(JobName, "Level3", "SephirothUI"), ETextAlign.TA_MiddleLeft);

			if(SetAvilityLv > 3)
				Add( MakeColorCode(SetAvilityColor) $ localize(JobName, "Level4", "SephirothUI"), ETextAlign.TA_MiddleLeft);
			else
				Add( MakeColorCode(DisableSetAvilityColor) $ localize(JobName, "Level4", "SephirothUI"), ETextAlign.TA_MiddleLeft);

			if(SetAvilityLv > 4)
				Add( MakeColorCode(SetAvilityColor) $ localize(JobName, "Level5", "SephirothUI"), ETextAlign.TA_MiddleLeft);
			else
				Add( MakeColorCode(DisableSetAvilityColor) $ localize(JobName, "Level5", "SephirothUI"), ETextAlign.TA_MiddleLeft);
		}

		//Log("Xelloss : <Lv.12> name="$Item.LocalizedDescription@"Match="$bMatch@"Level="$SetAvilityLv);
	}
}
//-----------------------------------------------------------------------------

defaultproperties
{
     NormalColor=(B=207,G=207,R=207,A=255)
     MagicColor=(B=12,G=255,R=23,A=255)
     DivineColor=(G=255,R=255,A=255)
     UniqueColor=(B=140,G=212,R=229,A=255)
     PlatinumColor=(B=249,G=51,R=174,A=255)
     AbilityColor=(B=126,G=176,R=223,A=255)
     ExtAbilityColor=(B=77,G=80,R=192,A=255)
     SufficientColor=(B=225,G=189,R=137,A=255)
     DeficientColor=(B=170,G=139,R=249,A=255)
     SpecialAffixesColor=(B=136,G=218,R=69,A=255)
     LimitTimeItemColor=(B=180,G=255,A=255)
     UnableColor=(R=220,A=255)
     SetAvilityColor=(B=184,G=101,R=153,A=255)
     SetAvilityColorX=(B=154,G=154,R=154,A=255)
     DisableSetAvilityColor=(B=154,G=154,R=154,A=255)
     SetAvilityTitleColor=(B=137,G=222,R=139,A=255)
     S_Durability="Durability"
     S_Requirement="Requirement"
     S_Level="LEVEL"
     S_Str="STR"
     S_Dex="DEX"
     S_Vigor="VIGOR"
     S_MagicPower="MAGIC-POWER"
     S_White="WHITE"
     S_Red="RED"
     S_Blue="BLUE"
     S_Yellow="YELLOW"
     S_Black="BLACK"
     S_Consume="Amount"
     S_Attack="Attack"
     S_MagicAttack="MagicAttack"
     S_OptionalEffect="OptionalEffect"
     S_PerRace(0)="Human"
     S_PerRace(1)="Nephilim"
     S_PerRace(2)="Titaan"
     S_PerRace(3)="Undead"
     S_PerRace(4)="Creature"
     S_PerRace(5)="Summon"
     S_PerRace(6)="Mutant"
     S_ChannelEmpty="Make Channel by Clicking Right Button"
     S_DefenseEffect="DefenseEffect"
     S_DefenseRate="DefenseRate"
     S_Health="Health"
     S_Mana="Mana"
     S_PlrRace(0)="Human"
     S_PlrRace(1)="Nephilim"
     S_PlrRace(2)="Titaan"
     S_JobType(0)="White"
     S_JobType(1)="Red"
     S_JobType(2)="Blue"
     S_JobType(3)="Yellow"
     S_JobType(4)="Black"
     S_JobType(5)="Bare"
     S_JobType(6)="OneHand"
     S_JobType(7)="TwoHand"
     S_JobType(8)="Spear"
     S_JobType(9)="Bow"
     S_BuyPrice="Buy Price"
     S_SellPrice="Sell Price"
     S_RepairPrice="Repair Price"
     S_BoothPrice="Booth Price"
     S_PetType="PetType"
     S_PetName="PetName"
     S_PetLevel="PetLevel"
     S_PetHPPoint="PetHPPoint"
     S_PetManaPoint="PetManaPoint"
     S_PetAttackPoint="PetAttackPoint"
     S_PetInventoryPoint="PetInventoryPoint"
     S_PetPoint="PetPoint"
     S_PetColor="PetColor"
}

class Recipe extends CMultiInterface;

//-----------------------------------------------------------------------------
//add neive : 12´Ü ¾ÆÀÌÅÛ Á¦ÀÛ¿ë ·¹½ÃÇÇ µ¥ÀÌÅÍ
// -_- ´Ù½Ã º¸´Ï ³»°¡ ¸¸µé¾úÁö¸¸ Âü ¾ÏÈ£¹® ¼öÁØÀÌ´Ù;; Á¤¸®ºÒ°¡
// ¸¸¾à ±â´É È®Àå, Á¦ÀÛ ¸®½ºÆ® È®Àå µî ÀÌ½´°¡ ÀÖÀ¸¸é ±×³É ºÐ¼®ÇÒ ½Ã°£¿¡ »õ·Î
// ¸¸µå´Â°Ô ºü¸§;; 
//-----------------------------------------------------------------------------



const OneHand = 1;
const Bare    = 2;
const Red     = 3;
const Bow     = 4;
const Blue    = 5;

const Weapon  = 6;
const Helmet  = 7;
const Armor   = 8;
const Vambrace= 9;
const Boots   =10;
const Shield  =11;


var array<string> RecipeName;       // ¸ðµç ·¹½ÃÇÇ ÀÌ¸§µé 5
var array<string> FirstStuffName;   // 1Â÷ Àç·á ÀÌ¸§µé 1
var array<string> SecondStuffName;  // 2Â÷ Àç·á ÀÌ¸§µé 2
var array<string> ThirdStuffName;   // 3Â÷ Àç·á ÀÌ¸§µé 3

var array<string> FirstStuffIconName;   // 1Â÷ Àç·á ÀÌ¸§µé 1
var array<string> SecondStuffIconName;  // 2Â÷ Àç·á ÀÌ¸§µé 2
var array<string> ThirdStuffIconName;   // 3Â÷ Àç·á ÀÌ¸§µé 3

struct RecipeData
{
	var int step;  // ´Ü°è
	var int index; // ÀÌ¸§
	var int pics;  // Á¦ÀÛ¿¡ ÇÊ¿äÇÑ °¹¼ö
};

var array<RecipeData> MurcielSword;
var array<RecipeData> MurcielShield;
var array<RecipeData> MurcielHelmet;
var array<RecipeData> MurcielArmor;
var array<RecipeData> MurcielVambrace;
var array<RecipeData> MurcielBoots;

var array<RecipeData> AcordGauntlet;
var array<RecipeData> AcordProtector;
var array<RecipeData> AcordArmor;
var array<RecipeData> AcordHelmet;
var array<RecipeData> AcordBoots;
var array<RecipeData> AcordVambrace;

var array<RecipeData> AblazeStaff;
var array<RecipeData> AblazeGarment;
var array<RecipeData> AblazeHelmet;
var array<RecipeData> AblazeBoots;
var array<RecipeData> AblazeVambrace;

var array<RecipeData> ApliteBow;
var array<RecipeData> ApliteGarb;
var array<RecipeData> ApliteCap;
var array<RecipeData> ApliteSandal;
var array<RecipeData> ApliteSleevelet;

var array<RecipeData> GlaciesStick;
var array<RecipeData> GlaciesGown;
var array<RecipeData> GlaciesCap;
var array<RecipeData> GlaciesSandal;
var array<RecipeData> GlaciesSleevelet;

var array<string> DisableList;
var array<int> InableList;

struct MakeData
{
	var int a;
	var int an;
	var int b;
	var int bn;
	var int c;
	var int cn;
	var int d;
	var int dn;
};

var array<MakeData> MakeList;


struct NeedData
{
	var string iname;
	var int needPics;
};

var array<NeedData> NeedList;


var array<string> ItemSDNameList;


function LoadRecipe()
{
	RecipeName[0] = "Ä¦Î÷¶ûÖ®½£";
	RecipeName[1] = "Ä¦Î÷¶ûÖ®¿ø";
	RecipeName[2] = "Ä¦Î÷¶ûÖ®îø";
	RecipeName[3] = "Ä¦Î÷¶ûÖ®ÊÖ";
	RecipeName[4] = "Ä¦Î÷¶ûÖ®Ñ¥";
	RecipeName[5] = "Ä¦Î÷¶ûÖ®¶Ü";
	RecipeName[6] = "°¢¿ËµÂÈ­Ì×";
	RecipeName[7] = "°¢¿ËµÂÖ®¿ø";
	RecipeName[8] = "°¢¿ËµÂÖ®îø";
	RecipeName[9] = "°¢¿ËµÂÖ®ÊÖ";
	RecipeName[10] = "°¢¿ËµÂÖ®Ñ¥";
	RecipeName[11] = "°¢¿ËµÂÖ®¶Ü";
	RecipeName[12] = "°¢²©À××È·¨ÕÈ";
	RecipeName[13] = "°¢²©À××ÈÖ®¿ø";
	RecipeName[14] = "°¢²©À××ÈÖ®·þ";
	RecipeName[15] = "°¢²©À××ÈÖ®ÊÖ";
	RecipeName[16] = "°¢²©À××ÈÖ®Ñ¥";
	RecipeName[17] = "°¬²¼À³µÂ¹­";
	RecipeName[18] = "°¬²¼À³µÂÖ®Ã±";
	RecipeName[19] = "°¬²¼À³µÂÖ®¼×";
	RecipeName[20] = "°¬²¼À³µÂÖ®ÊÖ";
	RecipeName[21] = "°¬²¼À³µÂÖ®Ð¬";
	RecipeName[22] = "¸ñÀ³Î÷Ö®¹÷";
	RecipeName[23] = "¸ñÀ³Î÷Ö®Ã±";
	RecipeName[24] = "¸ñÀ³Î÷Ö®·þ";
	RecipeName[25] = "¸ñÀ³Î÷Ö®ÊÖ";
	RecipeName[26] = "¸ñÀ³Î÷Ö®Ð¬";

	FirstStuffName[0] = "»ðÐÇÑÒ";
	FirstStuffName[1] = "îÑ Ô­Ê¯";
	FirstStuffName[2] = "Äø Ô­Ê¯";
	FirstStuffName[3] = "Í­ Ô­Ê¯";
	FirstStuffName[4] = "Ö©ÖëÑÒ";
	FirstStuffName[5] = "ÖýÌú ¿óÊ¯";
	FirstStuffName[6] = "Ñü¹û ¹ûÊµ";
	FirstStuffName[7] = "ÌØÊâ Ï¡ÊÍ¼Á";
	FirstStuffName[8] = "Ò©²Ý";
	FirstStuffName[9] = "ºìÉ« çßÁÛ";
	FirstStuffName[10] = "ÂÌÉ« çßÁÛ";
	FirstStuffIconName[0] = "Lv12Refine_IgneousRock_RS";
	FirstStuffIconName[1] = "Lv12Refine_Titanium_RS";
	FirstStuffIconName[2] = "Lv12Refine_Nickel_RS";
	FirstStuffIconName[3] = "Lv12Refine_Copper_RS";
	FirstStuffIconName[4] = "Lv12Refine_SpiderStone";
	FirstStuffIconName[5] = "Lv12Refine_IronOre";
	FirstStuffIconName[6] = "Lv12Refine_Cashew";
	FirstStuffIconName[7] = "SpecialDiluted";
	FirstStuffIconName[8] = "Herb";
	FirstStuffIconName[9] = "Lv12Refine_DragonScale_Red";
	FirstStuffIconName[10] = "Lv12Refine_DragonScale_Blue";


	SecondStuffName[0] = "ï¯";
	SecondStuffName[1] = "îÑ";
	SecondStuffName[2] = "Äø";
	SecondStuffName[3] = "Í­";
	SecondStuffName[4] = "¸ÖÌú";
	SecondStuffName[5] = "ºÏ½ð·Û";
	SecondStuffName[6] = "Ò»°ã ²¹¶¡Ìú";
	SecondStuffName[7] = "ÂÌÉ« Ö©Öë¿óÊ¯";
	SecondStuffName[8] = "ÖýÌú ¿óÊ¯ Öý¿é";
	SecondStuffName[9] = "À¶É« ÊàÅ¦";
	SecondStuffName[10] = "Ä§Á¦Ê¯";
	SecondStuffName[11] = "Ñü¹û Í¿ÁÏ";
	SecondStuffName[12] = "¸£¶ûÂíÁÖ »ìºÏÎï";
	SecondStuffName[13] = "Èø·ÆÂÞË¹ ÒÂÁÏ";
	SecondStuffName[14] = "ÑÌ»ðÖ®¾»Ë®";
	SecondStuffName[15] = "¾«¹¤±¦Ê¯";
	SecondStuffName[16] = "»ðÉ½µÄ ¼ë";
	SecondStuffName[17] = "ÌØÊâ Ï¡ÊÍ¼Á";
	SecondStuffName[18] = "ºìÉ«ÌìÈ»ÑÕÁÏ";
	SecondStuffName[19] = "¼áÈÍ çßÁÛ Æ¤";
	SecondStuffName[20] = "±´¿Ç";
	SecondStuffName[21] = "¾«ÁéÖ®Æø";
	SecondStuffName[22] = "Æ¤´ø";
	SecondStuffName[23] = "±ùµÄ ¾»Ë®";
	SecondStuffName[24] = "ÉúÃüµÄ ¼ë";
	SecondStuffName[25] = "ÂÌÉ« ÌìÈ»ÑÕÁÏ";
	SecondStuffIconName[0] = "Lv12Refine_Zirconium_I";
	SecondStuffIconName[1] = "Lv12Refine_Titanium";
	SecondStuffIconName[2] = "Lv12Refine_Nickel";
	SecondStuffIconName[3] = "Lv12Refine_Copper";
	SecondStuffIconName[4] = "Steel";
	SecondStuffIconName[5] = "AlloyPowder";
	SecondStuffIconName[6] = "HQ_Item_Hasp";
	SecondStuffIconName[7] = "Lv12Refine_BlueSpiderStone";
	SecondStuffIconName[8] = "Lv12Refine_IronOre_I";
	SecondStuffIconName[9] = "Lv12Refine_BlueHerb";
	SecondStuffIconName[10] = "PowerGem";
	SecondStuffIconName[11] = "Lv12Refine_CashewPaint";
	SecondStuffIconName[12] = "Lv12Refine_MixFormalin";
	SecondStuffIconName[13] = "Lv12Refine_SephirothCloth";
	SecondStuffIconName[14] = "Lv12Refine_Marrow_Fire";
	SecondStuffIconName[15] = "WareGemstone";
	SecondStuffIconName[16] = "Lv12Refine_Cocoon_Red";
	SecondStuffIconName[17] = "SpecialDiluted";
	SecondStuffIconName[18] = "Lv12Refine_Dye_Red";
	SecondStuffIconName[19] = "Lv12Refine_DragonScale_Tough";
	SecondStuffIconName[20] = "Patch";
	SecondStuffIconName[21] = "Lv12Refine_ElementalForce";
	SecondStuffIconName[22] = "Strap";
	SecondStuffIconName[23] = "Lv12Refine_Marrow_Ice";
	SecondStuffIconName[24] = "Lv12Refine_Cocoon_Green";
	SecondStuffIconName[25] = "Lv12Refine_Dye_Blue";

	ThirdStuffName[0]  = "ºìÉ«»ùÅµÖ®ÐÇ";
	ThirdStuffName[1]  = "°¬À­¶÷µÄ ÑÅÀ­ÎÞ ÖäÎÄÊé";
	ThirdStuffName[2]  = "ÒºÌå ½ðÊô Öý¿é";
	ThirdStuffName[3]  = "¸ÖÌú ²¹¶¡Ìú";
	ThirdStuffName[4]  = "Ð°¶ñÊØ»¤ÕßµÄÎÄÕÂ";
	ThirdStuffName[5]  = "ÂÌÉ« Ö©Öë ÖýÌú ¿óÊ¯ Öý¿é";
	ThirdStuffName[6]  = "Ä§Á¦µÄ ÂÌÉ« Í¿ÁÏ";
	ThirdStuffName[7]  = "µØÓü¿þÀÜµÄÈ­Í·";
	ThirdStuffName[8]  = "È¼ÆðµÄÑÌ»ð ÒÂÁÏ";
	ThirdStuffName[9]  = "Æ¤´ø";
	ThirdStuffName[10] = "Ä§Á¦µÄ ¾»Ë®";
	ThirdStuffName[11] = "»ðÉ½µÄ ¸Ö½ÊÏß";
	ThirdStuffName[12] = "Ä§Á¦µÄ ºìÉ«ÑÕÁÏ";
	ThirdStuffName[13] = "¶ñÄ§ÊõÊ¿µÄÀ¶±¦Ê¯";
	ThirdStuffName[14] = "Ç¿»¯ çßÁÛ Æ¤";
	ThirdStuffName[15] = "¾«Áé ´øÓÐµÄ Æ¤´ø";
	ThirdStuffName[16] = "»ÃÏëµÄ±¦Ê¯ ×°ÊÎÆ·";
	ThirdStuffName[17] = "¶ñÄ§¹­¼ýÊÖµÄ¼ý";
	ThirdStuffName[18] = "½á±ùµÄÔÂ¹â ÒÂÁÏ";
	ThirdStuffName[19] = "ÉúÃüµÄ ¸Ö½ÊÏß";
	ThirdStuffName[20] = "Ä§Á¦µÄ ÂÌÉ« ÑÕÁÏ";
	ThirdStuffName[21] = "¶ñÄ§ÊõÊ¿µÄÀ¶±¦Ê¯";
	ThirdStuffIconName[0]  = "MixGem";
	ThirdStuffIconName[1]  = "Lv12Refine_YellowScroll";
	ThirdStuffIconName[2]  = "Lv12Refine_LiquidMetal_I";
	ThirdStuffIconName[3]  = "Lv12Refine_SteelHasp";
	ThirdStuffIconName[4]  = "Event_Item_GiftDeco"; //"Insignia";
	ThirdStuffIconName[5]  = "Lv12Refine_BlueSpiderStone_IO_I";
	ThirdStuffIconName[6]  = "Lv12Refine_ManaPaint_Blue";
	ThirdStuffIconName[7]  = "Event_Item_GiftDeco"; //"Fist";
	ThirdStuffIconName[8]  = "Lv12Refine_FireCloth";
	ThirdStuffIconName[9]  = "Strap";
	ThirdStuffIconName[10] = "Lv12Refine_Magic_Cream";
	ThirdStuffIconName[11] = "Lv12Refine_Yarn_Red";
	ThirdStuffIconName[12] = "Lv12Refine_ManaDye_Red";
	ThirdStuffIconName[13] = "Event_Item_GiftDeco"; //"RedJewel";
	ThirdStuffIconName[14] = "Lv12Refine_DragonScale_Strong";
	ThirdStuffIconName[15] = "Lv12Refine_ElementalStrap";
	ThirdStuffIconName[16] = "Lv12Refine_FantasticAccessory";
	ThirdStuffIconName[17] = "Event_Item_GiftDeco"; //"Arrow";
	ThirdStuffIconName[18] = "Lv12Refine_IceCloth";
	ThirdStuffIconName[19] = "Lv12Refine_Yarn_Green";
	ThirdStuffIconName[20] = "Lv12Refine_ManaDye_Blue";
	ThirdStuffIconName[21] = "Event_Item_GiftDeco"; //"BlueJewel";

	NeedList[0].iname = "";
	NeedList[1].iname = "";
	NeedList[2].iname = "";
	NeedList[3].iname = "";
	NeedList[0].needPics = 0;
	NeedList[1].needPics = 0;
	NeedList[2].needPics = 0;
	NeedList[3].needPics = 0;
}

function int GetRecipeIndex(int job, int part)
{
	local int index;

	switch(job)
	{
		case OneHand: index = 0; break;
		case Bare:    index = 6; break;
		case Red:     index = 12; break;
		case Bow:     index = 17; break;
		case Blue:    index = 22; break;
	}

	index = 400 + index + (part - Weapon);

	return index;
}

function int GetRecipeDataNeedPics(int job, int part, int line)
{
	local array<RecipeData> temp;

	switch(job)
	{
		case OneHand:
			if(part == Weapon)
				temp = MurcielSword;  
			else if(part == Helmet)  
				temp = MurcielHelmet;   
			else if(part == Armor)
				temp = MurcielArmor;   
			else if(part == Vambrace)  
				temp = MurcielVambrace;
			else if(part == Boots)
				temp = MurcielBoots;
			else if(part == Shield)
				temp = MurcielShield;
			break;

		case Bare:
			if(part == Weapon)
				temp = AcordGauntlet;  
			else if(part == Helmet)  
				temp = AcordHelmet;   
			else if(part == Armor)
				temp = AcordArmor;   
			else if(part == Vambrace)  
				temp = AcordVambrace;
			else if(part == Boots)
				temp = AcordBoots;
			else if(part == Shield)
				temp = AcordProtector;
			break;

		case Red:
			if(part == Weapon)
				temp = AblazeStaff;  
			else if(part == Helmet)  
				temp = AblazeHelmet;   
			else if(part == Armor)
				temp = AblazeGarment;   
			else if(part == Vambrace)  
				temp = AblazeVambrace;
			else if(part == Boots)
				temp = AblazeBoots;
			break;

		case Bow:
			if(part == Weapon)
				temp = ApliteBow;  
			else if(part == Helmet)  
				temp = ApliteCap;   
			else if(part == Armor)
				temp = ApliteGarb;   
			else if(part == Vambrace)  
				temp = ApliteSleevelet;
			else if(part == Boots)
				temp = ApliteSandal;
			break;

		case Blue:
			if(part == Weapon)
				temp = GlaciesStick;  
			else if(part == Helmet)  
				temp = GlaciesCap;   
			else if(part == Armor)
				temp = GlaciesGown;   
			else if(part == Vambrace)  
				temp = GlaciesSleevelet;
			else if(part == Boots)
				temp = GlaciesSandal;
			break;

		default:
			return 99999;
	}

	return temp[line].pics;
}

function string GetRecipeData(int job, int part, int line)
{
	local array<RecipeData> temp;
	local int step, index;

	switch(job)
	{
		case OneHand:
			if(part == Weapon)
				temp = MurcielSword;  
			else if(part == Helmet)  
				temp = MurcielHelmet;   
			else if(part == Armor)
				temp = MurcielArmor;   
			else if(part == Vambrace)  
				temp = MurcielVambrace;
			else if(part == Boots)
				temp = MurcielBoots;
			else if(part == Shield)
				temp = MurcielShield;
			break;

		case Bare:
			if(part == Weapon)
				temp = AcordGauntlet;  
			else if(part == Helmet)  
				temp = AcordHelmet;   
			else if(part == Armor)
				temp = AcordArmor;   
			else if(part == Vambrace)  
				temp = AcordVambrace;
			else if(part == Boots)
				temp = AcordBoots;
			else if(part == Shield)
				temp = AcordProtector;
			break;

		case Red:
			if(part == Weapon)
				temp = AblazeStaff;  
			else if(part == Helmet)  
				temp = AblazeHelmet;   
			else if(part == Armor)
				temp = AblazeGarment;   
			else if(part == Vambrace)  
				temp = AblazeVambrace;
			else if(part == Boots)
				temp = AblazeBoots;
			break;

		case Bow:
			if(part == Weapon)
				temp = ApliteBow;  
			else if(part == Helmet)  
				temp = ApliteCap;   
			else if(part == Armor)
				temp = ApliteGarb;   
			else if(part == Vambrace)  
				temp = ApliteSleevelet;
			else if(part == Boots)
				temp = ApliteSandal;
			break;

		case Blue:
			if(part == Weapon)
				temp = GlaciesStick;  
			else if(part == Helmet)  
				temp = GlaciesCap;   
			else if(part == Armor)
				temp = GlaciesGown;   
			else if(part == Vambrace)  
				temp = GlaciesSleevelet;
			else if(part == Boots)
				temp = GlaciesSandal;
			break;

		default:
			return "";
	}

	step = temp[line].step;
	index = temp[line].index;

//	return "job :" $ job $ " part :" $ part; 
//	return "index :" $ index $ " step :" $ step $ " name :" $RecipeName[index];

	if(line < temp.Length+1)
	{
		switch(step)
		{
			//case 1:
			//	return "        " $ FirstStuffName[index];
			case 2:
				return "          " $ SecondStuffName[index];
			case 3:
				return "      " $ ThirdStuffName[index];
			case 4:
				return " " $ RecipeName[index];
	
			default:
				return "";
		}
	}

	return "";
}

function string GetNeedName(int job, int part, int line, int n)
{
	local array<RecipeData> temp;
	local MakeData MData;
	local int step, index, RecipeIndex;

	switch(job)
	{
		case OneHand:
			if(part == Weapon)
				temp = MurcielSword;  
			else if(part == Helmet)  
				temp = MurcielHelmet;   
			else if(part == Armor)
				temp = MurcielArmor;   
			else if(part == Vambrace)  
				temp = MurcielVambrace;
			else if(part == Boots)
				temp = MurcielBoots;
			else if(part == Shield)
				temp = MurcielShield;
			break;

		case Bare:
			if(part == Weapon)
				temp = AcordGauntlet;  
			else if(part == Helmet)  
				temp = AcordHelmet;   
			else if(part == Armor)
				temp = AcordArmor;   
			else if(part == Vambrace)  
				temp = AcordVambrace;
			else if(part == Boots)
				temp = AcordBoots;
			else if(part == Shield)
				temp = AcordProtector;
			break;

		case Red:
			if(part == Weapon)
				temp = AblazeStaff;  
			else if(part == Helmet)  
				temp = AblazeHelmet;   
			else if(part == Armor)
				temp = AblazeGarment;   
			else if(part == Vambrace)  
				temp = AblazeVambrace;
			else if(part == Boots)
				temp = AblazeBoots;
			break;

		case Bow:
			if(part == Weapon)
				temp = ApliteBow;  
			else if(part == Helmet)  
				temp = ApliteCap;   
			else if(part == Armor)
				temp = ApliteGarb;   
			else if(part == Vambrace)  
				temp = ApliteSleevelet;
			else if(part == Boots)
				temp = ApliteSandal;
			break;

		case Blue:
			if(part == Weapon)
				temp = GlaciesStick;  
			else if(part == Helmet)  
				temp = GlaciesCap;   
			else if(part == Armor)
				temp = GlaciesGown;   
			else if(part == Vambrace)  
				temp = GlaciesSleevelet;
			else if(part == Boots)
				temp = GlaciesSandal;
			break;

	}

	step = temp[line].step;
	index = temp[line].index;

	RecipeIndex = step*100 + index;
	
	MData = MakeList[RecipeIndex];

	NeedList[0].iname = IndexToName(MData.a);
	NeedList[1].iname = IndexToName(MData.b);
	NeedList[2].iname = IndexToName(MData.c);
	NeedList[3].iname = IndexToName(MData.d);
	NeedList[0].needPics = MData.an;
	NeedList[1].needPics = MData.bn;
	NeedList[2].needPics = MData.cn;
	NeedList[3].needPics = MData.dn;

	return NeedList[n].iname;
}

function int GetNeedIndex(int job, int part, int line, int n)
{
	local MakeData MData;
	local int RecipeIndex;

	RecipeIndex = GetRecipeDataIndex(job, part, line);
	
	MData = MakeList[RecipeIndex];

	if(n == 0)
		return MData.a;
	else if(n == 1)
		return MData.b;
	else if(n == 2)
		return MData.c;
	else
		return MData.d;
}

function int GetNeedPics(int job, int part, int line, int n)
{
	local MakeData MData;
	local int RecipeIndex;

	RecipeIndex = GetRecipeDataIndex(job, part, line);
	
	MData = MakeList[RecipeIndex];

	NeedList[0].iname = IndexToName(MData.a);
	NeedList[1].iname = IndexToName(MData.b);
	NeedList[2].iname = IndexToName(MData.c);
	NeedList[3].iname = IndexToName(MData.d);
	NeedList[0].needPics = MData.an;
	NeedList[1].needPics = MData.bn;
	NeedList[2].needPics = MData.cn;
	NeedList[3].needPics = MData.dn;

	return NeedList[n].needPics;
}

function int IndexToStep(int idx)
{
	if(idx > 99)
		return idx / 100;

	return 0;
}

function string IndexToName(int idx)
{
	local int step, index;

	if(idx > 99)
	{	
		step = idx / 100;
		index = idx % 100;

		switch(step)
		{
			case 1:
				return FirstStuffName[index];
			case 2:
				return SecondStuffName[index];
			case 3:
				return ThirdStuffName[index];
		}
	}

	return "";
}

function string IndexToIconName(int idx)
{
	local int step, index;

	if(idx > 99)
	{	
		step = idx / 100;
		index = idx % 100;

		switch(step)
		{
			case 1:
				return FirstStuffIconName[index];
			case 2:
				return SecondStuffIconName[index];
			case 3:
				return ThirdStuffIconName[index];
		}
	}

	return "";
}


function int GetRecipeDataIndex(int job, int part, int line)
{
	local array<RecipeData> temp;
	local int step, index;

	switch(job)
	{
		case OneHand:
			if(part == Weapon)
				temp = MurcielSword;  
			else if(part == Helmet)  
				temp = MurcielHelmet;   
			else if(part == Armor)
				temp = MurcielArmor;   
			else if(part == Vambrace)  
				temp = MurcielVambrace;
			else if(part == Boots)
				temp = MurcielBoots;
			else if(part == Shield)
				temp = MurcielShield;
			break;

		case Bare:
			if(part == Weapon)
				temp = AcordGauntlet;  
			else if(part == Helmet)  
				temp = AcordHelmet;   
			else if(part == Armor)
				temp = AcordArmor;   
			else if(part == Vambrace)  
				temp = AcordVambrace;
			else if(part == Boots)
				temp = AcordBoots;
			else if(part == Shield)
				temp = AcordProtector;
			break;

		case Red:
			if(part == Weapon)
				temp = AblazeStaff;  
			else if(part == Helmet)  
				temp = AblazeHelmet;   
			else if(part == Armor)
				temp = AblazeGarment;   
			else if(part == Vambrace)  
				temp = AblazeVambrace;
			else if(part == Boots)
				temp = AblazeBoots;
			break;

		case Bow:
			if(part == Weapon)
				temp = ApliteBow;  
			else if(part == Helmet)  
				temp = ApliteCap;   
			else if(part == Armor)
				temp = ApliteGarb;   
			else if(part == Vambrace)  
				temp = ApliteSleevelet;
			else if(part == Boots)
				temp = ApliteSandal;
			break;

		case Blue:
			if(part == Weapon)
				temp = GlaciesStick;  
			else if(part == Helmet)  
				temp = GlaciesCap;   
			else if(part == Armor)
				temp = GlaciesGown;   
			else if(part == Vambrace)  
				temp = GlaciesSleevelet;
			else if(part == Boots)
				temp = GlaciesSandal;
			break;

	}

	step = temp[line].step;
	index = temp[line].index;

	return step*100 + index;
}

defaultproperties
{
     MurcielSword(0)=(Step=4,pics=99)
     MurcielSword(1)=(Step=3,Index=2,pics=5)
     MurcielSword(2)=(Step=2,pics=2)
     MurcielSword(3)=(Step=2,Index=1,pics=2)
     MurcielSword(4)=(Step=2,Index=2,pics=2)
     MurcielSword(5)=(Step=2,Index=3,pics=2)
     MurcielSword(6)=(Step=3,Index=3,pics=1)
     MurcielSword(7)=(Step=2,Index=4,pics=700)
     MurcielSword(8)=(Step=2,Index=5,pics=650)
     MurcielSword(9)=(Step=2,Index=6,pics=1)
     MurcielSword(10)=(Step=3,pics=6)
     MurcielSword(11)=(Step=3,Index=4,pics=4)
     MurcielSword(12)=(Step=3,Index=1,pics=1)
     MurcielShield(0)=(Step=4,Index=5,pics=99)
     MurcielShield(1)=(Step=3,Index=2,pics=4)
     MurcielShield(2)=(Step=2,pics=2)
     MurcielShield(3)=(Step=2,Index=1,pics=2)
     MurcielShield(4)=(Step=2,Index=2,pics=2)
     MurcielShield(5)=(Step=2,Index=3,pics=2)
     MurcielShield(6)=(Step=3,Index=3,pics=1)
     MurcielShield(7)=(Step=2,Index=4,pics=700)
     MurcielShield(8)=(Step=2,Index=5,pics=650)
     MurcielShield(9)=(Step=2,Index=6,pics=1)
     MurcielShield(10)=(Step=3,pics=4)
     MurcielShield(11)=(Step=3,Index=4,pics=4)
     MurcielShield(12)=(Step=3,Index=1,pics=1)
     MurcielHelmet(0)=(Step=4,Index=1,pics=99)
     MurcielHelmet(1)=(Step=3,Index=2,pics=2)
     MurcielHelmet(2)=(Step=2,pics=2)
     MurcielHelmet(3)=(Step=2,Index=1,pics=2)
     MurcielHelmet(4)=(Step=2,Index=2,pics=2)
     MurcielHelmet(5)=(Step=2,Index=3,pics=2)
     MurcielHelmet(6)=(Step=3,Index=3,pics=1)
     MurcielHelmet(7)=(Step=2,Index=4,pics=700)
     MurcielHelmet(8)=(Step=2,Index=5,pics=650)
     MurcielHelmet(9)=(Step=2,Index=6,pics=1)
     MurcielHelmet(10)=(Step=3,pics=3)
     MurcielHelmet(11)=(Step=3,Index=4,pics=3)
     MurcielHelmet(12)=(Step=3,Index=1,pics=1)
     MurcielArmor(0)=(Step=4,Index=2,pics=99)
     MurcielArmor(1)=(Step=3,Index=2,pics=3)
     MurcielArmor(2)=(Step=2,pics=2)
     MurcielArmor(3)=(Step=2,Index=1,pics=2)
     MurcielArmor(4)=(Step=2,Index=2,pics=2)
     MurcielArmor(5)=(Step=2,Index=3,pics=2)
     MurcielArmor(6)=(Step=3,Index=3,pics=1)
     MurcielArmor(7)=(Step=2,Index=4,pics=700)
     MurcielArmor(8)=(Step=2,Index=5,pics=650)
     MurcielArmor(9)=(Step=2,Index=6,pics=1)
     MurcielArmor(10)=(Step=3,pics=5)
     MurcielArmor(11)=(Step=3,Index=4,pics=3)
     MurcielArmor(12)=(Step=3,Index=1,pics=1)
     MurcielVambrace(0)=(Step=4,Index=3,pics=99)
     MurcielVambrace(1)=(Step=3,Index=2,pics=1)
     MurcielVambrace(2)=(Step=2,pics=2)
     MurcielVambrace(3)=(Step=2,Index=1,pics=2)
     MurcielVambrace(4)=(Step=2,Index=2,pics=2)
     MurcielVambrace(5)=(Step=2,Index=3,pics=2)
     MurcielVambrace(6)=(Step=3,Index=3,pics=1)
     MurcielVambrace(7)=(Step=2,Index=4,pics=700)
     MurcielVambrace(8)=(Step=2,Index=5,pics=650)
     MurcielVambrace(9)=(Step=2,Index=6,pics=1)
     MurcielVambrace(10)=(Step=3,pics=2)
     MurcielVambrace(11)=(Step=3,Index=4,pics=2)
     MurcielVambrace(12)=(Step=3,Index=1,pics=1)
     MurcielBoots(0)=(Step=4,Index=4,pics=99)
     MurcielBoots(1)=(Step=3,Index=2,pics=2)
     MurcielBoots(2)=(Step=2,pics=2)
     MurcielBoots(3)=(Step=2,Index=1,pics=2)
     MurcielBoots(4)=(Step=2,Index=2,pics=2)
     MurcielBoots(5)=(Step=2,Index=3,pics=2)
     MurcielBoots(6)=(Step=3,Index=3,pics=1)
     MurcielBoots(7)=(Step=2,Index=4,pics=700)
     MurcielBoots(8)=(Step=2,Index=5,pics=650)
     MurcielBoots(9)=(Step=2,Index=6,pics=1)
     MurcielBoots(10)=(Step=3,pics=3)
     MurcielBoots(11)=(Step=3,Index=4,pics=3)
     MurcielBoots(12)=(Step=3,Index=1,pics=1)
     AcordGauntlet(0)=(Step=4,Index=6,pics=99)
     AcordGauntlet(1)=(Step=3,Index=5,pics=5)
     AcordGauntlet(2)=(Step=2,Index=7,pics=2)
     AcordGauntlet(3)=(Step=2,Index=8,pics=2)
     AcordGauntlet(4)=(Step=2,Index=2,pics=2)
     AcordGauntlet(5)=(Step=2,Index=3,pics=2)
     AcordGauntlet(6)=(Step=3,Index=6,pics=1)
     AcordGauntlet(7)=(Step=2,Index=9,pics=2)
     AcordGauntlet(8)=(Step=2,Index=10,pics=400)
     AcordGauntlet(9)=(Step=2,Index=11,pics=1)
     AcordGauntlet(10)=(Step=2,Index=12,pics=1)
     AcordGauntlet(11)=(Step=3,pics=6)
     AcordGauntlet(12)=(Step=3,Index=7,pics=4)
     AcordGauntlet(13)=(Step=3,Index=1,pics=1)
     AcordProtector(0)=(Step=4,Index=11,pics=99)
     AcordProtector(1)=(Step=3,Index=5,pics=4)
     AcordProtector(2)=(Step=2,Index=7,pics=2)
     AcordProtector(3)=(Step=2,Index=8,pics=2)
     AcordProtector(4)=(Step=2,Index=2,pics=2)
     AcordProtector(5)=(Step=2,Index=3,pics=2)
     AcordProtector(6)=(Step=3,Index=6,pics=1)
     AcordProtector(7)=(Step=2,Index=9,pics=2)
     AcordProtector(8)=(Step=2,Index=10,pics=400)
     AcordProtector(9)=(Step=2,Index=11,pics=1)
     AcordProtector(10)=(Step=2,Index=12,pics=1)
     AcordProtector(11)=(Step=3,pics=4)
     AcordProtector(12)=(Step=3,Index=7,pics=4)
     AcordProtector(13)=(Step=3,Index=1,pics=1)
     AcordArmor(0)=(Step=4,Index=8,pics=99)
     AcordArmor(1)=(Step=3,Index=5,pics=3)
     AcordArmor(2)=(Step=2,Index=7,pics=2)
     AcordArmor(3)=(Step=2,Index=8,pics=2)
     AcordArmor(4)=(Step=2,Index=2,pics=2)
     AcordArmor(5)=(Step=2,Index=3,pics=2)
     AcordArmor(6)=(Step=3,Index=6,pics=1)
     AcordArmor(7)=(Step=2,Index=9,pics=2)
     AcordArmor(8)=(Step=2,Index=10,pics=400)
     AcordArmor(9)=(Step=2,Index=11,pics=1)
     AcordArmor(10)=(Step=2,Index=12,pics=1)
     AcordArmor(11)=(Step=3,pics=5)
     AcordArmor(12)=(Step=3,Index=7,pics=3)
     AcordArmor(13)=(Step=3,Index=1,pics=1)
     AcordHelmet(0)=(Step=4,Index=7,pics=99)
     AcordHelmet(1)=(Step=3,Index=5,pics=2)
     AcordHelmet(2)=(Step=2,Index=7,pics=2)
     AcordHelmet(3)=(Step=2,Index=8,pics=2)
     AcordHelmet(4)=(Step=2,Index=2,pics=2)
     AcordHelmet(5)=(Step=2,Index=3,pics=2)
     AcordHelmet(6)=(Step=3,Index=6,pics=1)
     AcordHelmet(7)=(Step=2,Index=9,pics=2)
     AcordHelmet(8)=(Step=2,Index=10,pics=400)
     AcordHelmet(9)=(Step=2,Index=11,pics=1)
     AcordHelmet(10)=(Step=2,Index=12,pics=1)
     AcordHelmet(11)=(Step=3,pics=3)
     AcordHelmet(12)=(Step=3,Index=7,pics=3)
     AcordHelmet(13)=(Step=3,Index=1,pics=1)
     AcordBoots(0)=(Step=4,Index=10,pics=99)
     AcordBoots(1)=(Step=3,Index=5,pics=2)
     AcordBoots(2)=(Step=2,Index=7,pics=2)
     AcordBoots(3)=(Step=2,Index=8,pics=2)
     AcordBoots(4)=(Step=2,Index=2,pics=2)
     AcordBoots(5)=(Step=2,Index=3,pics=2)
     AcordBoots(6)=(Step=3,Index=6,pics=1)
     AcordBoots(7)=(Step=2,Index=9,pics=2)
     AcordBoots(8)=(Step=2,Index=10,pics=400)
     AcordBoots(9)=(Step=2,Index=11,pics=1)
     AcordBoots(10)=(Step=2,Index=12,pics=1)
     AcordBoots(11)=(Step=3,pics=3)
     AcordBoots(12)=(Step=3,Index=7,pics=3)
     AcordBoots(13)=(Step=3,Index=1,pics=1)
     AcordVambrace(0)=(Step=4,Index=9,pics=99)
     AcordVambrace(1)=(Step=3,Index=5,pics=1)
     AcordVambrace(2)=(Step=2,Index=7,pics=2)
     AcordVambrace(3)=(Step=2,Index=8,pics=2)
     AcordVambrace(4)=(Step=2,Index=2,pics=2)
     AcordVambrace(5)=(Step=2,Index=3,pics=2)
     AcordVambrace(6)=(Step=3,Index=6,pics=1)
     AcordVambrace(7)=(Step=2,Index=9,pics=2)
     AcordVambrace(8)=(Step=2,Index=10,pics=400)
     AcordVambrace(9)=(Step=2,Index=11,pics=1)
     AcordVambrace(10)=(Step=2,Index=12,pics=1)
     AcordVambrace(11)=(Step=3,pics=2)
     AcordVambrace(12)=(Step=3,Index=7,pics=2)
     AcordVambrace(13)=(Step=3,Index=1,pics=1)
     AblazeStaff(0)=(Step=4,Index=12,pics=99)
     AblazeStaff(1)=(Step=3,Index=8,pics=5)
     AblazeStaff(2)=(Step=2,Index=13,pics=5)
     AblazeStaff(3)=(Step=2,Index=14,pics=1)
     AblazeStaff(4)=(Step=3,Index=9,pics=2000)
     AblazeStaff(5)=(Step=3,Index=10,pics=1)
     AblazeStaff(6)=(Step=2,Index=15,pics=50)
     AblazeStaff(7)=(Step=2,Index=10,pics=50)
     AblazeStaff(8)=(Step=3,Index=11,pics=1)
     AblazeStaff(9)=(Step=2,Index=16,pics=3)
     AblazeStaff(10)=(Step=3,Index=12,pics=2)
     AblazeStaff(11)=(Step=2,Index=10,pics=160)
     AblazeStaff(12)=(Step=2,Index=17,pics=1)
     AblazeStaff(13)=(Step=2,Index=18,pics=1)
     AblazeStaff(14)=(Step=3,pics=4)
     AblazeStaff(15)=(Step=3,Index=13,pics=3)
     AblazeStaff(16)=(Step=3,Index=1,pics=1)
     AblazeGarment(0)=(Step=4,Index=14,pics=99)
     AblazeGarment(1)=(Step=3,Index=8,pics=3)
     AblazeGarment(2)=(Step=2,Index=13,pics=5)
     AblazeGarment(3)=(Step=2,Index=14,pics=1)
     AblazeGarment(4)=(Step=3,Index=9,pics=2000)
     AblazeGarment(5)=(Step=3,Index=10,pics=1)
     AblazeGarment(6)=(Step=2,Index=15,pics=50)
     AblazeGarment(7)=(Step=2,Index=10,pics=50)
     AblazeGarment(8)=(Step=3,Index=11,pics=1)
     AblazeGarment(9)=(Step=2,Index=16,pics=3)
     AblazeGarment(10)=(Step=3,Index=12,pics=2)
     AblazeGarment(11)=(Step=2,Index=10,pics=160)
     AblazeGarment(12)=(Step=2,Index=17,pics=1)
     AblazeGarment(13)=(Step=2,Index=18,pics=1)
     AblazeGarment(14)=(Step=3,pics=3)
     AblazeGarment(15)=(Step=3,Index=13,pics=3)
     AblazeGarment(16)=(Step=3,Index=1,pics=1)
     AblazeHelmet(0)=(Step=4,Index=13,pics=99)
     AblazeHelmet(1)=(Step=3,Index=8,pics=2)
     AblazeHelmet(2)=(Step=2,Index=13,pics=5)
     AblazeHelmet(3)=(Step=2,Index=14,pics=1)
     AblazeHelmet(4)=(Step=3,Index=9,pics=2000)
     AblazeHelmet(5)=(Step=3,Index=10,pics=1)
     AblazeHelmet(6)=(Step=2,Index=15,pics=50)
     AblazeHelmet(7)=(Step=2,Index=10,pics=50)
     AblazeHelmet(8)=(Step=3,Index=11,pics=1)
     AblazeHelmet(9)=(Step=2,Index=16,pics=3)
     AblazeHelmet(10)=(Step=3,Index=12,pics=2)
     AblazeHelmet(11)=(Step=2,Index=10,pics=160)
     AblazeHelmet(12)=(Step=2,Index=17,pics=1)
     AblazeHelmet(13)=(Step=2,Index=18,pics=1)
     AblazeHelmet(14)=(Step=3,pics=2)
     AblazeHelmet(15)=(Step=3,Index=13,pics=2)
     AblazeHelmet(16)=(Step=3,Index=1,pics=1)
     AblazeBoots(0)=(Step=4,Index=16,pics=99)
     AblazeBoots(1)=(Step=3,Index=8,pics=2)
     AblazeBoots(2)=(Step=2,Index=13,pics=5)
     AblazeBoots(3)=(Step=2,Index=14,pics=1)
     AblazeBoots(4)=(Step=3,Index=9,pics=2000)
     AblazeBoots(5)=(Step=3,Index=10,pics=1)
     AblazeBoots(6)=(Step=2,Index=15,pics=50)
     AblazeBoots(7)=(Step=2,Index=10,pics=50)
     AblazeBoots(8)=(Step=3,Index=11,pics=1)
     AblazeBoots(9)=(Step=2,Index=16,pics=3)
     AblazeBoots(10)=(Step=3,Index=12,pics=2)
     AblazeBoots(11)=(Step=2,Index=10,pics=160)
     AblazeBoots(12)=(Step=2,Index=17,pics=1)
     AblazeBoots(13)=(Step=2,Index=18,pics=1)
     AblazeBoots(14)=(Step=3,pics=2)
     AblazeBoots(15)=(Step=3,Index=13,pics=2)
     AblazeBoots(16)=(Step=3,Index=1,pics=1)
     AblazeVambrace(0)=(Step=4,Index=15,pics=99)
     AblazeVambrace(1)=(Step=3,Index=8,pics=1)
     AblazeVambrace(2)=(Step=2,Index=13,pics=5)
     AblazeVambrace(3)=(Step=2,Index=14,pics=1)
     AblazeVambrace(4)=(Step=3,Index=9,pics=2000)
     AblazeVambrace(5)=(Step=3,Index=10,pics=1)
     AblazeVambrace(6)=(Step=2,Index=15,pics=50)
     AblazeVambrace(7)=(Step=2,Index=10,pics=50)
     AblazeVambrace(8)=(Step=3,Index=11,pics=1)
     AblazeVambrace(9)=(Step=2,Index=16,pics=3)
     AblazeVambrace(10)=(Step=3,Index=12,pics=1)
     AblazeVambrace(11)=(Step=2,Index=10,pics=160)
     AblazeVambrace(12)=(Step=2,Index=17,pics=1)
     AblazeVambrace(13)=(Step=2,Index=18,pics=1)
     AblazeVambrace(14)=(Step=3,pics=1)
     AblazeVambrace(15)=(Step=3,Index=13,pics=1)
     AblazeVambrace(16)=(Step=3,Index=1,pics=1)
     ApliteBow(0)=(Step=4,Index=17,pics=99)
     ApliteBow(1)=(Step=3,Index=14,pics=4)
     ApliteBow(2)=(Step=2,Index=19,pics=2)
     ApliteBow(3)=(Step=2,Index=20,pics=500)
     ApliteBow(4)=(Step=3,Index=10,pics=1)
     ApliteBow(5)=(Step=2,Index=15,pics=50)
     ApliteBow(6)=(Step=2,Index=10,pics=50)
     ApliteBow(7)=(Step=3,Index=15,pics=3)
     ApliteBow(8)=(Step=2,Index=21,pics=1)
     ApliteBow(9)=(Step=2,Index=13,pics=5)
     ApliteBow(10)=(Step=2,Index=22,pics=500)
     ApliteBow(11)=(Step=3,Index=16,pics=3)
     ApliteBow(12)=(Step=3,pics=5)
     ApliteBow(13)=(Step=3,Index=17,pics=4)
     ApliteBow(14)=(Step=3,Index=1,pics=1)
     ApliteGarb(0)=(Step=4,Index=19,pics=99)
     ApliteGarb(1)=(Step=3,Index=14,pics=3)
     ApliteGarb(2)=(Step=2,Index=19,pics=2)
     ApliteGarb(3)=(Step=2,Index=20,pics=500)
     ApliteGarb(4)=(Step=3,Index=10,pics=1)
     ApliteGarb(5)=(Step=2,Index=15,pics=50)
     ApliteGarb(6)=(Step=2,Index=10,pics=50)
     ApliteGarb(7)=(Step=3,Index=15,pics=3)
     ApliteGarb(8)=(Step=2,Index=21,pics=1)
     ApliteGarb(9)=(Step=2,Index=13,pics=5)
     ApliteGarb(10)=(Step=2,Index=22,pics=500)
     ApliteGarb(11)=(Step=3,Index=16,pics=3)
     ApliteGarb(12)=(Step=3,pics=5)
     ApliteGarb(13)=(Step=3,Index=17,pics=3)
     ApliteGarb(14)=(Step=3,Index=1,pics=1)
     ApliteCap(0)=(Step=4,Index=18,pics=99)
     ApliteCap(1)=(Step=3,Index=14,pics=2)
     ApliteCap(2)=(Step=2,Index=19,pics=2)
     ApliteCap(3)=(Step=2,Index=20,pics=500)
     ApliteCap(4)=(Step=3,Index=10,pics=1)
     ApliteCap(5)=(Step=2,Index=15,pics=50)
     ApliteCap(6)=(Step=2,Index=10,pics=50)
     ApliteCap(7)=(Step=3,Index=15,pics=2)
     ApliteCap(8)=(Step=2,Index=21,pics=1)
     ApliteCap(9)=(Step=2,Index=13,pics=5)
     ApliteCap(10)=(Step=2,Index=22,pics=500)
     ApliteCap(11)=(Step=3,Index=16,pics=2)
     ApliteCap(12)=(Step=3,pics=2)
     ApliteCap(13)=(Step=3,Index=17,pics=2)
     ApliteCap(14)=(Step=3,Index=1,pics=1)
     ApliteSandal(0)=(Step=4,Index=21,pics=99)
     ApliteSandal(1)=(Step=3,Index=14,pics=2)
     ApliteSandal(2)=(Step=2,Index=19,pics=2)
     ApliteSandal(3)=(Step=2,Index=20,pics=500)
     ApliteSandal(4)=(Step=3,Index=10,pics=1)
     ApliteSandal(5)=(Step=2,Index=15,pics=50)
     ApliteSandal(6)=(Step=2,Index=10,pics=50)
     ApliteSandal(7)=(Step=3,Index=15,pics=2)
     ApliteSandal(8)=(Step=2,Index=21,pics=1)
     ApliteSandal(9)=(Step=2,Index=13,pics=5)
     ApliteSandal(10)=(Step=2,Index=22,pics=500)
     ApliteSandal(11)=(Step=3,Index=16,pics=2)
     ApliteSandal(12)=(Step=3,pics=2)
     ApliteSandal(13)=(Step=3,Index=17,pics=2)
     ApliteSandal(14)=(Step=3,Index=1,pics=1)
     ApliteSleevelet(0)=(Step=4,Index=20,pics=99)
     ApliteSleevelet(1)=(Step=3,Index=14,pics=1)
     ApliteSleevelet(2)=(Step=2,Index=19,pics=2)
     ApliteSleevelet(3)=(Step=2,Index=20,pics=500)
     ApliteSleevelet(4)=(Step=3,Index=10,pics=1)
     ApliteSleevelet(5)=(Step=2,Index=15,pics=50)
     ApliteSleevelet(6)=(Step=2,Index=10,pics=50)
     ApliteSleevelet(7)=(Step=3,Index=15,pics=2)
     ApliteSleevelet(8)=(Step=2,Index=21,pics=1)
     ApliteSleevelet(9)=(Step=2,Index=13,pics=5)
     ApliteSleevelet(10)=(Step=2,Index=22,pics=500)
     ApliteSleevelet(11)=(Step=3,Index=16,pics=1)
     ApliteSleevelet(12)=(Step=3,pics=1)
     ApliteSleevelet(13)=(Step=3,Index=17,pics=1)
     ApliteSleevelet(14)=(Step=3,Index=1,pics=1)
     GlaciesStick(0)=(Step=4,Index=22,pics=99)
     GlaciesStick(1)=(Step=3,Index=18,pics=5)
     GlaciesStick(2)=(Step=2,Index=13,pics=5)
     GlaciesStick(3)=(Step=2,Index=23,pics=1)
     GlaciesStick(4)=(Step=3,Index=9,pics=2000)
     GlaciesStick(5)=(Step=3,Index=10,pics=1)
     GlaciesStick(6)=(Step=2,Index=15,pics=50)
     GlaciesStick(7)=(Step=2,Index=10,pics=50)
     GlaciesStick(8)=(Step=3,Index=19,pics=1)
     GlaciesStick(9)=(Step=2,Index=24,pics=3)
     GlaciesStick(10)=(Step=3,Index=20,pics=2)
     GlaciesStick(11)=(Step=2,Index=10,pics=160)
     GlaciesStick(12)=(Step=2,Index=17,pics=1)
     GlaciesStick(13)=(Step=2,Index=25,pics=1)
     GlaciesStick(14)=(Step=3,pics=4)
     GlaciesStick(15)=(Step=3,Index=21,pics=3)
     GlaciesStick(16)=(Step=3,Index=1,pics=1)
     GlaciesGown(0)=(Step=4,Index=24,pics=99)
     GlaciesGown(1)=(Step=3,Index=18,pics=3)
     GlaciesGown(2)=(Step=2,Index=13,pics=5)
     GlaciesGown(3)=(Step=2,Index=23,pics=1)
     GlaciesGown(4)=(Step=3,Index=9,pics=2000)
     GlaciesGown(5)=(Step=3,Index=10,pics=1)
     GlaciesGown(6)=(Step=2,Index=15,pics=50)
     GlaciesGown(7)=(Step=2,Index=10,pics=50)
     GlaciesGown(8)=(Step=3,Index=19,pics=1)
     GlaciesGown(9)=(Step=2,Index=24,pics=3)
     GlaciesGown(10)=(Step=3,Index=20,pics=2)
     GlaciesGown(11)=(Step=2,Index=10,pics=160)
     GlaciesGown(12)=(Step=2,Index=17,pics=1)
     GlaciesGown(13)=(Step=2,Index=25,pics=1)
     GlaciesGown(14)=(Step=3,pics=3)
     GlaciesGown(15)=(Step=3,Index=21,pics=3)
     GlaciesGown(16)=(Step=3,Index=1,pics=1)
     GlaciesCap(0)=(Step=4,Index=23,pics=99)
     GlaciesCap(1)=(Step=3,Index=18,pics=2)
     GlaciesCap(2)=(Step=2,Index=13,pics=5)
     GlaciesCap(3)=(Step=2,Index=23,pics=1)
     GlaciesCap(4)=(Step=3,Index=9,pics=2000)
     GlaciesCap(5)=(Step=3,Index=10,pics=1)
     GlaciesCap(6)=(Step=2,Index=15,pics=50)
     GlaciesCap(7)=(Step=2,Index=10,pics=50)
     GlaciesCap(8)=(Step=3,Index=19,pics=1)
     GlaciesCap(9)=(Step=2,Index=24,pics=3)
     GlaciesCap(10)=(Step=3,Index=20,pics=2)
     GlaciesCap(11)=(Step=2,Index=10,pics=160)
     GlaciesCap(12)=(Step=2,Index=17,pics=1)
     GlaciesCap(13)=(Step=2,Index=25,pics=1)
     GlaciesCap(14)=(Step=3,pics=2)
     GlaciesCap(15)=(Step=3,Index=21,pics=2)
     GlaciesCap(16)=(Step=3,Index=1,pics=1)
     GlaciesSandal(0)=(Step=4,Index=26,pics=99)
     GlaciesSandal(1)=(Step=3,Index=18,pics=2)
     GlaciesSandal(2)=(Step=2,Index=13,pics=5)
     GlaciesSandal(3)=(Step=2,Index=23,pics=1)
     GlaciesSandal(4)=(Step=3,Index=9,pics=2000)
     GlaciesSandal(5)=(Step=3,Index=10,pics=1)
     GlaciesSandal(6)=(Step=2,Index=15,pics=50)
     GlaciesSandal(7)=(Step=2,Index=10,pics=50)
     GlaciesSandal(8)=(Step=3,Index=19,pics=1)
     GlaciesSandal(9)=(Step=2,Index=24,pics=3)
     GlaciesSandal(10)=(Step=3,Index=20,pics=2)
     GlaciesSandal(11)=(Step=2,Index=10,pics=160)
     GlaciesSandal(12)=(Step=2,Index=17,pics=1)
     GlaciesSandal(13)=(Step=2,Index=25,pics=1)
     GlaciesSandal(14)=(Step=3,pics=2)
     GlaciesSandal(15)=(Step=3,Index=21,pics=2)
     GlaciesSandal(16)=(Step=3,Index=1,pics=1)
     GlaciesSleevelet(0)=(Step=4,Index=25,pics=99)
     GlaciesSleevelet(1)=(Step=3,Index=18,pics=1)
     GlaciesSleevelet(2)=(Step=2,Index=13,pics=5)
     GlaciesSleevelet(3)=(Step=2,Index=23,pics=1)
     GlaciesSleevelet(4)=(Step=3,Index=9,pics=2000)
     GlaciesSleevelet(5)=(Step=3,Index=10,pics=1)
     GlaciesSleevelet(6)=(Step=2,Index=15,pics=50)
     GlaciesSleevelet(7)=(Step=2,Index=10,pics=50)
     GlaciesSleevelet(8)=(Step=3,Index=19,pics=1)
     GlaciesSleevelet(9)=(Step=2,Index=24,pics=3)
     GlaciesSleevelet(10)=(Step=3,Index=20,pics=1)
     GlaciesSleevelet(11)=(Step=2,Index=10,pics=160)
     GlaciesSleevelet(12)=(Step=2,Index=17,pics=1)
     GlaciesSleevelet(13)=(Step=2,Index=25,pics=1)
     GlaciesSleevelet(14)=(Step=3,pics=1)
     GlaciesSleevelet(15)=(Step=3,Index=21,pics=1)
     GlaciesSleevelet(16)=(Step=3,Index=1,pics=1)
     DisableList(1)="1000000111111"
     DisableList(2)="10000001100111"
     DisableList(3)="10111011010111111"
     DisableList(4)="1001011011111111"
     DisableList(5)="101110110101111111"
     InableList(0)=200
     InableList(1)=201
     InableList(2)=202
     InableList(3)=203
     InableList(4)=204
     InableList(5)=205
     InableList(6)=206
     InableList(7)=207
     InableList(8)=208
     InableList(9)=209
     InableList(10)=210
     InableList(11)=211
     InableList(12)=212
     InableList(13)=213
     InableList(14)=214
     InableList(15)=215
     InableList(16)=216
     InableList(17)=217
     InableList(18)=218
     InableList(19)=219
     InableList(20)=220
     InableList(21)=221
     InableList(22)=222
     InableList(23)=223
     InableList(24)=224
     InableList(25)=225
     InableList(26)=300
     InableList(27)=301
     InableList(28)=302
     InableList(29)=303
     InableList(30)=304
     InableList(31)=305
     InableList(32)=306
     InableList(33)=307
     InableList(34)=308
     InableList(35)=309
     InableList(36)=310
     InableList(37)=311
     InableList(38)=312
     InableList(39)=314
     InableList(40)=315
     InableList(41)=316
     InableList(42)=318
     InableList(43)=319
     InableList(44)=320
     InableList(45)=313
     InableList(46)=317
     InableList(47)=321
     InableList(48)=400
     InableList(49)=401
     InableList(50)=402
     InableList(51)=403
     InableList(52)=404
     InableList(53)=405
     InableList(54)=406
     InableList(55)=407
     InableList(56)=408
     InableList(57)=409
     InableList(58)=410
     InableList(59)=411
     InableList(60)=412
     InableList(61)=413
     InableList(62)=414
     InableList(63)=415
     InableList(64)=416
     InableList(65)=417
     InableList(66)=418
     InableList(67)=419
     InableList(68)=420
     InableList(69)=421
     InableList(70)=422
     InableList(71)=423
     InableList(72)=424
     InableList(73)=425
     InableList(74)=426
     MakeList(200)=(A=100,an=4)
     MakeList(201)=(A=101,an=3)
     MakeList(202)=(A=102,an=4)
     MakeList(203)=(A=103,an=4)
     MakeList(207)=(A=104,an=4)
     MakeList(208)=(A=105,an=3)
     MakeList(211)=(A=106,an=2)
     MakeList(212)=(A=107,an=1,B=108,bn=10000)
     MakeList(219)=(A=109,an=1,B=110,bn=1)
     MakeList(302)=(A=200,an=2,B=201,bn=2,C=202,cn=2,D=203,dn=2)
     MakeList(303)=(A=204,an=700,B=205,bn=650,C=206,cn=1)
     MakeList(305)=(A=207,an=2,B=208,bn=2,C=202,cn=2,D=203,dn=2)
     MakeList(306)=(A=209,an=2,B=210,bn=400,C=211,cn=1,D=212,dn=1)
     MakeList(308)=(A=213,an=5,B=214,bn=1)
     MakeList(310)=(A=215,an=50,B=210,bn=50)
     MakeList(311)=(A=216,an=3)
     MakeList(312)=(A=210,an=160,B=217,bn=1,C=218,cn=1)
     MakeList(314)=(A=219,an=2,B=220,bn=500)
     MakeList(315)=(A=221,an=1,B=213,bn=5,C=222,cn=500)
     MakeList(318)=(A=213,an=5,B=223,bn=1)
     MakeList(319)=(A=224,an=3)
     MakeList(320)=(A=210,an=160,B=217,bn=1,C=225,cn=1)
     ItemSDNameList(100)="Lv12Refine_IgneousRock_RS"
     ItemSDNameList(101)="Lv12Refine_Titanium_RS"
     ItemSDNameList(102)="Lv12Refine_Nickel_RS"
     ItemSDNameList(103)="Lv12Refine_Copper_RS"
     ItemSDNameList(104)="Lv12Refine_SpiderStone"
     ItemSDNameList(105)="Lv12Refine_IronOre"
     ItemSDNameList(106)="Lv12Refine_Cashew"
     ItemSDNameList(107)="SpecialDiluted"
     ItemSDNameList(108)="Herb"
     ItemSDNameList(109)="Lv12Refine_DragonScale_Red"
     ItemSDNameList(110)="Lv12Refine_DragonScale_Blue"
     ItemSDNameList(200)="Lv12Refine_Zirconium"
     ItemSDNameList(201)="Lv12Refine_Titanium"
     ItemSDNameList(202)="Lv12Refine_Nickel"
     ItemSDNameList(203)="Lv12Refine_Copper"
     ItemSDNameList(204)="Steel"
     ItemSDNameList(205)="AlloyPowder"
     ItemSDNameList(206)="Lv12Refine_Hasp"
     ItemSDNameList(207)="Lv12Refine_BlueSpiderStone"
     ItemSDNameList(208)="Lv12Refine_IronOre_I"
     ItemSDNameList(209)="Lv12Refine_BlueHerb"
     ItemSDNameList(210)="PowerGem"
     ItemSDNameList(211)="Lv12Refine_CashewPaint"
     ItemSDNameList(212)="Lv12Refine_MixFormalin"
     ItemSDNameList(213)="Lv12Refine_SephirothCloth"
     ItemSDNameList(214)="Lv12Refine_Marrow_Fire"
     ItemSDNameList(215)="WareGemstone"
     ItemSDNameList(216)="Lv12Refine_Cocoon_Red"
     ItemSDNameList(217)="SpecialDiluted"
     ItemSDNameList(218)="Lv12Refine_Dye_Red"
     ItemSDNameList(219)="Lv12Refine_DragonScale_Tough"
     ItemSDNameList(220)="Patch"
     ItemSDNameList(221)="Lv12Refine_ElementalForce"
     ItemSDNameList(222)="Strap"
     ItemSDNameList(223)="Lv12Refine_Marrow_Ice"
     ItemSDNameList(224)="Lv12Refine_Cocoon_Green"
     ItemSDNameList(225)="Lv12Refine_Dye_Blue"
     ItemSDNameList(300)="MixGem"
     ItemSDNameList(301)="Lv12Refine_YellowScroll"
     ItemSDNameList(302)="Lv12Refine_LiquidMetal_I"
     ItemSDNameList(303)="Lv12Refine_SteelHasp"
     ItemSDNameList(304)="Advance_Item_Insignia"
     ItemSDNameList(305)="Lv12Refine_BlueSpiderStone_IO_I"
     ItemSDNameList(306)="Lv12Refine_ManaPaint_Blue"
     ItemSDNameList(307)="Advance_Item_Fist"
     ItemSDNameList(308)="Lv12Refine_FireCloth"
     ItemSDNameList(309)="Strap"
     ItemSDNameList(310)="Lv12Refine_Magic_Cream"
     ItemSDNameList(311)="Lv12Refine_Yarn_Red"
     ItemSDNameList(312)="Lv12Refine_ManaDye_Red"
     ItemSDNameList(313)="Advance_Item_RedJewel"
     ItemSDNameList(314)="Lv12Refine_DragonScale_Strong"
     ItemSDNameList(315)="Lv12Refine_ElementalStrap"
     ItemSDNameList(316)="Lv12Refine_FantasticAccessory"
     ItemSDNameList(317)="Advance_Item_Arrow"
     ItemSDNameList(318)="Lv12Refine_IceCloth"
     ItemSDNameList(319)="Lv12Refine_Yarn_Green"
     ItemSDNameList(320)="Lv12Refine_ManaDye_Blue"
     ItemSDNameList(321)="Advance_Item_BlueJewel"
     ItemSDNameList(400)="MurcielSword"
     ItemSDNameList(401)="MurcielHelmet"
     ItemSDNameList(402)="MurcielArmor"
     ItemSDNameList(403)="MurcielVambrace"
     ItemSDNameList(404)="MurcielBoots"
     ItemSDNameList(405)="MurcielShield"
     ItemSDNameList(406)="AcordGauntlet"
     ItemSDNameList(407)="AcordHelmet"
     ItemSDNameList(408)="AcordArmor"
     ItemSDNameList(409)="AcordVambrace"
     ItemSDNameList(410)="AcordBoots"
     ItemSDNameList(411)="AcordProtector"
     ItemSDNameList(412)="AblazeStaff"
     ItemSDNameList(413)="AblazeHelmet"
     ItemSDNameList(414)="AblazeGarment"
     ItemSDNameList(415)="AblazeVambrace"
     ItemSDNameList(416)="AblazeBoots"
     ItemSDNameList(417)="ApliteBow"
     ItemSDNameList(418)="ApliteCap"
     ItemSDNameList(419)="ApliteGarb"
     ItemSDNameList(420)="ApliteSleevelet"
     ItemSDNameList(421)="ApliteSandal"
     ItemSDNameList(422)="GlaciesStick"
     ItemSDNameList(423)="GlaciesCap"
     ItemSDNameList(424)="GlaciesGown"
     ItemSDNameList(425)="GlaciesSleevelet"
     ItemSDNameList(426)="GlaciesSandal"
}

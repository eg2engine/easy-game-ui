class CSkillInfoBox extends CInfoBox;

var color NormalColor, AbilityColor, SufficientColor, DeficientColor, DescColor;
var string ColorCode, AbilityColorCode;

var localized string S_SkillLevel, S_SkillPoint;
var localized string S_ManaConsumption;
var localized string S_Str, S_Dex, S_Vigor, S_MagicPower, S_White, S_Red, S_Blue, S_Yellow, S_Black;
var localized string S_Requirement, S_SkillRequirement;
var localized string S_OR;

function OnSourceChange(Object Obj)
{
	local Skill Skill, PreSkill;
	local string DemandStr, StatStr, SkillStr;
	local int i, PreSkillCount, PreSkillIndex;
	local array<string> DescStrings;

	Skill = Skill(Obj);
	if (Skill == None)
		return;

	if (!Skill.bLearned || !Skill.bEnabled)
		ColorCode = MakeColorCode(DeficientColor);
	else
		ColorCode = MakeColorCode(SufficientColor);
	AbilityColorCode = MakeColorCode(AbilityColor);

	Clear();
	Add(MakeColorCode(NormalColor) $ Skill.FullName);
	Add(AbilityColorCode $ S_SkillLevel $ ":" $ Skill.SkillLevel);
	/*
	if (Skill.bHasSkillPoint)
		Add(AbilityColorCode $ S_SkillPoint $ ":" $ Skill.SkillPoint);
	*/
	if (Skill.ManaConsumption > 0)
		Add(ColorCode $ S_ManaConsumption $ ":" $ Skill.ManaConsumption);

	for (i=0;i<Skill.RequirementMap.Length;i++) {
		switch (Skill.RequirementMap[i].Type) {
		case 0: break;
		case 1: StatStr = S_Str $ " " $ Skill.RequirementMap[i].Value; break;
		case 2: StatStr = S_Dex $ " " $ Skill.RequirementMap[i].Value; break;
		case 3: StatStr = S_Vigor $ " " $ Skill.RequirementMap[i].Value; break;
		case 4: StatStr = S_MagicPower $ " " $ Skill.RequirementMap[i].Value; break;
		case 5: StatStr = S_White $ " " $ Skill.RequirementMap[i].Value; break;
		case 6: StatStr = S_Red $ " " $ Skill.RequirementMap[i].Value; break;
		case 7: StatStr = S_Blue $ " " $ Skill.RequirementMap[i].Value; break;
		case 8: StatStr = S_Yellow $ " " $ Skill.RequirementMap[i].Value; break;
		case 9: StatStr = S_Black $ " " $ Skill.RequirementMap[i].Value; break;
		case 10: 
			PreSkillCount++; 
			if (PreSkillIndex == 0) 
				PreSkillIndex = i; 
			break;
		}
		if (StatStr != "") {
			if (DemandStr == "")
				DemandStr = StatStr;
			else
				DemandStr = DemandStr $ " " $ StatStr;
		}
		StatStr = "";
	}
	if (DemandStr != "")
		Add(ColorCode $ S_Requirement $ ":" $ DemandStr);

	if (PreSkillCount > 0) {
		PreSkill = SephirothPlayer(PlayerOwner).QuerySkillByName(Skill.RequirementMap[PreSkillIndex].SkillName);
		SkillStr = PreSkill.FullName $ " " $ Skill.RequirementMap[PreSkillIndex].Value;
		Add(ColorCode $ S_SkillRequirement $ ":" $ SkillStr);
		for (i = PreSkillIndex+1;i<PreSkillIndex+PreSkillCount;i++) {
			PreSkill = SephirothPlayer(PlayerOwner).QuerySkillByName(Skill.RequirementMap[i].SkillName);
			SkillStr = ":" $ S_OR $ " " $ PreSkill.FullName $ " " $ Skill.RequirementMap[i].Value;
			Add(ColorCode $ SkillStr);
		}
	}

	// +jhjung, 2003-4-22
	if (Skill.Description != "") {
	class'CNativeInterface'.static.WrapStringToArray(Skill.Description, DescStrings, 10000, "|");
		Add(" ");
		for (i=0;i<DescStrings.Length;i++)
			Add(MakeColorCode(DescColor) $ DescStrings[i]);
		if (Skill.bHasSkillPoint)
			Add(" ");
	}
	// end of jhjung

	if (Skill.bHasSkillPoint)
		Add(" ");
}

function InternalDrawBackground(Canvas C)
{
	local Skill Skill;

	Super.InternalDrawBackground(C);
	Skill = Skill(Source);
	if (Skill == None)
		return;
	if (Skill.bHasSkillPoint) {
		C.SetPos(WinX+MarginWidth, WinY+WinHeight-MarginHeight-ItemHeight);
		C.SetDrawColor(30,30,36);
		C.DrawTileStretched(material'Engine.WhiteSquareTexture', WinWidth-2*MarginWidth, ItemHeight);
		C.SetPos(WinX+MarginWidth, WinY+WinHeight-MarginHeight-ItemHeight);
		C.SetDrawColor(255,255,163);
		C.DrawTileStretched(material'Engine.WhiteSquareTexture', (WinWidth-2*MarginWidth) * Skill.SkillPoint / 100.0, ItemHeight);
		C.DrawTextJustified(MakeColorCodeEx(101,115,146)$"SP "$Skill.SkillPoint$"%", 1, WinX+MarginWidth, WinY+WinHeight-MarginHeight-ItemHeight, WinX+WinWidth-2*MarginWidth, WinY+WinHeight-MarginHeight);
	}
}

defaultproperties
{
     NormalColor=(B=163,G=255,R=255,A=255)
     AbilityColor=(B=126,G=176,R=223,A=255)
     SufficientColor=(B=225,G=189,R=137,A=255)
     DeficientColor=(B=170,G=139,R=249,A=255)
     DescColor=(B=207,G=207,R=207,A=255)
     S_SkillLevel="SkillLevel"
     S_SkillPoint="SkillPoint"
     S_ManaConsumption="ManaConsume"
     S_Str="STR"
     S_Dex="DEX"
     S_Vigor="VIGOR"
     S_MagicPower="MagicPower"
     S_White="WHITE"
     S_Red="RED"
     S_Blue="BLUE"
     S_Yellow="YELLOW"
     S_Black="BLACK"
     S_Requirement="StatReq"
     S_SkillRequirement="SkillReq"
     S_OR="or"
}

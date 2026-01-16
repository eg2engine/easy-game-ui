class SecondSkillInfoBox extends CInfoBox;

var color NormalColor, AbilityColor, SufficientColor, DeficientColor, DescColor;
var string ColorCode;
var localized string S_Name, S_Level, S_Type, S_LevelUp;
var localized string S_ManaConsumption;
var localized string S_Active, S_Passive, S_Enable, S_Disable, S_Master;

function OnSourceChange(Object Obj)
{
	local SecondSkill Skill;
	local string Temp;

	Skill = SecondSkill(Obj);
	if(Skill == None)
		return;

	if (!Skill.bLearned)
		ColorCode = MakeColorCode(DeficientColor);
	else
		ColorCode = MakeColorCode(SufficientColor);

	Clear();
	Add(MakeColorCode(NormalColor) $ Skill.FullName);
	if( Skill.SkillLevel != 0 )
		Add(MakeColorCode(AbilityColor) $ S_Level $ ":" $ Skill.SkillLevel);
	
	if(Skill.SkillType == 0)
		Temp = S_Passive;
	else
		Temp = S_Active;	
	Add(MakeColorCode(AbilityColor) $ S_Type $ ":" $ Temp);
//	PSI = SephirothPlayer(PlayerOwner).PSI;
	if(Skill.ManaConsumption > 0)
		Add(ColorCode $ S_ManaConsumption $ ":" $ Skill.ManaConsumption);
	
/*	if(Skill.SkillLevel < 5)
	{		
		if(PSI.SkillCredit > Skill.SkillLevel+3)
			Temp = S_Enable;
		else
			Temp = S_Disable;
		Add(MakeColorCode(NormalColor) $ S_LevelUp$":" $ Temp $ " (" $ (Skill.SkillLevel+3) $ ") ");
	}
	else if (Skill.SkillLevel == 5)
		Add(MakeColorCode(NormalColor) $ S_LevelUp $ ":" $ S_Disable $ " (" $ S_Master $ ") ");
*/	
	Add(MakeColorCode(NormalColor) $ "");
	Add(MakeColorCode(NormalColor) $ Skill.Description);
}

function SetBoxPosition(float X, float Y)
{
	WinX = X-WinWidth;
	WinY = Y;
}

function InternalDrawBackground(Canvas C)
{
	Super.InternalDrawBackground(C);
}

defaultproperties
{
     NormalColor=(B=163,G=255,R=255,A=255)
     AbilityColor=(B=126,G=176,R=223,A=255)
     SufficientColor=(B=225,G=189,R=137,A=255)
     DeficientColor=(B=170,G=139,R=249,A=255)
     DescColor=(B=207,G=207,R=207,A=255)
     S_Name="Name"
     S_Level="Level"
     S_Type="Type"
     S_LevelUp="LevelUp"
     S_ManaConsumption="ManaConsume"
     S_Active="Active"
     S_Passive="Passive"
     S_Enable="Enable"
     S_Disable="Disable"
     S_Master="Master"
     MarginHeight=4.000000
}

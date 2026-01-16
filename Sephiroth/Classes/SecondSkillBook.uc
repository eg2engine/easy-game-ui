class SecondSkillBook extends Object
	native;

var string BookName;
var array<SecondSkill> Skills;

function Skill QuerySkillByName(string Name)
{
	local int i;
	for(i = 0 ; i < Skills.Length ; i++)
	{
		if(Skills[i].SkillName == Name)
			return Skills[i];
	}
	return None;
}

defaultproperties
{
}

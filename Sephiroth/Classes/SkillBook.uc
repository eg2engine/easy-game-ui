class SkillBook extends Object
	native;

var string BookName;
var bool bIsLearned;
var array<Skill> Skills;
var int TreeV;

//@by wj(05/23)------
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
//-------------------

function Skill QuerySkillByIndex(byte X, byte Y)
{
	local byte i;
	for (i=0;i<Skills.Length;i++)
		if (Skills[i].TreeLoc.X==X && Skills[i].TreeLoc.Y==Y)
			return Skills[i];
	return None;
}

function Skill QuerySkillByName(string Name)
{
	local byte i;
	for (i=0;i<Skills.Length;i++)
		if (Skills[i].SkillName == Name)
			return Skills[i];
	return None;
}

function Skill LearnSkill(string Name)
{
	local Skill Skill;
	Skill = QuerySkillByName(Name);
	if (Skill != None) {
//		//Log("Learning skill "$Name);
		Skill.bLearned = True;
		Skill.BookName = BookName;
	}
	return Skill;
}

function Skill ForgetSkill(string Name)
{
	local Skill Skill;
	Skill = QuerySkillByName(Name);
	if (Skill != None)
		Skill.bEnabled = False;
	return Skill;
}

function bool IsSkillLearned(string Name)
{
	local Skill Skill;
	Skill = QuerySkillByName(Name);
	return (Skill != None && Skill.bLearned == True);
}

function bool IsSkillEnabled(string Name)
{
	local Skill Skill;
	Skill = QuerySkillByName(Name);
	return (Skill != None && Skill.bEnabled == True);
}

function int GetBreadth()
{
	local int Breadth,i;
	for (i=0;i<Skills.Length;i++)
		Breadth = max(Breadth,int(Skills[i].TreeLoc.X));
	return Breadth;
}

function int GetDepth()
{
	local int Depth,i;
	for (i=0;i<Skills.Length;i++)
		Depth = max(Depth,int(Skills[i].TreeLoc.Y));
	return Depth+1;
}

function Skill QuerySkillByAnimSequence(string SequenceName)
{
	local int i;
	for (i=0;i<Skills.Length;i++)
		if (string(Skills[i].AnimSequence) == SequenceName)
			return Skills[i];
	return None;
}

defaultproperties
{
}

class PetServerInfo extends ModelServerInfo
	native;

var string MeshName;
var string AnimName;
var string PetName;
var INT PetLevel;
var INT PetColor;
var INT PetPosition;
var bool bChange;
var INT FoodGuage;
var INT FaceStatus;
var INT LearnedTextNums;
var INT LearnTextNumsMax;
var INT PetPoint;
var INT PointHP;
var INT PointMP;
var INT PointAttack;
var INT PointInven;

var string Comment;

var array<string> OwnerWord;
var array<string> PetComment;

function string GetTitle()
{
	/*
	switch(FaceStatus)
	{
	case 0: return "妇惑茄";
	case 1: return "快匡茄";
	case 2: return "疙尔茄";
	case 3: return "模剐茄";
	}
	*/
	switch(FaceStatus)
	{
	case 0: return "伤心的";
	case 1: return "忧郁的";
	case 2: return "开心的";
	case 3: return "亲密的";
	}

	return "";
}


// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)

defaultproperties
{
}

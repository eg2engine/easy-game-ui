class RaceType extends Actor;

var string RaceName;
var int MaleHairCount;
var int FemaleHairCount;

var array<string> Jobs;
var array<string> Castles;

struct StatType {
	var int Str;
	var int Dex;
	var int Vigor;
	var int White;
	var int Red;
	var int Blue;
	var int Yellow;
	var int Black;
};
var array<StatType> Stats;
var array<string> Genders;
var array<color> HairColors;

var int DefaultJob;
var int DefaultGender;
var int DefaultSkillBook;

defaultproperties
{
}

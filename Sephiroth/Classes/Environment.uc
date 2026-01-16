class Environment extends Actor
	native
	editinlinenew
	config(Environment)
	hidecategories(Advanced,Collision,Display,Events,Force,Karma,LightColor,Lighting,Movement,Object,None,Sound);

var(SkyColorModifier) ColorModifier Sky_Cloud; // cloud color modifier reference
var(SkyColorModifier) ColorModifier Sky_Atmosphere; // atmosphere color modifier reference
var(SkyColorModifier) ColorModifier Sky_Ring; // sky static mesh ring color modifier reference

var(GameTime) int GameTime;
var(GameTime) int Year;
var(GameTime) int Month;
var(GameTime) int Day;
var(GameTime) int Hour;

struct native EnvironmentBlendingParam {
	var float FogStart, FogEnd;
	var color FogColor;
	var color CloudColor, AtmosphereColor, RingColor;
	var bool bNoUse;
	var bool bNoSky;
	var bool bNight;
	var color AmbientColor;
	var color SunColor;
	var byte BrightnessFactor;
	var float MeshVisualDistance;
	var float StaticMeshVisualDistance;
};

//var(BlendingTable) globalconfig EnvironmentBlendingParam BlendingTable[24];
var(BlendingTable) config EnvironmentBlendingParam BlendingTable[24];

var EnvironmentBlendingParam BlendingLast,BlendingSrc,BlendingDest;
var int BlendingFlag;
var bool bBlendEnvironment;
var float BlendingTicks;
var float BlendingDuration;

var bool bSpecialBlending;
var EnvironmentBlendingParam SpecialBlend;

native final function BlendEnvironment();

// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)

function BlendSpecial(bool bSet)
{
	bSpecialBlending = bSet;
	BlendingDuration = 2.0f;
	BlendEnvironment();
}

function SetupSpecialBlending_Fog(float Start, float End)
{
	SpecialBlend = BlendingTable[Hour];
	SpecialBlend.FogStart = Start;
	SpecialBlend.FogEnd = End;
}

function SetupSpecialBlending_MeshVisualDistance(float Dist)
{
	SpecialBlend = BlendingTable[Hour];
	SpecialBlend.MeshVisualDistance = Dist;
}

function SaveToINI()
{
	SaveConfig();
}

defaultproperties
{
     BlendingTable(0)=(FogStart=10000.000000,FogEnd=22000.000000,FogColor=(B=18,R=19),CloudColor=(B=26,G=44,R=65),AtmosphereColor=(B=15,G=4,R=10),RingColor=(B=31,G=15,R=12),bNight=True,AmbientColor=(B=255,R=50),SunColor=(B=103,G=175,R=94),BrightnessFactor=100)
     BlendingTable(1)=(FogStart=10000.000000,FogEnd=22000.000000,FogColor=(B=18,R=19),CloudColor=(B=26,G=44,R=65),AtmosphereColor=(B=15,G=4,R=10),RingColor=(B=31,G=15,R=12),bNight=True,AmbientColor=(B=255,R=50),SunColor=(B=103,G=175,R=94),BrightnessFactor=80)
     BlendingTable(2)=(FogStart=11000.000000,FogEnd=22000.000000,FogColor=(B=36,G=35,R=54),CloudColor=(B=47,G=60,R=72),AtmosphereColor=(B=26,G=13,R=15),RingColor=(B=47,G=47,R=55),bNight=True,AmbientColor=(B=255,R=50),SunColor=(B=103,G=175,R=94),BrightnessFactor=60)
     BlendingTable(3)=(FogStart=12000.000000,FogEnd=22000.000000,FogColor=(B=63,G=86,R=105),CloudColor=(B=76,G=84,R=83),AtmosphereColor=(B=42,G=25,R=22),RingColor=(B=72,G=93,R=119),AmbientColor=(B=255,R=60),SunColor=(B=107,G=153,R=203),BrightnessFactor=40)
     BlendingTable(4)=(FogStart=15000.000000,FogEnd=22000.000000,FogColor=(B=108,G=172,R=191),CloudColor=(B=126,G=123,R=102),AtmosphereColor=(B=69,G=47,R=34),RingColor=(B=113,G=171,R=225),AmbientColor=(B=255,R=70),SunColor=(B=134,G=171,R=213),BrightnessFactor=20)
     BlendingTable(5)=(FogStart=16000.000000,FogEnd=22000.000000,FogColor=(B=122,G=168,R=185),CloudColor=(B=124,G=122,R=111),AtmosphereColor=(B=77,G=52,R=33),RingColor=(B=120,G=158,R=199),AmbientColor=(B=255,R=80),SunColor=(B=141,G=182,R=226))
     BlendingTable(6)=(FogStart=17000.000000,FogEnd=22000.000000,FogColor=(B=165,G=158,R=167),CloudColor=(B=122,G=122,R=124),AtmosphereColor=(B=89,G=60,R=33),RingColor=(B=130,G=140,R=161),AmbientColor=(B=255,R=90),SunColor=(B=150,G=183,R=218))
     BlendingTable(7)=(FogStart=18000.000000,FogEnd=22000.000000,FogColor=(B=182,G=154,R=159),CloudColor=(B=117,G=120,R=145),AtmosphereColor=(B=108,G=73,R=32),RingColor=(B=146,G=108,R=96),AmbientColor=(B=255,R=100),SunColor=(B=227,G=21,R=114))
     BlendingTable(8)=(FogStart=18500.000000,FogEnd=22000.000000,FogColor=(B=182,G=154,R=148),CloudColor=(B=145,G=139,R=151),AtmosphereColor=(B=107,G=70,R=28),RingColor=(B=145,G=108,R=83),AmbientColor=(B=255,R=130),SunColor=(B=234,G=37,R=124))
     BlendingTable(9)=(FogStart=19000.000000,FogEnd=22000.000000,FogColor=(B=180,G=156,R=133),CloudColor=(B=186,G=167,R=161),AtmosphereColor=(B=106,G=67,R=21),RingColor=(B=144,G=107,R=65),AmbientColor=(B=255,R=150),SunColor=(B=234,G=37,R=124))
     BlendingTable(10)=(FogStart=20000.000000,FogEnd=22000.000000,FogColor=(B=179,G=156,R=116),CloudColor=(B=226,G=195,R=170),AtmosphereColor=(B=105,G=62,R=15),RingColor=(B=142,G=107,R=45),AmbientColor=(B=255,R=200),SunColor=(B=255,R=100))
     BlendingTable(11)=(FogStart=20000.000000,FogEnd=22000.000000,FogColor=(B=179,G=156,R=116),CloudColor=(B=226,G=195,R=170),AtmosphereColor=(B=105,G=62,R=15),RingColor=(B=142,G=107,R=45),AmbientColor=(B=255,R=200),SunColor=(B=255,R=100))
     BlendingTable(12)=(FogStart=20000.000000,FogEnd=22000.000000,FogColor=(B=179,G=156,R=116),CloudColor=(B=226,G=195,R=170),AtmosphereColor=(B=105,G=62,R=15),RingColor=(B=142,G=107,R=45),AmbientColor=(B=255,R=200),SunColor=(B=255,R=100))
     BlendingTable(13)=(FogStart=20000.000000,FogEnd=22000.000000,FogColor=(B=179,G=156,R=116),CloudColor=(B=226,G=195,R=170),AtmosphereColor=(B=105,G=62,R=15),RingColor=(B=142,G=107,R=45),AmbientColor=(B=255,R=200),SunColor=(B=255,R=100))
     BlendingTable(14)=(FogStart=19000.000000,FogEnd=22000.000000,FogColor=(B=179,G=157,R=106),CloudColor=(B=254,G=214,R=177),AtmosphereColor=(B=104,G=60,R=11),RingColor=(B=143,G=107,R=33),AmbientColor=(B=255,R=200),SunColor=(B=255,R=100))
     BlendingTable(15)=(FogStart=18000.000000,FogEnd=22000.000000,FogColor=(B=169,G=147,R=104),CloudColor=(B=247,G=209,R=176),AtmosphereColor=(B=102,G=58,R=12),RingColor=(B=135,G=106,R=47),AmbientColor=(B=255,R=200),SunColor=(B=255,R=100))
     BlendingTable(16)=(FogStart=17000.000000,FogEnd=22000.000000,FogColor=(B=154,G=135,R=101),CloudColor=(B=230,G=198,R=173),AtmosphereColor=(B=95,G=53,R=14),RingColor=(B=122,G=105,R=69),AmbientColor=(B=255,R=200),SunColor=(B=255,R=100))
     BlendingTable(17)=(FogStart=16000.000000,FogEnd=22000.000000,FogColor=(B=137,G=120,R=98),CloudColor=(B=195,G=175,R=167),AtmosphereColor=(B=82,G=45,R=18),RingColor=(B=107,G=103,R=93),AmbientColor=(B=255,R=180),SunColor=(B=221,G=35,R=138))
     BlendingTable(18)=(FogStart=15000.000000,FogEnd=22000.000000,FogColor=(B=118,G=103,R=94),CloudColor=(B=155,G=148,R=160),AtmosphereColor=(B=67,G=34,R=23),RingColor=(B=91,G=102,R=120),AmbientColor=(B=255,R=160),SunColor=(B=202,G=32,R=157))
     BlendingTable(19)=(FogStart=13000.000000,FogEnd=22000.000000,FogColor=(B=99,G=87,R=91),CloudColor=(B=115,G=122,R=154),AtmosphereColor=(B=52,G=23,R=28),RingColor=(B=75,G=100,R=147),AmbientColor=(B=255,R=100),SunColor=(B=182,G=29,R=179),BrightnessFactor=20)
     BlendingTable(20)=(FogStart=12500.000000,FogEnd=22000.000000,FogColor=(B=82,G=71,R=87),CloudColor=(B=80,G=99,R=148),AtmosphereColor=(B=38,G=14,R=32),RingColor=(B=60,G=98,R=172),AmbientColor=(B=255,R=90),SunColor=(B=150,G=24,R=213),BrightnessFactor=40)
     BlendingTable(21)=(FogStart=12000.000000,FogEnd=22000.000000,FogColor=(B=57,G=49,R=83),CloudColor=(B=56,G=83,R=144),AtmosphereColor=(B=29,G=8,R=35),RingColor=(B=39,G=96,R=207),AmbientColor=(B=255,R=80),SunColor=(B=121,G=19,R=170),BrightnessFactor=60)
     BlendingTable(22)=(FogStart=11500.000000,FogEnd=22000.000000,FogColor=(B=49,G=39,R=70),CloudColor=(B=50,G=75,R=128),AtmosphereColor=(B=27,G=7,R=30),RingColor=(B=34,G=47,R=90),bNight=True,AmbientColor=(B=255,R=60),SunColor=(B=103,G=175,R=94),BrightnessFactor=80)
     BlendingTable(23)=(FogStart=11000.000000,FogEnd=22000.000000,FogColor=(B=38,G=24,R=51),CloudColor=(B=41,G=64,R=105),AtmosphereColor=(B=22,G=6,R=23),RingColor=(B=44,G=22,R=17),bNight=True,AmbientColor=(B=255,R=50),SunColor=(B=103,G=175,R=94),BrightnessFactor=100)
}

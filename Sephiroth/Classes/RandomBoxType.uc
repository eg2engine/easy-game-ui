class RandomBoxType extends Object
	abstract
	config(RandomBoxType);

struct init RandomBoxRecord
{
	var String					ItemTypeName;		// Item type
	var String					RndBoxTitle;			// BG Texture Name
	var String					BGImageName;			// BG Texture Name
	var String					ItemListTextName;			// BG Texture Name
	var String					MeshName;			// MeshTypeName
	var String					ItemListIconName;			// BG Texture Name
	var String					GaugeImageName;			// BG Texture Name
	var color					GaugeColor[5];			// BG Texture Name
	var String					EffectName[5];			// BG Texture Name
	var String					SoundName[5];			// BG Texture Name
	var float					TotalTime;			// BG Texture Name
	var float					RndTime[5];			// BG Texture Name
	var float					AnimMeshSpeed[5];			// BG Texture Name
	var float					AnimIconSpeed[5];			// BG Texture Name
};

struct init RandomBoxRecordRes
{
	var String					Name;				// Item type
	var String					ResTypeName;		// BG Texture Name
	var String					ResPackageName;		// MeshTypeName
	var String					ResPathName;		// MeshTypeName
	var String					EventName;			// GaugeTypeName
	var Vector					ResOffsetLoc;
	var rotator					ResOffsetRot;
	var float					ResSize;
	var float					ResResultSize;
	var float					XL,YL,U,V,UL,VL;
	var Actor.ERenderStyle		RenderStyle;
	var array<String>			ArrayItemList;			// BG Texture Name
	var name					RndMeshAnimName[5];			// BG Texture Name
	var String					SkinName;				// skinName
	var int						nComponentIndex;
};

struct init UIRecord			// UI할때 일케 처리 하자.. 지금은 이게 아닌듯 싶다..훔훔훔..
{
	var String					ItemTypeName;		// Item type
	var String					FrameName;			// FrameName
	var String					BGName;				// BG Texture Name
	var String					ItemListName;		// ItemListTextName
	var String					MeshName;			// MeshTypeName
	var String					EffectName;			// EffectTypeName
	var String					GaugeName;			// GaugeTypeName
	var String					SoundName;			// GaugeTypeName
};

struct init UIRecordFrame
{
	var String					Name;				// TypeIndex
    var String					ResName;			// Mesh type
	var String					BGName;				// Mesh type
	var Vector					ResOffsetLoc;
	var Vector					ResOffsetRot;
	var float					ResSize;
};

struct init UIRecordBG
{
	var String					Name;				// Mesh type
	var String					TypeName;           // TypeIndex
    var String					ResName;            // Mesh type
	var Vector					ResOffsetLoc;
	var Vector					ResOffsetRot;
	var float					ResSize;
};

struct init UIRecordItemList
{
	var String					Name;				// Mesh type
	var String					TypeName;           // TypeIndex
    var String					ResName;            // Mesh type
	var Vector					ResOffsetLoc;
	var Vector					ResOffsetRot;
	var float					ResSize;
};

struct init UIRecordGauge
{
	var String					Name;				// Mesh type
	var String					TypeName;           // TypeIndex
    var String					ResName;            // Mesh type
	var Vector					ResOffsetLoc;
	var Vector					ResOffsetRot;
	var float					ResSize;
};

struct init UIRecordRes
{
	var String					Name;				// Mesh type
	var String					TypeName;           // TypeIndex
    var String					ResName;            // Mesh type
	var Vector					ResOffsetLoc;
	var Vector					ResOffsetRot;
	var float					ResSize;
};

var config array<RandomBoxRecord> RndRec;
var config array<RandomBoxRecordRes> RndResRec;


//static function RandomBoxRecord FindRndBoxRec( string ItemTypeName, out RandomBoxRecord RndBoxRec )
static function int FindRndBoxRec( string ItemTypeName, out RandomBoxRecord RndBoxRec )
{
	local int numRndRec;
	local int i;

	numRndRec = default.RndRec.Length;

	for(i=0;i<numRndRec;i++)
	{
		if(default.RndRec[i].ItemTypeName == ItemTypeName )
		{
			RndBoxRec = default.RndRec[i];
			return i;
		}
	}

	return -1;
}

static function int LoadRndBoxRec( string ResName, out RandomBoxRecordRes RndBoxRes )
{
	local int numRndRec;
	local int i;

	for(i=0;i<default.RndResRec.Length;i++)
	{
		if(default.RndResRec[i].Name == ResName )
		{
			RndBoxRes = default.RndResRec[i];
			return i;
		}
	}

	return -1;
}

static function int LoadResources( string ResName, out RandomBoxRecordRes RndBoxRes )
{
	local int numRndRec;
	local int i;

	if( RndBoxRes.Name == ResName )
		return -1;

	for(i=0;i<default.RndResRec.Length;i++)
	{
		if(default.RndResRec[i].Name == ResName )
		{
			RndBoxRes = default.RndResRec[i];
			return i;
		}
	}

	return -1;
}

defaultproperties
{
}

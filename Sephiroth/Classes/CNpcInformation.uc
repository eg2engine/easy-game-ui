class CNpcInformation extends StaticMeshActor
	config(SephirothUI);

var StaticMesh		InfoMesh;				// Xelloss
var config		string	strSymbol[7];
var config		string	strTextures[18];


function SetMesh(int nIndex)
{
	local int n;
	local string strMesh;

	if ( nIndex == 0 )
	{
		SetStaticMesh(None);
		return;
	}

	if ( InfoMesh != None )
	{
		//DynamicUnloadObject(InfoMesh);
		InfoMesh = None;
	}

	strMesh = strSymbol[nIndex];
	InfoMesh = StaticMesh(DynamicLoadObject(strMesh, class'StaticMesh'));

	if ( InfoMesh != None )
	{
		SetStaticMesh(InfoMesh);

		for ( n = 0 ; n < 3 ; n++ )
			Skins[n] = Material(DynamicLoadObject(strTextures[(nIndex-1)*3+n], class'Material'));
	}
}


event Destroyed()
{
	if ( InfoMesh != None )
	{
		//DynamicUnloadObject(InfoMesh);
		InfoMesh = None;
	}

	Super.Destroyed();
}

defaultproperties
{
     strSymbol(1)="JEF_Environment_ST.Quest_EM_ST_FT"
     strSymbol(2)="JEF_Environment_ST.Quest_EM_ST_FT"
     strSymbol(3)="JEF_Environment_ST.Quest_EM_ST_FT"
     strSymbol(4)="JEF_Environment_ST.Quest_QM_ST_FT"
     strSymbol(5)="JEF_Environment_ST.Quest_QM_ST_FT"
     strSymbol(6)="JEF_Environment_ST.Quest_QM_ST_FT"
     strTextures(0)="JEF_Environment_T.Quest_GR01F"
     strTextures(1)="JEF_Environment_T.QuestQMEM_S01F"
     strTextures(2)="JEF_Environment_T.QuestQMEM_S02F"
     strTextures(3)="JEF_Environment_T.Quest_Y01F"
     strTextures(4)="JEF_Environment_T.QuestQMEM_S01F"
     strTextures(5)="JEF_Environment_T.QuestQMEM_S02F"
     strTextures(6)="JEF_Environment_T.Quest_B01F"
     strTextures(7)="JEF_Environment_T.QuestQMEM_S01F"
     strTextures(8)="JEF_Environment_T.QuestQMEM_S02F"
     strTextures(9)="JEF_Environment_T.Quest_GR01F"
     strTextures(10)="JEF_Environment_T.QuestQMEM_S01F"
     strTextures(11)="JEF_Environment_T.QuestQMEM_S03F"
     strTextures(12)="JEF_Environment_T.Quest_Y01F"
     strTextures(13)="JEF_Environment_T.QuestQMEM_S01F"
     strTextures(14)="JEF_Environment_T.QuestQMEM_S03F"
     strTextures(15)="JEF_Environment_T.Quest_B01F"
     strTextures(16)="JEF_Environment_T.QuestQMEM_S01F"
     strTextures(17)="JEF_Environment_T.QuestQMEM_S03F"
     bUnlit=True
}

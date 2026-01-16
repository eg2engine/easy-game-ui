class PageSound extends COptionPage;

const CB_ListenMusic = 1;
const CB_ListenSound = 2;

var bool bListenMusic;
var float fMusicVolume;
var bool bListenSound;
var float fSoundVolume;

var CSlide MusicSlide;
var CSlide SoundSlide;

function LoadOption()
{
	bListenMusic = bool(ConsoleCommand("GETOPTIONI ListenMusic"));
	fMusicVolume = float(ConsoleCommand("GETOPTIONF MusicVolume"));
	bListenSound = bool(ConsoleCommand("GETOPTIONI ListenSound"));
	fSoundVolume = float(ConsoleCommand("GETOPTIONF SoundVolume"));
	Super.LoadOption();
}

function SaveOption()
{
	ConsoleCommand("SETOPTIONB ListenMusic"@bListenMusic);
	ConsoleCommand("SETOPTIONF MusicVolume"@fMusicVolume);
	ConsoleCommand("SETOPTIONB ListenSound"@bListenSound);
	ConsoleCommand("SETOPTIONF SoundVolume"@fSoundVolume);
	Super.SaveOption();
}

function OnInit()
{
	SetComponentNotify(Components[2],CB_ListenMusic,Self);
	SetComponentNotify(Components[6],CB_ListenSound,Self);

	MusicSlide = CSlide(AddInterface("Interface.CSlide"));
	if(MusicSlide != None)
	{
		MusicSlide.ShowInterface();
		MusicSlide.SetSlide(-100,-100,115,20, 0.0f, fMusicVolume ,1.0f);
	}

	SoundSlide = CSlide(AddInterface("Interface.CSlide"));
	if(SoundSlide != None)
	{
		SoundSlide.ShowInterface();
		SoundSlide.SetSlide(-100,-100,115,20, 0.0f, fSoundVolume ,1.0f);
	}
}

function OnFlush()
{
	if(MusicSlide != None)
		RemoveInterface(MusicSlide);

	if(SoundSlide != None)
		RemoveInterface(SoundSlide);
}

function UpdateComponents()
{
	local float fTemp;

	if(MusicSlide != None)
	{
		MusicSlide.SetPos(Components[4].X,Components[4].Y);

		fTemp = MusicSlide.GetCalcedCurSlideValue();
		if(fMusicVolume != fTemp)
		{
			fMusicVolume = fTemp;
			Apply();
		}
	}

	if(SoundSlide != None)
	{
		SoundSlide.SetPos(Components[8].X,Components[8].Y);

		fTemp = SoundSlide.GetCalcedCurSlideValue();
		if(fSoundVolume != fTemp)
		{
			fSoundVolume = fTemp;
			Apply();
		}
	}
}

function bool PushComponentBool(int CmpId)
{
	switch (CmpId) {
	case 2:
		return bListenMusic;
	case 6:
		return bListenSound;
	}
}
/*
function vector PushComponentVector(int CmpId)
{
	local vector V;
	if (CmpId == 4) {
		V.X = 1;
		V.Y = fMusicVolume;
	}
	else if (CmpId == 8) {
		V.X = 1;
		V.Y = fSoundVolume;
	}
	return V;
}

function OnSlideUp(int CmpId)
{
	if (CmpId == 4)
		fMusicVolume = FClamp(fMusicVolume+0.1,0.0,1.0);
	else if (CmpId == 8)
		fSoundVolume = FClamp(fSoundVolume+0.1,0.0,1.0);
	Apply();
}

function OnSlideDown(int CmpId)
{
	if (CmpId == 4)
		fMusicVolume = FClamp(fMusicVolume-0.1,0.0,1.0);
	else if (CmpId == 8)
		fSoundVolume = FClamp(fSoundVolume-0.1,0.0,1.0);
	Apply();
}

function string PushComponentString(int CmpId)
{
	if (CmpId == 4) {
		if (fMusicVolume == 0.0) return Localize("Setting","MinVolume","Sephiroth");
		if (fMusicVolume == 1.0) return Localize("Setting","MaxVolume","Sephiroth");
	}
	else if (CmpId == 8) {
		if (fSoundVolume == 0.0) return Localize("Setting","MinVolume","Sephiroth");
		if (fSoundVolume == 1.0) return Localize("Setting","MaxVolume","Sephiroth");
	}
}
*/
function NotifyComponent(int CmpId,int NotifyId,optional string Command)
{
	switch (NotifyId) {
	case CB_ListenMusic:
		if (Command == "Checked")
			bListenMusic = true;
		else if (Command == "UnChecked")
			bListenMusic = false;
		break;
	case CB_ListenSound:
		if (Command == "Checked")
			bListenSound = true;
		else if (Command == "UnChecked")
			bListenSound = false;
		break;
	}
	Apply();
}

defaultproperties
{
     Components(1)=(Id=1,Caption="ListenMusicMenu",Type=RES_Text,XL=124.000000,YL=14.000000,PivotDir=PVT_Copy,OffsetXL=50.000000,OffsetYL=78.000000,TextColor=(B=113,G=215,R=241,A=255),LocType=LCT_Setting)
     Components(2)=(Id=2,Type=RES_CheckButton,XL=26.000000,YL=26.000000,PivotDir=PVT_Copy,OffsetXL=22.000000,OffsetYL=72.000000)
     Components(4)=(Id=4,XL=110.000000,YL=20.000000,PivotDir=PVT_Copy,OffsetXL=31.000000,OffsetYL=95.000000)
     Components(5)=(Id=5,Caption="ListenSoundMenu",Type=RES_Text,XL=124.000000,YL=14.000000,PivotDir=PVT_Copy,OffsetXL=230.000000,OffsetYL=78.000000,TextColor=(B=113,G=215,R=241,A=255),LocType=LCT_Setting)
     Components(6)=(Id=6,Type=RES_CheckButton,XL=26.000000,YL=26.000000,PivotDir=PVT_Copy,OffsetXL=202.000000,OffsetYL=72.000000)
     Components(8)=(Id=8,XL=110.000000,YL=20.000000,PivotDir=PVT_Copy,OffsetXL=211.000000,OffsetYL=95.000000)
}

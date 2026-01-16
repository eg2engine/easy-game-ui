class CLobbyNewCharacter extends CMultiInterface
	config(CompData);

var config BackgroundData BkgData[10];


const BTN_CreateCharacter = 3;
const BTN_Back = 4;
const BTN_HairTypeL = 5;
const BTN_HairTypeR = 6;
const BTN_HairColorL = 7;
const BTN_HairColorR = 8;
const BTN_RaceHuman = 9;
const BTN_RaceNephilim = 10;
const BTN_Man = 11;
const BTN_Woman = 12;
const BTN_OneHand = 13;
const BTN_Fist = 14;
const BTN_Red = 15;
const BTN_Bow = 16;
const BTN_Blue = 17;
const CMP_Edit = 18;

const Race_Human = 0;
const Race_Nephilim = 1;

const Job_Fist = 0;
const Job_OneHand = 1;
const Job_Red = 2;
const Job_Bow = 3;
const Job_Blue = 4;

var array<string> Jobs;

var string CharacterName;
var CImeEdit NameEdit;

var int SelectedRace;	// 0. 인간 1. 네피림
var int SelectedJob;	// 1. 한손검 0, 무투가 2. 레드 3. 궁수 4. 블루
var int SelectedSex;	// 1. 남 0. 여
var int SelectedHairType;
var int SelectedHairColor;

// model ctrl
var Hero Hero;
var RaceType RaceType;
var Attachment Hair;
var int MaleHair;
var int FemaleHair;
var vector ModelPosition;
var int RotState;
var bool bIsDragging;
var int DragStartX,DragStartY;


function OnInit()
{
	InitBackground(BkgData);
	MoveBackground(-1, -1);
	MatchComponentFromBackground();

	SetComponentTextureID(Components[3], 10, 11, 13, 12);
	SetComponentTextureID(Components[4], 14, 15, 17, 16);
	SetComponentTextureID(Components[5], 18, -1, 20, 19);
	SetComponentTextureID(Components[6], 21, -1, 23, 22);
	SetComponentTextureID(Components[7], 18, -1, 20, 19);
	SetComponentTextureID(Components[8], 21, -1, 23, 22);
	SetComponentTextureID(Components[9], 24, -1, 25, 26);
	SetComponentTextureID(Components[10], 27, -1, 28, 29);
	SetComponentTextureID(Components[11], 30, -1, 32, 31);
	SetComponentTextureID(Components[12], 30, -1, 32, 31);

	SetComponentTextureID(Components[13], 30, -1, 32, 31);
	SetComponentTextureID(Components[14], 30, -1, 32, 31);
	SetComponentTextureID(Components[15], 30, -1, 32, 31);
	SetComponentTextureID(Components[16], 30, -1, 32, 31);
	SetComponentTextureID(Components[17], 30, -1, 32, 31);

	SetComponentNotify(Components[3],BTN_CreateCharacter,Self);
	SetComponentNotify(Components[4],BTN_Back,Self);
	SetComponentNotify(Components[5],BTN_HairTypeL,Self);
	SetComponentNotify(Components[6],BTN_HairTypeR,Self);
	SetComponentNotify(Components[7],BTN_HairColorL,Self);
	SetComponentNotify(Components[8],BTN_HairColorR,Self);
	SetComponentNotify(Components[9],BTN_RaceHuman,Self);
	SetComponentNotify(Components[10],BTN_RaceNephilim,Self);
	SetComponentNotify(Components[11],BTN_Man,Self);
	SetComponentNotify(Components[12],BTN_Woman,Self);
	SetComponentNotify(Components[13],BTN_Fist,Self);
	SetComponentNotify(Components[14],BTN_OneHand,Self);
	SetComponentNotify(Components[15],BTN_Red,Self);
	SetComponentNotify(Components[16],BTN_Bow,Self);
	SetComponentNotify(Components[17],BTN_Blue,Self);

	NameEdit = CImeEdit(AddInterface("Interface.CImeEdit"));
	if (NameEdit != None)
	{
		NameEdit.bNative = True;
		NameEdit.SetMaxWidth(20);
		NameEdit.SetSize(165,18);
		NameEdit.SetFocusEditBox(false);
	}

	ResetEditCtrl();

	LoadRace(class'HumanType');

	SaveConfig();
}

function OnFlush()
{
	if (NameEdit != None)
	{
		NameEdit.SetFocusEditBox(false);
		NameEdit.HideInterface();
		RemoveInterface(NameEdit);
		NameEdit = None;
	}

	UnloadModel();
	if (RaceType != None)
		RaceType.Destroy();
	RaceType = None;

	SaveConfig();
}

function Layout(Canvas C)
{
	local int cx, cy, cw, ch;

	if (NameEdit != None)
		NameEdit.SetPos(Components[18].X + 1, Components[18].Y + 2);

	cx = Components[0].X;
	cy = Components[0].Y;
	cw = Components[0].XL;
	ch = Components[0].YL;

	MoveComponent(Components[3],true,cx+39,cy+428);
	MoveComponent(Components[4],true,C.ClipX-10-157,C.ClipY-10-44);
	MoveComponent(Components[5],true,cx+45,cy+253);
	MoveComponent(Components[6],true,cx+172,cy+253);
	MoveComponent(Components[7],true,cx+45,cy+325);
	MoveComponent(Components[8],true,cx+172,cy+325);

	MoveComponent(Components[9],true,cx+17,cy+15);
	MoveComponent(Components[10],true,cx+121,cy+15);

	MoveComponent(Components[11],true,cx+53,cy+163);
	MoveComponent(Components[12],true,cx+130,cy+163);

	MoveComponent(Components[13],true,cx+40,cy+66);
	MoveComponent(Components[14],true,cx+92,cy+66);
	MoveComponent(Components[15],true,cx+144,cy+66);
	MoveComponent(Components[16],true,cx+40,cy+66);
	MoveComponent(Components[17],true,cx+144,cy+66);

	MoveComponent(Components[18],true,cx+45,cy+397);

/*
	if(SelectedRace == 0)	// 종족 별, 사용 가능 클레스 활성화
	{
		VisibleComponent(Components[13], true);
		VisibleComponent(Components[14], true);
		VisibleComponent(Components[15], true);
		VisibleComponent(Components[16], false);
		VisibleComponent(Components[17], false);
	}
	else if(SelectedRace == 1)
	{
		VisibleComponent(Components[13], false);
		VisibleComponent(Components[14], false);
		VisibleComponent(Components[15], false);
		VisibleComponent(Components[16], true);
		VisibleComponent(Components[17], true);
	}
*/
	Super.Layout(C);
}


function bool OnKeyEvent(Interaction.EInputKey Key, Interaction.EInputAction Action, float Delta)
{
	if(Key == IK_LeftMouse)
	{
		if (Action == IST_Press)
		{
			if (IsCursorInsideComponent(Components[18]) && !NameEdit.HasFocus())
			{
				NameEdit.SetFocusEditBox(true);
				return true;
			}
			else if (!IsCursorInsideComponent(Components[18]) && NameEdit.HasFocus())
			{
				NameEdit.SetFocusEditBox(false);
				return true;
			}
		}

		if (IsCursorInsideComponent(Components[0]))
			return true;
	}
}

function NotifyComponent(int CmpId,int NotifyId,optional string Command)
{
	switch(NotifyId)
	{
	case BTN_CreateCharacter:
		ConsoleCommand("LOBBYQUICKSTART 0");
		CreateCharacter();
		break;
	case BTN_Back:
		Parent.NotifyInterface(Self,INT_Close);
		break;
	case BTN_HairTypeL:
		PreviousHair();
		break;
	case BTN_HairTypeR:
		NextHair();
		break;
	case BTN_HairColorL:
		SelectedHairColor = (SelectedHairColor-1 + RaceType.HairColors.Length) % RaceType.HairColors.Length;
		Hero.HairColor = RaceType.HairColors[SelectedHairColor];
		break;
	case BTN_HairColorR:
		SelectedHairColor = (SelectedHairColor+1) % RaceType.HairColors.Length;
		Hero.HairColor = RaceType.HairColors[SelectedHairColor];
		break;
	case BTN_RaceHuman:
		SelectedRace = Race_Human;
		SelectedJob = Job_OneHand;
		if (!RaceType.IsA('HumanType'))
			LoadRace(class'HumanType');
		VisibleComponent(Components[13], true);
		VisibleComponent(Components[14], true);
		VisibleComponent(Components[15], true);
		VisibleComponent(Components[16], false);
		VisibleComponent(Components[17], false);
		break;
	case BTN_RaceNephilim:
		SelectedRace = Race_Nephilim;
		SelectedJob = Job_Bow;
		if (!RaceType.IsA('NephilimType'))
			LoadRace(class'NephilimType');
		VisibleComponent(Components[13], false);
		VisibleComponent(Components[14], false);
		VisibleComponent(Components[15], false);
		VisibleComponent(Components[16], true);
		VisibleComponent(Components[17], true);
		break;
	case BTN_Man:
		SelectedSex = 1;
		LoadModel(true);
		break;
	case BTN_Woman:
		SelectedSex = 0;
		LoadModel(true);
		break;
	case BTN_OneHand:
		SelectedJob = Job_OneHand;
		Hero.PlayRandomOneHandSkillAnim();
		break;
	case BTN_Fist:
		SelectedJob = Job_Fist;
		Hero.PlayRandomBareSkillAnim();
		break;
	case BTN_Red:
		SelectedJob = Job_Red;
		Hero.PlayRandomStaffSkillAnim();
		break;
	case BTN_Bow:
		SelectedJob = Job_Bow;
		Hero.PlayRandomBowSkillAnim();
		break;
	case BTN_Blue:
		SelectedJob = Job_Blue;
		Hero.PlayRandomStaffSkillAnim();
		break;
	}
}

event Tick(float DeltaTime)
{

}

function OnPreRender(Canvas C)
{
	CharacterName = NameEdit.GetText();
/*
	if(SelectedRace == Race_Human)
	{
		VisibleComponent(Components[13], true);
		VisibleComponent(Components[14], true);
		VisibleComponent(Components[15], true);
		VisibleComponent(Components[16], false);
		VisibleComponent(Components[17], false);
	}
	else
	{
		VisibleComponent(Components[13], false);
		VisibleComponent(Components[14], false);
		VisibleComponent(Components[15], false);
		VisibleComponent(Components[16], true);
		VisibleComponent(Components[17], true);
	}*/

	C.SetDrawColor(255,255,255,255);
}

function OnPostRender(HUD H, Canvas C)
{
	local int i,X,Y;
	local color OldColor;

	C.SetDrawColor(255,255,255,255);

	C.SetPos(Components[0].X+11, Components[0].Y+55);
	C.DrawTile(TextureResources[9].Resource,256,512,0,0,256,512);

	DrawRaceTip(C);
	DrawJobTip(C);

	RenderModel(C);

	if(!NameEdit.HasFocus())
	{
		if(CharacterName == "")
		{
			OldColor = C.DrawColor;

			X = Components[18].X;
			Y = Components[18].Y;

			C.KTextFormat = ETextAlign.TA_MiddleCenter;
			C.SetDrawColor(126,126,126);
			C.DrawKoreanText(Localize("CharacterMenu","TypeCharacterName","Sephiroth"),X,Y,Components[18].XL,Components[18].YL);	//TEXT "캐릭터 이름을 입력하세요"

			C.DrawColor = OldColor;
		}
	}

	// 선택 된 종족
	if(SelectedRace == Race_Human)
	{
		C.SetPos(Components[9].X, Components[9].Y);
		C.DrawTile(TextureResources[25].Resource,Components[9].XL, Components[9].YL,0,0,Components[9].XL, Components[9].YL);

	}
	else if(SelectedRace == Race_Nephilim)
	{
		C.SetPos(Components[10].X, Components[10].Y);
		C.DrawTile(TextureResources[28].Resource,Components[10].XL, Components[10].YL,0,0,Components[10].XL, Components[10].YL);
	}

	// 선택 된 클레스
	if(SelectedJob != -1)
	{
		i = BTN_OneHand + SelectedJob;
		C.SetPos(Components[i].X, Components[i].Y);
		C.DrawTile(TextureResources[31].Resource,Components[i].XL, Components[i].YL,0,0,Components[i].XL, Components[i].YL);
	}

	for(i=13; i<=17; i++)
	{
		if(SelectedRace == 0 && (i == 16 || i == 17))
			continue;
		if(SelectedRace == 1 && (i == 13 || i == 14 || i == 15))
			continue;

		C.SetPos(Components[i].X,Components[i].Y-2);
		C.DrawTile(TextureResources[i+25].Resource,52,52,0,0,52,52);
	}


	// 선택 된 성별
	if(SelectedSex == 0)
		i = BTN_Woman;
	else
		i = BTN_Man;

	C.SetPos(Components[i].X, Components[i].Y);
	C.DrawTile(TextureResources[31].Resource,Components[i].XL, Components[i].YL,0,0,Components[i].XL, Components[i].YL);

	i = BTN_Woman;
	C.SetPos(Components[i].X+12, Components[i].Y+7);
	C.DrawTile(TextureResources[44].Resource,Components[i].XL, Components[i].YL,0,0,Components[i].XL, Components[i].YL);
	i = BTN_Man;
	C.SetPos(Components[i].X+12, Components[i].Y+7);
	C.DrawTile(TextureResources[43].Resource,Components[i].XL, Components[i].YL,0,0,Components[i].XL, Components[i].YL);
	



	// 선택 된 머리스타일
	C.KTextFormat = ETextAlign.TA_MiddleCenter;
	C.SetDrawColor(255,255,255);
	C.DrawKoreanText(SelectedHairType,Components[5].X,Components[5].Y,Components[18].XL,Components[18].YL);

	// 선택 된 머리 색깔
	C.DrawKoreanText(SelectedHairColor,Components[7].X,Components[7].Y,Components[18].XL,Components[18].YL);

	C.SetDrawColor(255,255,255,255);
}


function ResetEditCtrl()
{
	NameEdit.SetText(CharacterName);
	NameEdit.bNative = True;
	NameEdit.SetMaxWidth(20);
	NameEdit.ShowInterface();
//	ActivateComponent(Components[56]);
}

function bool CheckValidName(string Name)
{
	local int NameLen,Space;
	local string ErrorString;

	NameLen = StrLen(Name);
	if (NameLen < 2 || NameLen > 20)
		ErrorString = Localize("Modals","InvalidCharacterNameLength","Sephiroth");
	Space = InStr(Name," ");
	if (Space != -1)
		ErrorString = Localize("Modals","InvalidCharacterNameSpace","Sephiroth");
	if (bool(PlayerOwner.ConsoleCommand("CHECKNAMEVALID" @ Name)))
		ErrorString = Localize("Modals","PlayerWrongName","Sephiroth");
	if (ErrorString != "") {
		NewCharacterError(ErrorString);
		return false;
	}
	return true;
}

function CreateCharacter()
{
	local string FaceName;
	if (!CheckValidName(CharacterName))
		return;
	FaceName = "Face";
	FaceName = FaceName $ Left(RaceType.RaceName, 1);
	if (SelectedSex == 0)
		FaceName = FaceName $ "F1";
	else
		FaceName = FaceName $ "M1";

	//PlayerOwner.myHud.AddMessage(1,"CharacterName"@CharacterName,class'Canvas'.static.MakeColor(200,100,200));
	//NewCharacterError(CharacterName);

	ConsoleCommand("CREATECHARACTER"
		$" "$CharacterName
		$" "$RaceType.RaceName
		$" "$SelectedSex
		$" "$GetHairName(true)
		$" "$FaceName
		$" "$"HunterSuit"
		$" "$Jobs[SelectedJob]
		$" "$RaceType.Castles[0]
		);
}

function NewCharacterError(string Error)
{
	class'CMessageBox'.static.MessageBox(Self,"InvalidCharacterName",Error,MB_Ok);
}

function DrawRaceTip(Canvas C)
{
	local int sx, sy, nMaxWidth, nMaxHeight, nMidWidth, nMidHeight;
	local float fX, fY;
	local float x, y, w, h, ul, vl;

	fX = C.ClipX/1024;
	fY = C.ClipY/768;

	sx = Components[1].X * fX;
	sy = Components[1].Y * fY;

	nMaxWidth = Components[1].XL;
	nMaxHeight = Components[1].YL;
	nMidWidth = nMaxWidth - (64 + 64);
	nMidHeight = nMaxHeight - (64 + 64);

	ul = 64;
	vl = 64;

    x = sx;
    y = sy;
	w = 64;
	h = 64;
	C.SetPos(x, y);
	C.DrawTile(TextureResources[0].Resource,w,h,0,0,ul,vl);

    x = sx + nMaxWidth - 64;
    y = sy;
	w = 64;
	h = 64;
	C.SetPos(x, y);
	C.DrawTile(TextureResources[2].Resource,w,h,0,0,ul,vl);

    x = sx + 64;
    y = sy;
	w = nMidWidth;
	h = 64;
	C.SetPos(x, y);
	C.DrawTile(TextureResources[1].Resource,w,h,0,0,ul,vl);

    x = sx;
    y = sy + 64;
	w = 64;
	h = nMidHeight;
	C.SetPos(x, y);
	C.DrawTile(TextureResources[3].Resource,w,h,0,0,ul,vl);

    x = sx + 64;
    y = sy + 64;
	w = nMidWidth;
	h = nMidHeight;
	C.SetPos(x, y);
	C.DrawTile(TextureResources[4].Resource,w,h,0,0,ul,vl);

    x = sx + nMaxWidth - 64;
    y = sy + 64;
	w = 64;
	h = nMidHeight;
	C.SetPos(x, y);
	C.DrawTile(TextureResources[5].Resource,w,h,0,0,ul,vl);

    x = sx;
    y = sy + nMaxHeight - 64;
	w = 64;
	h = 64;
	C.SetPos(x, y);
	C.DrawTile(TextureResources[6].Resource,w,h,0,0,ul,vl);

    x = sx + 64;
    y = sy + nMaxHeight - 64;
	w = nMidWidth;
	h = 64;
	C.SetPos(x, y);
	C.DrawTile(TextureResources[7].Resource,w,h,0,0,ul,vl);

    x = sx + nMaxWidth - 64;
    y = sy + nMaxHeight - 64;
	w = 64;
	h = 64;
	C.SetPos(x, y);
	C.DrawTile(TextureResources[8].Resource,w,h,0,0,ul,vl);

	C.KTextFormat = ETextAlign.TA_MiddleCenter;
	C.SetDrawColor(229,201,174);
	if(SelectedRace == 0)
		C.DrawKoreanText(Localize("Terms","Human","Sephiroth"), sx, sy+18, nMaxWidth, 16);
	else if(SelectedRace == 1)
		C.DrawKoreanText(Localize("Terms","Nephilim","Sephiroth"), sx, sy+18, nMaxWidth, 16);

	C.KTextFormat = ETextAlign.TA_MiddleLeft;
	C.SetDrawColor(255,255,255);
	x = sx+18;
	y = sy+57;
	w = Components[1].XL;
	h = 14; //Components[1].YL;
	//DrawKoreanTextMultiLine(C,x,y,w,h,5,25,Localize("CNewCharacter","RaceTip" $ SelectedRace,"SephirothUI"));
	DrawKoreanTextMultiLine(C,x,y,w,h,5,22,Localize("CNewCharacter","RaceTip" $ SelectedRace,"SephirothUI")); //@cs changed 
}

function DrawJobTip(Canvas C)
{
	local int sx, sy, nMaxWidth, nMaxHeight, nMidWidth, nMidHeight;
	local float fX, fY;
	local float x, y, w, h, ul, vl;
	local int nMarkIndex;
	local string sTemp;

	fX = C.ClipX/1024;
	fY = C.ClipY/768;

	sx = Components[2].X * fX;
	sy = Components[2].Y * fY;

	nMaxWidth = Components[2].XL;
	nMaxHeight = Components[2].YL;
	nMidWidth = nMaxWidth - (64 + 64);
	nMidHeight = nMaxHeight - (64 + 64);

	ul = 64;
	vl = 64;

    x = sx;
    y = sy;
	w = 64;
	h = 64;
	C.SetPos(x, y);
	C.DrawTile(TextureResources[0].Resource,w,h,0,0,ul,vl);

    x = sx + nMaxWidth - 64;
    y = sy;
	w = 64;
	h = 64;
	C.SetPos(x, y);
	C.DrawTile(TextureResources[2].Resource,w,h,0,0,ul,vl);

    x = sx + 64;
    y = sy;
	w = nMidWidth;
	h = 64;
	C.SetPos(x, y);
	C.DrawTile(TextureResources[1].Resource,w,h,0,0,ul,vl);

    x = sx;
    y = sy + 64;
	w = 64;
	h = nMidHeight;
	C.SetPos(x, y);
	C.DrawTile(TextureResources[3].Resource,w,h,0,0,ul,vl);

    x = sx + 64;
    y = sy + 64;
	w = nMidWidth;
	h = nMidHeight;
	C.SetPos(x, y);
	C.DrawTile(TextureResources[4].Resource,w,h,0,0,ul,vl);

    x = sx + nMaxWidth - 64;
    y = sy + 64;
	w = 64;
	h = nMidHeight;
	C.SetPos(x, y);
	C.DrawTile(TextureResources[5].Resource,w,h,0,0,ul,vl);

    x = sx;
    y = sy + nMaxHeight - 64;
	w = 64;
	h = 64;
	C.SetPos(x, y);
	C.DrawTile(TextureResources[6].Resource,w,h,0,0,ul,vl);

    x = sx + 64;
    y = sy + nMaxHeight - 64;
	w = nMidWidth;
	h = 64;
	C.SetPos(x, y);
	C.DrawTile(TextureResources[7].Resource,w,h,0,0,ul,vl);

    x = sx + nMaxWidth - 64;
    y = sy + nMaxHeight - 64;
	w = 64;
	h = 64;
	C.SetPos(x, y);
	C.DrawTile(TextureResources[8].Resource,w,h,0,0,ul,vl);

	C.KTextFormat = ETextAlign.TA_MiddleCenter;

	switch(SelectedJob)
	{
	case 0: sTemp = Localize("Terms","Bare","Sephiroth"); nMarkIndex=33; break;
	case 1: sTemp = Localize("Terms","OneHand","Sephiroth"); nMarkIndex=34; break;
	case 2: sTemp = Localize("Terms","Red","Sephiroth"); nMarkIndex=35; break;
	case 3: sTemp = Localize("Terms","Bow","Sephiroth"); nMarkIndex=36; break;
	case 4: sTemp = Localize("Terms","Blue","Sephiroth"); nMarkIndex=37; break;
	}

	// 배경 무늬
	C.SetDrawColor(255,255,255);
	C.SetPos(sx + (nMaxWidth-255) / 2, sy + (nMaxHeight-255) / 2);
	C.DrawTile(TextureResources[nMarkIndex].Resource,255,255,0,0,255,255);

	C.SetDrawColor(229,201,174);
	C.DrawKoreanText(sTemp, sx, sy+18, nMaxWidth, 16);	// 타이틀


	C.KTextFormat = ETextAlign.TA_MiddleLeft;
	C.SetDrawColor(255,255,255,255);
	x = sx+18;
	y = sy+57;
	w = Components[2].XL;
	h = 14; //Components[2].YL;
	//DrawKoreanTextMultiLine(C,x,y,w,h,5,25,Localize("CNewCharacter","JobTip" $ SelectedJob,"SephirothUI"));
	DrawKoreanTextMultiLine(C,x,y,w,h,5,22,Localize("CNewCharacter","JobTip" $ SelectedJob,"SephirothUI")); //@cs changed

}

//#############################################################################
// model ctrl
//#############################################################################


function string GetHexString(byte Value)
{
	local string Result;
	local int R,D;
	R = Value / 16;
	D = Value % 16;
	switch (R) {
	case 0: Result = Result $ "0"; break;
	case 1: Result = Result $ "1"; break;
	case 2: Result = Result $ "2"; break;
	case 3: Result = Result $ "3"; break;
	case 4: Result = Result $ "4"; break;
	case 5: Result = Result $ "5"; break;
	case 6: Result = Result $ "6"; break;
	case 7: Result = Result $ "7"; break;
	case 8: Result = Result $ "8"; break;
	case 9: Result = Result $ "9"; break;
	case 10: Result = Result $ "A"; break;
	case 11: Result = Result $ "B"; break;
	case 12: Result = Result $ "C"; break;
	case 13: Result = Result $ "D"; break;
	case 14: Result = Result $ "E"; break;
	case 15: Result = Result $ "F"; break;
	}
	switch (D) {
	case 0: Result = Result $ "0"; break;
	case 1: Result = Result $ "1"; break;
	case 2: Result = Result $ "2"; break;
	case 3: Result = Result $ "3"; break;
	case 4: Result = Result $ "4"; break;
	case 5: Result = Result $ "5"; break;
	case 6: Result = Result $ "6"; break;
	case 7: Result = Result $ "7"; break;
	case 8: Result = Result $ "8"; break;
	case 9: Result = Result $ "9"; break;
	case 10: Result = Result $ "A"; break;
	case 11: Result = Result $ "B"; break;
	case 12: Result = Result $ "C"; break;
	case 13: Result = Result $ "D"; break;
	case 14: Result = Result $ "E"; break;
	case 15: Result = Result $ "F"; break;
	}
	return Result;
}

function string GetHairName(optional bool bWithColor)
{
	local string HairName;

	HairName = "Hair";
	HairName = HairName $ Left(RaceType.RaceName,1);
	HairName = HairName $ Left(RaceType.Genders[SelectedSex],1);
	if (SelectedSex == 0)
		HairName = HairName $ (FemaleHair+1);
	else if (SelectedSex == 1)
		HairName = HairName $ (MaleHair+1);

	if (bWithColor)
		HairName = HairName $ "#" $ GetHexString(Hero.HairColor.R) $ GetHexString(Hero.HairColor.G) $ GetHexString(Hero.HairColor.B);

	return HairName;
}

function NextHair()
{
	if (SelectedSex == 0)
	{
		FemaleHair = (FemaleHair + 1) % RaceType.FemaleHairCount;
		SelectedHairType = FemaleHair;
	}
	else
	{
		MaleHair = (MaleHair + 1) % RaceType.MaleHairCount;
		SelectedHairType = MaleHair;
	}
	Hero.SetHair(GetHairName());
	Hero.Attachments[Hero.AT_Head].bUnlit = true;
	Hero.Attachments[Hero.AT_Head].SetDrawScale(1.6f);
}

function PreviousHair()
{
	if (SelectedSex == 0)
	{
		FemaleHair = (FemaleHair - 1 + RaceType.FemaleHairCount) % RaceType.FemaleHairCount;
		SelectedHairType = FemaleHair;
	}
	else
	{
		MaleHair = (MaleHair - 1 + RaceType.MaleHairCount) % RaceType.MaleHairCount;
		SelectedHairType = MaleHair;
	}
	Hero.SetHair(GetHairName());
	Hero.Attachments[Hero.AT_Head].bUnlit = true;
	Hero.Attachments[Hero.AT_Head].SetDrawScale(1.6f);
}

function LoadRace(class<RaceType> RaceClass)
{
	if (RaceType != None)
		RaceType.Destroy();
	RaceType = Spawn(RaceClass);
	SelectedJob = RaceType.DefaultJob; //Job_OneHand; //RaceType.DefaultJob;
	SelectedSex = RaceType.DefaultGender;
//	Castle = 0;

	SelectedHairColor = 0;   //Rand(RaceType.MaleHairCount) ;	//색도 랜덤으로 하려면 이거 켜주면 되요. //이러면 안되고, RaceType에 haircolor_num 추가 하고, 개수 정해 줘야 되지만 우연히 같으므로

	MaleHair = Rand(RaceType.MaleHairCount) ;		//0;   원래 코드		//modified by yj
	
	FemaleHair = Rand(RaceType.FemaleHairCount) ;	//0;   원래는 0

	if(SelectedSex == 1)
		SelectedHairType = MaleHair;
	else
		SelectedHairType = FemaleHair;

	LoadModel(true);
}

function LoadModel(optional bool bClear)
{
	local string HeroName;
	local class<Hero> HeroClass;
	local Rotator Rot;
	local int i;

	if (bClear && Hero != None && !Hero.bDeleteMe)
		Hero.Destroy();

	HeroName = RaceType.RaceName;
	HeroName = HeroName $ RaceType.Genders[SelectedSex];

	HeroClass = class<Hero>(DynamicLoadObject("Lobby."$HeroName$"_New",class'Class'));
	Hero = PlayerOwner.spawn(HeroClass);
	Hero.SetHair(GetHairName());
	Hero.SetFace(RaceType.RaceName, (SelectedSex == 1));
	Hero.Attachments[Hero.AT_Head].bUnlit = true;
	Rot = Hero.Rotation;
	Rot.Yaw = (Rot.Yaw + 32768 - 8192) % 65536;
	Hero.SetRotation(Rot);
	Hero.bHidden = true;
	Hero.bUnlit = true;
	Hero.HairColor = RaceType.HairColors[SelectedHairColor];
	Hero.SetDrawScale(1.6f);
	//Hero.Attachments[Hero.AT_Head].SetDrawScale(1.6f);
	for(i=0; i<=16; i++)
	{
		if( Hero.Attachments[i] != none )
			Hero.Attachments[i].SetDrawScale(1.6f);
	}
}

function UnloadModel()
{
	Hero.bHidden = false;
	Hero.Destroy();
	Hero = None;
}

function RenderModel(Canvas C)
{
	local vector CamPos,X,Y,Z;
	local rotator CamRot;

	CamPos = PlayerOwner.Location;
	CamRot = PlayerOwner.Rotation;
//	PlayerOwner.PlayerCalcView(ViewActor,CamPos,CamRot);

	GetAxes(CamRot,X,Y,Z);
	// 2689.52 / 4411.59 / -4455.77
	//Log("neive : check temp " $ Temp.X $ " / " $ Temp.Y $ " / " $ Temp.Z);
	Hero.SetRotation(OrthoRotation(-X,-Y,Z));
	//ModelPosition.Z += 0.1f;
	//ModelPosition.X -= 0.1f;
	//Log("neive : check temp " $ ModelPosition.X);
	//Hero.SetLocation(ModelPosition);
	Hero.SetLocation(CamPos + (ModelPosition.X * X) + (ModelPosition.Y * Y) + (ModelPosition.Z * Z));

	C.DrawActor(Hero,false,true,90);
}

defaultproperties
{
     Jobs(0)="Bare"
     Jobs(1)="OneHand"
     Jobs(2)="Red"
     Jobs(3)="Bow"
     Jobs(4)="Blue"
     SelectedSex=1
     ModelPosition=(X=280.000000,Z=-100.000000)
     Components(0)=(XL=806.000000,YL=606.000000)
     Components(1)=(Id=1,X=710.000000,Y=57.000000,XL=304.000000,YL=314.000000)
     Components(2)=(Id=2,X=710.000000,Y=373.000000,XL=304.000000,YL=314.000000)
     Components(3)=(Id=3,Caption="CreateCharacter",Type=RES_PushButton,XL=157.000000,YL=44.000000,TextAlign=TA_MiddleCenter,LocType=LCT_User,LocalizeSection="CharacterMenu")
     Components(4)=(Id=4,Caption="Back",Type=RES_PushButton,XL=157.000000,YL=44.000000,TextAlign=TA_MiddleCenter,TextColor=(B=22,G=175,R=226,A=255),LocType=LCT_User,LocalizeSection="CharacterMenu")
     Components(5)=(Id=5,Type=RES_PushButton,XL=20.000000,YL=20.000000)
     Components(6)=(Id=6,Type=RES_PushButton,XL=20.000000,YL=20.000000)
     Components(7)=(Id=7,Type=RES_PushButton,XL=20.000000,YL=20.000000)
     Components(8)=(Id=8,Type=RES_PushButton,XL=20.000000,YL=20.000000)
     Components(9)=(Id=9,Type=RES_PushButton,XL=101.000000,YL=44.000000)
     Components(10)=(Id=10,Type=RES_PushButton,XL=101.000000,YL=44.000000)
     Components(11)=(Id=11,Type=RES_PushButton,XL=52.000000,YL=52.000000)
     Components(12)=(Id=12,Type=RES_PushButton,XL=52.000000,YL=52.000000)
     Components(13)=(Id=13,Type=RES_PushButton,XL=52.000000,YL=52.000000)
     Components(14)=(Id=14,Type=RES_PushButton,XL=52.000000,YL=52.000000)
     Components(15)=(Id=15,Type=RES_PushButton,XL=52.000000,YL=52.000000)
     Components(16)=(Id=16,Type=RES_PushButton,XL=52.000000,YL=52.000000)
     Components(17)=(Id=17,Type=RES_PushButton,XL=52.000000,YL=52.000000)
     Components(18)=(Id=18,XL=147.000000,YL=20.000000)
     TextureResources(0)=(Package="UI_2011",Path="win_1_LU",Style=STY_Alpha)
     TextureResources(1)=(Package="UI_2011",Path="win_1_CU",Style=STY_Alpha)
     TextureResources(2)=(Package="UI_2011",Path="win_1_RU",Style=STY_Alpha)
     TextureResources(3)=(Package="UI_2011",Path="win_1_LC",Style=STY_Alpha)
     TextureResources(4)=(Package="UI_2011",Path="win_1_CC",Style=STY_Alpha)
     TextureResources(5)=(Package="UI_2011",Path="win_1_RC",Style=STY_Alpha)
     TextureResources(6)=(Package="UI_2011",Path="win_1_LD",Style=STY_Alpha)
     TextureResources(7)=(Package="UI_2011",Path="win_1_CD",Style=STY_Alpha)
     TextureResources(8)=(Package="UI_2011",Path="win_1_RD",Style=STY_Alpha)
     TextureResources(9)=(Package="UI_2011",Path="chr_add_info",Style=STY_Alpha)
     TextureResources(10)=(Package="UI_2011_btn",Path="btn_blue_n",Style=STY_Alpha)
     TextureResources(11)=(Package="UI_2011_btn",Path="btn_blue_d",Style=STY_Alpha)
     TextureResources(12)=(Package="UI_2011_btn",Path="btn_blue_o",Style=STY_Alpha)
     TextureResources(13)=(Package="UI_2011_btn",Path="btn_blue_c",Style=STY_Alpha)
     TextureResources(14)=(Package="UI_2011_btn",Path="btn_red_n",Style=STY_Alpha)
     TextureResources(15)=(Package="UI_2011_btn",Path="btn_blue_d",Style=STY_Alpha)
     TextureResources(16)=(Package="UI_2011_btn",Path="btn_red_o",Style=STY_Alpha)
     TextureResources(17)=(Package="UI_2011_btn",Path="btn_red_c",Style=STY_Alpha)
     TextureResources(18)=(Package="UI_2011_btn",Path="btn_s_arr_L_N",Style=STY_Alpha)
     TextureResources(19)=(Package="UI_2011_btn",Path="btn_s_arr_L_O",Style=STY_Alpha)
     TextureResources(20)=(Package="UI_2011_btn",Path="btn_s_arr_L_c",Style=STY_Alpha)
     TextureResources(21)=(Package="UI_2011_btn",Path="btn_s_arr_R_N",Style=STY_Alpha)
     TextureResources(22)=(Package="UI_2011_btn",Path="btn_s_arr_R_O",Style=STY_Alpha)
     TextureResources(23)=(Package="UI_2011_btn",Path="btn_s_arr_R_c",Style=STY_Alpha)
     TextureResources(24)=(Package="UI_2011_btn",Path="chr_add_tab_h_n",Style=STY_Alpha)
     TextureResources(25)=(Package="UI_2011_btn",Path="chr_add_tab_h_c",Style=STY_Alpha)
     TextureResources(26)=(Package="UI_2011_btn",Path="chr_add_tab_h_o",Style=STY_Alpha)
     TextureResources(27)=(Package="UI_2011_btn",Path="chr_add_tab_n_n",Style=STY_Alpha)
     TextureResources(28)=(Package="UI_2011_btn",Path="chr_add_tab_n_c",Style=STY_Alpha)
     TextureResources(29)=(Package="UI_2011_btn",Path="chr_add_tab_n_o",Style=STY_Alpha)
     TextureResources(30)=(Package="UI_2011_btn",Path="btn_icon_n",Style=STY_Alpha)
     TextureResources(31)=(Package="UI_2011_btn",Path="btn_icon_c",Style=STY_Alpha)
     TextureResources(32)=(Package="UI_2011_btn",Path="btn_icon_o",Style=STY_Alpha)
     TextureResources(33)=(Package="UI_2011",Path="emble_job_punch",Style=STY_Alpha)
     TextureResources(34)=(Package="UI_2011",Path="emble_job_swd",Style=STY_Alpha)
     TextureResources(35)=(Package="UI_2011",Path="emble_job_red",Style=STY_Alpha)
     TextureResources(36)=(Package="UI_2011",Path="emble_job_bow",Style=STY_Alpha)
     TextureResources(37)=(Package="UI_2011",Path="emble_job_blue",Style=STY_Alpha)
     TextureResources(38)=(Package="UI_2011_btn",Path="icon_job_punch_n",Style=STY_Alpha)
     TextureResources(39)=(Package="UI_2011_btn",Path="icon_job_swd_n",Style=STY_Alpha)
     TextureResources(40)=(Package="UI_2011_btn",Path="icon_job_red_n",Style=STY_Alpha)
     TextureResources(41)=(Package="UI_2011_btn",Path="icon_job_bow_n",Style=STY_Alpha)
     TextureResources(42)=(Package="UI_2011_btn",Path="icon_job_blue_n",Style=STY_Alpha)
     TextureResources(43)=(Package="UI_2011_btn",Path="icon_gender_m_n",Style=STY_Alpha)
     TextureResources(44)=(Package="UI_2011_btn",Path="icon_gender_f_n",Style=STY_Alpha)
}

class CPatch extends CMultiInterface
	config(Patch);

#exec Obj Load File=../Textures/UI_Board.utx Package=UI_Board

var CTextFile FileLoader;

var int CurrentPage;
var int PageCount;

struct PatchReadInfo {
	var string Username;
	var string Version;
};
var config array<PatchReadInfo> PatchVersion;
var vector UserVersion;

var Texture BoardMat[12];
var Texture Bullet;

var CTextScroll Texts;
var CButton Next;
var CButton Previous;
var CButton Exit;

function vector VersionToVector(string Version)
{
	local int DotPos;
	local string Remained;
	local int Major, Middle, Minor;
	local vector VersionVector;

	Remained = Version;
	DotPos = InStr(Remained, ".");

	if (DotPos != -1) {
		Major = int(Left(Remained, DotPos));
		Remained = Mid(Remained, DotPos+1);
		DotPos = InStr(Remained, ".");
		if (DotPos != -1) {
			Middle = int(Left(Remained, DotPos));
			Remained = Mid(Remained, DotPos+1);
			Minor = int(Remained);
		}
		else
			Middle = -1;
	}
	else
		Major = -1;

	VersionVector.X = float(Major);
	VersionVector.Y = float(Middle);
	VersionVector.Z = float(Minor);

	return VersionVector;
}

function string VectorToVersion(vector Version)
{
	return string(int(Version.X)) $ "." $ int(Version.Y) $ "." $ int(Version.Z);
}

function int CompareVersion(string Version1, string Version2)
{
	local vector PreVersion, PostVersion;
	PreVersion = VersionToVector(Version1);
	PostVersion = VersionToVector(Version2);

	if (PreVersion.X < PostVersion.X)
		return -1;
	else if (PreVersion.X == PostVersion.X) 
	{
		if (PreVersion.Y < PostVersion.Y)
			return -1;
		else if (PreVersion.Y == PostVersion.Y) 
		{
			if (PreVersion.Z < PostVersion.Z)
				return -1;
			else if (PreVersion.Z == PostVersion.Z)
				return 0;
			else
				return 1;
		}
		else
			return 1;
	}
	else
		return 1;

	return 0;
}

function LoadBoard()
{
	local int i;
	for (i=0;i<12;i++)
		BoardMat[i] = Texture(DynamicLoadObject("UI_Board.Board" $ i / 4 $ int(i % 4), class'Texture'));
}

function DrawBoard(Canvas C)
{
	local int i;
	local float W, H;
	
	W = C.ClipX / 4;
	H = C.ClipY / 3;

	C.SetDrawColor(160,160,160);
	C.SetRenderStyleAlpha();
	for (i=0;i<12;i++) {
		C.SetPos(W*int(i%4), H*(i/4));
		C.DrawTile(BoardMat[i], W, H, 0, 0, 256, 256);
	}
}

function OnInit()
{
	local int i, IDDelim;
	local PatchReadInfo CurrentReadInfo;

	FileLoader = spawn(class'CTextFile');

	CurrentReadInfo.Username = ConsoleCommand("GetAccountName");
	IDDelim = InStr(CurrentReadInfo.Username, ":");
	if (IDDelim > -1)
		CurrentReadInfo.Username = Left(CurrentReadInfo.Username, IDDelim);
	CurrentReadInfo.Version = ConsoleCommand("GetSephirothVersion");

	for (i=0;i<PatchVersion.Length;i++) {
		if (PatchVersion[i].Username == CurrentReadInfo.Username) {
			UserVersion = VersionToVector(PatchVersion[i].Version);
			if (CompareVersion(PatchVersion[i].Version, CurrentReadInfo.Version) < 0) {
				PatchVersion[i].Version = CurrentReadInfo.Version;
				SaveConfig();
			}
			break;
		}
	}
	if (i == PatchVersion.Length) {
		PatchVersion.Length = PatchVersion.Length+1;
		PatchVersion[PatchVersion.Length-1].Username = CurrentReadInfo.Username;
		PatchVersion[PatchVersion.Length-1].Version = CurrentReadInfo.Version;
		SaveConfig();
	}

	FileLoader.LoadFilesMoreThan("Notice\\*.*", VectorToVersion(UserVersion));
	if (FileLoader.DirectoryFiles.Length == 0) {
		Parent.NotifyInterface(Self,INT_Close);
		return;
	}

	PageCount = FileLoader.DirectoryFiles.Length;

	Texts = CTextScroll(AddInterface("Interface.CTextScroll"));
	if (Texts != None) {
		Texts.ShowInterface();
		Texts.TextList.bReadOnly = True;
		Texts.TextList.bWrapText = True;
		Texts.TextList.TextAlign = 0;
		Texts.TextList.ItemHeight = 18;
		Texts.bNoScrollBar = True;
		Texts.SetSize(298, 197);
		Texts.TextList.TextColor = class'Canvas'.static.MakeColor(80,80,80);
		Texts.TextList.OnDrawText = InternalDrawTextItem;
	}

	if (!LoadFile()) {
		Parent.NotifyInterface(Self,INT_Close);
		return;
	}

	LoadBoard();

	//SepPlayerController(PlayerOwner).bNoDrawWorld = true;
	PlayerOwner.bNoDrawWorld = true;

	Next = CButton(AddInterface("Interface.CButton"));
	if (Next != None) {
		Next.ShowInterface();
		Next.SetSize(64, 32);
		Next.OnClick = ButtonClick;
		Next.SetImage("UI_Board.Menu.BoardRight", true, true, true, true);
	}
	Previous = CButton(AddInterface("Interface.CButton"));
	if (Previous != None) {
		Previous.ShowInterface();
		Previous.SetSize(64, 32);
		Previous.OnClick = ButtonClick;
		Previous.SetImage("UI_Board.Menu.BoardLeft", true, true, true, true);
	}
	Exit = CButton(AddInterface("Interface.CButton"));
	if (Exit != None) {
		Exit.ShowInterface();
		Exit.SetSize(32,32);
		Exit.OnClick = ButtonClick;
		Exit.SetImage("UI_Board.Menu.BoardExit", true, true, true, true);
	}
}

function InternalChangeTextArea(CInterface Sender)
{
	if (!LoadFile())
		Parent.NotifyInterface(Self, INT_Close);
}

function bool LoadFile()
{
	local int i;
	if (Texts != None && FileLoader.LoadParagraphs("Notice\\"$FileLoader.DirectoryFiles[CurrentPage])) {
		Texts.TextList.Clear();
		for (i=0;i<FileLoader.Paragraphs.Length;i++)
			Texts.TextList.MakeList(FileLoader.Paragraphs[i]);
		return true;
	}
	else
		return false;
	return true;
}

function OnFlush()
{
	if (FileLoader != None) {
//		FileLoader.PurgeFile("Notice.txt");
//		for (i=0;i<PageCount;i++)
//			FileLoader.PurgeFile("Notice\\"$FileLoader.DirectoryFiles[i]);
		FileLoader.Destroy();
		FileLoader = None;
	}
	if (Texts != None) {
		Texts.HideInterface();
		RemoveInterface(Texts);
		Texts = None;
	}

	SaveConfig();

	//SepPlayerController(PlayerOwner).bNoDrawWorld = false;
	PlayerOwner.bNoDrawWorld = false;

	if (Next != None) {
		Next.HideInterface();
		RemoveInterface(Next);
		Next = None;
	}
	if (Previous != None) {
		Previous.HideInterface();
		RemoveInterface(Previous);
		Previous = None;
	}
	if (Exit != None) {
		Exit.HideInterface();
		RemoveInterface(Exit);
		Exit = None;
	}
}

function Layout(Canvas C)
{
	if (Texts != None) {
		if (Texts.WinWidth != C.ClipX * 2 / 3.0 || Texts.WinHeight != C.ClipY * 2 / 3.0) {
			Texts.SetSize(C.ClipX * 2 / 3.0, C.ClipY * 2 / 3.0);
			InternalChangeTextArea(Self);
		}
		Texts.SetPos((C.ClipX - Texts.WinWidth) / 2.0, (C.ClipY - Texts.WinHeight) / 2.0);
	}
	if (Previous != None)
		Previous.SetPos(Texts.WinX + Texts.WinWidth - 32 - 64 - 64, Texts.WinY + Texts.WinHeight + 10);
	if (Next != None)
		Next.SetPos(Texts.WinX + Texts.WinWidth - 32 - 64, Texts.WinY + Texts.WinHeight + 10);
	if (Exit != None)
		Exit.SetPos(Texts.WinX + Texts.WinWidth - 32, Texts.WinY + Texts.WinHeight + 10);

	Super.Layout(C);
}

function string GetFileExt(string FullFileName, out string FileExt)
{
	local int ExtPt;
	local string LeftStr, RightStr;

	RightStr = FullFileName;
	ExtPt = InStr(RightStr, ".");
	if (ExtPt == -1) {
		FileExt = "";
		return FullFileName;
	}
	while (ExtPt != -1) {
		LeftStr = Left(RightStr, ExtPt);
		RightStr = Right(RightStr, ExtPt+1);
		ExtPt = InStr(RightStr, ".");
	}
	FileExt = RightStr;
	return LeftStr;
}

function OnPreRender(Canvas C)
{
	//add neive : 알림창을 자동으로 닫게 한다 ---------------------------------
	Parent.NotifyInterface(Self, INT_Close);
	return ;
	//-------------------------------------------------------------------------

	Next.EnableButton(CurrentPage < PageCount - 1);
	Previous.EnableButton(CurrentPage > 0);

	C.SetDrawColor(0,0,0);
	C.SetPos(0,0);
	C.DrawTileStretched(Texture'Engine.WhiteSquareTexture', C.ClipX, C.ClipY);
	DrawBoard(C);
}

function bool OnKeyEvent(Interaction.EInputKey Key, Interaction.EInputAction Action, float Delta)
{
	if (Key == IK_Space && Action == IST_Press) {
		if (Controller.bCtrlPressed) {
			CurrentPage = CurrentPage - 1;
			if (CurrentPage < 0)
				CurrentPage = 0;
			if (!LoadFile()) {
				Parent.NotifyInterface(Self, INT_Close);
				return true;
			}
		}
		else {
			CurrentPage = CurrentPage + 1;
			if (CurrentPage >= PageCount)
				CurrentPage = PageCount - 1;
			if (!LoadFile()) {
				Parent.NotifyInterface(Self, INT_Close);
				return true;
			}
		}
		return true;
	}
	if (Key == IK_Escape && Action == IST_Press) {
		Parent.NotifyInterface(Self, INT_Close);
		return true;
	}
	return false;
}

function ButtonClick(CInterface Sender)
{
	if (Sender == Next) {
		CurrentPage = CurrentPage + 1;
		if (CurrentPage >= PageCount)
			CurrentPage = PageCount - 1;
		if (!LoadFile()) {
			Parent.NotifyInterface(Self, INT_Close);
		}
	}
	else if (Sender == Previous) {
		CurrentPage = CurrentPage - 1;
		if (CurrentPage < 0)
			CurrentPage = 0;
		if (!LoadFile()) {
			Parent.NotifyInterface(Self, INT_Close);
		}
	}
	else if (Sender == Exit) {
		Parent.NotifyInterface(Self, INT_Close);
	}
}

function InternalDrawTextItem(Canvas C, int i, string Text, float X, float Y, float W, float H, bool bSelected)
{
	local string Rep;
	local int Pos;
	local string ColorCode;

	if (Left(Text, 2) == "<<") {
		Rep = Mid(Text, 2);
		Pos = InStr(Rep, ">>");
		if (Pos != -1)
			Rep = Left(Rep, Pos);

		C.SetPos(X+1, Y+1);
		C.SetRenderStyleAlpha();
		C.SetDrawColor(255,255,255);
		C.DrawTile(Bullet, 16, 16, 0, 0, 16, 16);

		ColorCode = MakeColorCodeEx(0, 0, 0);

		C.SetPos(X+20, Y);
		C.DrawTextScaled(ColorCode $ Rep, false, 1.4, 1.4);
	}
	else {
		Rep = Text;

		ColorCode = MakeColorCodeEx(0, 0, 0);

		C.DrawTextJustified(ColorCode $ Rep, 0, X, Y, X+W, Y+H);
	}
}

defaultproperties
{
     Bullet=Texture'UI_Board.Bullet.SubtitleBullet'
}

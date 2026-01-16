class CHelp extends CMultiInterface;
/*
	Ʈ�� �޴� ���·� �ٲٱ� ���Ͽ� ���� ������ CHelp�Դϴ�.
	������Ʈ �����ð��� �Ѱ� ������ �ڵ带 �������Ƚ��ϴ�. ����������, �ּ��� �������ּ���.
	2009.10.21.Sinhyub
*/

struct SubMenu{	//���� �޴�
	var string Title;			//���� �޴��� ����
	var int HelpIndex;			//���ö���¡�� ������ �ε��� ( "Help\\Help"$Index$"."LangExt )
	var string HelpTextureIndex;	//++�߰����� .�׸������� �ε��� (���� �Ф� �������ּ��� ��Ʈ���Դϴ�... ¥�����ڵ�)
};

struct HelpMenu{
	var bool bExpanded;				//������ �ִ°�
	var string Title;				//�޴��� ����
	var array<SubMenu> Submenus;	//�������ִ� ���� �޴���
};

var array<HelpMenu> MenuList;	//�޴� ����Ʈ
var int SelectedMenuNum;		//���õ� ����,�޴�
var int SelectedSubMenuNum;		//���õ� �����޴�/��������
var int CurHelpIndex;			//���� �д� Help���� �ε���
var string CurHelpTextureIndex;	//���� �д� Help �ؽ��� �ε���

//var float VLine

//Component ID
const ID_PB_EXIT	= 1;	//exit pushbutton

//Component Notify ID
const BN_MenuArea = 1;		//�޴� ������ Ŭ�������� �����ϱ� ���Ͽ�
const BN_Exit = 20;

var CTextFile FileLoader;
var CScrollTextureTextArea TextArea;
var string LangExt;

var int id_start;

//Menu�� Layout
const LineHeight = 16;		//�� ���� ����
const LineWidth	=	125;	//�� ���� ����
//const MaxLine	= 29;		//â�ȿ� �� �� �ִ� �ִ� �� ��
var int CurStartLine;		//���� ������ �޴��� ������ ���° ���ΰ�?

var string m_sTitle;

function OnInit()
{
	SetComponentTextureId(Components[ID_PB_EXIT],11,-1,11,12);
	Components[ID_PB_EXIT].NotifyId = BN_Exit;

	//Set Menu Area
	Components[2].NotifyId = BN_MenuArea;
	
	SetSephirothHelpMenu(9);
	SetSubmenuFileIndex();

	/*
	for(i=0; i<MenuList.Length; i++)
	{
		for(j=0; j<MenuList[i].Submenus.Length; j++)
			//Log("Log::::"@MenuList[i].Submenus[j].HelpIndex);
	}
	*/
	SelectedMenuNum = -1;
	SelectedSubMenuNum = -1;

	//Set Text Area
	LangExt = PlayerOwner.ConsoleCommand("LangExt");
	FileLoader = spawn(class'CTextFile');
	TextArea = CScrollTextureTextArea(AddInterface("SephirothUI.CScrollTextureTextArea"));
	if (TextArea != None) {
		TextArea.ShowInterface();
		TextArea.PageWidth = 350;
		TextArea.PageHeight = 310;
		TextArea.SetPosition(Components[0].X+150,Components[0].Y+65);
		TextArea.ScrollBarOffsetXL = 22;
		LoadHelp(CurHelpIndex,CurHelpTextureIndex);
	}
	
	m_sTitle = Localize("HelpUI","HelpUI","SephirothUI");
}

function OnFlush()
{
    RemoveInterface(TextArea);
	super.OnFlush();
}

function Layout(Canvas C)
{
	local int i;
	MoveComponentId(0,true,(C.ClipX-550)/2,(C.ClipY-406)/2);
	for (i=1;i<Components.Length;i++)
		MoveComponentId(i);

	TextArea.SetPosition(Components[0].X+150,Components[0].Y+65); //19,Components[0].Y+85);

	Super.Layout(C);
}

function OnPreRender(Canvas C)
{
	local float X,Y;

	DrawBackGround3x3(C, 64, 64, 0, 1, 2, 3, 4, 5, 6, 7, 8);
	DrawTitle(C, m_sTitle);

	X = Components[0].X;
	Y = Components[0].Y;
	C.SetPos(X + 11, Y + 48);
	C.DrawTile(TextureResources[9].Resource,544,4,0,0,4,4);	// ��� ����

	C.SetPos(X + 157, Y + 52);
	C.SetDrawColor(0,0,0);
	C.DrawTile(TextureResources[10].Resource,398,359,0,0,1,1);	// ���� ��׶���

	C.SetDrawColor(255,255,255);
}

function OnPostRender(HUD H, Canvas C)
{
	DrawMenu(c);
//	CurHelpIndex=MenuList[SelectedMenuNum].Submenus[SelectedSubMenuNum].HelpIndex;
//	LoadHelp(CurHelpIndex);
}

function bool OnKeyEvent(Interaction.EInputKey Key, Interaction.EInputAction Action,float Delta)
{
	if (Key == IK_Escape && Action == IST_Press) {
		Parent.NotifyInterface(Self,INT_Close);
		return true;
	}
	if(IsCursorInsideComponent(Components[2]))
	{//case : Cursor is inside of Text Area.
		if(Action==IST_Press){
			switch(Key)	{
			case IK_LeftMouse:
				IsArrangeMenuSelected();
				break;
			}
		}
		CurHelpIndex=MenuList[SelectedMenuNum].Submenus[SelectedSubMenuNum].HelpIndex;
		CurHelpTextureIndex=MenuList[SelectedMenuNum].Submenus[SelectedSubMenuNum].HelpTextureIndex;
		LoadHelp(CurHelpIndex,CurHelpTextureIndex);
	}
}

function NotifyComponent(int CmpId,int NotifyId,optional string Command)
{
	if(NotifyId == BN_Exit) {
		Parent.NotifyInterface(Self,INT_Close);
		return;
	}
}	

/*
	�޴�����Ʈ�� �� �ټ��� ����. (�����ִ� �޴� ����)
	-�׽�Ʈ ���� �ʾ���.-
*/
function int GetMenuTotalLine()
{
	local int Plength, Slength,Tlength;			//length(lines) of ParentMenu/SubMenu/Total
	Plength = MenuList.Length;
	if(SelectedMenuNum != -1)
		Slength = MenuList[SelectedMenuNum].Submenus.Length;
	else
		Slength = 0;
	Tlength = Plength + Slength;
	return Tlength;
}

/*
	Setting Menu.
*/
function SetMenuList(int MenuIndex, bool expanded)
{
	if(MenuIndex > MenuList.Length)
		MenuList.Insert(MenuList.Length-1,MenuIndex-MenuList.Length-1);
	MenuList.Insert(MenuList.Length,1);
	MenuList[MenuIndex].bExpanded = expanded;
	MenuList[MenuIndex].Title = Localize("Help","Menu"$MenuIndex, "Sephiroth");
}

/*
	���� �޴��� �����մϴ�.
	ParentIndex : �߰��� �����޴��� ��ġ�ϰԵ� �θ����� �ε���(ID)
	SubMenuIndex : �߰��ϴ� �����޴��� �ε���(ID)
*/
function SetSubmenu(int ParentIndex, int SubMenuIndex)//, int FileIndex)
{
	local int Plength;
	Plength = MenuList[ParentIndex].Submenus.Length;
	if(SubMenuIndex > Plength )
		MenuList[ParentIndex].Submenus.Insert(Plength-1,SubmenuIndex-Plength-1);
	MenuList[ParentIndex].Submenus.Insert(MenuList[ParentIndex].Submenus.Length, 1);
	Plength = MenuList[ParentIndex].Submenus.Length;
	MenuList[ParentIndex].Submenus[Plength-1].HelpIndex = -1;	//�̼�������
	MenuList[ParentIndex].Submenus[Plength-1].Title = Localize("Help", "Menu"$ParentIndex$"_"$SubMenuIndex, "Sephiroth");
}

/*
	���� �޴��� ����Ǵ� ���� �ε����� �������ݴϴ�.
	�����޴��� �����޴��� ��� �߰����� �Ŀ�, �� �Լ��� �ҷ��־� ������� ���� �ε����� ���ĵ˴ϴ�.
	��)
	"��(�����޴� ����°) ->  �����(�����޴� �ι�°)" �� ���� �ε����� 18���� �����Ǿ��ֽ��ϴ�.
	�����޴� ù��° �ʺ��� ���̵忡 �޴��� 12��, �����޴� �ι�° ��ų �޴��� 4��,
	�� 16���� �ռ� �޴��� �����Ƿ� �ι��� �� ������ 18�� �ش� ������ �ε����� �˴ϴ�.
	�̷��� ������ ���� �ε���(Index)�� �ش� ����޴��� ���� �ؽ�Ʈ������ �������� ��μ����� ���˴ϴ�.
	�ش��ϴ� ���� �ؽ�Ʈ ������ ��� : ( "Help\\Help"$Index$"."LangExt ) 

	++ �߰����� 2009.10.27.
	++ �ؽ��� ���ҽ��� ����ϱ� ����  CScrollTextureTextArea�� �����Ͽ����ϴ�.
	++ �˸����� �ؽ��� ���ҽ��� ������ ���� ������ �ε��� ������ �Ұ����Ͽ� 
	++ �ؽ��� ���ҽ��� ��� SetSubMenuFileIndex���� �ش� ���ҽ��� ��� ���� �ϳ��� �ڵ��Ͽ��Ӵϴ�.
	++ ������ �ڵ� �˼��մϴ�.

*/
function SetSubmenuFileIndex()
{
	local int nMenu, nSubmenu, i,j,total;
	nMenu = MenuList.Length;
	total = 0;
	for(i=0; i<nMenu; i++)
	{
		nSubmenu=MenuList[i].Submenus.Length;
		for(j=0; j<nSubmenu; j++)
		{
			switch(total)
			{//�ؽ��� ���ҽ� �ε��� (�ФФФ���)
			case 0:	//�⺻����
				MenuList[i].Submenus[j].HelpTextureIndex = "01";
				break;
			case 1://��ġ�̵�
				MenuList[i].Submenus[j].HelpTextureIndex = "09";
				break;
			case 2://�������
				MenuList[i].Submenus[j].HelpTextureIndex = "03";
				break;
			case 3://���Ⱥй�
				MenuList[i].Submenus[j].HelpTextureIndex = "02";
				break;
			case 5:// ��ų
				MenuList[i].Submenus[j].HelpTextureIndex = "04";
				break;
			case 7://ä��/��Ƽ/�ŷ�
				MenuList[i].Submenus[j].HelpTextureIndex = "06";
				break;
			case 8:
				MenuList[i].Submenus[j].HelpTextureIndex = "05";
				break;
			case 9:
				MenuList[i].Submenus[j].HelpTextureIndex = "08";
				break;
			case 11:
				MenuList[i].Submenus[j].HelpTextureIndex = "12";
				break;
			case 16:
				MenuList[i].Submenus[j].HelpTextureIndex = "11";
				break;
			default:
				MenuList[i].Submenus[j].HelpTextureIndex = "";
				break;
			}
			MenuList[i].Submenus[j].HelpIndex=total++;
			
		}
	}
}


//n(9)���� ���� �޴��� �׿� ���� �����޴��� ���� - �� for ���� �ݺ�Ƚ���� �����޴��� ����  -
function SetSephirothHelpMenu(int n)
{
	local int i;
	for(i=0; i<n; i++)
		SetMenuList(i,false);
	for(i=0;i<12;i++)
		SetSubMenu(0,i);
	for(i=0;i<4;i++)
		SetSubMenu(1,i);
	for(i=0;i<3;i++)
		SetSubMenu(2,i);
	for(i=0;i<4;i++)
		SetSubMenu(3,i);
	for(i=0;i<2;i++)
		SetSubMenu(4,i);
	for(i=0;i<2;i++)
		SetSubMenu(5,i);
	for(i=0;i<4;i++)
		SetSubMenu(6,i);
	for(i=0;i<3;i++)
		SetSubMenu(7,i);
	for(i=0;i<4;i++)
		SetSubMenu(8,i);
}

function LoadHelp(int Index, string TextureIndex)
{
	//Log("TESTLOADHELP:::"@"Help\\Help"$Index$"."$LangExt);
	FileLoader.LoadParagraphs("Help\\Help"$Index$"."$LangExt);
	TextArea.CopyTexts(FileLoader.Paragraphs);
	TextArea.LoadTexture("Help.Tutorial_0"$TextureIndex$"_"$"kr");
}

/*
    � �޴� �׸��� ���õǾ������� üũ�մϴ�.
*/
function bool IsArrangeMenuSelected()
{
	local int i;
	local float X,Y;

	X = Components[2].X;
	Y = Components[2].Y;

	for(i = 0 ; i < GetMenuTotalLine(); i++)//SephirothPlayer(PlayerOwner).BuddyMgr.BuddyGroups.Length ; i++)
	//for(i = 0 ; i < BuddyMgr.BuddyGroups.Length ; i++)
	{
		if(IsCursorInsideAt(X,Y+LineHeight*i,LineWidth,LineHeight))
		{
			if(SelectedMenuNum<0)	// || SelectedMenuNum>=TreeMenu.Length){
				SelectedMenuNum = i;
			else if(i<SelectedMenuNum)
				SelectedMenuNum = i;
			else if(i == SelectedMenuNum)
				SelectedMenuNum = -1;
			else if(i>SelectedMenuNum)
			{
				if( i <= (SelectedMenuNum + MenuList[SelectedMenuNum].SubMenus.Length) )
					SelectedSubMenuNum = i - SelectedMenuNum-1;
				else
				{
					SelectedMenuNum= i - MenuList[SelectedMenuNum].SubMenus.Length;
					SelectedSubMenuNum=-1;
				}
			}
			return true;
		}
	}
	return false;
}
/*
	�޴��� �׷��ݴϴ�.
	�ð��� ����ġ�ʾ� �޴��� �׸� �������� �Է¹����ʰ�, DrawMenuTitle()���� �ش� ������ ������Ʈ X,Y����Ʈ�� �����ҽ��ϴ�.
*/
function DrawMenu(Canvas C)
{
	local int i, j;
	local int CurLine;
	local color OldColor;
//	local string temp;

	OldColor = C.DrawColor;
	C.DrawColor = Controller.TextColorNormal;
	CurLine = 0;	//���� �۾����� ��
	C.SetKoreanTextAlign(ETextAlign.TA_MiddleLeft);
	for(i=0; i<MenuList.Length; i++)
	{
		if( CurLine >= CurStartLine)
		{
			if( i == SelectedMenuNum)//���� �����ִٸ�
			{
				/*
				temp = "-";
				C.DrawColor = Controller.TextColorSelected;
				temp = temp@MenuList[i].Title;
				DrawMenuTitle(C, false, true, temp, CurLine);
				*/
				DrawMenuTitle(C, false, true, MenuList[i].Title, CurLine);
				CurLine++;

				for(j=0; j<MenuList[i].Submenus.Length; j++)
				{
					if(j==SelectedSubMenuNum)
						C.DrawColor = Controller.TextColorHighLight;
					DrawMenuTitle(C, true, false, MenuList[i].Submenus[j].Title, CurLine);
					if(j==SelectedSubMenuNum)
						C.DrawColor = Controller.TextColornormal;
					CurLine++;
				}
			}
			else{
				/*
				temp = "+";

				//////////////Color Variable ���� �����ؼ� ����սô�
				C.DrawColor = Controller.TextColorSelected;
				temp = temp@MenuList[i].Title;
				DrawMenuTitle(C, false, temp, CurLine);
				*/
				DrawMenuTitle(C, false, false, MenuList[i].Title, CurLine);
				CurLine++;
			}			
		}
		else
			CurLine++;
	}
	C.DrawColor = OldColor;
}

/*
	nLine��° �ٿ� �ش��ϴ� �޴�(title)�� �׷��ش�.
	SubMenu��� ������(XL)���� Offset��ŭ �̵��Ͽ� �׷��ش�.
*/
function DrawMenuTitle(Canvas C, bool IsSubMenu, bool IsOn, string title, int nline)
{
	local float X,Y,W;
	local int ResId;
	
	X = Components[2].x+4;
	Y = Components[2].y+1;
	W = 16;

	if(isSubMenu)	//SubMEnu�� ���������� �� �ȼ� �� �̵��Ͽ� �׷��ݴϴ�.
	{
		C.DrawColor = Controller.TextColorNormal;
		C.DrawKoreanText(title, X + W + 1, Y+LineHeight*nline, LineWidth, LineHeight);
	}
	else
	{


		if(IsOn)
			ResId = 14;
		else
			ResId = 13;

		C.SetDrawColor(255,255,255);
		C.SetPos(X, Y+LineHeight*nline);
		C.DrawTile(TextureResources[ResId].Resource,16,16,0,0,20,20);

		C.SetDrawColor(241,215,113);
		C.DrawKoreanText(title, X + W + 1, Y+LineHeight*nline, LineWidth, LineHeight);
	}
}

defaultproperties
{
     SelectedMenuNum=-1
     SelectedSubMenuNum=-1
     Components(0)=(XL=566.000000,YL=422.000000)
     Components(1)=(Id=1,Type=RES_PushButton,XL=14.000000,YL=13.000000,PivotDir=PVT_Copy,OffsetXL=535.000000,OffsetYL=14.000000,HotKey=IK_Escape,ToolTip="CloseContext")
     Components(2)=(Id=2,XL=128.000000,YL=350.000000,PivotDir=PVT_Copy,OffsetXL=10.000000,OffsetYL=55.000000)
     TextureResources(0)=(Package="UI_2011",Path="win_2_LU",Style=STY_Alpha)
     TextureResources(1)=(Package="UI_2011",Path="win_2_CU",Style=STY_Alpha)
     TextureResources(2)=(Package="UI_2011",Path="win_2_RU",Style=STY_Alpha)
     TextureResources(3)=(Package="UI_2011",Path="win_1_LC",Style=STY_Alpha)
     TextureResources(4)=(Package="UI_2011",Path="win_1_CC",Style=STY_Alpha)
     TextureResources(5)=(Package="UI_2011",Path="win_1_RC",Style=STY_Alpha)
     TextureResources(6)=(Package="UI_2011",Path="win_1_LD",Style=STY_Alpha)
     TextureResources(7)=(Package="UI_2011",Path="win_1_CD",Style=STY_Alpha)
     TextureResources(8)=(Package="UI_2011",Path="win_1_RD",Style=STY_Alpha)
     TextureResources(9)=(Package="UI_2011",Path="tab_line",Style=STY_Alpha)
     TextureResources(10)=(Package="UI_2011",Path="pulldown_bg",Style=STY_Alpha)
     TextureResources(11)=(Package="UI_2011_btn",Path="btn_x_n",Style=STY_Alpha)
     TextureResources(12)=(Package="UI_2011_btn",Path="btn_x_o",Style=STY_Alpha)
     TextureResources(13)=(Package="UI_2011_btn",Path="btn_s_+_n",Style=STY_Alpha)
     TextureResources(14)=(Package="UI_2011_btn",Path="btn_s_-_n",Style=STY_Alpha)
}

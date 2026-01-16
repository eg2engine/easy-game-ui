//-----------------------------------------------------------
// Ŭ���̾�Ʈ���� ���������� �����ֱ� ����.
//-----------------------------------------------------------
class CWebBrowser extends CInterface;

//var config float WinX,WinY;
//var float WinX,WinY,WinWidth, WinHeight; CInterface�� �����Ѵ�. X,Y,WinWidth,WinHeight

const BN_Exit = 1;
const BN_Apply = 2; //�����ϱ� ��ư.
const BN_New = 3;	//��ùޱ�.

var int WebBrowserState;    // 0: ��ü����,����. 1: ��ü����,����, 3:��ü����.����
var int WebOTP;
var int ServerID;

var float DeltaTime_CheckNewItem;
var int nNewItem;

function OnInit()
{
    //Exit��ư �߰�.
    SetComponentNotify(Components[3], BN_Exit, self);
    SetComponentTextureId(Components[3],1,0,3,2);
    //Apply��ư �߰�
    SetComponentNotify(Components[4], BN_Apply, self);
    SetComponentTextureId(Components[4],1,0,3,2);

	//Notify��ư �߰�. ��ùޱ� ��ư
	SetComponentNotify(Components[5], BN_New, self);
	SetComponentTextureId(Components[5],5,0,7,7);

	DeltaTime_CheckNewItem=0;
	NotifyNewGrantItem(0);

    SetSize(750,550);
    ResetDefaultPosition();     //2009.10.27.Sinhyub
}

function NotifyNewGrantItem(int bNew)
{
	//Log("NotiGrantItem"@bNew);
	nNewItem = bNew;
	if(bNew != 0)
	{
		SetComponentTextureId(Components[5],4,0,6,6);
		EnableComponent(Components[5],true);
	}
	else
	{
		SetcomponentTextureId(Components[5],5,0,7,7);
		Enablecomponent(Components[5],false);
	}
}

function OnFlush()
{
    SaveConfig();
}

function Tick(float DeltaTime)
{
	DeltaTime_CheckNewItem += DeltaTime;
	if(DeltaTime_CheckNewItem >= 10.0)	//10��?
	{
// 		if(nNewItem !=0)F
// 			nNewItem = 0;
// 		else
// 			nNewItem = 1;
// 		NotifyNewGrantItem(nNewItem);
		//Log("Tick, 10Seccond");
		SephirothPlayer(PlayerOwner).Net.NotiRequestCheckNewGrantItem();
		DeltaTime_CheckNewItem = 0;
	}

	Super.Tick(DeltaTime);
}

function Layout(Canvas C)
{
//    local int DX,DY;  //â�̵� ����� ���� ����
    local int i;

    if(bNeedLayoutUpdate)
    {
        MoveComponent(Components[0],true,WinX,WinY,WinWidth,WinHeight);
        for (i=1;i<Components.Length;i++)
            MoveComponentId(i);
        bNeedLayoutUpdate = false;
    }

    Super.Layout(C);
}

function OnPreRender(Canvas C)
{
    local color OldColor;
    OldColor = C.DrawColor;
    C.SetDrawColor(0,0,0,180);
    //Ŭ���̾�Ʈ ������ �ѿ��� ����.
    C.DrawTileAlpha(texture'engine.WhiteSquareTexture',0,0,C.ClipX,C.ClipY);
    C.DrawColor = OldColor;
}

function NotifyComponent(int CmpId,int NotifyId,optional string Command)
{
    if (NotifyId == BN_Exit)    //�ݱ��ư
        Parent.NotifyInterface(Self,INT_Close);
    if (NotifyId == BN_Apply)   //�����ϱ� ��ư. (�ݱ��ư�� �����ϱ� ��ư�� ������ ���� �ϱ⿡ INT_Close�� ȣ���մϴ�.
        Parent.NotifyInterface(Self,INT_Close);
	if (NotifyID==BN_New)
		SephirothPlayer(PlayerOwner).Net.NotiRequestGrantItem();
	 
	
}

function bool OnKeyEvent(Interaction.EInputKey Key,Interaction.EInputAction Action,float Delta)
{
/*  â�̵��� ���� ����
    if (Key == IK_LeftMouse ) {//2009.10.27.Sinhyub
        if ((Action == IST_Press) && IsCursorInsideComponent(Components[0]))
        {
            bMovingUI = true;
            bIsDragging = true;
            DragOffsetX = Controller.MouseX - PageX;
            DragOffsetY = Controller.MouseY - PageY;
        //  return true;
        }
        if (Action == IST_Release && bIsDragging) {
            bIsDragging = false;
            DragOffsetX = 0;
            DragOffsetY = 0;
        //  return true;
        }
    }
*/
    if (Key == IK_LeftMouse && IsCursorInsideComponent(Components[0]))
        return true;
}

function SetOTP(int nOTP, int nServerID)
{
	WebOTP = nOTP;
	ServerID = nServerID;
	ShowInterface();
}

function ShowInterface()
{
    local string strUserAccount;
    local string strServer;
    local string strPlayName;

    local string strUserAccount_Encoded;
    local string strServer_Encoded;
    local string strPlayName_Encoded;

    super.ShowInterface();

    strUserAccount = ConsoleCommand("GetAccountName");
	
// strServer = ConsoleCommand("SERVERSETNAME");	//�̰� ��Ʈ�����ιۿ� �ȵ�����
//   strServer = string(ServerID);
//   strServer="6";
   strPlayName = string(SephirothPlayer(PlayerOwner).PSI.PlayName); //SephirothPlayer(PlayerOwner).PSI.PlayName;

   class'CNativeInterface'.static.URLEncode(strUserAccount, strUserAccount_Encoded);
   class'CNativeInterface'.static.URLEncode(strServer, strServer_Encoded);
   class'CNativeInterface'.static.URLEncode(strPlayName, strPlayName_Encoded);

   //Log(" WebOTP :"@WebOTP@"ServerID"@ServerID);
   RequestNavigateURL("http://www.kaixuan2.com/sephiroth/www/html/gshop_main.jsp?id="$strUserAccount_Encoded$"&OTP="$WebOTP$"&server="$ServerID$"&alias="$strPlayName_Encoded$"");
   RequestShowWebBrowser();

// 
// //    strUserAccount = ConsoleCommand("GetAccountName");
//     strUserAccount = "dhdgnpf";
// //    strServer = ConsoleCommand("ServerSetName");
//     strServer = "6";
// //    strPlayName = string(SephirothPlayer(PlayerOwner).PSI.PlayName); //SephirothPlayer(PlayerOwner).PSI.PlayName;
//     strPlayName = "Ambient";
// 
//     class'CNativeInterface'.static.URLEncode(strUserAccount, strUserAccount_Encoded);
//     class'CNativeInterface'.static.URLEncode(strServer, strServer_Encoded);
//     class'CNativeInterface'.static.URLEncode(strPlayName, strPlayName_Encoded);
// 
//     RequestNavigateURL("http://www.kaixuan2.com/sephiroth/www/html/gshop_main.jsp?id="$strUserAccount_Encoded$"&OTP=2"$"&server="$strServer_Encoded$"&alias="$strPlayName_Encoded$"");
// 	//Log("http://www.kaixuan2.com/sephiroth/www/html/gshop_main.jsp?id="$strUserAccount_Encoded$"&OTP=2"$"&server="$strServer_Encoded$"&alias="$strPlayName_Encoded$"");
//     //RequestNavigateURL("http://www.daum.net");
// 
//     RequestNavigateURL("http://www.kaixuan2.com/sephiroth/www/html/gshop_main.jsp?id="$strUserAccount_Encoded$"&OTP="$WebOTP$"&server="$ServerID$"&alias="$strPlayName_Encoded$"");
//     RequestShowWebBrowser();

}

function HideInterface()
{
    RequestHideWebBrowser();
    super.HideInterface();
}

function RequestShowWebBrowser()
{
    ConsoleCommand("SHOWBROWSER");
}

function RequestNavigateURL(string theURL)
{
    //Log("EHWOEHTLKQWEHTLKWE:::::::"@theURL);
    //Log("NAVIGATEURL"@theURL);
    ConsoleCommand("NAVIGATEURL"@theURL);
}

function RequestHideWebBrowser()
{
    ConsoleCommand("HIDEBROWSER");
}

/*
function RequestAddWebBrowser()
{
//  ConsoleCommand("AddBrowser");
}
*/

function RemoveWebBrowser()
{
    ConsoleCommand("RemoveBrowser");
}

//CInterface�� SetSize, SetPos�� ������ �װ� ���.
/*function SetWindowSize(float XL, float YL)
{
    WinWidth = XL;
    WinHeight = YL;
}
function SetWindowPosition(float X, float Y, float XL, float YL)
{
    WinX = X;
    WinY = Y;
    WinWidth = XL;
    WinHeight = YL;
}
*/

function ResetDefaultPosition()     //2009.10.27.Sinhyub
{
    local string Resolution;
    local int pos;
    local int ClipX,ClipY;

    Resolution = PlayerOwner.ConsoleCommand("GETCURRENTRES");
    pos = InStr(Resolution, "x");

    ClipX=int(Left(Resolution, pos));
    ClipY=int(Mid(Resolution, pos+1));

    WinWidth = Components[0].XL;
    WinHeight = Components[0].YL;

    WinX = (ClipX-WinWidth)/2;
    WinY = (ClipY-WinHeight)/2-10;

    MoveComponent(Components[0], true, WinX, WinY, WinWidth, WinHeight);

    Components[3].OffsetXL= (WinWidth-Components[3].XL);
    Components[4].OffsetXL= (WinWidth-Components[3].XL);
	Components[5].OffsetXL= (WinWidth-300);

    bNeedLayoutUpdate = true;
    SaveConfig();
}

defaultproperties
{
     Components(0)=(XL=750.000000,YL=550.000000)
     Components(1)=(Id=1,Type=RES_Image,XL=750.000000,YL=550.000000,PivotDir=PVT_Copy)
     Components(3)=(Id=3,Type=RES_PushButton,XL=23.000000,YL=20.000000,PivotDir=PVT_Copy,OffsetXL=727.000000,OffsetYL=3.000000,ToolTip="CloseContext")
     Components(4)=(Id=4,Type=RES_PushButton,XL=23.000000,YL=20.000000,PivotDir=PVT_Copy,OffsetXL=727.000000,OffsetYL=530.000000,ToolTip="ApplyShop")
     Components(5)=(Id=5,Type=RES_PushButton,XL=99.000000,YL=99.000000,PivotDir=PVT_Copy,OffsetXL=500.000000,OffsetYL=-60.000000)
     TextureResources(0)=(Package="UI_2009",Path="Win22",Style=STY_Alpha)
     TextureResources(1)=(Package="UI_2009",Path="BTN01_01_N",Style=STY_Alpha)
     TextureResources(2)=(Package="UI_2009",Path="BTN01_01_O",Style=STY_Alpha)
     TextureResources(3)=(Package="UI_2009",Path="BTN01_01_P",Style=STY_Alpha)
     TextureResources(4)=(Package="UI_2009",Path="Icon_Cho01C",Style=STY_Alpha)
     TextureResources(5)=(Package="UI_2009",Path="Icon_Cho01D",Style=STY_Alpha)
     TextureResources(6)=(Package="UI_2009",Path="Icon_Cho02C",Style=STY_Alpha)
     TextureResources(7)=(Package="UI_2009",Path="Icon_Cho02D",Style=STY_Alpha)
     WinX=-1.000000
     WinY=-1.000000
}

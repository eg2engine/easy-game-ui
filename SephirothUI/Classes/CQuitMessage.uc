//--------------
// ��Ʋ �ý����� ���� ���̴� Ŭ�����Դϴ�
// �޽���â(CMessageBox)�� ���������,�ܺ� Ŭ�������� ��ü�� ����־� ������ ������ ���̾�α��Դϴ�.
// -�ð��� ���� ī��Ʈ��������.
// * �� ��
// ** ��Ʋ �ý��� �������̽� (SephirothInterface.BattleSystemInterface)�� �������ִ� ������ �ð��ֽ��ϴ�.
// ** QuitMessage�� ������ ��찡 ��Ʋ�ý����� ������ ������ ó�����̹Ƿ�  (�����κ��� ���ƿ��� ���������� �������� �ʽ��ϴ�)
// ** ��Ʋ �ý��� �������̽��� �� �������ְ� ��������մϴ�.
// *** EndingEffect�� ���� �Ŀ� ��Ÿ�����ϱ�����, bIsVisible�� �߰��Ͽ� �׷���Ÿ�̹��� �����մϴ�.
// 2010.1.13.Sinhyub
//---------------
class CQuitMessage extends CInterface;

const BN_Quit = 1;

const BTN_QUIT_ID = 2;     //������ ��ư�� ������Ʈ ���̵�

var int PageX;
var int PageY;

//var bool bNeedLayoutUpdate;

var bool bIsTimerOn;
var bool bIsVisible;    //�� UIâ�� �������ʰ� ����

var float duration_time;
var float remain_time;
var float start_time;

var string str_remaintime;
var string str_bodytext;
//var string str_body_1;
//var string str_body_2;


//���̾ƿ� ��ȿȭ. ( Layout()���� ���̾ƿ��� �ٽ� �����ϵ��� �մϴ�)
function InvalidateLayout()
{
	bNeedLayoutUpdate = True;
}
//���̾ƿ��� �ٽ� �����ؾ��ϴ��� üũ�մϴ�
function bool IsInvalidLayout()
{
	return bNeedLayoutUpdate;
}
//�޽��� â�� ��ġ�� �������ݴϴ�
function SetPosition(float X, float Y)
{
	PageX = X;
	PageY = Y;
	Components[0].X = PageX;
	Components[0].Y = PageY;
	InvalidateLayout();
}

//������ ��ư�� �ؽ�Ʈ�� �������ݴϴ�.
function SetQuitButtonText(string btn_caption)
{
	SetComponentText(Components[BTN_QUIT_ID], btn_caption);
}
/*
function SetBodyText(string message)
{
    SetComponentText(Components[3], message);
}
*/
function SetQuitTimer(int sec)
{
	duration_time = sec;
	start_time = Level.TimeSeconds;
	bIsTimerOn = True;
	UpdateTimer();
}

// Hide Interface �� ���� ���� ������,
// BattleInterface�� �����ϴ� ���� QuitMessage�� ����ϰ� �����Ƿ�,
// �׳� ����������� �ȵ˴ϴ�. �� �����ϰ� ��������մϴ�.
//function HideInterface()
//{
//    SephirothInterface(CBattleInterface(Parent).Parent).RemoveBattleInterface();
//    super.HideInterface();
//}

function bool UpdateTimer()
{
	local float cur_time;
	cur_time = Level.TimeSeconds;
	remain_time = duration_time - (cur_time - start_time);
    // 1. �ð��� �ʰ��� ���(remain_time <= 1 ) - 1�ʿ����� �ΰ� ����
    // 2. ��Ұ� ����Ǿ� Ŭ���̾�Ʈ ������ ���� ���ŵ� ��� ( start_time > cur_time )
	if( remain_time <= 1 || (start_time > cur_time) )
		return False;
	str_remaintime = "";
	if( (remain_time / 3600) >= 1.0 )
		str_remaintime = int(remain_time / 3600)$"h";
	if( (remain_time / 60) >= 1.0 )
		str_remaintime = str_remaintime$int(remain_time / 60)$"m";
	str_remaintime = str_remaintime$int(remain_time%60)$"s";
	return True;
}

//�� �޽��� â�� �ݾ� �ֵ��� �� ��ü(SephirothInterface)�� ��Ź.
//�Ϲ�ȭ�������ϰ�, SephirothInterface���� ���� ���� �����Ǿ����ϴ�.
function EndMessage()
{
	bIsTimerOn = False;
	SephirothInterface(CBattleInterface(Parent).Parent).RemoveBattleInterface();
	HideInterface();  //�� ���α��� �Ѿ�ñ��? ���� �װ��� �ñ��մϴ�.
}

function MakeInvisible()
{
	local int i;
	bIsVisible = False;
	for( i = 0;i < Components.Length;i++ )
	{
		Components[i].bVisible = False;
	}
}

function MakeVisible()
{
	local int i;
	bIsVisible = True;
	for( i = 0;i < Components.Length;i++ )
	{
		Components[i].bVisible = True;
	}
}

function OnInit()
{
	SetComponentTextureID(Components[BTN_QUIT_ID], 0,1,2,3);
	SetComponentNotify(Components[BTN_QUIT_ID], BN_Quit, Self);
	//str_body_1 = Localize("Match","STB_Quit_1","Sephiroth");
	//str_body_2 = Localize("Match","STB_Quit_2","Sephiroth");
	str_bodytext = Localize("Match","STB_Quit_2","Sephiroth");
	SetComponentText(Components[3],Localize("Match","STB_Quit_1","Sephiroth"));
	SetComponentText(Components[4], (str_remaintime@str_bodytext));
	SetComponentText(Components[5],Localize("Match","STB_Quit_3","Sephiroth"));
	duration_time = 0;
	bIsTimerOn = False;
	MakeInVisible();
	InvalidateLayout();
}

function Layout(Canvas C)
{
	local int i;

    //ȭ�鿡 ������ ������ �׸���������ġ�� ������Ű����
    //Canvas.ClipX �� �����پ����ִٸ� SetPosition�Լ��� �̿��Ͽ� PageX,Y�� �����ϴ� ���� ���ٽ��ϴ�.
	PageX = (C.ClipX - Components[0].XL) / 2;
	PageY = C.ClipY - Components[0].YL - 125;

	if( IsInvalidLayout() )
	{
		MoveComponent(Components[0],True,PageX,PageY);
		for( i = 1; i < Components.Length;i++ )
			MoveComponent(Components[i]);
		bNeedLayoutUpdate = False;
	}
	if( !bIsVisible && (remain_time <= 20) )
		MakeVisible();

	if( bIsTimerOn )
	{
		if( UpdateTimer() )
		{
//          str_bodytext = str_body_1@str_remaintime@str_body_2;
			SetComponentText(Components[4], (str_remaintime@str_bodytext));
		}
		else
			EndMessage();
	}
	Super.Layout(C);
}
/*
function PostRender(Canvas C)
{
//    if(UpdateTimer())
//    {
        C.SetDrawColor(255,255,255,255);
        C.DrawKoreanText(str_bodytext, Components[0].X+5, Components[0].Y+5, Components[0].XL-10, Components[0].YL-10);
//        C.DrawKoreanText(str_remaintime, Components[1].Type EResourc

//    }
}
*/
/*
function PreRender(Canvas C)
{
     C.SetDrawColor(255,15,15,255);
     C.DrawKoreanText(str_bodytext,Components[0].X-110, Components[0].Y+10, Components[0].XL-20, Components[0].YL-20);
}
*/


function NotifyComponent(int ResId, int NotifyID, optional string NotifyCommand)
{
	switch( NotifyID )
	{
		case BN_Quit:
        //something
        //�̺κ���... �Ϲ�ȭ��Ű�� ���Ͽ���. ��ư�� ������ �� ����. UC���Լ������Ͱ��ִٸ� �̰��� �Լ������͸� �ΰ�, �ܺ�Ŭ�������� �Լ������Ϳ� ����� �Լ��� ������ �� �ֵ��� ����.
			SephirothPlayer(PlayerOwner).Net.NotiMatchQuit(SephirothPlayer(PlayerOwner).PSI.MatchName);
			EndMessage();
			break;
	}
}

defaultproperties
{
	Components(0)=(XL=300.000000,YL=192.000000)
	Components(1)=(Id=1,ResId=4,Type=RES_Image,XL=300.000000,YL=192.000000,PivotDir=PVT_Copy)
	Components(2)=(Id=2,Type=RES_PushButton,XL=192.000000,YL=32.000000,PivotDir=PVT_Copy,OffsetXL=54.000000,OffsetYL=130.000000,TextAlign=TA_MiddleCenter)
	Components(3)=(Id=3,Type=RES_Text,XL=280.000000,YL=20.000000,PivotDir=PVT_Copy,OffsetXL=10.000000,OffsetYL=30.000000,TextAlign=TA_MiddleCenter,TextColor=(B=255,G=255,R=255,A=255))
	Components(4)=(Id=4,Type=RES_Text,XL=280.000000,YL=20.000000,PivotDir=PVT_Copy,OffsetXL=10.000000,OffsetYL=50.000000,TextAlign=TA_MiddleCenter,TextColor=(B=255,G=255,R=255,A=255))
	Components(5)=(Id=5,Type=RES_Text,XL=280.000000,YL=20.000000,PivotDir=PVT_Copy,OffsetXL=10.000000,OffsetYL=70.000000,TextAlign=TA_MiddleCenter,TextColor=(B=255,G=255,R=255,A=255))
	TextureResources(0)=(Package="UI_2009",Path="BTN04_02_N",Style=STY_Alpha)
	TextureResources(1)=(Package="UI_2009",Path="BTN04_02_D",Style=STY_Alpha)
	TextureResources(2)=(Package="UI_2009",Path="BTN04_02_P",Style=STY_Alpha)
	TextureResources(3)=(Package="UI_2009",Path="BTN04_02_O",Style=STY_Alpha)
	TextureResources(4)=(Package="UI_2009",Path="WIN16",Style=STY_Alpha)
}

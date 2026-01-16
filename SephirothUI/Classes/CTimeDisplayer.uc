//-----------------------------------------------------------
// This Class is for time display.
// EX) BattleSystemTimeInfo.
//........
//...........
//......
//  -Sinhyub. 2009.12.30
//-----------------------------------------------------------
class CTimeDisplayer extends CInterface;

//�ð��� ǥ������ ����ü
struct myTime
{
	var int Hour;
    var int Min;
    var int Sec;
};

var bool bIsTimerOn;
var myTime remainTime;			//�ð�. (Timer�� ���δٸ� ���� �ð�)
var myTime startTime;		//ī��Ʈ�ٿ��� ���۵� �ð�.
var myTime DurationTime;	//ī��Ʈ�ٿ� ���� �� �ð�. (�� �ʸ� ī��Ʈ�ٿ��� ���ΰ�)
var myTime curTime;			//���� �ð�
var string BattleName;      //��Ʋ �̸�

/*
	��(totalSec)�� �Է����� �޾�, �ð�/��/�ʷ� ���� myTime����ü(inTime)�� �־��ݴϴ�
*/
function SetTime(out myTime inTime, int totalSec)
{
	inTime.Hour = (totalSec/3600);
	inTime.Min = (totalSec/60)%60;
	inTime.Sec = (totalSec%60);
	return;
}

/*
	���� ������ �ð��� �����մϴ�.
*/
function GetCurrentTime(out myTime inTime)
{
    inTime.Hour = Level.Hour;
    inTime.Min = Level.Minute;
    inTime.Sec = Level.Second;
}

/*
	myTime Ÿ���� ����
*/
function myTime TimeSubtraction(myTime LTime, myTime RTime)
{
	local myTime result;
	result.Hour = LTime.Hour - RTime.Hour;
	result.Min = LTime.Min - RTime.Min;
	result.Sec = LTime.Sec - RTime.Sec;
	MakeValidTime(result);
    return result;
}

/*
  ���ڷ� ���� �ð��� ��ȿ������ �˻��ϰ�, ǥ�� ����(60��/60��)���� �ð��� ǥ���� �ݴϴ�.
  �ð����� ��ȿ���� ���� ���(���� ��)  false�� ��ȯ�մϴ�.
*/
function bool MakeValidTime(out myTime inTime)
{
	local bool bIsValid;
	local int modifier;
	bIsValid = true;
	if(InTime.Sec<0)
	{
		modifier = InTime.Sec/60 +1;
		InTime.Min -= modifier;
		InTime.Sec = 60*modifier + InTime.Sec;
	}
	if(InTime.Min<0)
	{
        modifier = InTime.Min/60 +1;
        InTime.Hour -= modifier;
        InTime.Min = 60*modifier + InTime.Min;
	}

	if(InTime.Hour<0)
	{
		//InTime.Hour = 0;
        //Log("CTimeDisplayer::MakeValidTime()!! Invalid Time!! Time value can't present negative number");
		bIsValid = false;
	}
	return bIsValid;
}

/*
	durationSec��ŭ Ÿ�̸Ӹ� �۵���ŵ�ϴ�.
	�� ��, �������� remainTime�� ���� �ð��� ����
	startTime�� Ÿ�̸Ӱ� ���� �ð��� �ǹ��մϴ�.
*/
function TimerStart(int durationSec)
{
	curTime.Hour = Level.Hour;
    curTime.Min = Level.Minute;
	curTime.Sec = Level.Second;
	startTime = curTime;
	SetTime(DurationTime, durationSec);
	bIsTimerOn = true;
}

function TimerEnd()
{
    bIsTimerOn = false;
}

/*
	�����ð�(remainTime)�� ���Ž����ݴϴ�.
	���� �ð��� 0�ϰ�� false�� �����ϸ�, �� ���� �޾� Ÿ�̸Ӱ� ����Ǵ� ���� ǥ���մϴ�.
*/
function bool TimerUpdate()
{
    local myTime gapTime;
    local myTime theTime;
    curTime.Hour = Level.Hour;
    curTime.Min = Level.Minute;
    curTime.Sec = Level.Second;
    gapTime = TimeSubtraction(curTime, startTime);
    theTime = TimeSubtraction(DurationTime, gapTime);
    remainTime = theTime;
    if(remainTime.Hour < 0 )
        return false;   //Ÿ�̸� ����.
    else
        return true;    //Ÿ�̸� �P��������
}

function SetBattleName(string battle)
{
    BattleName = battle;
}
function OnInit()
{
   //TimerStart(99995);
}

function OnPreRender(Canvas C)
{
}

function OnPostRender(HUD H, Canvas C)
{
    if(bIsTimerOn)
    {
        if(TimerUpdate()==false)
            TimerEnd();
        DrawTime(C, C.ClipX-10, 10, 2);
    }
}


/*
	�ð�(remainTime)�� DrawText�� �̿��Ͽ� �׷��ݴϴ�.
	�׷��� ��ġ�� (TopRightX, TopRightY)�� �������� �����������Ͽ� �׷��ݴϴ�.
	ScaleFactor��ŭ �����ϸ��Ͽ� �׷��ݴϴ�.
*/
function DrawTime(Canvas C, float TopRightX, float TopRightY, float ScaleFactor)
{
	local Font OldFont;
	local color OldColor;
	local string str_remainTime;
	local float XL_str;
    local float YL_str;
	local string strTemp;
	local float XL_temp;
	local float YL_temp;
    local float Scale_str;

	Scale_str = ScaleFactor;
	OldColor = C.DrawColor;
    OldFont = C.Font;
   	C.KTextFormat = ETextAlign.TA_MiddleRight;

	//1. ���� �ð��� ���� ǥ�� ���� ����
    if( (remainTime.Hour<1)&&(remainTime.Min<1) )
    {
        if(remainTime.Sec>30)
            C.SetDrawColor(243,225,15,255);//�����
        else
        {
        	if(remainTime.Sec<=10)
        		scale_str = scale_str*2;
            C.SetDrawColor(255,15,35,255); //�û��ǻ�
    }
    }
    else
    	C.SetDrawColor(255,255,255,255);

	//2. ���� �ð��� str�������� ����.
    if(remainTime.Hour>0)
        str_remainTime = remainTime.Hour$":"$remainTime.Min$":"$remainTime.Sec;
    else
    {
   		if( (remainTime.Min<1) && (remainTime.Sec <=10) )
			str_remainTime = string(remainTime.Sec);
		else
	    	str_remainTime = remainTime.Min$":"$remainTime.Sec;
    }

	C.Font = Font'FontEx.TrebLarge';
	C.TextSize(str_remainTime, XL_str, YL_str);
    C.SetPos(TopRightX-XL_str*Scale_str, TopRightY);  //TopRight���������� �����������Ͽ��׷���.
    C.DrawTextScaled(str_remainTime, true, scale_str, scale_str);

    /* ��ġ ������ ���ʿ� �� ���ִ� ���. */
    strTemp = BattleName;//"Waiting...";

    C.TextSize(strTemp, XL_temp, YL_temp);
    C.SetPos(TopRightX-XL_str*Scale_str-XL_temp*ScaleFactor/3-10, TopRightY);  //TopRight���������� �����������Ͽ��׷���.
    C.DrawTextScaled(strTemp, true, ScaleFactor/3, ScaleFactor/3);//ScaleFactor, ScaleFactor);
	//C.DrawKoreanText(strTemp, TopRightX-XL_str*ScaleFactor/3, TopRightY, 16, 15);
	/* ��� �� */
	C.DrawColor = OldColor;
    C.Font = OldFont;
}


/*
���� ����� �ְ� �ȴٸ� ����սô�.
var texture ATexture;
//2D �������̽��� �׷��� �̹���(sprite) ����ü.
struct SpriteImage
{
	var texture Texture;
	var float U;        //������(x���ǹ�)
	var float V;        //������(y���ǹ�)
	var float UL;       //�ؽ��� ����(���ǹ�)
	var float VL;       //�ؽ��� ����(�����ǹ�)
};
function SetSpriteTexture(OUT SpriteImage Sprite, Texture Texture)
{
	Sprite.Texture = Texture;
}
function SetSpriteScale(OUT SpriteImage Sprite, float U_in, float V_in, float UL_in, float VL_in)
{
	Sprite.U = U_in;
	Sprite.V = V_in;
    Sprite.UL = UL_in;
  	Sprite.VL = VL_in;
}
function DrawUnitSprite(Canvas C, SpriteImage Sprite, float X, float Y, float XL, float YL)
{
	local Texture Texture;
	C.SetPos(X,Y);
	Texture = Sprite.Texture;
	C.DrawTile(Texture,XL,YL,Sprite.U,Sprite.V,Sprite.UL,Sprite.VL);
}
function DrawUnitSprite(Canvas C, SpriteImage Sprite, float X, float Y, float XL, float YL)
{
	local Texture Texture;
	C.SetPos(X,Y);
	Texture = Sprite.Texture;
	C.DrawTile(Texture,XL,YL,Sprite.U,Sprite.V,Sprite.UL,Sprite.VL);
}
*/

//function Layout(Canvas C){}

//function NotifyComponent(int CmpId,int NotifyId,optional string Command){ }

//function SetPagePosition(float x, float y){ }

defaultproperties
{
}

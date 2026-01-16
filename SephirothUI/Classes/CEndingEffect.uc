//-----------------------------------------------------------
//Class for Team Battle Ending Effect
//      -Sinhyub. 2010.1.6
//-----------------------------------------------------------
class CEndingEffect extends CInterface;

//���� ����Ʈ�� ���� ����ü(PlayerController.uc)
/*enum EMusicTransition
{
	MTRAN_None,
	MTRAN_Instant,
	MTRAN_Segue,
	MTRAN_Fade,
	MTRAN_FastFade,
	MTRAN_SlowFade,
};
*/
//���� ���
enum EBattleEnding{
    BE_DRAW,
    BE_WIN,
    BE_LOSE,
    BE_OUT,
    BE_NONE,
};
//�ð��� ǥ������ ����ü
struct myTime
{
	var int Hour;
    var int Min;
    var int Sec;
    var int mSec;
};
//ȿ�� �̹���
struct SpriteImage
{
	var texture Texture;
	var float U;        //������(x���ǹ�)
	var float V;        //������(y���ǹ�)
	var float UL;       //�ؽ��� ����(���ǹ�)
	var float VL;       //�ؽ��� ����(�����ǹ�)
};

// ����Ʈ �ؽ��� �׷��� �κ� ������ (���ҽ��� �ִ� ������� �ǻ������ Ŀ�� ����� ����մϴ�)
const WIN_UL = 400;// = 3785;
const WIN_VL = 165;
const DRAW_UL = 460;
const DRAW_VL = 150;
const LOSE_UL = 370;
const LOSE_VL = 145;
const OVER_UL = 850;
const OVER_VL = 190;
const READY_UL = 495;
const READY_VL = 210;

var EBattleEnding BattleEndingType;

/* ����Ʈ�� ���� �ؽ��� */
var bool bIsEffectOn;
var texture ATexture;     //���� ��� ǥ�ÿ� ����� �ؽ���  (����� ���� �ٸ�)
var SpriteImage ASprite;  //          -             ��������Ʈ
var texture BTexture;     //Game Over�� ǥ���� �ؽ���. (����)
var SpriteImage BSprite;  //          - ��������Ʈ

/* ����Ʈ�� ���� �ð� */
var myTime StartTime;		//����Ʈ�� ���۵� �ð�.
var myTime DurationTime;	//����Ʈ�� ���� �� �� �ð�. (�� �ʸ� ī��Ʈ�ٿ��� ���ΰ�)
var myTime EffectTime;		//���� ����Ʈ�� ����� �ð�. (�� ���� ��ġ�� �ִ°��ΰ�)

var bool bIsSoundOn;
var string effectMusic;
var bool bIsWaiting;

const WaitTime = 4000;		//����Ʈ�� ���۵Ǳ� ���� ��ٸ��� �ð�.( ������ �̵��� ���, ȭ����ȯ�� �Ͼ����� ��ٷ�����Ѵ�.)

/***********************
// ��������Ʈ(2D����Ʈ)�� �׷��ֱ� ���� �Լ� ����
***********************/
function SetSpriteTexture(OUT SpriteImage Sprite, Texture Texture)
{
	Sprite.Texture = Texture;
}
//��������Ʈ �׷��� �κ��� ���� .( �ؽ����̹����� �κ��� ����)
function SetSpriteScale(OUT SpriteImage Sprite, float U_in, float V_in, float UL_in, float VL_in)
{
	Sprite.U = U_in;
	Sprite.V = V_in;
    Sprite.UL = UL_in;
  	Sprite.VL = VL_in;
}
function DrawUnitSprite(Canvas C, SpriteImage Sprite, float X, float Y, float XL, float YL)
{
	local Texture theTexture;
	C.SetPos(X,Y);
	thetexture = Sprite.Texture;
	C.DrawTile(theTexture,XL,YL,Sprite.U,Sprite.V,Sprite.UL,Sprite.VL);
}


/*************************
// ��ȭ�� �ֱ����� ���ڷ� �ð�(MyTime)�� ����մϴ�.
// �̸� ���� �Լ� ����
*************************/

//�и� ��(totalMSec)�� �Է����� �޾�, �ð�/��/��/�и��ʷ� ���� myTime����ü(inTime)�� �־��ݴϴ�
function SetTime(out myTime inTime, int totalMSec)
{
	inTime.Hour = (totalMSec/3600000);
	inTime.Min = (totalMSec/60000)%60;
	inTime.Sec = (totalMSec/1000)%60;
	inTime.mSec= (totalMSec%1000);
	return;
}
// ���� ������ �ð��� �����մϴ�.
function GetCurrentTime(out myTime inTime)
{
    inTime.Hour = Level.Hour;
    inTime.Min = Level.Minute;
    inTime.Sec = Level.Second;
    inTime.mSec= Level.MilliSecond;
}
// myTime Ÿ���� ����
function myTime TimeSubtraction(myTime LTime, myTime RTime)
{
	local myTime result;
	result.Hour = LTime.Hour - RTime.Hour;
	result.Min = LTime.Min - RTime.Min;
	result.Sec = LTime.Sec - RTime.Sec;
	result.mSec = LTime.mSec - RTime.mSec;
	MakeValidTime(result);
    return result;
}
// ���ڷ� ���� �ð��� ��ȿ������ �˻��ϰ�, ǥ�� ����(60��/60��)���� �ð��� ǥ���� �ݴϴ�.
// �ð����� ��ȿ���� ���� ���(���� ��)  false�� ��ȯ�մϴ�.
function bool MakeValidTime(out myTime inTime)
{
	local bool bIsValid;
	local int modifier;
	bIsValid = true;
	if(InTime.mSec<0)
	{
	    modifier = InTime.mSec/1000 +1;
	    InTime.Sec -= modifier;
	    InTime.mSec = 1000*modifier + InTime.mSec;
	}

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
// myTime��ü�� �޾� msec���θ� ǥ���� �ð��� ��ȯ�մϴ�
// ��, ����Ʈ ��ȭ�� ����� ����(t)�� ������ݴϴ�.
function int get_t(myTime aTime)
{
    return ( aTime.Hour*3600000 + aTime.Min*60000 + aTime.Sec*1000 + aTime.mSec );
}

/********************
// ����Ʈ�� �����ϴ� �Լ� ����
*********************/
//    Duration_Time(millisecond)��ŭ ����Ǵ� ����Ʈ�� �����ϵ��� �ʱ�ȭ�մϴ�.
function EffectStart(int duration_time)
{
    GetCurrentTime(StartTime);
    SetTime(DurationTime, duration_time);
	EffectUpdate();
	bIsEffectOn = true;
	bIsSoundOn = true;
	bIsWaiting = true;
}
// ����Ʈ�� ����Ǹ� ����� �� �ֵ��� ����(�ð�)�� ��������ݴϴ�.
//  ����Ʈ�� ��� ����ǰ����� ��� true��ȯ
//  ����Ʈ�� ������ ��� false ��ȯ. (EffectEndȣ�����ֵ��� �ؾ��մϴ�)
function bool EffectUpdate()
{
    local myTime curTime;
	local int t_effect;
	local int t_duration;

    GetCurrentTime(curTime);
    EffectTime = TimeSubtraction(curTime, StartTime);
	t_effect = Get_t(EffectTime);
	t_duration = Get_t(DurationTime);

    //������ �̵��ϰԵǸ� Ŭ���̾�Ʈ�� ������� �ð��� �ʿ��ϹǷ� ��ٷ��� �� ����.
    //��ٸ��� �ʰ� �����ϸ�, �̵� ���� � ȭ�鿡 �� ����Ʈ�� ���۵ǹ���. -2010.1.6.
    // -> ��ȹ�� ����Ǿ� ������ �̵��ϴ� ��찡 ������ �ʽ��ϴ�.          -2010.1.11.
    // -> ��� GameOver�޽����� �߰��ϰ� �Ǿ�, bIsWaiting ���� GameOver�� ����ϰ�,
    // -> ���Ŀ� ����޽����� ����մϴ�.
	if(bIsWaiting && (t_effect > WaitTime))
	{
	    bIsWaiting = false;
	    GetCurrentTime(StartTime);
        PlayerOwner.ClientSetMusic(effectMusic, MTRAN_SlowFade);   //BGM����
        EffectUpdate();
    }

    if( bIsSoundOn && ((t_effect > 11000) || (t_effect < 0) ))
    {//ȿ���� ����. ��� 11��
	    PlayerOwner.ClientSetMusic("", MTRAN_SlowFade);
	    bIsSoundOn = false;
    }

	if(t_effect > t_duration)
        return false;           //����Ʈ ��
    return true;            //����Ʈ ���
}
function EffectEnd()
{
    bIsEffectOn = false;
    //���� ���Ƿν� BGM���� ����
    if( bIsSoundOn )
    {
	    PlayerOwner.ClientSetMusic("", MTRAN_SlowFade);
	    bIsSoundOn = false;
    }
    ConsoleCommand("MUSIC");
}
function EffectDraw(Canvas C)
{
    if(bIsWaiting){//Game Over�� ���
         Effect_over(C);
    }
    else{    //���� ��� ����Ʈ ����
        switch(BattleEndingType)
        {
        case EBattleEnding.BE_WIN:
             Effect_win(C);
             break;
        case EBattleEnding.BE_LOSE:
             Effect_lose(C);
             break;
        case EBattleEnding.BE_DRAW:
              Effect_draw(C);
              break;
        case EBattleEnding.BE_NONE:
             //
              break;
        }
    }
}
function EffectSet(int result)//EBattleEnding EndingType)
{
    switch(result)
    {
        case 0: BattleEndingType = EBattleEnding.BE_DRAW; break;
        case 1: BattleEndingType = EBattleEnding.BE_WIN; break;
        case 2: BattleEndingType = EBattleEnding.BE_LOSE; break;
        case 3: BattleEndingType = EBattleEnding.BE_OUT; break;
    }
	//1. ����� ���� Ending Effect����
    switch(BattleEndingType)
    {
    case EBattleEnding.BE_WIN:
         ATexture = Texture(DynamicLoadObject("UI_2009.WIN1",class'Texture'));
         effectMusic = "Ending_Win.ogg";
         //PlayerOwner.ClientSetMusic("Ending_Win.ogg", MTRAN_Fade);   //BGM����
         break;
    case EBattleEnding.BE_LOSE:
         ATexture = Texture(DynamicLoadObject("UI_2009.LOSE1",class'Texture'));
         effectMusic = "Ending_Lose.ogg";
         //PlayerOwner.ClientSetMusic("Ending_Lose.ogg", MTRAN_Fade);
         break;
    case EBattleEnding.BE_DRAW:
         ATexture = Texture(DynamicLoadObject("UI_2009.DRAW1",class'Texture'));
         //SetSpriteScale(ASprite,0,0,0,ATexture.VSize);
         effectMusic = "";
         //PlayerOwner.ClientSetMusic("", MTRAN_Fade);
         break;
    case EBattleEnding.BE_NONE:
         ATexture = none;
         effectMusic = "";
         break;     //
    }
    ATexture.bAlphaTexture = true;
    SetSpriteTexture(ASprite, ATexture);

	//2. GameOver ��������Ʈ ����
    BTexture = texture(dynamicLoadObject("UI_2009.GAMEOVER",class'Texture'));
    BTexture.bAlphaTexture= true;
    SetSpriteTexture(BSprite, BTexture);
}
//�������Ḧ �˸��� ȿ��
function Effect_over(Canvas C)
{
   	local color OldColor;
   	local int t;
	local int t_alpha;
	local float t_UL;
	local float t_VL;
	local float t_X;
	local float t_Y;

   	t = get_t(EffectTime);
	//Alpha ����-����������
	t_alpha = t*t/3000+20;
	if(t_alpha>245)
		t_alpha = 245;

    t_UL = OVER_UL;
    t_VL = OVER_VL;
	//Texture ��ġ ���� - ȭ�� �߾�
    t_X = (C.ClipX-OVER_UL)/2;
    t_Y = (C.ClipY-OVER_VL)/2-200;

    OldColor = C.DrawColor;

    // �� ���� ����ȿ��
    C.SetDrawColor(255,255,255,64);
    //SetSpriteScale(Asprite,0,0,t_UL,t_VL);
    DrawUnitSprite(C,BSprite,t_X-8,t_Y-8,t_UL+16,t_VL+16);
    DrawUnitSprite(C,BSprite,t_X-5,t_Y-5,t_UL+10,t_VL+10);
    DrawUnitSprite(C,BSprite,t_X-3,t_Y-3,t_UL+6,t_VL+6);
    DrawUnitSprite(C,BSprite,t_X-2,t_Y-2,t_UL+4,t_VL+4);

    C.SetDrawColor(255,255,255,t_alpha);
    SetSpriteScale(Bsprite,0,0, t_UL, t_VL);
    DrawUnitSprite(C,BSprite,t_X, t_Y, t_UL, t_VL);
    C.DrawColor = OldColor;
}
//�̱� ����� ȿ��
function Effect_win(Canvas C)
{
   	local color OldColor;
   	local int t;
	local int t_alpha;
	local int t_alpha2;
	local float t_UL;
	local float t_VL;
	local float t_X;
	local float t_Y;
	local float t_XL;
	local float t_YL;
	local float t_per;

    local float t_Climax_begin;
    local float t_Climax;
    t_Climax_begin = 2300;
    t_Climax = 2400;

    OldColor = C.DrawColor;
   	t = get_t(EffectTime);
	//Alpha ����-����������
	if(t<10000)
	{
        t_alpha = t*t/10000+30;
        if(t_alpha>255)
            t_alpha = 255;
	}
	else
	{
        t_alpha = 255-0.045*(t-10000);//(t-10000)*(t-10000)*0.0064;
        if((t_alpha < 0))
            t_alpha = 0;
    }

    //�׷��� �ؽ��� �κ� - ���� ��ü �׷���
	t_UL = WIN_UL;//ASprite.Texture.USize;
	t_VL = WIN_VL;//ASprite.Texture.VSize;

    SetSpriteScale(Asprite,0,0,t_UL,t_VL);

	//�׷��� ��������Ʈ ũ�� - ���� Ŀ�� (t_Climax �� �� �����̿�����)
	if(t<t_Climax_begin) // 1/4 ũ�� ��ŭ�� �� �ӵ��� �׷���
        t_per = (t*t)/4/t_Climax_Begin/t_Climax_Begin;//(t*t)/16000000;// t_per = (t*t)/(t_Climax_Begin*t_Climax_Begin)
    else if(t<t_Climax) //���� �κ� ���� 4/4ũ�Ⱑ �ɶ����� ������ ����. (Climax ����)
    {
        t_per = (0.75*(t-t_Climax_begin))/(t_Climax-t_Climax_begin) + 0.25;
    }
    else if(t>=t_Climax) //Climax ���ĺ��ʹ� õõ�� ����. (�ܻ��� ���� �κ�)
    {
        t_per = 1 - (t*t+t_Climax*t_Climax) / (t_Climax+1600) / (-6400);
    }

    /*
    if((t>t_Climax_Begin)&&(t<t_Climax))
    {
        t_per = 4*t+0.75-4*t_Climax_Begin;
    }
    else
    {
        t_per = (t*t)/(t_Climax_Begin*t_Climax_Begin)*0.75;
    }
    */

    t_XL = (WIN_UL * t_per);
    t_YL = (WIN_VL * t_per);

	//�׷��� ��ġ ���� - ���� Ŀ���� ����
    t_X=(C.ClipX-t_XL)/2;
    t_Y=(C.ClipY-t_YL)/2-200;

    // Ŭ���̸��� ������ �ܻ��� �׷���
    if(t>t_Climax && t<t_Climax+2800)
    {
        t_alpha2 = 115-0.040*(t-t_Climax);//135-0.045*(t-t_Climax);
        if(t_alpha2<0)
            t_alpha2 = 0;
        C.SetDrawColor(255,255,255,t_alpha2);
        //SetSpriteScale(Asprite,0,0,t_UL,t_VL);
        DrawUnitSprite(C,ASprite,t_X,t_Y,t_XL,t_YL);
        C.DrawColor = OldColor;
    }

    // �� ���� �׷���
    if(t_XL>WIN_UL)
    {
        t_XL = WIN_UL;
        t_X=(C.ClipX-t_XL)/2;
    }
    if(t_YL>WIN_VL)
    {
        t_YL = WIN_VL;
        t_Y = (C.ClipY-t_YL)/2-200;
    }


    // �� ���� ����ȿ��
    if(t>=t_Climax)// && t<t_Climax+2800)
    {
        t_alpha2 = 64;//-0.040*(t-t_Climax);//135-0.045*(t-t_Climax);
        if(t_alpha2<0)
            t_alpha2 = 0;
        C.SetDrawColor(255,255,255,t_alpha2);
        //SetSpriteScale(Asprite,0,0,t_UL,t_VL);
        DrawUnitSprite(C,ASprite,t_X-8,t_Y-8,t_XL+16,t_YL+16);
        DrawUnitSprite(C,ASprite,t_X-5,t_Y-5,t_XL+10,t_YL+10);
        DrawUnitSprite(C,ASprite,t_X-3,t_Y-3,t_XL+6,t_YL+6);
        DrawUnitSprite(C,ASprite,t_X-1,t_Y-1,t_XL+4,t_YL+4);
        C.DrawColor = OldColor;
    }


    C.SetDrawColor(255,255,255,t_alpha);
   // SetSpriteScale(Asprite,0,0, t_UL, t_VL);
    DrawUnitSprite(C,ASprite, t_X, t_Y, t_XL, t_YL);
    C.DrawColor = OldColor;

}
//��� ����� ȿ��
function Effect_draw(Canvas C)
{
   	local color OldColor;
   	local int t;
	local int t_alpha;
	local float t_UL;
	local float t_VL;
	local float t_X;
	local float t_Y;


   	t = get_t(EffectTime);
	//Alpha ����-����������
	t_alpha = t*t/80000+20;
	if(t_alpha>235)
		t_alpha = 235;
	//Texture ũ�� ����-���������� ����������
	t_VL = t*t/70000;
	if(t_VL>DRAW_VL)
		t_VL=DRAW_VL;
	T_UL = DRAW_UL;
	//Texture ��ġ ���� - ȭ�� �߾�
    t_X = (C.ClipX-DRAW_UL)/2;
    t_Y = (C.ClipY-DRAW_VL)/2-200;

    OldColor = C.DrawColor;
/*
    // �� ���� ����ȿ��
    C.SetDrawColor(255,255,255,64);
    //SetSpriteScale(Asprite,0,0,t_UL,t_VL);
    DrawUnitSprite(C,ASprite,t_X-8,t_Y-8,t_UL+16,t_VL+16);
    DrawUnitSprite(C,ASprite,t_X-5,t_Y-5,t_UL+10,t_VL+10);
    DrawUnitSprite(C,ASprite,t_X-3,t_Y-3,t_UL+6,t_VL+6);
    DrawUnitSprite(C,ASprite,t_X-2,t_Y-2,t_UL+4,t_VL+4);
*/
    C.SetDrawColor(255,255,255,t_alpha);
    SetSpriteScale(Asprite,0,0, t_UL, t_VL);
    DrawUnitSprite(C,ASprite,t_X, t_Y, t_UL, t_VL);
    C.DrawColor = OldColor;
}
//�� ����� ȿ��
function Effect_lose(Canvas C)
{
   	local color OldColor;
   	local int t;
	local int t_alpha;
	local float t_UL;
	local float t_VL;
	local float t_X;
	local float t_Y;

   	t = get_t(EffectTime);
    if(t<8000)
    { 	//Alpha ����-����������
        t_alpha = t*t/30000+20;
        if(t_alpha>255)
            t_alpha = 255;
    }
	else
	{   //������ �����.
	     t_alpha = 255 - (t-8000)*0.045;
	     if( (t_alpha<0) )     //�ð��� Ŀ�� t_alpha�� �����Ⱚ�̵���� ����
	         t_alpha = 0;
    }

	t_UL = LOSE_UL;
	t_VL = LOSE_VL;

	//�׷��� ��ġ ����-������ ������
    t_X=(C.ClipX-LOSE_UL)/2;
    t_Y=t*t/40000-50;

    if(t_Y> (C.ClipY/2)-300)
            t_Y=C.ClipY/2-300;

    OldColor = C.DrawColor;

    // �� ���� ����ȿ��
    C.SetDrawColor(255,255,255,64);
    //SetSpriteScale(Asprite,0,0,t_UL,t_VL);
    DrawUnitSprite(C,ASprite,t_X-8,t_Y-8,t_UL+16,t_VL+16);
    DrawUnitSprite(C,ASprite,t_X-5,t_Y-5,t_UL+10,t_VL+10);
    DrawUnitSprite(C,ASprite,t_X-3,t_Y-3,t_UL+6,t_VL+6);
    DrawUnitSprite(C,ASprite,t_X-1,t_Y-1,t_UL+4,t_VL+4);

    C.SetDrawColor(255,255,255,t_alpha);
    SetSpriteScale(Asprite,0,0, t_UL, t_VL);
    if(t<13500)
        DrawUnitSprite(C,ASprite, t_X, t_Y, t_UL, t_VL);
    C.DrawColor = OldColor;
}

function OnInit();
function OnPreRender(Canvas C);
function OnPostRender(HUD H, Canvas C)
{
    if(bIsEffectOn)
    {
        if(EffectUpdate())
            EffectDraw(C);
        else{
            EffectEnd();
            HideInterface();
        }
    }
}

defaultproperties
{
}

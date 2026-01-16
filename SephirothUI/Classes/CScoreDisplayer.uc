//-----------------------------------------------------------
// ��Ʋ�ý����� ���� Ŭ�����Դϴ�.
// ���� �� ��Ʋ ���� ��Ȳ�� ���÷����� �ݴϴ�.
//-----------------------------------------------------------
class CScoreDisplayer extends CInterface;

//ȿ�� �̹���
struct SpriteImage
{
	var texture Texture;
	var float U;        //������(x���ǹ�)
	var float V;        //������(y���ǹ�)
	var float UL;       //�ؽ��� ����(���ǹ�)
	var float VL;       //�ؽ��� ����(�����ǹ�)
};
/*

//�� ����
struct TeamInfo
{
    var string TeamName;
    var int Score;
    //var SpriteImage TeamSymbol;
};
*/

//var TeamInfo TeamA;
//var TeamInfo TeamB;

var int ScoreA;
var int ScoreB;

var SpriteImage SymbolA;
var SpriteImage SymbolB;
var SpriteImage Spliter;

const Symbol_XL = 60;
const Symbol_YL = 60;
const Symbol_UL = 48;
const Symbol_VL = 48;
const Spliter_UL = 16;
const Spliter_VL = 16;

//var TextureA;
//var TextureB;

/*
function SetTeamInfo(TeamInfo theTeam, string theTeamName, string theTeamSymbol, int theScore)
{
    theTeam.TeamName = theTeamName;
//	if(theTeamSymbol != "")
//		SetTeamSymbol(theTeam, theTeamSymbol);
    theTeam.Score = theScore;
}
*/
/*
//���ϰ�θ��� �ָ� symbol �����ϵ��� �ϴ°��� ���ڴ�.
function SetTeamSymbol(TeamInfo theTeam, SpriteImage theTeamSymbol)
{
    theTeam.TeamSymbol = theTeamSymbol;
}
function SetTeamName(TeamInfo theTeam, string theTeamName)
{
    theTeam.TeamName = theTeamName;
}
*/
function SetScore(int Score_TeamA, int Score_TeamB)
{
    //Log("SetScore TEAMA:"$Score_TeamA@"TEAMB"$Score_TeamB);
 //   TeamA.Score = Score_TeamA;
 //   TeamB.Score = Score_TeamB;
	ScoreA = Score_TeamA;
	ScoreB = Score_TeamB;
    //Log("SetScore TeamA.Score:"$ScoreA@"TEAMB"$ScoreB);
}

function SetTeamName(string name_TeamA, string name_TeamB)
{
}

function SetTeamSymbol(string Symbol_TeamA, string Symbol_TeamB)
{
}



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

function DrawScore(Canvas C, float TopCenterX, float TopCenterY, float ScaleFactor)
{
    local Font OldFont;
    local color OldColor;
    local string str_scoreA;
    local float A_XL;
    local float A_YL;
    local string str_scoreB;
    local float B_XL;
    local float B_YL;
    local string strVS;
    strVS = ":";

	OldColor = C.DrawColor;
    OldFont = C.Font;

    //���� �׷��ش�.
    str_scoreA = string(ScoreA);
    str_scoreB = string(ScoreB);
	C.Font = Font'FontEx.TrebLarge';          //TrebLarge

	C.TextSize(str_scoreA, A_XL, A_YL);
	C.TextSize(str_scoreB, B_XL, B_YL);

	//A�� ����, B�� ����
	C.SetDrawColor(235,235,235,255);
   	C.KTextFormat = ETextAlign.TA_MiddleCenter;
    C.SetPos(TopCenterX-A_XL*ScaleFactor-Spliter_UL/2-10,TopCenterY+Symbol_YL);
	C.DrawTextScaled(str_scoreA, true, ScaleFactor, ScaleFactor);
	C.SetPos(TopCenterX+Spliter_UL/2+10,TopCenterY+Symbol_YL);
	C.DrawTextScaled(str_scoreB, true, ScaleFactor, ScaleFactor);

    //A�� �ؽ���, B�� �ؽ���
    SetSpriteScale(SymbolA,0,0,Symbol_UL,Symbol_VL);
    C.SetDrawColor(255,255,255,255);
    DrawUnitSprite(C,SymbolA, TopCenterX-Symbol_XL-Spliter_UL/2-10, TopCenterY,Symbol_XL,Symbol_YL);
    SetSpriteScale(SymbolB,0,0,Symbol_UL,Symbol_VL);
    DrawUnitSprite(C,SymbolB,TopCenterX+Spliter_UL/2+10, TopCenterY,Symbol_XL,Symbol_YL);

    //Spliter �׸���
    SetSpriteScale(Spliter, 0, 0, Spliter_UL, Spliter_VL);
    Spliter.Texture.bAlphaTexture = true;
    C.SetDrawColor(255,255,255,255);
    C.SetPos(TopCenterX-Spliter_UL/2,TopCenterY+Symbol_YL+21);
    C.DrawTile(Spliter.Texture,Spliter_UL,2*Spliter_VL,0,0,Spliter_UL,2*Spliter_VL);
//    DrawUnitSprite(C,Spliter, TopCenterX-Spliter_UL/2, TopCenterY+Symbol_YL, Spliter_UL, Symbol_YL);

/*
    ���ھ� ���̰� ���̳��� ���ھ� ���� ��ȭ���Ѻ���
    if( (remainTime.Hour<1)&&(remainTime.Min<1) )
    {
        if(remainTime.Sec>30)
            C.SetDrawColor(243,225,15,255);//�����
        else
            C.SetDrawColor(255,15,35,255); //�û��ǻ�
    }
    else
    	C.SetDrawColor(255,255,255,255);
*/
    C.DrawColor = OldColor;
    C.Font = OldFont;
}
function OnInit()
{
     //SetTeamInfo(TeamA, "BlackCat", "", 10);
     //SetTeamInfo(TeamB, "WhiteEagle", "", 2);
     SymbolA.Texture = Texture(DynamicLoadObject("Marks.BlackCatL",class'Texture'));
     SymbolB.Texture = Texture(DynamicLoadObject("Marks.WhiteEagleL",class'Texture'));
     Spliter.Texture = texture(DynamicLoadObject("UI_2009.BTN06_12_N",class'Texture'));
}
function OnPreRender(Canvas C)
{
	 DrawScore(C, C.ClipX/2, 10, 1.5);
}
function OnPostRender(HUD H, Canvas C)
{
//    DrawScore(C, C.ClipX/2, 0, 2);
}

defaultproperties
{
}

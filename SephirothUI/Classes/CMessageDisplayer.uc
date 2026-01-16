//-----------------------------------------------------------
// 팀 베틀을 위한 클래스입니다.
// 팀 배틀 메시지를 출력해주는 인터페이스
// Kill/Death 이벤트가 발생할 경우 이를 텍스트로 띄워줍니다.
//-----------------------------------------------------------
class CMessageDisplayer extends CInterface;

var int curIndex;
const maxIndex = 3;     //메시지 리스트의 크기
const expireTime = 8;  //8초가 지난 메시지는 유효하지 않습니다.

//생성시에는 꼭 SetMessageObject를 이용하도록 합니다.
//SetMessageObject에서 OccuredTime을 입력합니다.
struct MessageObject
{
    var bool IsValid;           // 메시지가 유효한가. (expireTime-4초-가 지난 메시지는 그려주지 않습니다.)
    var float OccuredTime;      // 메시지 발생한 시간. (Level.TimeSeconds)
    var string Killer_Name;
    var string Killer_Team;
    var string Deader_Name;
    var string Deader_Team;
};

//var array<string> MessageList;
var array<MessageObject> MessageList;
var string TeamNameA;
var string TeamNameB;
var texture SymbolA;
var texture SymbolB;
var texture finalSkill;

const Symbol_UL = 24;
const Symbol_VL = 24;

function OnInit()
{
    local int i;
    curIndex = 0;
     //초기화 와함께 생성.
    for( i =0; i<maxIndex; i++)
         MessageList.Insert(0,MaxIndex);
    for(i=0; i<maxIndex; i++)
        MessageList[i].IsValid = false;
    SymbolA = texture(DynamicLoadObject("Marks.WhiteEagle",class'Texture'));
    SymbolB = texture(DynamicLoadObject("Marks.BlackCat",class'Texture'));
    finalSkill = texture(DynamicLoadObject("UI_2009.BTN_ShopSB_notout_O",class'Texture'));
    SymbolA.bAlphaTexture = true;
    SymbolB.bAlphaTexture = true;
    finalSkill.bAlphaTexture = true;
}

function SetTeamName(string teamA, string teamB)
{
    TeamNameA = teamA;
    TeamNameB = teamB;
}
function SetMessageList(int theIndex, MessageObject theObject)
{
    MessageList[theIndex].Killer_Name = theObject.Killer_Name;
    MessageList[theIndex].Killer_Team = theObject.Killer_Team;
    MessageList[theIndex].Deader_Name = theObject.Deader_Name;
    MessageList[theIndex].Deader_Team = theObject.Deader_Team;
    MessageList[theIndex].OccuredTime = theObject.OccuredTime;
}
//메시지 오브젝트를 셋팅하여줍니다.
// IsCreate가 true일 경우 생성하는 경우로, 메시지가 생성된 시간을 저장하여줍니다.
// IsCreate가 false일 경우는 수정하는 경우로, OccuredTime은 수정되어서는 안됩니다.
function SetMessageObject(out MessageObject theObject, string kName, string kTeam, string dName, string dTeam, optional bool IsCreate)
{
    theObject.Killer_Name = kName;
    theObject.Killer_Team = kTeam;
    theObject.Deader_Name = dName;
    theObject.Deader_Team = dTeam;
    if(IsCreate)
    {
        theObject.IsValid = true;
        theObject.OccuredTime = Level.TimeSeconds;
    }
}
function UpdateMessageList()
{
    //리스트에서, 4초가 지난 메시지들은 폐기(?)시켜 줍니다.
    local int i;
    local float curTime;
    curTime = Level.TimeSeconds;
    for(i=0; i<maxIndex; i++)
    {
        if( (curTime-MessageList[i].OccuredTime)<expireTime )
            MessageList[i].IsValid = true;
        else
            MessageList[i].IsValid = false;
    }
}
//메시지 리스트(array)에 메시지 하나를 추가시킵니다.
//단, 새로생성된 메시지가 아래에서부터 그려질 수 있도록, curIndex를 조작하여줍니다.
function PushMessageList(string KillerName, string KillerTeam, string DeaderName, string DeaderTeam)//(MessageObject theMessage)
{
    local MessageObject newMessage;
    curIndex = (curIndex+1)%maxIndex;
    SetMessageObject(newMessage, KillerName, KillerTeam, DeaderName, DeaderTeam, true);
    SetMessageList(curIndex, newMessage);
}

/*
function string GetKillerName(int theIndex)
{
    return MessageList[theIndex].Killer_Name;
}
function string GetKillerTeam(int theIndex)
{
    return MessageList[theIndex].Killer_Team;
}
function string GetDeaderName(int theIndex)
{
    return MessageList[theIndex].Deader_Name;
}
function string GetDeaderTeam(int theIndex)
{
    return MessageList[theIndex].Deader_Team;
}
*/

function DrawMessageObject(Canvas C, MessageObject theObject, float TopLeftX, float TopLeftY)
{
    local Font OldFont;
    local color OldColor;
    local string theKiller;
    local string theDeader;
    local float k_XL;
    local float k_YL;
    local float d_XL;
    local float d_YL;
    local float Alpha;     //텍스트가 4초이후엔 사라지도록합니다.

    OldColor = C.DrawColor;
    OldFont = C.Font;
    C.KTextFormat = ETextAlign.TA_MiddleLeft;

    theKiller = theObject.Killer_Name;
    theDeader = theObject.Deader_Name;
    Alpha = 255-(Level.TimeSeconds-theObject.OccuredTime)*(255/expireTime);        // 63 = (255/4)
    if(Alpha>255)
        Alpha = 255;
    else if(Alpha<0)
        Alpha = 0;

    C.Font = Font'FontEx.TrebLarge';          //TrebLarge
    C.TextSize(theKiller, k_XL, k_YL);
    C.TextSize(theDeader, d_XL, d_YL);
    //죽인사람을 그리고
    if( theObject.Killer_Team == TeamNameA )
        C.SetDrawColor(80,245,241,Alpha); //시뻘건색
    else// if( theObject.Killer_Team == TeamNameB )
        C.SetDrawColor(248,64,18,Alpha); //시퍼런색
    C.SetPos(TopLeftX, TopLeftY);
    C.DrawTextScaled(theKiller, true, 1, 1);
    //죽은사람을 그리고
    if( theObject.Deader_Team == TeamNameA )
        C.SetDrawColor(80,245,241,Alpha); //시뻘건색
    else if( theObject.Deader_Team == TeamNameB )
        C.SetDrawColor(248,64,18,Alpha); //시퍼런색
    C.SetPos(TopLeftX+k_XL+30, TopLeftY);
    C.DrawTextScaled(theDeader, true, 1, 1);
    //텍스쳐는 다음에
    //DrawUnitSprite(C, BlackCat.TeamSymbol, PageX
    C.DrawColor = OldColor;
    C.Font = OldFont;
}

function DrawMessageObjectKorean(Canvas C,MessageObject theObject, float TopLeftX, float TopLeftY)
{
    local Font OldFont;
    local color OldColor;
    local string theKiller;
    local string theDeader;
    local float k_XL;
    local float k_YL;
    local float d_XL;
    local float d_YL;
    local float Alpha;     //텍스트가 4초이후엔 사라지도록합니다.

    OldColor = C.DrawColor;
    OldFont = C.Font;
    C.KTextFormat = ETextAlign.TA_MiddleLeft;

    theKiller = theObject.Killer_Name;
    theDeader = theObject.Deader_Name;

    Alpha = 300-(Level.TimeSeconds-theObject.OccuredTime)*(300/expireTime);        // 63 = (255/4)
    if(Alpha>255)
        Alpha = 255;
    else if(Alpha<0)
        Alpha = 0;

    C.StrLen(theKiller, k_XL, k_YL);
    C.StrLen(theDeader, d_XL, d_YL);

	if(theKiller != "")	//로그아웃된 경우는 따로 메시지 출력합니다.
	{
    //죽인사람
    C.SetDrawColor(255,255,255,Alpha);
    C.SetPos(TopLeftX, TopLeftY);
    if( theObject.Killer_Team == TeamNameA )
    {
        C.DrawTile(SymbolA,12,12,0,0,Symbol_UL,Symbol_VL);
        C.SetDrawColor(0,0,0,Alpha);
        	C.DrawKoreanText(theKiller,TopLeftX+17,TopLeftY+1,k_XL,k_YL);
            C.SetDrawColor(248,64,18,Alpha);
    }
    else if( theObject.Killer_Team == TeamNameB )
    {
        C.DrawTile(SymbolB,12,12,0,0,Symbol_UL,Symbol_VL);
        C.SetDrawColor(0,0,0,Alpha);
        C.DrawKoreanText(theKiller,TopLeftX+17,TopLeftY+1,k_XL,k_YL);
            C.SetDrawColor(80,245,241,Alpha);
    }
    C.DrawKoreanText(theKiller,TopLeftX+16,TopLeftY,k_XL,k_YL);

    //마지막 공격 스킬을 그리고(현재는 그냥 칼표시로 예정)
    C.SetDrawColor(255,255,255,Alpha);
    C.SetPos(TopLeftX+k_XL+28,TopLeftY);
    C.DrawTile(finalSkill,12,12,0,0,30,30);

    //죽은사람
    C.SetDrawColor(255,255,255,Alpha);
    C.SetPos(TopLeftX+k_XL+48,TopLeftY);
    if( theObject.Deader_Team == TeamNameA )
    {
        C.DrawTile(SymbolA,12,12,0,0,Symbol_UL,Symbol_VL);
        C.SetDrawColor(0,0,0,Alpha);
        	C.DrawKoreanText(theDeader,TopLeftX+k_XL+69,TopLeftY+1,d_XL,d_YL);
            C.SetDrawColor(248,64,18,Alpha);
    }
    else if( theObject.Deader_Team == TeamNameB )
    {
        C.DrawTile(SymbolB,12,12,0,0,Symbol_UL,Symbol_VL);
        C.SetDrawColor(0,0,0,Alpha);
        C.DrawKoreanText(theDeader,TopLeftX+k_XL+69,TopLeftY+1,d_XL,d_YL);
            C.SetDrawColor(80,245,241,Alpha);
    }
    C.DrawKoreanText(theDeader,TopLeftX+k_XL+68,TopLeftY,d_XL,d_YL);
   	}
   	else
   	{
    	//비정상 종료
    	C.SetDrawColor(255,255,255,Alpha);
    	C.SetPos(TopLeftX+48,TopLeftY);
	    if( theObject.Deader_Team == TeamNameA )
	    {
        	C.DrawTile(SymbolA,12,12,0,0,Symbol_UL,Symbol_VL);
        	C.SetDrawColor(0,0,0,Alpha);
        	C.DrawKoreanText(theDeader@Localize("Match","AbnormalQuit","Sephiroth"),TopLeftX+69,TopLeftY+1,d_XL,d_YL);
            C.SetDrawColor(248,64,18,Alpha);
    	}
    	else if( theObject.Deader_Team == TeamNameB )
    	{
        	C.DrawTile(SymbolB,12,12,0,0,Symbol_UL,Symbol_VL);
        	C.SetDrawColor(0,0,0,Alpha);
            C.DrawKoreanText(theDeader@Localize("Match","AbnormalQuit","Sephiroth"),TopLeftX+69,TopLeftY+1,d_XL,d_YL);
            C.SetDrawColor(80,245,241,Alpha);
    	}
   		C.DrawKoreanText(theDeader,TopLeftX+68,TopLeftY,d_XL,d_YL);
   	}

    C.DrawColor = OldColor;
    C.Font = OldFont;
}

function DrawMessageList(Canvas C)
{
    local int i;
    local int tempIndex;

    // curIndex가 제일 마지막으로 도착한 메시지임을 유의해서 그려줌.
    for(i=0; i<maxIndex; i++)
    {
        tempIndex = (CurIndex+3-i)%maxIndex;
        if(MessageList[tempIndex].IsValid)
            //DrawMessageObject(C,MessageList[tempIndex],50,150-30*i);
            DrawMessageObjectKorean(C,MessageList[tempIndex],50,130-30*i);
    }
}
function OnPostRender(HUD H, Canvas C)
{
    UpdateMessageList();
    DrawMessageList(C);
}

defaultproperties
{
}

class QuestStepInfo	extends Object
	native;

var int		nQuestZone;			// 퀘스트 존 - 라디아네스, 베로스, 덕트 등..
var int		nQuestType;			// 퀘스트 타입 - 일반, 반복, 일일, 한정, 등등

var string	strQuestName;		// 퀘스트 이름 - 단지 표현하기 위한 스트링일 뿐
var string	strStepName;		// 퀘스트 스텝 이름 - 서버, SD등과 일치하는 메인 데이터임
var int		nStepValue;			// 퀘스트 스텝 값 - 현재 진행상태

var string	strRequireQuest;	// 선행퀘스트 이름
var int		nMinLevel;			// 가능한 레벨 하한
var int		nMaxLevel;			// 표시할 레벨 상한

var int		nRaceClass;			// 가능한 종족이나 직업

var string	strReceiveNPC;		// 퀘스트를 의뢰하는 NPC
var int		nReceiveSymbol;		// 의뢰 NPC에 표시할 기호
var string	strRewardNPC;		// 완료/보상받는 NPC
var int		nRewardSymbol;		// 완료 NPC에 표시할 기호
var string	strShortName;		// 지도 위치표시를 위한 이름

var string	strHudTitle;		// 허드용 타이틀
var string	strHudDesc;			// 허드용 설명
var int		nHudMax;			// 허드용 수집퀘스트 목표 요구치

defaultproperties
{
     nStepValue=99
     nMinLevel=1
     nMaxLevel=300
}

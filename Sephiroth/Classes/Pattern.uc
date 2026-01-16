class Pattern extends Object
	native;

var String	strKey;				// 아이디로 사용되는 패턴의 이름

// Effect
var String	strEffRes;			// 이펙트에 사용되는 리소스의 이름
var Name	strEffAttach;		// 이펙트를 붙이 본의 이름
var float	fEffDelay;			// 실행 시작하기 위한 딜레이 (초단위 소숫점 가능)
var float	fEffPlaying;		// 이펙트 플레이 시간 (초단위 소숫점 가능)
var int		nEffRepeat;			// 반복 횟수 (0 : 무한반복, 1 : 반복없음, n : n회 반복)
var float	fEffInterval;		// 반복 간격 (초단위 소숫점 가능)

// Animation
var Name	strAniRes;			// 애니메이션에 사용되는 리소스의 이름
var float	fAniDelay;			// 실행 시작하기 위한 딜레이 (초단위 소숫점 가능)
var float	fAniPlaying;		// 애니메이션에 사용되는 리소스의 이름
var int		nAniRepeat;			// 반복 횟수 (0 : 무한반복, 1 : 반복없음, n : n회 반복)
var float	fAniInterval;		// 반복 간격 (초단위 소숫점 가능)

// Sound
var String	strSndRes;			// 사운드에 사용되는 리소스의 이름
var float	fSndDelay;			// 실행 시작하기 위한 딜레이 (초단위 소숫점 가능)
var int		nSndRepeat;			// 반복 횟수 (0 : 무한반복, 1 : 반복없음, n : n회 반복)
var float	fSndInterval;		// 반복 간격 (초단위 소숫점 가능)

// Message
var String	strMsgRes;			// 메시지에 사용되는 리소스의 이름
var float	fMsgDelay;			// 실행 시작하기 위한 딜레이 (초단위 소숫점 가능)
var int		nMsgRepeat;			// 반복 횟수 (0 : 무한반복, 1 : 반복없음, n : n회 반복)
var float	fMsgInterval;		// 반복 간격 (초단위 소숫점 가능)

// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)

defaultproperties
{
     strEffRes="None"
     strEffAttach="'"
     fEffDelay=1.000000
     fEffPlaying=1.000000
     nEffRepeat=1
     fEffInterval=99.000000
}

class CPositionInfo extends Object
	config(PosInfo);

struct _PosData
{
	var string sName;
	var vector vPos;	// x, y 는 좌표고 z 는 타입 (타입에 따라서 포인트 or 영역으로 표현)
};

var config array<_PosData> m_arPosList;

function vector Find(string sName)
{
	local int i;
	local vector v;

	for(i=0; i<m_arPosList.Length; i++)
		if(m_arPosList[i].sName == sName)
			return m_arPosList[i].vPos;

	v.z = 0;	// 타입이 0 이면 없는 것으로 간주
	return v;
}

defaultproperties
{
}

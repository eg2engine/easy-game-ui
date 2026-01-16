class EnchantTable extends Object
	native;

//
// keios - enchant 정보를 담는 테이블
//

// hp,mp 게이지의 변경 타입
enum EGAUGEEFFECT { 
	GAUGEEFFECT_NORMAL,
	GAUGEEFFECT_POISON, 
	GAUGEEFFECT_ROTTING,
	// 기타 등등
};	

// native defines
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)

// vars
var array<EnchantInfo> InfoTable;

// load 
native function SepLoad();

// find 
native function EnchantInfo Find(name enchant_name);

defaultproperties
{
}

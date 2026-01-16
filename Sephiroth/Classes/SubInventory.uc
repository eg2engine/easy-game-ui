//-----------------------------------------------------------
//
//-----------------------------------------------------------
class SubInventory extends SephirothInventory
	native;

var int Index;      //보조 인벤토리 번호
var int InvenWidth;
var int InvenHeight;
//var int EndTime;
var string EndTime;
var int Validity;

function bool IsValid()
{
	return ( ! ( Validity==0 || Validity == -1) );
}

// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)

defaultproperties
{
}

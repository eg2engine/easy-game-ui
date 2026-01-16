// keios - enchant�� icon���� ui�� ǥ���ϱ� ���� ������ ��� �ִ� class

class EnchantIcon extends Object
	native;

// types
struct native ICONTEXTURESTRUCT
{
	var Texture	Texture;
	var float	U, V, UL, VL;
	var float	ScaleX, ScaleY;
};


// properties
var name	Name;
var ICONTEXTURESTRUCT IconTexture;


// static functions

// EnchantIconTable�κ��� enchant_id�� �´� icon������ ��� EnchantIcon Object�� ��ȯ
static function EnchantIcon FindIcon(ClientController controller, name icon_name)
{
	local GameManager GameMgr;

	GameMgr = GameManager(controller.Level.Game);

	return GameMgr.EnchantIconTable.FindIcon(icon_name);
}

defaultproperties
{
     IconTexture=(ScaleX=1.000000,ScaleY=1.000000)
}

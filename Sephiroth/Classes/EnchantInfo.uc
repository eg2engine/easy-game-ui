// keios - information about enchant
class EnchantInfo extends Object
	native;

var name Name;
var name IconName;
var bool ShowEffect, ShowInfo, ShowIcon, HPGauge, MPGauge;
var int HPGaugeEffect, MPGaugeEffect;
var float Duration;
var string Tooltip;
var EnchantIcon Icon;		// icon������ ptr


// static functions

// EnchantTable�κ��� enchant_name�� �´� enchantinfo�� ��� EnchantInfo Object�� ��ȯ
static function EnchantInfo Find(ClientController controller, name enchant_name)
{
	local GameManager GameMgr;

	GameMgr = GameManager(controller.Level.Game);

	return GameMgr.EnchantTable.Find(enchant_name);
}

defaultproperties
{
     ShowEffect=True
     Duration=60.000000
}

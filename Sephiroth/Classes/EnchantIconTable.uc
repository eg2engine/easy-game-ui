// keios - enchant icon�� ������ ��� ���̺�
class EnchantIconTable extends Object
	native;

var array<EnchantIcon> IconTable;

// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)

native function SepLoad();

event function Destroy()
{
	local int i, len;

	len = IconTable.Length;
	for(i=0; i < len; ++i)
	{
		IconTable[i].IconTexture.Texture = None;
		IconTable[i] = None;
		//Log("EnchantIconTable eventDestroy Texture"@i);		
	}

	IconTable.Remove(0, IconTable.Length);
}

function EnchantIcon FindIcon(name icon_name)
{
	local int i, len;

	len = IconTable.Length;
	for(i=0; i < len; ++i)
	{
		if(IconTable[i].Name == icon_name)
			return IconTable[i];
	}
	return None;
}


native function EnchantIcon Find(name icon_name);

///////////////////////////////////////////////////////////

defaultproperties
{
}

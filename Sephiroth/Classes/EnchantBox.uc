class EnchantBox extends Object;

///////////////////////////////////////////////////
// keios - ĳ���Ͱ� �ɸ� enchant ���¸� ��������
///////////////////////////////////////////////////


// types

// properties
var ClientController			OwnerController;
var array<EnchantInfoInstance>	EnchantInfoMap;


////////////////////////////////////////////////////////////////////////


// create functions
static function EnchantBox Create(Object Owner, ClientController OwnerController)
{
	local EnchantBox instance;

	instance = new(Owner) class'EnchantBox';
	instance.OwnerController = OwnerController;

	return instance;
}

////////////////////////////////////////////////////////////////////////


// manage functions
function int FindIndex(name enchant_name)
{
	local int i, len;

	len = EnchantInfoMap.Length;
	for(i=0; i < len; ++i)
	{
		if(EnchantInfoMap[i].Info.Name == enchant_name)
		{
			return i;
		}
	}
	return -1;
}

function EnchantInfoInstance Find(name enchant_name)
{
	local int i, len;

	len = EnchantInfoMap.Length;
	for(i=0; i < len; ++i)
	{
		if(EnchantInfoMap[i].Info.Name == enchant_name)
		{
			return EnchantInfoMap[i];
		}
	}

	return None;
}

////////////////////////////////////////////////////////////////////////



function AddEnchant(name enchant_name)
{
	local EnchantInfoInstance inst;
	local EnchantInfo info;


	// �̹� �ִ� enchant���� check

	if(FindIndex(enchant_name) >= 0)
		return;

	//Log("Finding enchant");

	// table���� enchant������ �˻��Ͽ� ��ȯ
	info = class'EnchantInfo'.static.Find(OwnerController, enchant_name);
	if(info == None)
		return;


	// info instance�� �����Ѵ�. (duration�� ���� disenchanttime�� ��´�.)
	inst				= new(Self) class'EnchantInfoInstance';
	inst.Info			= info;
	inst.EnchantTime	= OwnerController.Level.TimeSeconds;
	if(info.Duration == 0)
		inst.DisenchantTime	= 0;
	else
		inst.DisenchantTime = inst.EnchantTime + info.Duration;


	//Log("Adding to map");

	// map�� �߰�
	EnchantInfoMap[EnchantInfoMap.Length] = inst;

	//Log("NotifyUI");

	// notify ui
	OwnerController.OnUpdateUI_EnchantBox();
}


function RemoveEnchant(name enchant_name)
{
	local int idx;

	idx = FindIndex(enchant_name);
	if(idx < 0)
		return;

	EnchantInfoMap[idx] = None;
	EnchantInfoMap.Remove(idx,1);

	// notify ui
	OwnerController.OnUpdateUI_EnchantBox();
}

defaultproperties
{
}

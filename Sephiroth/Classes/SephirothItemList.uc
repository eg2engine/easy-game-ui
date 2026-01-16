class SephirothItemList extends Object
	native;

var array<SephirothItem> Items;

native function Clear();

// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)

delegate OnUpdateItem(SephirothItem Item);
function UpdateItems()
{
	local int i;
	for (i=0;i<Items.Length;i++)
		OnUpdateItem(Items[i]);
}

delegate OnDrawItem(Canvas C, SephirothItem Item, int OffsetX, int OffsetY);
function DrawItems(Canvas C, int OffsetX, int OffsetY)
{
	local int i;

	for (i=0;i<Items.Length;i++)
		OnDrawItem(C, Items[i], OffsetX, OffsetY);
}

function SelectAll(bool bSet)
{
	local int i;
	for (i=0;i<Items.Length;i++)
		Items[i].bSelected = bSet;
}

function int GetSelectedItems(out array<SephirothItem> Selected, optional bool bAppend)
{
	local int i, k;

	if (!bAppend) {  
		Selected.Remove(0, Selected.Length);
		k = 0;
	}
	else {
		k = Selected.Length;
	}

	for (i=0;i<Items.Length;i++) {
		if (Items[i].bSelected) {
			Selected[k] = Items[i];
			k++;
		}
	}

	return Selected.Length;
}

function int CountItem(byte CheckType, string Name)
{
	local int i, Amount;

	for (i=0;i<Items.Length;i++) {
		switch (CheckType) {
		case 0: // TypeName
			if (Items[i].TypeName == Name)
				Amount++;
			break;
		case 1: // Description
			if (Items[i].Description == Name)
				Amount++;
			break;
		case 2: // ModelName
			if (Items[i].ModelName == Name)
				Amount++;
			break;
		}
	}
	return Amount;
}

function int FindItemToArray(byte CheckType, string Name, out array<SephirothItem> OutArray, optional bool bAppend)
{
	local int i, k;

	if (!bAppend) {
		OutArray.Remove(0, OutArray.Length);
		k = 0;
	}
	else
		k = OutArray.Length;

	for (i=0;i<Items.Length;i++) {
		switch (CheckType) {
		case 0: // TypeName
			if (Items[i].TypeName == Name) {
				OutArray[k] = Items[i];
				k++;
			}
			break;
		case 1: // Description
			if (Items[i].Description == Name) {
				OutArray[k] = Items[i];
				k++;
			}
			break;
		case 2: // ModelName
			if (Items[i].ModelName == Name) {
				OutArray[k] = Items[i];
				k++;
			}
			break;
		}
	}

	return OutArray.Length;
}

//@by wj(12/02)------
function int GetItemAmountSum(string Name)
{
	local int i;
	local int Amount;

	Amount = 0;

	for(i =0 ; i < Items.Length ; i++)
	{
		if(Items[i].TypeName == Name && Items[i].Amount != Items[i].ITEM_HAS_NO_AMOUNT)
			Amount += Items[i].Amount;
	}

	return Amount;
}
//-------------------

//add neive : 12단 아이템 -----------------------------------------------------
function int GetSmithItemSum(string Name)
{
	local int i;
	local int Amount;

	Amount = 0;

	for(i =0 ; i < Items.Length ; i++)
	{
		if(Items[i].Level == 1 || Items[i].Level == 2 || Items[i].Level == 31) // 12단 제조에는 1, 2, 31렙 아이템만 쓰인다
		{
			if(Items[i].TypeName == Name)
			{
				if(Items[i].Amount == -1)
					++Amount;
				else
					Amount += Items[i].Amount;
			}
		}
	}

	return Amount;
}
//-----------------------------------------------------------------------------


function SephirothItem FirstMatched(byte CheckType, string Name)
{
	local int i;

	for (i=0;i<Items.Length;i++) {
		if (CheckType == 0 && Items[i].TypeName == Name)
			return Items[i];
		if (CheckType == 1 && Items[i].Description == Name)
			return Items[i];
		if (CheckType == 2 && Items[i].ModelName == Name)
			return Items[i];
		if (CheckType == 3 && Items[i].LocalizedDescription == Name)    //cs added
			return Items[i];
	}

	return None;
}

function int Size()
{
	return Items.Length;
}

defaultproperties
{
}

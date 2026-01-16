class SephirothInventory extends SephirothItemList
	native;

var int OwnerId;
var name OwnerName;
var int Weight; // Perc
var int Money;
var string strMoney;

struct native Rectangle
{
	var int Left, Top, Right, Bottom;
};

// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)

function SephirothItem FindItem(int X, int Y)
{
	local int i;
	for (i=0;i<Items.Length;i++)
		if (Items[i].X == X && Items[i].Y == Y)
			return Items[i];
}

function SephirothItem FindItemEx(string strTypeName)
{
	local int i;
	for (i=0;i<Items.Length;i++)
	{
		if (Items[i].TypeName == strTypeName)
			return Items[i];
	}
}

function SephirothItem FindItemByLocalDesc(string strLocalDesc) //cs added
{
	local int i;
	for (i=0;i<Items.Length;i++)
	{
		if (Items[i].LocalizedDescription == strLocalDesc)
			return Items[i];
	}
}

function Rectangle Rectangle_Get(SephirothItem Item)
{
	local Rectangle Rc;
	Rc.Left = Item.X;
	Rc.Top = Item.Y;
	Rc.Right = Item.X + Item.Width - 1;
	Rc.Bottom = Item.Y + Item.Height - 1;
	return Rc;
}

function bool Rectangle_Intersect(Rectangle target, Rectangle probe)
{
	if (target.Right < probe.Left || target.Left > probe.Right ||
		target.Bottom < probe.Top || target.Top > probe.Bottom)
		return false;
	return true;
}

function bool Rectangle_Contain_Point(Rectangle target, int X, int Y)
{
	if (X >= target.Left && X <= target.Right && Y >= target.Top && Y <= target.Bottom)
		return true;
	else
		return false;
}

function SephirothItem GetItem_RC(int Column, int Row)
{
	local Rectangle ItemRc;
	local int i;
	for (i=0;i<Items.Length;i++) {
		ItemRc = Rectangle_Get(Items[i]);
		if (Rectangle_Contain_Point(ItemRc, Column, Row))
			return Items[i];
	}
	return None;
}

defaultproperties
{
}

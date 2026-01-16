class CMentorMatching	extends CMultiInterface;

var globalconfig float PageX,PageY;
var bool bIsDragging;
var int DragOffsetX;
var int DragOffsetY;


function MoveWindow(int OffsetX, int OffsetY)
{
	PageX = OffsetX;
	PageY = OffsetY;
}

defaultproperties
{
}

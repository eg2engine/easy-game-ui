//=============================================================================
// MonsterAnimAction.
//=============================================================================
class MonsterAnimAction extends AnimAction
	placeable;

defaultproperties
{
     Actions(0)=(Sequence="Melee",Frames=30,ActionClass=AC_Finish,AnimTime=1000.000000,PreparePivot="Bip01 L Toe0",CleanupPivot="Bip01 L Toe0")
     Actions(1)=(Sequence="Pain",Frames=30,ActionClass=AC_Pain,AnimTime=1000.000000,PreparePivot="Bip01 L Toe0",CleanupPivot="Bip01 L Toe0")
     Actions(2)=(Sequence="Knockback",Frames=30,ActionClass=AC_Knockback,AnimTime=1000.000000,PreparePivot="Bip01 L Toe0",CleanupPivot="Bip01 L Toe0")
     Actions(3)=(Sequence="Range",Frames=30,ActionClass=AC_Finish,AnimTime=1000.000000,PreparePivot="Bip01 L Toe0",CleanupPivot="Bip01 L Toe0")
}

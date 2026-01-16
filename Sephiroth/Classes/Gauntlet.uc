class Gauntlet extends Attachment;

/*
var Actor ActionEffect;

function PostBeginPlay()
{
	Super.PostBeginPlay();
	ActionEffect = Spawn(class<Actor>(DynamicLoadObject("EnchantFx.Spirit_Naiad_Glow", class'Class')),Self);
}

event Destroyed()
{
	if (ActionEffect != None) {
		ActionEffect.Destroy();
		ActionEffect = None;
	}
	Super.Destroyed();
}

function SpawnActionEffect()
{
	if (ActionEffect != None)
		ActionEffect.bHidden = false;
}					

function DestroyActionEffect()
{
	if (ActionEffect != None)
		ActionEffect.bHidden = true;
}
//上面全部注释掉
*/

defaultproperties
{
}

class ClientCommandProcessor extends Actor
	native;

var PlayerController PlayerOwner;

native function RunCommand(string command);

// �׽�Ʈ�� ���� effectProjectile class�� spawn�ϴ� Ŭ����
event function ShootProjectile(string name)
{
	local class<Actor>		EffectClass;
	local Actor				EffectActor;
	local EffectProjectile	EffectProj;
	local Pawn				EffectPawn;


	EffectPawn = PlayerOwner.Pawn;
	if(EffectPawn == None)
	{
		//Log("[ClientCommandProcessor] ShootProjectile ERROR : EffectPawn == None!");
		return;
	}

	EffectClass = class<Actor>(DynamicLoadObject(name, class'class'));
	if(EffectClass == None)
	{
		//Log("[ClientCommandProcessor] ShootProjectile ERROR : EffectClass == None!");
		return;
	}


	if(EffectClass != None)
	{
		EffectActor = Spawn(EffectClass,,,EffectPawn.Location,EffectPawn.Rotation);

		if(!EffectActor.IsA('EffectProjectile'))
		{
			//Log("[ClientCommandProcessor] ShootProjectile ERROR : EffectActor != EffectProjectile");
			return;
		}

		if(EffectActor.IsA('EffectProjectile'))
		{
			EffectProj					= EffectProjectile(EffectActor);
			EffectProj.TargetLocation	= EffectPawn.Location;
			EffectProj.TargetLocation.X += 1000.0f;
			EffectProj.bTouchOnlySeek	= True;
			EffectProj.DamageType		= 3;
		}
		
	}
}

defaultproperties
{
}

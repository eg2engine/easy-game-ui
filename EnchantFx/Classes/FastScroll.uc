class FastScroll extends EnchantType;

/*defaultproperties
{
	EnchantDesc="FastScroll"
	EnchantEmitterClass=class'EnchantFx.FastScrollEmitter'
	AttachType=EA_Spine
}
*/

var class<Actor> HandEffectClass[2];
var Actor HandEffectActor[2];
var class<Actor> RootEffectClass;
var Actor RootEffectActor;

var vector    BoneLoc[3];

function PostBeginPlay()
{
	Super.PostBeginPlay();

	if ( HandEffectClass[0] != None )
	{
		HandEffectActor[0] = Spawn(HandEffectClass[0], self, , Owner.Location, Owner.Rotation);
	    HandEffectActor[0].SetDrawScale(1.0f);
	}

	if ( HandEffectClass[1] != None )
	{
		HandEffectActor[1] = Spawn(HandEffectClass[1], self, , Owner.Location, Owner.Rotation);
	    HandEffectActor[1].SetDrawScale(1.0f);
	}

	if ( RootEffectClass != None )
	{
		RootEffectActor = Spawn(RootEffectClass, self, , Owner.Location, Owner.Rotation);
	    RootEffectActor.SetDrawScale(1.0f);
	}
}


event Tick(FLOAT DeltaTime)
{

    // No bone lookup is needed when all child effects are absent.
    if (HandEffectActor[0] != None || HandEffectActor[1] != None || RootEffectActor != None)
    {
	BoneLoc[0] = Owner.GetBoneCoords('Bip01 L Hand').Origin;
    BoneLoc[1] = Owner.GetBoneCoords('Bip01 R Hand').Origin;
    BoneLoc[2] = Owner.GetBoneCoords('Root').Origin;

	if ( HandEffectActor[0] != None )
		HandEffectActor[0].SetLocation(BoneLoc[0]);

	if ( HandEffectActor[1] != None )
		HandEffectActor[1].SetLocation(BoneLoc[1]);

	if ( RootEffectActor != None )
		RootEffectActor.SetLocation(BoneLoc[2]);


    }
    Super(EnchantType).Tick(DeltaTime);
}


event LostChild (Actor Child)
{
	if ( Child == HandEffectActor[0] )
	{
		HandEffectActor[0] = None;
	}
    else if ( Child == HandEffectActor[1] )
	{
		HandEffectActor[1] = None;
	}
    else if ( Child == RootEffectActor )
	{
		RootEffectActor = None;
	}
	else
		Super.LostChild(Child);
}


event Destroyed()
{
	Super.Destroyed();

	if ( HandEffectClass[0] != None)
	{
		HandEffectActor[0].Destroy();
		HandEffectClass[0] = None;
	}

	if ( HandEffectClass[1] != None)
	{
		HandEffectActor[1].Destroy();
		HandEffectClass[1] = None;
	}

	if ( RootEffectClass != None)
	{
		RootEffectActor.Destroy();
		RootEffectClass = None;
	}
}

defaultproperties
{
     HandEffectClass(0)=Class'EnchantFx.JEF_AttackSpeedUp_Hand'
     HandEffectClass(1)=Class'EnchantFx.JEF_AttackSpeedUp_Hand'
     RootEffectClass=Class'EnchantFx.JEF_AttackSpeedUp_Center'
}

class SpeedScroll extends EnchantType;

event Tick(FLOAT DeltaTime)
{




	Super(EnchantType).Tick(DeltaTime);



	if ( Hero(Owner) != None )
	{
		if ( Hero(Owner).IsRunning() && !Hero(Owner).IsJumping() )
		{
			if ( EnchantEmitter == None )
			{
				EnchantEmitter = Spawn(EnchantEmitterClass,Owner,,EnchantCharacter.Location,EnchantCharacter.Rotation);

				if (AttachBone != '' && AttachBone != 'None') {
					EnchantCharacter.AttachToBone(EnchantEmitter, AttachBone);
				}
				//@by wj(04/01)------
				else
				{
					if(AttachType==EA_Spine)
						EnchantCharacter.AttachToBone(EnchantEmitter, EnchantCharacter.BoneSpine);
					else if(AttachType==EA_Head)
						EnchantCharacter.AttachToBone(EnchantEmitter, EnchantCharacter.BoneHead);
				}

				EnchantEmitter.SetRelativeLocation(AttachOffset);
			}
		}
		else
		{
			if ( EnchantEmitter != None )
			{
				EnchantEmitter.destroy();
				EnchantEmitter = None;
			}
		}
	}
	else
		Log("Xelloss : Owner is not HERO");



}

defaultproperties
{
     EnchantEmitterClass=Class'EnchantFx.SpeedScrollEmitter'
     EnchantDesc="SpeedScroll"
}

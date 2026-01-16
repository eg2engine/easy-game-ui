class RandomboxModel extends Creature;

function CreateStyle()
{
	local int i;

	for (i = 0;i < Skins.Length;i++) {
		if (Skins[i] == None)
			break;
		if (!bStyleCreated) {
			ColorStyle[i] = new(None) class'ColorModifier';
			BlendStyle[i] = new(None) class'FinalBlend';
		}
		BlendStyle[i].Material = Skins[i];
		BlendStyle[i].AlphaTest = true;
		BlendStyle[i].FrameBufferBlending = BlendStyle[i].EFrameBufferBlending.FB_AlphaBlend;
		ColorStyle[i].Material = BlendStyle[i];
		ColorStyle[i].Color.A = 255;
		Skins[i] = ColorStyle[i];
	}
	if (Skins.Length > 0)
		bStyleCreated = True;
}

defaultproperties
{
}

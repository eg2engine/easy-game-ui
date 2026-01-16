class ModelCache extends Object
	native
	config(ModelCache);

struct ItemSlot
{
	var name Bone;
	var vector Scale;
	var vector Location;
	var rotator Rotation;
};

struct native ModelObjectCache
{
	var string Name;
	var string ClassName;
	var string MeshName;
	var int CollisionHeight;
	var int CollisionRadius;
	var array<string> Skins;
	var array<string> SkinNames;
	var float GroundSpeed;
	var name BoneHead;
	var name BoneSpine;
	var string RangeActEffectString;
	var name RangeActAnim;
	var name MagicActAnim;
	var bool bAttachToBothHand;
	var bool bTrackLocation;
	var int UpperOffset;
	var int LowerOffset;
	var array<ItemSlot> AttachmentSlots;
	var name BaseAnim;
	var bool bAnimate;
};

var globalconfig array<ModelObjectCache> Model;

// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)

static native function string GetClassName(string InName, out int Index);
static native function BindCacheProperty(Actor InActor, int Index);

static final function GetMeshName(string InName, out string OutName)
{
	local int i;

	for (i=0;i<default.Model.Length;i++) {
		if (default.Model[i].Name == InName) {
			OutName = default.Model[i].MeshName;
			break;
		}
	}
}

event ModelObjectCacheProp(out int Index, out Actor Actor, string Name, optional float Scale)
{
	local int i, k;
	local Creature Creature;
	local Attachment Attachment;
	local string TempName;
	local float TempValue, TempValueTwo;
	local Material Material;

	if (Index == -1) {
		for (i=0;i<Model.Length;i++) {
			if (Model[i].Name == Name) {
				Index = i;
				break;
			}
		}
	}

	if (Index == -1)
		return;

	Creature = Creature(Actor);
	Attachment = Attachment(Actor);

	// copy skin names
	if (Creature != None)
		Creature.SkinNames = Model[Index].SkinNames;
	else if (Attachment != None)
		Attachment.SkinNames = Model[Index].SkinNames;

	// copy mesh
	TempName = Model[Index].MeshName;
	if (TempName == "")
		TempName = Model[Index].Name $ "." $ Model[Index].Name;
	Actor.LinkMesh(SkeletalMesh(DynamicLoadObject(TempName, class'SkeletalMesh')));

	// create skins
	for (k=0;k<Model[Index].Skins.Length;k++) {
		Material = Material(DynamicLoadObject(Model[Index].Skins[k], class'Material'));
		Actor.Skins[Actor.Skins.Length] = Material;
	}

	// copy collision
	TempValue = Model[Index].CollisionRadius;
	if (TempValue == 0)
		TempValue = Actor.Class.Default.CollisionRadius;
	TempValueTwo = Model[Index].CollisionHeight;
	if (TempValueTwo == 0)
		TempValueTwo = Actor.Class.Default.CollisionHeight;
	if (Scale == 0)
		Scale = 1.0;
	Actor.SetDrawScale(Actor.DrawScale * Scale);
	Actor.SetCollisionSize(TempValue * Scale, TempValueTwo * Scale);
}

event MonsterCacheProp(out int Index, out Actor Actor, string Name, optional float Scale)
{
	local name TempName;
	local float TempValue;
	local Creature Creature;

	ModelObjectCacheProp(Index, Actor, Name, Scale);
	if (Index < 0)
		return;

	Creature = Creature(Actor);
	if (Creature == None)
		return;

	TempValue = Model[Index].GroundSpeed;
	if (TempValue == 0)
		TempValue = Creature.Class.Default.GroundSpeed;
	Creature.GroundSpeed = TempValue;

	TempName = Model[Index].BoneHead;
	if (TempName == '')
		TempName = Creature.Class.Default.BoneHead;
	Creature.BoneHead = TempName;

	TempName = Model[Index].BoneSpine;
	if (TempName == '')
		TempName = Creature.Class.Default.BoneSpine;
	Creature.BoneSpine = TempName;

	Creature.RangeActEffectString = Model[Index].RangeActEffectString;

	TempName = Model[Index].RangeActAnim;
	if (TempName == '')
		TempName = 'Range';
	Creature.RangeActAnims[0].SeqName = TempName;

	TempName = Model[Index].MagicActAnim;
	if (TempName == '')
		TempName = 'Magic';
	Creature.MagicActAnims[0].SeqName = TempName;
}

event NpcCacheProp(out int Index, out Actor Actor, string Name, optional float Scale)
{
	ModelObjectCacheProp(Index, Actor, Name, Scale);
}

//@by wj(12/12)------
event GuardStoneCacheProp(out int Index, out Actor Actor, string Name, optional float Scale)
{
	ModelObjectCacheProp(Index, Actor, Name, Scale);
}
//-------------------
event MatchStoneCacheProp(out int Index, out Actor Actor, string Name, optional float Scale)
{
	ModelObjectCacheProp(Index, Actor, Name, Scale);
}

event ItemCacheProp(out int Index, out Actor Actor, string Name, optional float Scale)
{
	local int k;
	local Attachment Attachment;
	local Attachment.AttachmentSlot Slot;

	ModelObjectCacheProp(Index, Actor, Name, Scale);
	if (Index < 0)
		return;

	Attachment = Attachment(Actor);
	if (Attachment == None)
		return;

	for (k=0;k<Model[Index].AttachmentSlots.Length;k++) {
		Slot.Bone = Model[Index].AttachmentSlots[k].Bone;
		Slot.Scale = Model[Index].AttachmentSlots[k].Scale;
		Slot.Location = Model[Index].AttachmentSlots[k].Location;
		Slot.Rotation = Model[Index].AttachmentSlots[k].Rotation;
		Attachment.AttachmentSlots[Attachment.AttachmentSlots.Length] = Slot;
	}

	Attachment.bTrackLocation = Model[Index].bTrackLocation;
	Attachment.UpperOffset = Model[Index].UpperOffset;
	Attachment.LowerOffset = Model[Index].LowerOffset;

	if (Attachment.bTrackLocation && Attachment.MTClass != None)
		Attachment.MotionTrace = new(Attachment) Attachment.MTClass;

	Attachment.bAttachToBothHand = Model[Index].bAttachToBothHand;
	Attachment.bAnimate = Model[Index].bAnimate;
	Attachment.BaseAnim = Model[Index].BaseAnim;

	if (Attachment.bAnimate && Attachment.BaseAnim != '')
		Attachment.LoopAnim(Attachment.BaseAnim, 1, 0);
}

defaultproperties
{
}

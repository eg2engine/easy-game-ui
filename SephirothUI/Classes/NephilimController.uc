class NephilimController extends SephirothController;

function EInteractType CalcInteractType(optional Actor Actor)
{
	local PlayerServerInfo PSI;
	local Skill MagicSkill;
	local SephirothPlayer CC, OtherCC;

	CC = SephirothPlayer(ViewportOwner.Actor);
	PSI = NephilimPlayer(ViewportOwner.Actor).PSI;
	MagicSkill = PSI.Magic;
	//@by wj(03/15)
	if (Actor != None)
	{
		if(PSI.JobName == 'Bow')
		{
			if (InteractionKey == IK_LeftMouse) {
				if (Actor.bWorldGeometry || Actor.IsA('TerrainInfo') || Actor.IsA('StaticMeshActor'))
					return IT_Move;
				if (Actor.IsA('Attachment') && Attachment(Actor).Info.CanPickup(PSI.PlayName))
					return IT_Pick;
				if (Actor.IsA('Monster') && CC.PSI.Combo != None && !Character(Actor).bIsDead)
					return IT_AttackBow;
				if (Actor.IsA('GuardStone') && CC.PSI.Combo != None && class'PlayerServerInfo'.static.CanAttackGuardStone(CC.PSI, GuardStone(Actor).GSI))
					return IT_AttackBow;
				if (Actor.ISA('MatchStone') && CC.PSI.Combo != None && class'PlayerServerInfo'.static.CanAttackMatchStone(CC.PSI, MatchStone(Actor).MSI))
					return IT_AttackBow;
				if (Actor.IsA('Hero') && !Character(Actor).bIsDead) {
					OtherCC = SephirothPlayer(Hero(Actor).Controller);
					if (CC.PSI.Combo != None && class'PlayerServerInfo'.static.CanAttackPlayer(CC.PSI, OtherCC.PSI, CC.ZSI.bUnderSiege))
						return IT_AttackBow;
					else
						return IT_Talk;
				}
				if (Actor.IsA('Npc') || Actor.IsA('Hero') && Actor != ViewportOwner.Actor.Pawn && !PSI.PkState)
					return IT_Talk;
				/*
				//@by wj(12/20)------
				if (Actor.IsA('GuardStone') && PSI.WarState != 1){
					if(class'GuardStone'.static.IsGuardStoneAttackable(GuardStone(Actor).GSI,PSI))
					return IT_AttackBow;
			}
				//-------------------
				*/
			}
			else if (Actor == ViewportOwner.Actor.Pawn && InteractionKey == IK_RightMouse && MagicSkill != None && MagicSkill.IsA('SpiritSkill'))
				return IT_Enchant;
			return IT_None;
		}
		else if(PSI.JobName == 'Blue' || PSI.JobName == 'Yellow')
		{
			if (InteractionKey == IK_LeftMouse)
			{
				if(Actor.bWorldGeometry || Actor.IsA('TerrainInfo') || Actor.IsA('StaticMeshActor'))
					return IT_Move;

				if(Actor.IsA('Monster') && !Character(Actor).bIsDead && CC.PSI.Combo != None)
						return IT_AttackMelee;

				if (Actor.IsA('GuardStone') && CC.PSI.Combo != None && class'PlayerServerInfo'.static.CanAttackGuardStone(CC.PSI, GuardStone(Actor).GSI))
					return IT_AttackMelee;

				if(Actor.IsA('MatchStone') && CC.PSI.Combo != None && class'PlayerServerInfo'.static.CanAttackMatchStone(CC.PSI, MatchStone(Actor).MSI))
					return IT_AttackMelee;

				if (Actor.IsA('Hero') && !Character(Actor).bIsDead) {
					OtherCC = SephirothPlayer(Hero(Actor).Controller);
					if (CC.PSI.Combo != None && class'PlayerServerInfo'.static.CanAttackPlayer(CC.PSI, OtherCC.PSI, CC.ZSI.bUnderSiege))
						return IT_AttackMelee;
					else
						return IT_Talk;
				}
				/*
				//@by wj(12/20)------
				if(Actor.IsA('GuardStone') && PSI.WarState != 1){
					if(PSI.Combo != None){
						if(class'GuardStone'.static.IsGuardStoneAttackable(GuardStone(Actor).GSI,PSI))
							return IT_AttackMelee;
					}
				}
				//-------------------
				if(Actor.IsA('Hero')) {
					if(PSI.pkState == true)
						return IT_AttackMelee;
					else
						return IT_Talk;
				}
				*/
				if(Actor.IsA('NPC') || Actor.IsA('Hero') && Actor != ViewportOwner.Actor.Pawn && !PSI.PkState)
					return IT_Talk;

				if (Actor.IsA('Attachment') && Attachment(Actor).Info.CanPickup(PSI.PlayName))
					return IT_Pick;
			}
			else if (InteractionKey == IK_RightMouse)
			{
				if(Actor == ViewportOwner.Actor.Pawn && MagicSkill != None && MagicSkill.bSelf && MagicSkill.bEnchant)
					return IT_Enchant;

				if(Actor.bWorldGeometry || Actor.IsA('TerrainInfo') || Actor.IsA('StaticMeshActor'))
					if(MagicSkill != None && /*MagicSkill.bIsSplash*/MagicSkill.bServerHitCheck)
						return IT_AttackRange;

				if(Actor.IsA('Monster')){
					if(MagicSkill != None)
					{
						if(MagicSkill.bEnchant && !MagicSkill.bSelf)
							return IT_Enchant;
						else if(!MagicSkill.bEnchant)
							return IT_AttackRange;
					}
				}
				if (Actor.IsA('GuardStone') &&
					MagicSkill != None &&
					!MagicSkill.bEnchant &&
					class'PlayerServerInfo'.static.CanAttackGuardStone(CC.PSI, GuardStone(Actor).GSI)) {
					return IT_AttackRange;
				}
				if(Actor.IsA('MatchStone') &&
					MagicSkill != None &&
					!MagicSkill.bEnchant &&
					class'PlayerServerInfo'.static.CanAttackMatchStone(CC.PSI, MatchStone(Actor).MSI)) {
					return IT_AttackRange;
					}

				if (Actor.IsA('Hero') && !Character(Actor).bIsDead && MagicSkill != None) {
					if (MagicSkill.bEnchant && !MagicSkill.bSelf)
							return IT_Enchant;
					else {
						OtherCC = SephirothPlayer(Hero(Actor).Controller);
						if (class'PlayerServerInfo'.static.CanAttackPlayer(CC.PSI, OtherCC.PSI, CC.ZSI.bUnderSiege))
							return IT_AttackRange;
					}
				}
			}
		}
	}
	else 
	{
		// jjh ---
		if (PSI.JobName == 'Bow' && MagicSkill != None && MagicSkill.IsA('SpiritSkill') && InteractionKey == IK_RightMouse)
			return IT_Enchant;
		if(MagicSkill != None && MagicSkill.bSelf && MagicSkill.bEnchant && InteractionKey == IK_RightMouse)
			return IT_Enchant;
	}
	return IT_None;
}

defaultproperties
{
     InterfaceSkin=(B=223,G=229,R=199)
}

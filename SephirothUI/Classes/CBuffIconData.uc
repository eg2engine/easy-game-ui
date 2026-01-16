class CBuffIconData extends Object;

function bool GetBuffIconData(string sBuffName, out int nIdx, out int nText)
{
	local bool bBuff;

	switch(sBuffName)
	{
		case "ASPDUP":			bBuff = true; nIdx = 13; nText = 1; break;
		case "MSPDUP":			bBuff = true; nIdx = 53; nText = 7; break;
		case "DAMUP":			bBuff = true; nIdx = 12; nText = 2; break;
		case "EXPUP":			bBuff = true; nIdx = 11; nText = 3; break;
		case "HPUPLv1":			bBuff = true; nIdx = 37; nText = 4; break;
		case "HPUPLv2":  bBuff = true; nIdx = 38; nText = 4; break;
		case "HPUPLv3":  bBuff = true; nIdx = 39; nText = 4; break;
		case "HMPUPLv1": bBuff = true; nIdx = 40; nText = 6; break;
		case "HMPUPLv2": bBuff = true; nIdx = 41; nText = 6; break;
		case "HMPUPLv3": bBuff = true; nIdx = 42; nText = 6; break;
		case "MPUPLv1":  bBuff = true; nIdx = 43; nText = 5; break;
		case "MPUPLv2":  bBuff = true; nIdx = 44; nText = 5; break;
		case "MPUPLv3":  bBuff = true; nIdx = 45; nText = 5; break;
		case "STMUPLv1": bBuff = true; nIdx = 40; nText = 8; break;
		case "STMUPLv2": bBuff = true; nIdx = 41; nText = 8; break;
		case "STMUPLv3": bBuff = true; nIdx = 42; nText = 8; break;


		// 일반 아이템
		case "SpeedScroll":		 bBuff = true; nIdx = 36; nText = 7; break;
		case "FastScroll":		bBuff = true; nIdx = 49; nText = 1; break;

		case "Transformation":   bBuff = true; nIdx = 10; nText = 0; break;

		// 정령술
		case "Undine":           bBuff = true; nIdx = 31; nText = 0; break;
		case "SpiritSalamander": bBuff = true; nIdx = 32; nText = 0; break;
		case "Dryad":            bBuff = true; nIdx = 33; nText = 0; break;
		case "Nereid":           bBuff = true; nIdx = 34; nText = 0; break;
		case "Alseide":          bBuff = true; nIdx = 35; nText = 0; break;

		// 블루 보조
		case "FrostEnemy":       bBuff =false; nIdx = 24; nText = 0; break;
		case "WaveOfIce":        bBuff =false; nIdx = 26; nText = 0; break;
		case "WindOfIce":        bBuff =false; nIdx = 27; nText = 0; break;
		case "ColdEnemy":        bBuff =false; nIdx = 22; nText = 0; break;

		// 레드 보조
		case "Warm":             bBuff = true; nIdx = 51; nText = 0; break;
		case "WarmOther":        bBuff = true; nIdx = 50; nText = 0; break;
		case "FireWarm":         bBuff = true; nIdx = 28; nText = 0; break;
		case "ResistNature":     bBuff = true; nIdx = 29; nText = 0; break;
		case "WindOfFire":       bBuff = true; nIdx = 30; nText = 0; break;
		case "ResistFire":       bBuff = true; nIdx = 25; nText = 0; break;


		case "ManaRebirth":      bBuff = true; nIdx = 23; nText = 0; break;
		case "ManaBarrier":      bBuff = true; nIdx = 21; nText = 0; break;
		case "IceStinger":       bBuff =false; nIdx = 48; nText = 0; break;
		case "WinterRestriction":bBuff =false; nIdx = 47; nText = 0; break;
		case "PoisonArrow":      bBuff =false; nIdx = 46; nText = 0; break;
		case "BlindMaker":       bBuff =false; nIdx = 20; nText = 0; break;
		case "BattleCry":        bBuff =false; nIdx = 19; nText = 0; break;
		case "DeathHand":        bBuff =false; nIdx = 18; nText = 0; break;
		case "SilenceAura":      bBuff =false; nIdx = 17; nText = 0; break;
		case "AuraOfFury":       bBuff = true; nIdx = 16; nText = 0; break;
		case "UltraEndure":      bBuff = true; nIdx = 14; nText = 0; break;
		case "AbsoluteDefense":  bBuff = true; nIdx = 15; nText = 0; break;
		case "GodSpeed":         bBuff = true; nIdx =  8; nText = 0; break;
		case "ManaSaver":        bBuff = true; nIdx = 52; nText = 0; break;

		//퀘스트 스킬
		case "Guts":             bBuff = true; nIdx = 52; nText = 0; break;
		case "Untouchable":      bBuff = true; nIdx = 52; nText = 0; break;
		case "Invisable":        bBuff = true; nIdx = 52; nText = 0; break;
		case "Regeneration":     bBuff = true; nIdx = 52; nText = 0; break;

		case "HPBurn":           bBuff =false; nIdx = 40; nText = 9; break;
		case "MPBurn":           bBuff =false; nIdx = 40; nText =10; break;
		case "HPRegen":          bBuff = true; nIdx = 38; nText =13; break; //add neive : 퀘던2nd 버프
		case "MPRegen":          bBuff = true; nIdx = 44; nText =13; break;

		case "Freezing":         bBuff =false; nIdx = 60; nText =11; break;
		case "DanceOfFire":      bBuff =false; nIdx = 58; nText = 9; break;
		case "ColdEye":          bBuff =false; nIdx = 56; nText =12; break;
		case "FlameRage":        bBuff =false; nIdx = 59; nText =12; break;
		case "CounterAttack":    bBuff = true; nIdx = 61; nText = 0; break;
		case "Berserker":        bBuff = true; nIdx = 55; nText = 0; break;
		case "BattleSpirit":     bBuff = true; nIdx = 57; nText = 0; break;

		case "EventDummy":       bBuff = true; nIdx = 62; nText = 0; break;

//			case "Sleep":            bBuff =false; nIdx = 62; nText = 0; break;
//			case "Fetter":           bBuff =false; nIdx = 62; nText = 0; break;

		case "DamWater":         bBuff = true; nIdx = 63; nText = 2; break;
		case "DefWater":         bBuff = true; nIdx = 63; nText =14; break;
		case "HPWater":          bBuff = true; nIdx = 63; nText =15; break;
		case "MPWater":          bBuff = true; nIdx = 63; nText =16; break;
		case "DevilCurse":       bBuff =false; nIdx = 64; nText = 0; break;

		case "SoulCure":         bBuff = true; nIdx = 65; nText = 0; break;

		case "Slow":             bBuff =false; nIdx = 24; nText =17; break;

		//add neive : AC 스킬
		case "DeathTime":		 bBuff =false; nIdx = 66; nText = 0; break;
		case "STMBreak":		 bBuff =false; nIdx = 67; nText = 0; break;
		case "RiotFx":			 bBuff = true; nIdx = 68; nText = 0; break;
		case "AbsDodge":		 bBuff = true; nIdx = 69; nText = 0; break;
		case "DemolitionFx":	 bBuff = true; nIdx = 70; nText = 0; break;
		case "EradicationFx":	 bBuff = true; nIdx = 71; nText = 0; break;
		case "SilentFx":		 bBuff =false; nIdx = 72; nText = 0; break;
		case "ColdReflectionFx": bBuff = true; nIdx = 73; nText = 0; break;
		case "BleedingFx":		 bBuff =false; nIdx = 74; nText = 0; break;
		case "ColdReflectFx":	 bBuff =false; nIdx = 75; nText = 0; break;

		//add neive : 펫 성장 버프
		case "TrainerLv2":			bBuff = true; nIdx = 76; nText =18; break;
		case "TrainerLv3":			bBuff = true; nIdx = 76; nText =19; break;
		case "TrainerLv4":			bBuff = true; nIdx = 76; nText =20; break;

		case "GasResist":			bBuff = true; nIdx = 77; nText =21; break; //add neive : 메가로파 굴
		case "StewHP":				bBuff = true; nIdx = 37; nText =22; break;

		//add neive : 초보자 스킬
		case "GuardianShield_IO":	bBuff = true; nIdx = 78; nText = 0; break;
		case "CrashSword_IO":		bBuff = true; nIdx = 79; nText = 0; break;
		case "DynamicFinish_IO":	bBuff = true; nIdx = 80; nText = 0; break;
		case "Devastator_IO":		bBuff = true; nIdx = 81; nText = 0; break;
		case "ManaRecovery_IO":		bBuff = true; nIdx = 82; nText = 0; break;

		//add neive : PvP 스킬
		case "ShieldReflectionFx":	bBuff = true; nIdx = 83; nText = 0; break;
		case "PatalBlow_IO":		bBuff =false; nIdx = 84; nText = 0; break;
		case "DecResistRedFx":		bBuff =false; nIdx = 85; nText =12; break;
		case "AcrobaticFx":			bBuff = true; nIdx = 86; nText = 0; break;
		case "DecResistBlueFx":		bBuff =false; nIdx = 87; nText =12; break;

		//add neive : 비약 시리즈
		case "Elixir_Courge":		bBuff = true; nIdx = 88; nText = 2; break;
		case "Elixir_Defence":		bBuff = true; nIdx = 89; nText =14; break;
		case "Elixir_Guardian":		bBuff = true; nIdx = 90; nText =21; break;
		case "Elixir_Exp":			bBuff = true; nIdx = 91; nText = 3; break;
		case "Elixir_MagicCritical": 
									bBuff = true; nIdx = 92; nText =23; break;

		//add neive : pk 포인트 증가
		case "PKPointUpLv2_IO":		bBuff = true; nIdx = 93; nText =18; break;
		case "PKPointUpLv3_IO":		bBuff = true; nIdx = 94; nText =19; break;
		case "PKPointUpLv4_IO":		bBuff = true; nIdx = 95; nText =20; break;

		//add neive : 펫 자동 먹이
		case "AutoPetFood01_IO":	bBuff = true; nIdx = 96; nText =24; break;
		case "AutoPetFood02_IO":	bBuff = true; nIdx = 97; nText =24; break;
		case "AutoPetFood03_IO":	bBuff = true; nIdx = 98; nText =24; break;
		case "AutoPetFood04_IO":	bBuff = true; nIdx = 99; nText =24; break;
		case "AutoPetFood05_IO":	bBuff = true; nIdx =100; nText =24; break;
		case "AutoPetFood06_IO":	bBuff = true; nIdx =101; nText =24; break;

		case "GoldTime_Exp_IO":		bBuff = true; nIdx =102; nText = 0; break; //add neive : 골드 타임 이벤트

		case "FreezenFx":			bBuff =false; nIdx =103; nText =17; break;	//add neive : 프리즌 그라운드 아이콘 별도 생성

		case "Trans_Basic":			bBuff = true; nIdx =104; nText = 0; break;	//add neive : 변신 카드 아이콘 표시


		//case "SetWeapon_IO":		bBuff = true; nIdx =102; nText =1000; break;
		//case "SetArmor_IO":			bBuff = true; nIdx =102; nText =1000; break;
	}

	return bBuff;
}

defaultproperties
{
}

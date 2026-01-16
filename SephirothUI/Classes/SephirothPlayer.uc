class SephirothPlayer extends ClientController;

var bool bNoUseChatEraser;
var color CriticalColor, CriticalFinishColor, MissColor, ImmuneColor, DamageColor, StunColorA, StunColorB;
var color DamagedColor; //add neive : ���� ���� ������ ����
var color FieldDamageColor;
//add neive : Ÿ�Ժ� ������ ǥ��
var color MagicCritical;

var struct DamageType
	{
		var string AttackerName;
		var string SkillName;
		var bool bPain;
		var bool bKnockback;
		var bool bCritical;
		var bool bMiss;
		var bool bBlock;
		var bool bImmune;
	} 
	ThisDamage;

var Character EnchantTarget;

//var int nDamaged; //add neive : ���� ���� ������

//var TestPet TestPet;

// keios - hp,mp�������� ���¸� �����ϱ� ����
var struct GaugeStatus
	{
		var int gauge_effect;
	} 
	HPGaugeStatus, MPGaugeStatus;

function bool CheckChatEraser() 
{ 
	return !bNoUseChatEraser; 
}

function UseChatEraser(bool bSet) 
{ 
	bNoUseChatEraser = !bSet; 
}

//@by wj(040113)------
function RClickActionEnd()
{
	if ( myHud != None )
		SephirothController(SephirothInterface(myHud).Controller).RightClickActionEnd();
}
//--------------------

//@by wj(07/24)------
function bool CheckInterface(string InterfaceName)
{
	if( InterfaceName == "Inventory" )
	{
		if( SephirothInterface(MyHud).m_InventoryBag != None )
			return True;
	}
	else if(InterfaceName == "StashBox")
	{
		if( SephirothInterface(MyHud).StashLobby.StashBox != None )
			return True;
	}
	else if(InterfaceName == "Store")
	{
		if( SephirothInterface(MyHud).Store != None )
			return True;
	}
	else if(InterfaceName == "Exchange")
	{
		if( SephirothInterface(MyHud).Exchange != None )
			return True;
	}
	else if(InterfaceName == "Booth")
	{
		if( SephirothInterface(myHud).SellerBooth != None )
			return True;
		else if( SephirothInterface(myHud).GuestBooth != None )
			return True;
	}
	return False;
}
//-------------------

state Selling extends Navigating
{
}

state Repairing extends Navigating
{
}

state TracingEx extends Tracing
{
	event NetRecv_TracePlayerMovedOut()
	{
//		//Log(Self@GetStateName()@"NetRecv_TracePlayerMovedOut");
		SephirothInterface(myHud).OnTraceFinish();
		Destination = Location;
		GotoState('Navigating');
	}
	function RepeatState()
	{
		GotoState('TracingEx','Trace');
	}
}


// parameter : int TellerInfo �߰� 03.5.28 by BK
event NetRecv_PlayerMessage(int TellerInfo, string Teller,string Type,string Message,float HitSizeX,float HitSizeY,string HitText)
{


	
//	//Log(Self@"NetRecv_PlayerMessage"@Teller@Type@Message);
	//// OnPlayerMessage�� TellerInfo �߰�
	SephirothInterface(myHud).OnPlayerMessage(TellerInfo, Teller,Type,Message,HitSizeX,HitSizeY,HitText);
}

event NetRecv_AssignSkill(int Index, string SkillName)
{
	local Skill Skill;

	Skill = QuerySkillByName(SkillName);
	if ( Index == 0 ) PSI.Combo = Skill;
	else if (Index == 1) PSI.Finish = Skill;
	else if (Index == 2) PSI.Magic = Skill;
	if ( Index >= 0 )
		SephirothInterface(myHud).OnSkillUpdate(Index,Skill != None);
}

event NetRecv_LevelUp()
{
	SephirothInterface(myHud).OnLevelUp();
}

event NetRecv_LearnSkill(Skill Skill)
{
	SephirothInterface(myHud).OnSkillLearn(Skill);
}

event NetRecv_PartyJoinRequest(string Requester, int level) // ��Ƽ ����
{
	SephirothInterface(myHud).OnPartyJoinRequest(Requester, level);
}

event NetRecv_PartyInviteRequest(string Requester, int level) // ��Ƽ ����
{
	SephirothInterface(myHud).OnPartyInviteRequest(Requester, level);
}

function NetRecv_OpenShop()
{
//	SephirothInterface(myHud).OnOpenShop();
}

function NetRecv_ExchangeRequest(PlayerServerInfo Requester)
{
	SephirothInterface(myHud).OnExchangeRequest(Requester);
}

function NetRecv_ExchangeStart()
{
	SephirothInterface(myHud).OnExchangeStart();
}

function NetRecv_ExchangeOkPressed(bool bySelf)
{
	SephirothInterface(myHud).OnExchangeOkPressed(bySelf);
}

function NetRecv_ExchangeOkReleased(bool bySelf)
{
	SephirothInterface(myHud).OnExchangeOkReleased(bySelf);
}

function NetRecv_ExchangeEnd()
{
	SephirothInterface(myHud).OnExchangeEnd();
}

// Mentor
function NetRecv_MentorRequest(string strName, int nOccuID)
{
	SephirothInterface(myHud).OnRecv_RequestMentor(strName, nOccuID);
}

// Mentee(Follower)
function NetRecv_FollowerRequest(string strName, int nOccuID)
{
	SephirothInterface(myHud).OnRecv_RequestFollower(strName, nOccuID);
}

function NetRecv_SetMentor(string strName, int nLevel, Name JobName)
{
	// ���� ������ �����Ѵ�.
	strMentorName	= strName;
	nMentorLevel	= nLevel;
	MentorJob = JobName;

	// �� ��쿡�� ���� ������ �����ؾ��Ѵ�.
	aMentees.Length = 0;
}

function NetRecv_SetMentee(int nSlotIndex, string strMenteeName, int nLevel, bool IsEnable, int nReputePoint, name JobName)
{
	// ���� ������ �����Ѵ�.
	// ���������� ����ȴ�.
	local int n, nIndex;

	// Ȱ��ȭ �� ���԰� �ƴѰ��� �����Ͽ� ó���Ѵ�.
	if ( IsEnable )
	{
		// Ȱ��ȭ �� ������ ���� ������ �ް� ����.
		// ���� ������ ����Ʈ���� ���� ���� ã�Ƽ� ������ �����ְ�
		for ( n = 0 ; n < aMentees.Length ; n++ )
		{
			if ( aMentees[n].nSlotIndex == nSlotIndex )
			{
				aMentees.Remove(n, 1);
				break;
			}
		}

		// ������ �������ϱ� �ߺ��ǰ� ���������� ���� ���̹Ƿ� �ڱ� ��ġ ��Ƽ� �����ϸ� �ȴ�.
		for ( n = 0 ; n < aMentees.Length ; n++ )
		{
			// Ȱ��ȭ �Ȱ��߿��� ������� �����ؼ� ����.
			if ( aMentees[n].nLevel < nLevel || !aMentees[n].IsEnabled )
			{
				aMentees.Insert(n, 1);
				break;
			}
		}

		// �ڱ� �ڸ��� ã�Ƶ���.
		nIndex = n;

		if ( nIndex >= aMentees.Length )
			aMentees.Length = nIndex + 1;
	}
	else
	{
		// Ȱ��ȭ ���� ���� ��쿡�� �ִ� ���� ã�Ƶ��⸸ �ϰ� (�������� �ʾƵ� �ǹǷ�)
		for ( n = 0 ; n < aMentees.Length ; n++ )
		{
			if ( aMentees[n].nSlotIndex == nSlotIndex )
				break;
		}

		nIndex = n;

		// ���� ��쿡�� ���� ������ش�.
		if ( nIndex >= aMentees.Length )
			aMentees.Length = nIndex + 1;
	}

	aMentees[nIndex].nSlotIndex = nSlotIndex;
	aMentees[nIndex].strMenteeName	= strMenteeName;
	aMentees[nIndex].nlevel = nLevel;
	aMentees[nIndex].IsEnabled = IsEnable;
	aMentees[nIndex].nReputePoint	= nReputePoint;
	aMentees[nIndex].JobName = JobName;
}


// ���ڰ� �����Ǵ� ���� ������ �����߿� ������ �ƴѰ�쿡�� �ش�ȴ�.
function NetRecv_LeaveMentorSystem(int nSlotIndex)
{
	local int n;
	local int nTemp;

	for ( n = 0 ; n < aMentees.Length ; n++ )
	{
		if ( aMentees[n].nSlotIndex == nSlotIndex )
		{
			aMentees.Remove(n, 1);
			nTemp = n;
			break;
		}
	}

	for ( n = nTemp ; n < aMentees.Length ; n++ )
	{
		if ( aMentees[n].strMenteeName != "" )
			continue;

		if ( aMentees[n].IsEnabled == False )
			break;

		if ( aMentees[n].nSlotIndex > nSlotIndex )
			break;
	}

	aMentees.Insert(n, 1);

	aMentees[n].nSlotIndex = nSlotIndex;
	aMentees[n].strMenteeName	= "";
	aMentees[n].nlevel = 0;
	aMentees[n].IsEnabled = True;
	aMentees[n].nReputePoint	= 0;
	aMentees[n].JobName = '';
}


// ������ ���������� ����Ǹ�
// �ƹ��� ������ ����� �Ѵ�.
function NetRecv_ResetMentorSystem()
{
	local int n;
	local int nCount;

	strMentorName = "";
	aMentees.Length = 0;
}


function NetRecv_MentorPreInfo(string strName, int MaxLevel, int nCurrMenteeNum, int nEmptySlots, int nCurrReputationPoint)
{
	SephirothInterface(myHud).XMenu.SetPreInfo(strName, MaxLevel, nCurrMenteeNum, nEmptySlots, nCurrReputationPoint);
}


function NetRecv_UpdateMentorLevel(int nLevel)
{
	nMentorLevel = nLevel;
}


// Booth
event NetRecv_BoothFee(string FeeString)
{
	SephirothInterface(myHud).OnBoothFee(FeeString);
}

event NetRecv_BoothOpen()
{
	SephirothInterface(myHud).OnBoothOpen();
}

event NetRecv_BoothState()
{
	SephirothInterface(myHud).OnBoothStateChange();
}

event NetRecv_BoothVisit(PlayerServerInfo Seller)
{
	SephirothInterface(myHud).OnBoothVisit(Seller);
}

event NetRecv_SellerBoothClose()
{
	SephirothInterface(myHud).OnSellerBoothClose();
}

event NetRecv_GuestBoothClose()
{
	SephirothInterface(myHud).OnGuestBoothClose();
}

function AskBoothVisit(Hero Hero)
{
	SephirothInterface(myHud).AskBoothVisit(Hero);
}
// Booth END

event NetRecv_StashLobbyOpen()
{
	SephirothInterface(myHud).OnOpenStashLobby();
}

event NetRecv_StashOpen()
{
	SephirothInterface(myHud).OnOpenStashBox();
}

event NetRecv_NpcDialog(NpcServerInfo NpcSI, string Dialog)
{
	local Npc Npc;
	Npc = Npc(Controller(NpcSI.Owner).Pawn);
	SephirothInterface(myHud).OnDialog(Npc,Dialog);
}

function OpenXMenu(Hero Hero)
{
	SephirothInterface(myHud).OnXMenu(Hero);
}

function NetRecv_Dead()
{
	SephirothInterface(myHud).OnPlayerDead();
}

event NetRecv_UpdateZone()
{
	SephirothInterface(myHud).OnUpdateZone();
}

event NetRecv_StartItemTransform()
{
	SephirothInterface(myHud).OnCompoundStart();
}

event OnSmithDlg() //add neive : 12�� ������ ����
{
	SephirothInterface(myHud).OnSmithStart();
}

event OnWorldMap()
{
	SephirothInterface(myHud).OnWorldMapStart();
}

event OnNPCSearch(string sName)
{
	SephirothInterface(myHud).OnNPCSearch(sName);
}

event OpenCompoundMenu(array<int> Dealings)
{
	SephirothInterface(myHud).OnOpenCompound(Dealings);
}

function FollowPlayer(Hero Player)
{
	if ( Player != None && !Player.bDeleteMe ) 
	{
		bTracePlayer = True;
		TracePlayer = Player;
//		//Log(Self@"FollowPlayer"@bTracePlayer@TracePlayer);
		GotoState('TracingEx','Trace');
	}
}

function ActivateTickInterfaceController()
{
	if ( myHud != None && SephirothInterface(myHud).Controller != None )
		SephirothInterface(myHud).Controller.bRequiresTick = True;
}

function NetRecv_Restart()
{
	Super.NetRecv_Restart();
	SephirothInterface(myHud).OnRestart();
}

event NetRecv_PlayerOut(PlayerServerInfo PSI, Pawn Pawn)
{
	SephirothInterface(myHud).OnPlayerOut(PSI,Pawn);
}

event NetRecv_Disconnected(string Result)
{
//	local string ResultMsg;
	SephirothInterface(myHud).OnDisconnected();
	//SephirothInterface(myHud).OnDisconnected(Result);
}

event NetRecv_DisconnectError(string Result)
{
	SephirothInterface(myHud).OnDisconnected(Result);
}

event NetRecv_ReadingQuestDone()
{
	local CQuest Q;
	Q = SephirothInterface(myHud).Quest;
	if ( Q != None ) 
	{
		Q.bIsWaitingData = False;
	}
}


//@by wj(12/12) Castle
event NetRecv_CastleInfo()
{
	//Log("=====>SephirothPlayer NetRecv_CastleInfo");
	if( SephirothInterface(myHud).CastleManager == None )
	{
		SephirothInterface(myHud).ShowCastleManagerInterface();
	}
}
//--------------------

event PlayModeChanged()
{
	Super.PlayModeChanged();
	if ( bIsPlayer && IsTransparent() )
		SephirothInterface(myHud).MakeTransparent();
}

//@by wj(040203)------
event NetRecv_ClanMemberInfo()
{
	if( SephirothInterface(myHud).ClanInterface == None )
		SephirothInterface(myHud).ShowClanInterface();
	else
		SephirothInterface(myHud).ClanInterface.RecvClanMemberInfo();
}

event NetRecv_ClanApplicantsInfo()
{
	SephirothInterface(myHud).ClanInterface.RecvClanApplicantInfo();
}

event NetRecv_ClanApplying(string ClanName)
{
	SephirothInterface(myHud).OnClanApplying(ClanName);
}
//--------------------

//@by wj(040311)------
event NetRecv_RemodelItemDialog(int npcID,string npcName)
{
	if( SephirothInterface(myHud).RemodelingUI == None )
		SephirothInterface(myHud).ShowRemodelingUI();
	if( SephirothInterface(myHud).RemodelingUI != None )
		SephirothInterface(myHud).RemodelingUI.SetNpcName(npcID,npcName);

}

event NetRecv_RemodelItemDesc(bool bAble, string npcDialog)
{
	if( SephirothInterface(myHud).RemodelingUI == None )
		return;
	SephirothInterface(myHud).RemodelingUI.OnRemodelItemDesc(bAble, npcDialog);
}
//--------------------

event NetRecv_MessageBox(int nType, int nResult)
{
	SephirothInterface(myHud).ShowIngameShopDlg(nType, nResult);
}

/**
 * 网络接收Actor移出视野事件
 * 当服务器通知客户端某个Actor（怪物、玩家或其他角色）移出玩家视野时调用此函数
 * 此函数负责清理所有对该Actor的引用，防止悬空指针导致的崩溃
 * 
 * @param SI 服务器信息对象，包含Actor的服务器端信息
 * @param Actor 移出视野的Actor对象（可能是怪物、玩家、NPC等）
 * 
 * 注意：此函数在玩家视野移除怪物或其他角色时被调用，必须进行严格的空指针检查
 * 以防止访问已销毁对象导致的访问违规（Access Violation）崩溃
 */
event NetRecv_ActorOut(ServerInfo SI, Actor Actor)
{
	local NephilimPlayer CC;
	local SephirothInterface Interface;
	local SephirothController Controller;
	local Hero HeroActor;
	local Pawn PawnActor;

	// 调用父类处理，执行基础清理工作
	Super.NetRecv_ActorOut(SI, Actor);

	// 第一步：基础参数验证
	// 检查服务器信息和Actor是否有效，如果已标记删除则直接返回
	// 这是防止崩溃的第一道防线
	if ( SI == None || SI.bDeleteMe || Actor == None || Actor.bDeleteMe )
		return;

	// 第二步：检查UI接口是否有效
	// myHud 是玩家界面的根对象，如果为None说明界面未初始化或已销毁
	// 此时无法进行UI相关的清理操作，直接返回避免崩溃
	if ( myHud == None )
		return;

	// 第三步：类型转换并验证Interface对象
	// 将myHud转换为SephirothInterface类型，如果转换失败说明类型不匹配
	// 必须验证转换结果，避免后续访问空指针
	Interface = SephirothInterface(myHud);
	if ( Interface == None )
		return;

	// 第四步：处理玩家移出事件
	// 如果移出的是玩家角色，通知UI界面更新玩家列表
	// 例如关闭该玩家的菜单界面、移除玩家信息显示等
	// 注意：在类型转换和访问Actor之前，需要再次检查Actor是否仍然有效
	// 因为Actor可能在检查之后、访问之前被标记为删除或进入销毁过程
	if ( SI.IsA('PlayerServerInfo') && Actor != None && !Actor.bDeleteMe )
	{
		PawnActor = Pawn(Actor);
		// 类型转换后再次检查，防止Actor在转换过程中被销毁
		if ( PawnActor != None && !PawnActor.bDeleteMe )
			Interface.OnPlayerOut(PlayerServerInfo(SI), PawnActor);
	}

	// 第五步：清理Controller中的Actor引用
	// Controller可能持有该Actor的引用（如锁定目标、悬停目标等）
	// 必须清理这些引用，防止Controller访问已销毁的Actor导致崩溃
	// 在传递Actor给Controller之前，再次检查Actor是否仍然有效
	Controller = SephirothController(Interface.Controller);
	if ( Controller != None && Actor != None && !Actor.bDeleteMe )
		Controller.OnActorOut(Actor);

	// 第六步：处理Hero角色的特殊清理
	// 如果移出的是Hero类型角色（玩家或NPC），需要清理SpiritType相关的引用
	// SpiritType是精灵类型，可能持有AnimHost（动画宿主）引用
	// 注意：在类型转换Hero(Actor)之前，必须确保Actor仍然有效
	// 因为类型转换可能会触发Actor的状态检查，如果Actor正在被销毁会导致断言失败
	if ( Actor == None || Actor.bDeleteMe )
		return;
	
	HeroActor = Hero(Actor);
	// 类型转换后立即检查Actor是否仍然有效，防止在转换过程中Actor被销毁
	// 注意：类型转换Hero(Actor)可能会触发引擎的IsValid检查
	// 如果Actor正在被销毁过程中，这个检查会失败并导致断言错误
	// 因此必须在转换后立即验证Actor的有效性
	if ( HeroActor != None && !HeroActor.bDeleteMe && HeroActor.Controller != None ) 
	{
		// 获取Hero的Controller并转换为NephilimPlayer类型
		// 必须检查Controller是否存在，因为Hero可能已销毁但Controller引用仍存在
		CC = NephilimPlayer(HeroActor.Controller);
		if ( CC != None && !CC.bDeleteMe ) 
		{
			// 如果SpiritType存在且其AnimHost指向当前移出的Actor
			// 需要清空AnimHost引用，防止SpiritType访问已销毁的Actor
			// 这是防止崩溃的关键步骤之一
			// 在访问SpiritType之前，再次检查Actor是否仍然有效
			// 因为Actor可能在之前的处理过程中被标记为删除
			if ( CC.SpiritType != None && Actor != None && !Actor.bDeleteMe && CC.SpiritType.AnimHost == Actor ) 
			{
				CC.SpiritType.AnimHost = None;
			}
		}
	}

	// 第七步：清理附魔目标引用
	// 如果当前移出的Actor是玩家的附魔目标，清空附魔目标引用
	// 防止后续技能释放时访问已销毁的Actor
	// 在比较之前，确保Actor仍然有效（虽然此时Actor可能已经被标记为删除）
	if ( Actor != None && Actor == EnchantTarget )
		EnchantTarget = None;
}

function DereferenceActor(Actor actor)
{
	SephirothController(SephirothInterface(myHud).Controller).OnActorOut(actor);
}

event ItemOut(SephirothItem Item)
{
	if ( Item != None && Item.Model != None )
		DereferenceActor(Item.Model);
}

function ForceFinishInteraction(actor Actor)
{
	DereferenceActor(Actor);
}

function MovePawnToMove(Actor MoveTarget,vector Loc)
{
	local vector vTarget, vTarget2D;
/* �������϶��� �������̵��� �غ���.
   �̷��� �ϸ� ����� ����������... �Ƹ� �ĵ��ò���
	if (IsInState('Attacking'))
		return;
*/
	vTarget = Loc - Pawn.Location;
	vTarget2D = vTarget;
	vTarget2D.Z = 0;

	bKeyboardMove = False;
	InteractTo = MoveTarget;
	LockedTarget = None;
	if ( VSize(vTarget2D) > 30 ) 
	{
		GotoState('Navigating','Move');
		Destination = Loc;
		RotatePawnTo(Destination);
	}
	else
		GotoState('Navigating');
}

function MovePawnToTalk(Actor MoveTarget)
{
	local vector vTarget, vTarget2D;
	vTarget = MoveTarget.Location - Pawn.Location;
	vTarget2D = vTarget;
	vTarget2D.Z = 0;

	InteractTo = MoveTarget;
	RotatePawnTo(MoveTarget.Location);
	if ( VSize(vTarget2D) > MoveTarget.CollisionRadius + 500 ) 
	{
		GotoState('Talking','Move');
		Destination = MoveTarget.Location;
	}
	else
		GotoState('Talking','Talk');
}

function MovePawnToPick(Actor MoveTarget)
{
	local vector vTarget, vTarget2D;
	vTarget = MoveTarget.Location - Pawn.Location;
	vTarget2D = vTarget;
	vTarget2D.Z = 0;

	InteractTo = MoveTarget;
	RotatePawnTo(MoveTarget.Location);
	if ( VSize(vTarget2D) > MoveTarget.CollisionRadius + 100 ) 
	{
		GotoState('Picking','Move');
		Destination = MoveTarget.Location;
	}
	else
		GotoState('Picking','Pick');
}

function MovePawnToAttackMelee(Actor MoveTarget)
{
	local vector vTarget, vTarget2D;

	if ( CoolTime >= 0 )
		return;

	if ( ZSI != None && ZSI.bNoUseSkill )
		return;

//	if (LockedTarget == None)
	LockedTarget = Character(MoveTarget);

	if ( LockedTarget != None && !LockedTarget.bDeleteMe ) 
	{
		vTarget = LockedTarget.Location - Pawn.Location;
		vTarget2D = vTarget;
		vTarget2D.Z = 0;

		RotatePawnTo(LockedTarget.Location);
		if ( VSize(vTarget2D) > sqrt(2.0) * (2 * Pawn.CollisionRadius + LockedTarget.CollisionRadius) ) 
		{
			GotoState('MeleeAttacking','Move');
			InteractTo = LockedTarget;
			Destination = LockedTarget.Location;
		}
		else if (PSI.Combo != None) 
		{
			GotoState('MeleeAttacking','Attack');
		}
	}
}

function bool MovePawnToAttackRange(Actor MoveTarget, vector Loc)
{
	local vector vTarget;
	local bool bValid;

	if ( CoolTime >= 0 ) //check neive : ���� ���⿡ ��Ȯ�� 0.00 �� ������ ������ �ȵǹ����� (-0.00 �� �ȴ�;)
		return False;

	if ( ZSI != None && ZSI.bNoUseSkill )
		return False;

	if ( MoveTarget.bWorldGeometry || MoveTarget.IsA('TerrainInfo') || MoveTarget.IsA('StaticMeshActor') )
	{
//		//Log("=====>MovePawnToAttackRange GroundTargeting");
		if( LockedTarget != None )
			LockedTarget = None;

		vTarget = Loc;
		ActionTarget.Location = Loc;
		bValid = True;
	}
	else
	{
		LockedTarget = Character(MoveTarget);

		if ( LockedTarget != None && !LockedTarget.bDeleteMe )
		{
			vTarget = LockedTarget.Location;
			bValid = True;
		}
	}

	if ( bValid )
	{
		if ( LockedTarget != None && !LockedTarget.bDeleteMe || PSI.Magic != None && PSI.Magic.bServerHitCheck )
		{
			if( LockedTarget != Pawn ) //@by wj(03/04)----------
				RotatePawnTo(vTarget);
			GotoState('RangeAttacking','Attack');
			return True;
		}
	}

	return False;
}

//add neive : ��ü ���� ������ ����Ű�� �ڱ⿡�� ���� �Ѵ� --------------------
function bool SelfBuff()
{
	if( PSI.JobName == 'Red' || PSI.JobName == 'Blue' )
	{
		if ( PSI.Magic.bSelf )
		{
			LockedTarget = Character(Pawn);
			GotoState('RangeAttacking','Attack');
			return True;
		}
	}

	if( PSI.JobName == 'Bow' )
	{
		GotoState('SummonSpirit', 'Summon');
		return True;
	}
}

//@cs added for auto enchant plugin
/*function bool SelfBuffBySkill(Skill)
{
	if(PSI.JobName == 'Red' || PSI.JobName == 'Blue')
	{
		if (Skill.bSelf)
		{
			LockedTarget = Character(Pawn);
			GotoState('RangeAttacking','Attack');
			return true;
		}
	}

	if(PSI.JobName == 'Bow')
	{
		GotoState('SummonSpirit', 'Summon');
		return true;
	}
}*/
//-----------------------------------------------------------------------------

function MovePawnToAttackBow(Actor MoveTarget, vector Loc);

function MovePawnToTrace(Actor MoveTarget)
{
	if ( MoveTarget.IsA('Hero') )
		FollowPlayer(Hero(MoveTarget));
}

simulated function DisplayDebug(Canvas Canvas, out float YL, out float YPos)
{
	local color OldColor;
	Super.DisplayDebug(Canvas, YL, YPos);

	OldColor = Canvas.DrawColor;
	Canvas.DrawColor = class'Canvas'.Static.MakeColor(255,255,255);
	Canvas.DrawText("[My Last Damage]");
	Canvas.DrawText("    Attacker: "$ThisDamage.AttackerName);
	Canvas.DrawText("    Skill: "$ThisDamage.SkillName);
	Canvas.DrawText("    Pain: "$ThisDamage.bPain);
	Canvas.DrawText("    Knockback: "$ThisDamage.bKnockback);
	Canvas.DrawText("    Critical: "$ThisDamage.bCritical);
	Canvas.DrawText("    Miss: "$ThisDamage.bMiss);
	Canvas.DrawText("    Block: "$ThisDamage.bBlock);
	Canvas.DrawText("    Immune: "$ThisDamage.bImmune);
	Canvas.DrawColor = OldColor;
	SephirothController(SephirothInterface(myHud).Controller).DisplayDebug(Canvas, YL, YPos);
}

//event ActiveItemDetected()
//{
//	SephirothInterface(myHud).OnActiveItemDetected();
//}

function Stopped()
{
	SephirothController(SephirothInterface(myHud).Controller).OnPlayerStopped();
}

event OpenDialogMenu(NpcServerInfo NpcSI, Dialog Dialog)
{
	SephirothInterface(myHud).OnOpenDialog(NpcSI, Dialog);
}

event OpenShopMenu(NpcServerInfo NpcSI, Shop Shop)
{
	SephirothInterface(myHud).OnOpenShop(NpcSI, Shop);
}

event UpdateShopItems(ShopItems Items)
{
	SephirothInterface(myHud).OnUpdateShop(Items);
}

event OpenBankMenu(NpcServerInfo NpcSI, Bank Bank)
{
	SephirothInterface(myHud).OnOpenBank(NpcSI, Bank);
}

event OpenDepository(StashItems StashItems)
{
	SephirothInterface(myHud).OnOpenDepository(StashItems);
}

event UpdateStashInfo(int StashID)
{
	SephirothInterface(myHud).OnUpdateStashInfo(StashID);
}

event UpdateBuddyInfo() //@by wj(02/24)
{
	SephirothInterface(myHud).OnUpdateBuddyInfo();
}

//@by wj(08/21)------
event UpdateSkillCredit()
{
	SephirothInterface(myHud).OnUpdateSkillCredit();
}
//-------------------

function bool IsTalking()
{
	return SephirothInterface(myHud).DialogMenu != None;
}

// ������ ǥ�� (ũ��Ƽ�� ǥ��)
event SetDamage(Pawn aPawn,int Damage,optional int Type)
{
	if ( Player != None )
	{
		if ( DamageInteractor == None )
			DamageInteractor = DamageInteractor(Player.InteractionMaster.AddInteraction("Sephiroth.DamageInteractor",Player));
		if ( DamageInteractor == None )
			return;
		if ( aPawn == None || aPawn.bDeleteMe )
			return;

		if( Type == 0 )
			DamageInteractor.AddDamage(aPawn,Damage,DamageInteractor.DT_NotUse,DamageColor);
		else if (Type == 1) // Critical
			DamageInteractor.AddDamage(aPawn,Damage,DamageInteractor.DT_Cri,CriticalColor);
		else if(Type == 2) //@by wj(040304) Stun for PlayerOwner
			DamageInteractor.AddDamage(aPawn,Damage,DamageInteractor.DT_Stun,StunColorA);
		else if(Type == 3) //@by wj(040304) Stun for Other
			DamageInteractor.AddDamage(aPawn,Damage,DamageInteractor.DT_Stun,StunColorB);
		else if(Type == 4) //add neive : ���� ������ ǥ��
		{
			if( Damage != 1 )
				DamageInteractor.AddDamageB(aPawn,Damage,DamageInteractor.DT_NotUse,DamagedColor,1);
				//DamageInteractor.AddDamageB(aPawn,Damage,DamageInteractor.DT_NotUse,FieldDamageColor,1);
		}
		else if(Type == 5) //add neive : Ÿ�Ժ� ������ ǥ��
			DamageInteractor.AddDamage(aPawn,Damage,DamageInteractor.DT_Max,CriticalColor);
		else if(Type == 11)
			DamageInteractor.AddDamage(aPawn,Damage,DamageInteractor.DT_Immune,CriticalColor);
	}
}

event ResetWaitingAttackResult()
{
	SephirothInterface(myHud).ResetWaitingAttackResult();
}

function SpawnMissEffect(optional Pawn Attacker)
{
	local SephirothPlayer AttackerPlayer;
	
	// 如果有攻击者，优先在攻击者的屏幕上显示miss效果
	if ( Attacker != None && Attacker.Controller != None )
	{
		AttackerPlayer = SephirothPlayer(Attacker.Controller);
		if ( AttackerPlayer != None && AttackerPlayer.Player != None )
		{
			// 获取或创建攻击者的DamageInteractor
			if ( AttackerPlayer.DamageInteractor == None )
				AttackerPlayer.DamageInteractor = DamageInteractor(AttackerPlayer.Player.InteractionMaster.AddInteraction("Sephiroth.DamageInteractor", AttackerPlayer.Player));
			
			if ( AttackerPlayer.DamageInteractor != None )
			{
				// 在攻击者的屏幕上显示目标位置的miss效果
				AttackerPlayer.DamageInteractor.AddDamage(Pawn, 0, AttackerPlayer.DamageInteractor.DT_Miss, AttackerPlayer.MissColor);
				return;
			}
		}
	}
	
	// 如果没有攻击者或攻击者不是玩家，则在自身屏幕上显示（原有逻辑）
	if ( Player != None ) 
	{
		if ( DamageInteractor == None )
			DamageInteractor = DamageInteractor(Player.InteractionMaster.AddInteraction("Sephiroth.DamageInteractor",Player));
		if ( DamageInteractor == None )
			return;
		DamageInteractor.AddDamage(Pawn,0,DamageInteractor.DT_Miss,MissColor);
	}
}

function SpawnImmuneEffect(Pawn pawn)
{
	if ( Player != None ) 
	{
		if ( DamageInteractor == None )
			DamageInteractor = DamageInteractor(Player.InteractionMaster.AddInteraction("Sephiroth.DamageInteractor",Player));
		if ( DamageInteractor == None )
			return;
		DamageInteractor.AddDamage(pawn,0,DamageInteractor.DT_Immune,ImmuneColor);
	}
}

exec function SetCriticalColor(byte R, byte G, byte B)
{
	CriticalColor = class'Canvas'.Static.MakeColor(R,G,B);
}

exec function SetMissColor(byte R, byte G, byte B)
{
	MissColor = class'Canvas'.Static.MakeColor(R,G,B);
}

exec function SetDamageColor(byte R, byte G, byte B)
{
	DamageColor = class'Canvas'.Static.MakeColor(R,G,B);
}

event NetRecv_ActRange(Skill Skill, Actor TargetActor, vector TargetLocation, float ActRatio, int ActPitch);
event NetRecv_SpiritCast(Skill Skill);
event NetRecv_SpiritMagic(string SpiritName, bool bSet);

event LostChild(Actor Lost)
{
	local SephirothController Ctrl;
	Super.LostChild(Lost);

	if ( bIsPlayer && Player != None ) 
	{
		Ctrl = SephirothController(SephirothInterface(myHud).Controller);
		if ( Ctrl != None ) 
		{
			if ( Lost == Ctrl.Decal )
				Ctrl.Decal = None;
			if ( Lost == Ctrl.DecalAfter )
				Ctrl.DecalAfter = None;
		}
	}
}

//@by wj(05/19)
event PreMapChange()
{
	if( myHud != None ) 
	{
		myHud.Destroy();
		myHUD = None;
	}
}

event OnRemoveInventoryItem(SephirothItem Item)
{
	local SephirothInterface Interface;
	Interface = SephirothInterface(myHud);
	if ( Interface != None )
		Interface.OnRemoveBagItem(Item);

	Interface.Controller.ResetDragAndDropAll(); // test by BK
}

event Damaged(Pawn Attacker, Skill Skill, bool bPain, bool bKnockback, bool bCritical, bool bMiss, bool bBlock, bool bImmune)
{
	Super.Damaged(Attacker, Skill, bPain, bKnockback, bCritical, bMiss, bBlock, bImmune);
	if ( Attacker != None )
		ThisDamage.AttackerName = string(Attacker.Name);
	if ( Skill != None )
		ThisDamage.SkillName = Skill.SkillName;
	ThisDamage.bPain = bPain;
	ThisDamage.bKnockback = bKnockback;
	ThisDamage.bCritical = bCritical;
	ThisDamage.bMiss = bMiss;
	ThisDamage.bBlock = bBlock;
	ThisDamage.bImmune = bImmune;
}

function EnchantSupportMagic(Skill Skill, Actor MoveTarget)
{
/*	ThisSkill = Skill;
	if (Skill.bSelf)
		EnchantTarget = Character(Pawn);
	else
		EnchantTarget = Character(MoveTarget);

	if (ThisSkill != None && EnchantTarget != None)
		GotoState('EnchantSupport', 'Enchant');*/
}

state EnchantSupport extends Navigating
{
	ignores KeyboardMove,
	MovePawnToMove,
	MovePawnToTalk,
	MovePawnToAttackMelee,
	MovePawnToPick,
	MovePawnToTrace,
	MovePawnToAttackRange,
	MovePawnToAttackBow,
	FindNearestItem;

	function bool CanStop(float Dist) 
	{ 
		return True; 
	}

	function AchieveGoal()
	{
		if (ThisSkill == None) 
		{
			GotoState('Navigating');
			return;
		}

		if(!CanUseAllSkill())		// ��ų ��� ���� üũ
		{
			myHud.AddMessage(2,
				Localize("Warnings", "CannotUseSkill", "Sephiroth"),
				class'Canvas'.Static.MakeColor(255,255,255));
			GotoState('Navigating');
			return;
		}

		if(PSI.CheckBuffDontAct()) //add neive : 12�� ������ ���̽� ������ ȿ�� ����Ű ��� ����
		{
			myHud.AddMessage(2, Localize("Warnings","CannotUseSkill","Sephiroth"),class'Canvas'.Static.MakeColor(55,55,200));
			return;
		}

		if (InStr(ThisSkill.BookName, "Support") == -1) 
		{
			GotoState('Navigating');
			return;
		}

		if (ThisSkill != None && !(ThisSkill.bEnabled && ThisSkill.bLearned)) 
		{
			GotoState('Navigating');
			return;
		}

		if (ThisSkill.ManaConsumption > PSI.Mana) 
		{
			myHud.AddMessage(2, Localize("Warnings", "NeedMana", "Sephiroth")@ThisSkill.FullName@Localize("Warnings", "CannotUseSkill", "Sephiroth"), class'Canvas'.Static.MakeColor(255,255,255));
			GotoState('Navigating');
			return;
		}

		if (ThisSkill.bHasSkillPoint && ThisSkill.SkillPoint == 0) 
		{
			myHud.AddMessage(2, Localize("Warnings", "NeedSkillPoint", "Sephiroth")@ThisSkill.FullName@Localize("Warnings", "CannotUseSkill", "Sephiroth"), class'Canvas'.Static.MakeColor(255,255,255));
			GotoState('Navigating');
			return;
		}


		if (PlayAction(ThisSkill, 0, 3.0))
			SpawnCastEffect(ThisSkill);
	}

	function PlayerMove(float DeltaTime)
	{
		aForward = 0;
		aStrafe = 0;
		Super.PlayerMove(DeltaTime);
	}

	function AnimStep(int Channel)
	{
		BroadcastFire(ThisSkill);
		EnchantTarget = None;
	}

	function AnimEnd(int Channel)
	{
		local float Delay;
		Delay = ThisSkill.MagicCastingDelay / 1000.f;
		SetTimer(Delay, False);
	}

	function Timer()
	{
		bIsActing = False;
		Character(Pawn).StartIdle(True, 0.3);
		GotoState('Navigating');
	}

	function BroadcastAction(Skill Skill, float Speed, float Delay)
	{
		local int Seq, Id;
		if (Skill == None || Speed == 0.f)
			return;
		if (EnchantTarget == None || EnchantTarget.bDeleteMe || EnchantTarget.bIsDead) 
		{
			SkillFrame.ResetSkillFrame();
			return;
		}
		if (SkillFrame.LastState != SkillFrame.STATE_None)
			SkillFrame.ResetSkillFrame();
		Seq = SkillFrame.AdvanceFrame();
		if (Hero(EnchantTarget) != None)
			Id = ClientController(EnchantTarget.Controller).PSI.PanID;
		else if (Creature(EnchantTarget) != None)
			Id = ServerController(EnchantTarget.Controller).MSI.PanID;
		else
			Id = 0;
		Net.NotiCast(Skill.SkillName, Seq, Id, EnchantTarget.Location, Character(Pawn).ActionSpeedRate);
		SkillFrame.NewSkillFrame(Seq, SkillFrame.STATE_Cast);
	}

	function int BroadcastFire(Skill Skill)
	{
		local int Seq, Id;
		if (Skill == None)
			return -1;
		if (EnchantTarget == None || EnchantTarget.bDeleteMe || EnchantTarget.bIsDead) 
		{
			SkillFrame.ResetSkillFrame();
			return -1;
		}
		Seq = SkillFrame.FindSkillFrame(SkillFrame.STATE_Cast);
		if (Hero(EnchantTarget) != None)
			Id = ClientController(EnchantTarget.Controller).PSI.PanID;
		else if (Creature(EnchantTarget) != None)
			Id = ServerController(EnchantTarget.Controller).MSI.PanID;
		else
			Id = 0;
		Net.NotiFire(Seq, Id, EnchantTarget.Location);
		return Seq;
	}

Enchant:
	AchieveGoal();
}

event NetRecv_StartStun(bool bySelf)
{
	GotoState('Stunning');
	Character(Pawn).CHAR_PlayWaiting();
	if( bySelf )
		SephirothController(SephirothInterface(myHud).Controller).bLostControl = True;
}

event NetRecv_FinishStun(bool bySelf)
{
	if( bySelf )
		SephirothController(SephirothInterface(myHud).Controller).bLostControl = False;
	GotoState('Navigating');
}

state Stunning extends Navigating
{
	ignores KeyboardMove,
	MovePawnToMove,
	MovePawnToTalk,
	MovePawnToAttackMelee,
	MovePawnToPick,
	MovePawnToTrace,
	MovePawnToAttackRange,
	MovePawnToAttackBow,
	FindNearestItem,
	Jump;

	function BeginState()
	{
	}

	function EndState()
	{
	}

	function PlayerMove(float DeltaTime)
	{
		aForward = 0;
		aStrafe = 0;
		Super.PlayerMove(DeltaTime);
	}
}

//@by wj(09/30)------
/*
exec function CreatePet(name MeshName, name AnimName)
{
	if (TestPet == None)
		TestPet = Spawn(class'TestPet',Pawn, ,Pawn.Location,Pawn.Rotation);
	if (TestPet == None)
		return;
//	Character(Pawn).AttachToBone(TestPet,Character(Pawn).BoneSpine);

//	TestPet.SetPhysics(PHYS_Trailer);
//	TestPet.bTrailerPrePivot = true;
//	TestPet.PrePivot = vect(100, 0, 0);

	TestPet.SetBase(Pawn);
	TestPet.SetRelativeLocation(vect(0, 100, 0));
	//Log("=======>"@TestPet.RelativeLocation);
	//TestPet.PivotLoc.Y = 100;
	//TestPet.PivotLoc.Y = 0;
	if (MeshName != '' && AnimName != '')
		TestPet.ChangePetMesh(string(MeshName), string(AnimName));
}*/

exec function CreatePet(name MeshName, name AnimName)
{
	local vector TempOffset;

	if ( Pet == None )
		Pet = Spawn(class'Pet',Pawn, ,Pawn.Location,Pawn.Rotation);
	if ( Pet == None )
		return;

	Pet.SetBase(Pawn);
	if( MeshName == 'Egg' )
	{
		TempOffset = vect(0, -20,0);
		TempOffset.Z = Pawn.CollisionHeight - 20;
		Pet.SetRelativeLocation(TempOffset);
		SpawnEggGlow();
	}
	/*
	else{
		Pet.SetRelativeLocation(TempOffset);
	}*/

	if ( MeshName != '' && AnimName != '' )
		Pet.ChangePetMesh(string(MeshName), string(AnimName));
	SpawnPetInOutEffect(string(MeshName));
	if( Pet.MeshName == 'Egg' )
		SpawnEggGlow();
}


exec function DestroyPet()
{
	/*
	SpawnPetInOutEffect(string(Pet.MeshName));
	if(Pet == None)
		return;

	Pet.Destroy();
	Pet = None;
	*/
	Net.NotiPetToCage();
}

exec function ChangePet(name MeshName, name AnimName)
{
	if( Pet == None || MeshName == '' || AnimName == '' )
		return;

//	Pet.SetRelativeLocation(vect(0, 50, 0));
	if( Pet.MeshName == 'Egg' )
		SpawnPetInOutEffect(string(Pet.MeshName));

	pet.ChangePetMesh(string(MeshName), string(AnimName));
	SpawnPetChangeEffect(string(Pet.MeshName));
}

exec function ShowPetComment()
{
	if( Pet != None )
	{
		Pet.bBalloon = True;
		Pet.BalloonString = Localize("Information","JobChangeGuide2","Sephiroth");
		Pet.BalloonTick = Character(Pawn).BalloonTick;
		Pet.BalloonDuration = 60.f;
	}
}

exec function ChangePosition(INT Position)
{
	Pet.SetPosition(Position);
}
//-------------------

exec function SetAnimation(name AnimName)
{
	Pet.PET_PlayAction(AnimName);
}

function OnPetCreate()
{
	if( myHud != None )
	{
		SephirothInterface(myHud).bPetSummon = True;
		SephirothInterface(myHud).ShowPetFace();
	}
}

function OnPetDestroy()
{
	if( myHud != None )
	{
		SephirothInterface(myHud).HidePetInterface();
		SephirothInterface(myHud).bPetSummon = False;
		SephirothInterface(myHud).HidePetFace();
	}
}

function PlayerJustDead()
{
	SephirothInterface(myHud).OnPlayerJustDead();
}
//@by wj(040622)------
event NetRecv_PetInvenResize(int Width, int Height)
{
	PSI.PetInventory.InvenWidth = Width;
	PSI.PetInventory.InvenHeight = Height;
	SephirothInterface(myHud).PetBag.SetInvenSize(Width, Height);
}

event OpenPetDialogInterface()
{
	SephirothInterface(myHud).ShowPetChat();
}
//--------------------

//@by wj(040327)------
event CameraShake(float OffsetX, float OffsetY, float OffsetZ, int MaxCount)
{
	//Log("=====>CameraShake "$bCameraShaking@OffsetX@OffsetY@OffsetZ@MaxCount);
	if( bCameraShaking )
		return;
	bCameraShaking = True;
	ShakeFactor.TickCount = 0;
	ShakeFactor.Offset.X = OffsetX;
	ShakeFactor.Offset.Y = OffsetY;
	ShakeFactor.Offset.Z = OffsetZ;
	ShakeFactor.MaxCount = MaxCount;
	ShakeFactor.OldOffset.X = CameraBias;
	ShakeFactor.OldOffset.Y = CameraDist;
	ShakeFactor.OldOffset.Z = CameraHeight;
	//SephirothInterface(myHud).ScreenBlending(255, 255, 255, 150, 0, 1, 150);
}
//@by wj(040805)------
event NetRecv_ScreenEffectStart(int Id, int R, int G, int B, int A)
{
	SephirothInterface(myHud).ScreenBlending(byte(R),byte(G),byte(B),byte(A),0,0,0);
}

event NetRecv_ScreenEffectEnd(int Id)
{
	SephirothInterface(myHud).HideScreenEffect();
}

exec function BlindStart()
{
	SephirothInterface(myHud).ScreenBlending(255,255,255,100,0,0,0);
}

exec function BlindEnd()
{
	SephirothInterface(myHud).HideScreenEffect();
}
//--------------------
//ksshim + 2004.8.23
event ChangeManaState()
{
	SephirothInterface(myHud).ChangeManaState();
}
//ksshim END

event UpdateChannel(bool bForceOn,optional bool bLeftEar)		//bForceOn  -  bListen_channel1(Ȥ�� 2)�� ������ true�� ����	//bLeftEar - ���� �Ҷ����� �ƴ���
{
	SephirothInterface(myHud).ChannelMgr.UpdateChannel(bForceOn,bLeftEar);
}

event NetRecv_Die(bool bVanished)
{
	Super.NetRecv_Die(bVanished);
	SephirothInterface(myHud).bVanished = bVanished;
}

event UpdateMatchInfo()
{
	SephirothInterface(myHud).ChannelMgr.UseTeamChannel();
}

// Team Battle
event NetRecv_NotiEnterMatch(string MatchName, int remain_sec)
{
	SephirothInterface(myHud).AddBattleInterface(MatchName);
	SephirothInterface(myHud).BattleInterface.UpdateTeamBattleMessage(MatchName, remain_sec);
}

event NetRecv_NotiMatchWait(string MatchName, int WaitTime)
{
	SephirothInterface(myHud).BattleInterface.HideTeamBattleMessage();
	SephirothInterface(myHud).BattleInterface.ShowBattleWaitTimer(MatchName, WaitTime);
}


event NetRecv_NotiStartMatch(string MatchName, int DurationTime)
{
	SephirothInterface(myHud).AddBattleInterface(MatchName);
	//SephirothInterface(myHud).BattleInterface.ShowBattleWaitTimer(MatchName, DurationTime);
	SephirothInterface(myHud).PlayerOwner.ClientSetMusic("OnBattle.ogg", MTRAN_Fade);
	SephirothInterface(myHud).BattleInterface.ShowBattleScore();
	SephirothInterface(myHud).BattleInterface.ShowBattleMessage();
}

event NetRecv_NotiEndMatch(string MatchName, int Result, int MatchWaitQuitTime)
{
	SephirothInterface(myHud).BattleInterface.HideBattleScore();
	SephirothInterface(myHud).BattleInterface.HideBattleWaitTimer();
	SephirothInterface(myHud).BattleInterface.ShowBattleEndingEffecter(MatchName,Result);
	SephirothInterface(myHud).ChannelMgr.SetChannelMode(0);
	//SephirothInterface(myHud).BattleInterface.ShowBattleQuitMessage(MatchName, 15);
}

event NetRecv_NotiUpdateMatchScore(string MatchName, int TeamAScore, int TeamBScore)
{
	SephirothInterface(myHud).BattleInterface.UpdateBattleScore(TeamBScore, TeamAScore);
}

simulated function BattleNotiPlayerKillMessage(string killPlayerName, string killPlayerTeam, string deathPlayerName, string deathPlayerTeam)
{
	SephirothInterface(myHud).BattleInterface.UpdateBattleMessage(killPlayerName, killPlayerTeam, deathPlayerName, deathPlayerTeam);
}

event NetRecv_NotiPlayerKillMessage(string MatchName, string kill_player_Name, string kill_player_Team, string death_player_Name, string death_player_Team)
{
	SephirothInterface(myHud).BattleInterface.UpdateBattleMessage(kill_player_Name, kill_player_Team, death_player_Name, death_player_Team);
}

event NetRecv_NotiSubInvenInfoUpdate(int Index, string EndTime, int Validity, bool bCommandOpen)	
{

	//local int i;

	//Log("NotiSubInvenInfoUpdate"@Index@EndTime@Validity@bCommandOpen);

	//�ش� �κ��丮�� ����ð� ����,
	if( SephirothInterface(myHud).SubInventories[Index] != None )
		SephirothInterface(myHud).SubInventories[Index].UpdateEndTime();

	// Ȯ�� �κ��丮 ���� ��ư�� ����.
	//	SephirothInterface(myHud).m_InventoryBag.SubSelectBox.UpdateOpenButtons();
	// �׷��� SelectBox�� InventoryBag�� �������� ���� �� �ִ�. Xelloss
	if ( SephirothInterface(myHud).SubSelectBox != None )
		SephirothInterface(myHud).SubSelectBox.UpdateOpenButtons();

	if( bCommandOpen ) // && ( SephirothInterface(myHud).SubInventories[Index]==None ) )
		SephirothInterface(myHud).ShowSubInventory(Index);
		//SephirothInterface(myHud).m_InventoryBag.SubSelectBox.OnSubInvenButtonEvent(Index);
}

event NetRecv_NotiResponeOtp(int Otp, int ServerID)
{
	//Log("NotiResponOTP"@Otp);
	if( !SephirothInterface(myHud).IsWebbrowserOn() )
		SephirothInterface(myHud).ShowWebBrowser(Otp,ServerID);
}

event NetRecv_NotiResponeConfirmNewGrantItem(int nNewGrantItem)
{
	//Log("NotiResponNewGrantItem"@nNewGrantItem);
	SephirothInterface(myHud).NotifyNewGrantItem(nNewGrantItem);
}

event NetRecv_NotiRandomBoxResult( string strTypeName, string strModelName, string LocalizedDescription )
{
	SephirothInterface(myHud).ResultRandombox( strTypeName, strModelName, LocalizedDescription );
}

function OpenRandomBox( SephirothItem ISI, optional int nSubIndex )
{
	SephirothInterface(myHud).ShowRandomBox(ISI,nSubIndex);
}

// keios - HP ������ ���¸� ó��(SephirothPlayer) (���̶���� �׷��� �ɷ��� ��)
event OnUpdateHPGauge(int gauge_effect)
{
	HPGaugeStatus.gauge_effect = gauge_effect;
	SephirothInterface(myHud).UpdateHPGauge();
}

// keios - enchant icon box ui update
event OnUpdateUI_EnchantBox()
{
	SephirothInterface(myHud).EnchantBoxUI.OnUpdate();
}


event NetRecv_NotiDissolveOpen( string strCategoryName )
{
	SephirothInterface(myHud).ShowDissolveBox(strCategoryName);
}

event NetRecv_NotiDissolveResult( int nErrCode, array<string> strItem, array<string> strModel, array<int> nItemCount )
{
	SephirothInterface(myHud).ResultDissolve( nErrCode, strItem, strModel, nItemCount );
}

// keios - ���� item�̳� ��ų�� ����� �� �ִ� �����ΰ�?
function bool CanUseItemNow()
{
	// ��������
	if( SephirothInterface(myHud).SellerBooth != None || SephirothInterface(myHud).GuestBooth != None )
		return False;

	return True;
}

function bool CanUseAllSkill()
{
	// ���� = ��ų ��� �Ұ� ����
	if( PSI.StateNoUseSkill )
		return False;

	// ��������
	if( SephirothInterface(myHud).SellerBooth != None || SephirothInterface(myHud).GuestBooth != None )
		return False;

	return True;
}

function bool CanUse2ndSkill()
{
	// ���� = ��ų ��� �Ұ� ����
	if( PSI.StateNoUseSkill )
		return False;

	// ��������
	if( SephirothInterface(myHud).SellerBooth != None || SephirothInterface(myHud).GuestBooth != None )
		return False;

	if( PSI.CheckBuffDontUseSkill() )
		return False;

	return True;
}


// keios - skill�� target�� �� �� �ִ� actor�� ��ȯ�Ѵ�.
function Actor GetSkillTargetActor(out vector HitLocation)
{
	local SephirothInterface interface;
	local SephirothController controller;
	local Actor localMoveTarget;
	local vector hitnormal;
	local vector vieworigin, direction, mousepos;

	interface = SephirothInterface(myHud);
	controller = SephirothController(interface.Controller);


	if ( controller.IsValidContext(controller.HoverContext, 3.0) )
	{
		localMoveTarget = controller.HoverContext.Actor;
		if ( localMoveTarget != None )
			HitLocation = localMoveTarget.Location;
	}
	else 
	{
		vieworigin = Location;
		mousepos.X = controller.MouseX;
		mousepos.Y = controller.MouseY;
		direction = interface.ScreenToWorld(mousepos);
		localMoveTarget = Trace(HitLocation, hitnormal, vieworigin + 5000 * direction, vieworigin, True);
	}

	return localMoveTarget;
}


//@cs added for ��չ�����ʹ�÷�����������: SendMsgToClient(SM_Notice, "+-+-+-PICKUPFAIL");
event NetRecv_NotiExtendedCMD(string cmd)
{
	local SephirothInterface interface;

	//Log("NetRecv_NotiExtendedCMD("@cmd@")");
	if( cmd == "+-+-+-PICKUPFAIL" )
	{
		interface = SephirothInterface(myHud);
		SephirothController(interface.Controller).RecvEventToDisableAutoPickup();
	}


}

defaultproperties
{
	bNoUseChatEraser=True
	CriticalColor=(B=47,G=252,R=47,A=255)
	CriticalFinishColor=(B=28,G=71,R=255,A=255)
	MissColor=(B=58,G=200,R=243,A=255)
	ImmuneColor=(B=128,G=128,R=128,A=255)
	DamageColor=(B=200,G=200,R=255,A=255)
	StunColorA=(B=163,G=169,R=166,A=255)
	StunColorB=(B=255,G=255,R=255,A=255)
	DamagedColor=(B=96,G=92,R=233,A=240)
	FieldDamageColor=(B=200,G=118,R=190,A=255)
}

class WornItems extends SephirothItemList
	native;

// �̰͵��� �ַ� Ŭ�󿡼� ������ ������ �� & ������ �� ǥ������ �� ����
const IP_Neck = 0;
const IP_Head = 1;
const IP_Body = 2;
const IP_Calves = 3;
const IP_RArm = 4;
const IP_LArm = 5;
const IP_RWrist = 6;
const IP_LWrist = 7;
const IP_RHand = 8;
const IP_LHand = 9;
const IP_FingerR1 = 10;
const IP_FingerR2 = 11;
const IP_FingerL1 = 12;
const IP_FingerL2 = 13;

const IP_REar = 14;
const IP_LEar = 15;

const IP_BHand = 16;

const IP_REaring = 17;      //add neive : �Ͱ��� �߰�
const IP_LEaring = 18;

const IP_Charm1 = 19;       //add neive : ���������� �������� ��ȯ
const IP_Charm2 = 20;
const IP_Charm3 = 21;
const IP_Charm4 = 22;
const IP_Charm5 = 23;
const IP_Charm6 = 24;

const IP_Pet = 25;          //add neive : �� ��� ����

const IP_Belt = 26;			//add neive : ��Ʈ �߰� 2
const IP_Emblem = 27;
const IP_Wings = 28;

const IP_Inventory = 29;
const IP_Ground = 30;
const IP_NoPlace = 31;

const MaxBodyPlace = 32;

const IP_New = 33;

const IP_Used = 9999;

const AP_None = 0x00000000;
const AP_Neck = 0x00000001;
const AP_Head = 0x00000002;
const AP_Body = 0x00000004;
const AP_Calves = 0x00000008;
const AP_Arm = 0x00000010;

const AP_Wrist = 0x00000020;
const AP_RHand = 0x00000040;	// ����
const AP_LHand = 0x00000080;	// ����
const AP_BHand = 0x00000100;	// ������

const AP_Finger = 0x00000200;
const AP_Ear = 0x00000400;
const AP_Belt = 0x00000800;		//add neive : ��Ʈ �߰� 2

const AP_Earing = 0x00001000;     //add neive : �Ͱ��� �߰�
const AP_Charm = 0x00002000;      //add neive : ���� ���ȭ
const AP_DeadPet = 0x00004000;        //add neive : ���� �� ��ȯ��

const AP_Emblem = 0x00008000;
const AP_Wings = 0x00010000;
const AP_New = 0x00020000;


var float m_fLastSwapTime;

// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)

function SephirothItem FindItem(int EquipPlace)
{
	local int i;
	for (i=0;i<Items.Length;i++)
		if (Items[i].EquipPlace == EquipPlace)
			return Items[i];
	return None;
}

function int FirstMatchedEquipPlace(int AttachPlace)
{
	switch (AttachPlace) 
	{
	case AP_Neck:
		return IP_Neck;
	case AP_Head:
		return IP_Head;
	case AP_Body:
		return IP_Body;
	case AP_Calves:
		return IP_Calves;
	case AP_Arm:
		return IP_RArm;
	case AP_Wrist:
		return IP_RWrist;
	case AP_RHand:
		return IP_RHand;
	case AP_LHand:
		return IP_LHand;
	case AP_BHand:
		return IP_RHand;
	case AP_Finger:
		return IP_FingerR1;
	case AP_Ear:
		return IP_REar;
	case AP_Earing: //add neive : �Ͱ��� �߰�
		return IP_REaring;
	case AP_Charm:  //add neive : ���� ���ȭ
		return IP_Charm1;
	case AP_DeadPet:    //add neive : ���� �� ��ȯ��
		return IP_Pet;
	case AP_Belt:		//add neive : ��Ʈ �߰�
		return IP_Belt;
	case AP_Emblem:		//add neive : ������ �߰�
		return IP_Emblem;
	case AP_Wings:
		return IP_Wings;
	case AP_New:
		return IP_New;
	default:
		return IP_NoPlace;
	}
}

function int FindEquipAblePlace(SephirothItem Item)
{
	local int i, CandidateNum, MatchedPlace;
	local SephirothItem Dest;

	if (Item == None)
		return IP_NoPlace;

	switch (Item.AttachPlace) {
	case AP_Wrist:
	case AP_Arm:
	case AP_Ear:
		CandidateNum = 2;
		break;
	case AP_Finger:
		CandidateNum = 4;
		break;
	case AP_Earing: //add neive : �Ͱ��� �߰�
		CandidateNum = 2;
		break;
	case AP_Charm:  //add neive : ���������� �������� ��ȯ
		CandidateNum = 6;
		break;
	case AP_DeadPet: //add neive : ���� �� ��ȯ��
		CandidateNum = 0;
		break;
	default:
		CandidateNum = 1;
		break;
	}

	if (CandidateNum > 0)
	{
		MatchedPlace = FirstMatchedEquipPlace(Item.AttachPlace);

		for (i=MatchedPlace;i<=min(MatchedPlace+CandidateNum-1, MaxBodyPlace-1);i++)	
			return i;
	}

	return IP_NoPlace;
}

function int FindEquipPlace(SephirothItem Item)
{
	local int i, CandidateNum, MatchedPlace, nCheckedPlace;
	local SephirothItem Dest;

	if (Item == None)
		return IP_NoPlace;

	switch (Item.AttachPlace) {
	case AP_Wrist:
	case AP_Arm:
	case AP_Ear:
		CandidateNum = 2;
		break;
	case AP_Finger:
		CandidateNum = 4;
		break;
	case AP_Earing: //add neive : �Ͱ��� �߰�
		CandidateNum = 2;
		break;
	case AP_Charm:  //add neive : ���������� �������� ��ȯ
		CandidateNum = 6;
		break;
	case AP_DeadPet: //add neive : ���� �� ��ȯ��
		CandidateNum = 0;
		break;
	default:
		CandidateNum = 1;
		break;
	}

	if (CandidateNum > 0)
	{
		MatchedPlace = FirstMatchedEquipPlace(Item.AttachPlace);

		//if(MatchedPlace > 19) //add neive : ������ġ����
		//	MatchedPlace = MatchedPlace - 4;
		nCheckedPlace = 0;
		for (i=MatchedPlace; i<=min(MatchedPlace+CandidateNum-1, MaxBodyPlace-1); i++)
		{
			Dest = FindItem(i);
			if (Dest == None)
				return i;
			else
				nCheckedPlace ++;	// ��� ������ ������ ��ã�Ҵ��� ī������ �ؼ� üũ�� �صд�
		}

		if(nCheckedPlace == CandidateNum)	// �� üũ�غ� ������ ���� ������ ���� ������ ������
			return IP_Used;					// ������ ���������� ����� ���ٴ� ���� �ȴ�
	}
	return IP_NoPlace;
}

function array<int> FindEquipPlaces(SephirothItem Item)
{
	local int i, CandidateNum;
	local SephirothItem Dest;
	local array<int> EquipPlaces;
	local int MatchedPlace;

	if (Item == None)
		return EquipPlaces;
		
	switch (Item.AttachPlace) 
	{
	case AP_Wrist:
	case AP_Arm:
	case AP_Ear:
		CandidateNum = 2;
		break;
	case AP_Finger:
		CandidateNum = 4;
		break;
	case AP_Earing: //add neive : �Ͱ��� �߰�
		CandidateNum = 2;
		break;
	case AP_Charm:  //add neive : ���������� �������� ��ȯ
		CandidateNum = 6;
		break;
	default:
		CandidateNum = 1;
		break;
	}
	
	if (CandidateNum > 0)
	{
		MatchedPlace = FirstMatchedEquipPlace(Item.AttachPlace);
		
		//if(MatchedPlace > 19) //add neive : ������ġ����
		//	MatchedPlace = MatchedPlace - 4;
			
		for (i=MatchedPlace;i<=min(MatchedPlace+CandidateNum-1, MaxBodyPlace-1);i++) {
			Dest = FindItem(i);
			if (Dest == None)
				EquipPlaces[EquipPlaces.Length] = i;
		}
	}
	return EquipPlaces;
}

//add neive : Ư�������� ��� ���� ���� ---------------------------------------
// ���⸦ ���� �ߴ°�?
function bool IsEquipWeapon()
{
	if(FindItem(IP_RHand) == None)
		return false;

	return true;
}
//-----------------------------------------------------------------------------

function bool IsSwapAbleTime(float fTime)
{
	if(fTime - m_fLastSwapTime < 3.0f)
	{
		//Log("Swap Cooltime... " $ fTime - m_fLastSwapTime);
		return false;
	}

	m_fLastSwapTime = fTime;
	return true;
}

//#############################################################################
// ���� ���� üũ
//#############################################################################

function string CheckEquip(SephirothItem Item, name JobName, int nLV, int nStr, int nDex, int nVig, int nMag, optional int nRed, optional int nBlue)
{
	local int i;

//	if(Item.IsSeal())
//		return "CheckSeal";

	if(Item.DetailType != class'GConst'.default.IDT_Earring)	// �Ͱ��̴� ���� üũ ����
	{
		if (JobName == 'White' && (Item.AttachJobMask & class'GConst'.default.EJT_White) != class'GConst'.default.EJT_White) return "CheckJob";
		if (JobName == 'Red' && (Item.AttachJobMask & class'GConst'.default.EJT_Red) != class'GConst'.default.EJT_Red) return "CheckJob";
		if (JobName == 'Blue' && (Item.AttachJobMask & class'GConst'.default.EJT_Blue) != class'GConst'.default.EJT_Blue) return "CheckJob";
		if (JobName == 'Yellow' && (Item.AttachJobMask & class'GConst'.default.EJT_Yellow) != class'GConst'.default.EJT_Yellow) return "CheckJob";
		if (JobName == 'Black' && (Item.AttachJobMask & class'GConst'.default.EJT_Black) != class'GConst'.default.EJT_Black) return "CheckJob";
		if (JobName == 'Bare' && (Item.AttachJobMask & class'GConst'.default.EJT_Bare) != class'GConst'.default.EJT_Bare) return "CheckJob";
		if (JobName == 'OneHand' && (Item.AttachJobMask & class'GConst'.default.EJT_OneHand) != class'GConst'.default.EJT_OneHand) return "CheckJob";
		if (JobName == 'TwoHand' && (Item.AttachJobMask & class'GConst'.default.EJT_TwoHand) != class'GConst'.default.EJT_TwoHand) return "CheckJob";
		if (JobName == 'Spear' && (Item.AttachJobMask & class'GConst'.default.EJT_Spear) != class'GConst'.default.EJT_Spear) return "CheckJob";
		if (JobName == 'Bow' && (Item.AttachJobMask & class'GConst'.default.EJT_Bow) != class'GConst'.default.EJT_Bow) return "CheckJob";
	}

	// �䱸ġ ��
	if(Item.ItemDemands.Length > 0)
	{
		for (i=0; i<Item.ItemDemands.Length; i++)
		{
			switch (Item.ItemDemands[i].Type)
			{
			case 0: 
				if(Item.ItemDemands[i].Value > nLV)
					return "CheckLevel";
				break;
			case 1:
				if(Item.ItemDemands[i].Value > nStr)
					return "CheckStr";
				break;
			case 2:
				if(Item.ItemDemands[i].Value > nDex)
					return "CheckDex";
				break;
			case 3: 
				if(Item.ItemDemands[i].Value > nVig)
					return "CheckVig";
				break;
			case 4: 
				if(Item.ItemDemands[i].Value > nMag)
					return "CheckMag";
				break;
			case 5:
				//if(Item.ItemDemands[i].Value > nWhi)
					return "CheckWhite";
				break;
			case 6: 
				if(Item.ItemDemands[i].Value > nRed)
					return "CheckRed";
				break;
			case 7: 
				if(Item.ItemDemands[i].Value > nBlue)
					return "CheckBlue";
				break;
			case 8: 
				//if(Item.ItemDemands[i].Value > nYel)
					return "CheckYellow";
				break;
			case 9: 
				//if(Item.ItemDemands[i].Value > nBla)
					return "CheckBlack";
				break;
			}
		}
	}

	return "";
}

defaultproperties
{
}

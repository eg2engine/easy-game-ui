class SkillFrame extends Object;

const STATE_None=0;
const STATE_Melee=1;
const STATE_Cast=2;
const STATE_Fire=3;
const STATE_Pull=4;

var int SequenceNumber;
var struct __SkillFrame
{
	var int Sequence;
	var int State;
} Frames[11];		// Accessed array 'Frames' out of bounds ¹®Á¦·Î ÀÎÇØ °Á ¹è¿­ Å©±â¸¦ ´Ã·È´Ù.
//} Frames[10];
var int SequencePointer;
var int LastState;

function int AdvanceFrame()
{
	SequenceNumber++;
	return SequenceNumber;
}

function NewSkillFrame(int Seq,int State) 
{
	SequencePointer = (SequencePointer+1) % 10;
	Frames[SequencePointer].Sequence = Seq;
	Frames[SequencePointer].State = State;
	LastState = State;
}

function int FindSkillFrame(int State)
{
	local int Result,i,tmpPtr;
	if (State==STATE_Melee) {
		Result = Frames[SequencePointer].Sequence;
		for (i=0;i<10;i++)
		{
			Frames[i].Sequence = 0;
			Frames[i].State = STATE_None;
			LastState = STATE_None;
		}
		return Result;
	}
	else if (State == STATE_Pull) {
		Result = Frames[SequencePointer].Sequence;
		return Result;
	}
	else if (State == STATE_Cast) {
		tmpPtr = SequencePointer+1;
		for(i=0;i<10;i++) {
			if (Frames[tmpPtr].State == State) {
				Frames[tmpPtr].State = STATE_Fire;
				LastState = STATE_Fire;
				return Frames[tmpPtr].Sequence;
			}
			tmpPtr = (tmpPtr+1) % 10;
		}
		return 0;
	}
	else {
		tmpPtr = clamp(SequencePointer+1,0,9);
		for (i=0;i<10;i++) {
			if (Frames[tmpPtr].State == State)
				break;
			tmpPtr = (tmpPtr+1) % 10;
		}
		if (i==10)
			return 0;
		Result = Frames[tmpPtr].Sequence;
		for(i=0;i<10;i++) {
			if (Frames[i].Sequence == Result && (Frames[i].State == STATE_Cast || Frames[i].State == STATE_Fire)) {
				Frames[i].Sequence = 0;
				Frames[i].State = STATE_None;
				LastState = STATE_None;
			}
		}
		return Result;
	}
}

function ResetSkillFrame()
{
	local int i;
	for (i=0;i<10;i++) {
		Frames[i].Sequence = 0;
		Frames[i].State = STATE_None;
		LastState = STATE_None;
	}
}

defaultproperties
{
     SequencePointer=-1
}

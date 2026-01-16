class CImeRichEditEx extends CImeEdit;

var int MaxLines;
var int CurrentLine;
var int LineSpace;
var bool bNewLine;
var color TextColor;

function SetMaxWidth(int InMaxWidth)
{
}

function SetMaxLines(int InLines)
{
	MaxLines = InLines;
}

function OnFlush()
{
	SetFocus(false);
	if( IME != None )
		IME = None;
}

function bool OnEnter()
{
	local array<string> Texts;

	class'CNativeInterface'.static.WrapStringToArray(IME.m_InputStr, Texts, WinWidth, "|");
	if (Texts.Length >= 0 && Texts.Length < MaxLines - 1) {
		if (Texts[Texts.Length-1] != "") {
			IME.InsertChar("|");
			bNewLine = true;
		}
	}
	return true;
}


function bool OnEscape() { return false; }
function bool OnUp() { return true; }
function bool OnDown() { return true; }
function bool OnLeft() { return true; }
function bool OnRight() { return true; }
function bool OnHome() { return true; }
function bool OnEnd() { return true; }



function SetFocus(bool bSet)
{
	Super.SetFocus(bSet);
	if (bSet && IME != None) {
		IME.UpdateStringProc = InternalUpdateStringProc;
		IME.ControlProc = None;
		IME.m_bDiscardNewLineChar = true;
		IME.m_NewLineChar = "|";
		InternalUpdateStringProc();
	}
	else if (!bSet && IME != None) {
		IME.UpdateStringProc = None;
	}
}

function bool InternalPreInsertCharProc()
{
	local array<string> Texts;
	local string TestStr;

	local array<string> txtCaret;
	local string CaretStr;

	local int i, nLength;

	Super.InternalPreInsertCharProc();

	TestStr = Left(IME.m_InputStr, IME.m_xInsertPos) $ IME.m_CompStr $ Mid(IME.m_InputStr, IME.m_xInsertPos);
	class'CNativeInterface'.static.WrapStringToArray(TestStr, Texts, WinWidth, "|");

	if ( Texts.Length > MaxLines - 1 )	{

		IME.CancelIme();
		return false;
	}

	CaretStr = Left(IME.m_InputStr, IME.m_xInsertPos);
	class'CNativeInterface'.static.WrapStringToArray(CaretStr, txtCaret, WinWidth, "|");

	CurrentLine = max(txtCaret.Length - 1, 0);
	bNewLine = false;

	nLength = 0;

	for ( i = 0 ; i < Texts.Length ; i++ )
		nLength += Len(Texts[i]);

	return true;
}


function InternalUpdateStringProc()
{
	local array<string> Texts;
	local string InputStr;

	if (bHasFocus)
		InputStr = IME.m_InputStr;
	else
		InputStr = TextStr;

	class'CNativeInterface'.static.WrapStringToArray(InputStr, Texts, WinWidth, "|");

	CurrentLine = max(Texts.Length - 1, 0);

	bNewLine = false;
}

function SetTextColor(color c)
{
	TextColor = c;
}

function SetTextColorEx(byte R, byte G, byte B)
{
	TextColor.A = 255;
	TextColor.R = R;
	TextColor.G = G;
	TextColor.B = B;
}

function OnPostRender(HUD H, Canvas C)
{
	local string Temp;
	local int i, Length;
	local float XL, YL;
	local array<string> Texts;
	local string InputStr;
	local string sCompare;
	local int nInterval, nPos;

	if (bHasFocus)
		InputStr = IME.m_InputStr;
	else
		InputStr = TextStr;

	C.WrapStringToArray(InputStr, Texts, WinWidth, "|");

	C.SetPos(WinX, WinY);
	C.DrawColor = TextColor;

	C.Style = ERenderStyle.STY_Normal;
	C.KTextFormat = ETextAlign.TA_MiddleLeft;

	// 텍스트를 그린다.
	for (i=0;i<Texts.Length;i++)
		C.DrawKoreanText(Texts[i], WinX, WinY+i*LineSpace, WinWidth, LineSpace);

	// Caret을 그린다.
	if ( bHasFocus && PlayerOwner.Level.TimeSeconds - int(PlayerOwner.Level.TimeSeconds) < 0.5 )	{

		if ( bNewLine )	{

			C.SetPos(WinX+2, WinY+LineSpace*(CurrentLine+1)+3);	
			C.TextSize("W",XL,YL);
			Controller.SetImePos(int(WinX+2)+XL, int(WinY+LineSpace*(CurrentLine+1)+3+YL));
		}			
		else if ( Texts.Length > 0 )	{

			Length = 0;
			nPos = 0;
			sCompare = InputStr;

			for ( i = 0 ; i < CurrentLine ; i++ )	{

				nInterval = Len(Texts[i]);
				nPos = Instr(Mid(InputStr, Length), "|");

				if ( nPos >= 0 && nPos <= nInterval )
					Length++;

				Length += nInterval;
			}

			Temp = Left(Texts[CurrentLine], IME.m_xCaretPos - Length);
			C.TextSize(Temp, XL, YL);

			if ( Temp == "" )	{

				C.TextSize("W", XL, YL);
				XL = 2;
			}

			C.SetPos(WinX+XL, WinY+LineSpace*CurrentLine+3);
//			Controller.SetImePos(int(WinX+XL)+10, int(WinY+LineSpace*CurrentLine+3+YL));
			Controller.SetImePos(0, 0);
		}
		else	{

			C.SetPos(WinX+2, WinY+3);
			C.TextSize("W",XL,YL);
		}

		C.SetRenderStyleAlpha();
		C.SetDrawColor(255,255,255);
		C.DrawTileStretched(Controller.WhitePen,1,YL-2);
	}
}


function bool OnKeyEvent(Interaction.EInputKey Key, Interaction.EInputAction Action, FLOAT Delta)
{
	local float xOffset, yOffset, XL, YL, XL2;
	local int Ptr;
	local string ProbeStr;
	local int i, nLength;
	local array<string> Texts;

	if ( !bHasFocus )
		return false;

	if ( Action == IST_Press )	{

		if ( Key == IK_LeftMouse )	{

			if (IME.OnSelectCandidate(Controller.MouseX, Controller.MouseY))
				return true;

			if ( IsInBounds() )	{

				bNewLine = false;
				IME.CompleteIme();
				ProbeStr = IME.m_InputStr;

				class'CNativeInterface'.static.WrapStringToArray(ProbeStr, Texts, WinWidth, "|");

				// Y축으로 먼저 가까이 가고
				yOffset = int((Controller.MouseY - WinY - 3) / LineSpace);

				if ( yOffset >= Texts.Length )	{

					IME.MoveCaret(Len(ProbeStr));

					CurrentLine = max(Texts.Length - 1, 0);
					return true;
				}

				for ( i = 0; i < yOffset ; i++ )	{

					if ( InStr(Mid(IME.m_InputStr, nLength), "|") == Len(Texts[i]) )
						nLength++;

					nLength += Len(Texts[i]);
				}

				// X축으로 찾기
				xOffset = Controller.MouseX - WinX - 10;
				CurrentLine = yOffset;
				class'CNativeInterface'.static.TextSize(Texts[CurrentLine], XL, YL);

				// 텍스트를 벗어났으면 가장 끝에 놔준다.
				if ( xOffset > XL )	{

					IME.MoveCaret(nLength + Len(Texts[CurrentLine]));
				}
				else if ( xOffset < 0 )	{

					IME.MoveCaret(nLength);
				}
				else	{

					XL = 0;
					while (XL < xOffset)
						class'CNativeInterface'.static.TextSize(Left(Texts[CurrentLine], ++Ptr), XL, YL);

					class'CNativeInterface'.static.TextSize(Left(Texts[CurrentLine], Ptr-1), XL, YL);
					class'CNativeInterface'.static.TextSize(Left(Texts[CurrentLine], Ptr), XL2, YL);

					if (abs(xOffset - XL) < abs(xOffset - XL2))
						IME.MoveCaret(nLength + Len(Left(Texts[CurrentLine], Ptr-1)));
					else
						IME.MoveCaret(nLength + Len(Left(Texts[CurrentLine], Ptr)));
				}

				return true;
			}
		}

		switch ( key )	{

			case IK_Delete :		return OnDelete();	break;
			case IK_Left :			return OnLeft();	break;
			case IK_Right :			return OnRight();	break;
			case IK_Home :			return OnHome();	break;
			case IK_End :			return OnEnd();		break;
			case IK_Escape :		return OnEscape();	break;
			case IK_Enter :			return OnEnter();	break;
			case IK_Up :			return OnUp();		break;
			case IK_Down :			return OnDown();	break;
		}
	}

	if ( Action == IST_Release )	{
		
		if ( Key >= IK_0 && Key <= IK_9 || Key >= IK_A && Key <= IK_Z )	{

			if (IME.OnKeyUp(Key))
				return true;
		}
	}

	return false;
}

defaultproperties
{
     MaxLines=8
     LineSpace=15
     TextColor=(B=255,G=255,R=255,A=255)
}

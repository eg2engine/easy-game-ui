// 自定义提示浏览器：根据后端下发的轻量标记文本绘制到主UI
// 约定：
// 1) 使用 '|' 作为分隔符（UE2 默认支持 | 换行），支持连续分隔产生空行
// 2) 行首样式前缀使用 "[X]" 标记，多个标记可叠加，最后以 ":" 结束
//    例：[F][Y][1]:折叠标题（黄色一级缩进）
//    支持：F(分区折叠标题) Y(黄) B(蓝) W(白) G(绿) R(红) O(橙) 1/2/3(缩进) >(前缀箭头)
//    多列行：[C=0,38,150]:第一列 [C]第二列 [C]第三列，列位置和内容均由后端声明
//    注意：每个固定分区各有一个 [F] 标题，点击可独立折叠/展开
// 3) 行内可选色标记：[Y]文字[/]（可叠加，但仅做简单切换）
class CCustomBrowser extends CInterface;

// 显示与排版参数（可按需求调整）
const LINE_HEIGHT = 14;
const LINE_GAP = 4;
const INDENT_WIDTH = 14;
const HEADER_HEIGHT = 20;

// 简单分段结构（用于行内颜色切换）
struct RichSegment
{
	var string Text;
	var color DrawColor;
};

// 行数据结构：保存一行的样式与分段信息
struct RichLine
{
	var array<RichSegment> Segments;
	var int Indent;
	var bool bBullet;
	var bool bTitle;
	var bool bEmpty;
	var color LineColor;
	var bool bColumns;
	var array<int> ColumnOffsets;
	var array<string> ColumnTexts;
};

// 是否显示、折叠状态、原始内容、解析后的行数据
struct BrowserSection
{
	var bool bVisible;
	var bool bCollapsed;
	var string RawContent;
	var array<RichLine> ParsedLines;
	var int TitleLineIndex;
	var float TitleLineY;
	var float LastUpdateTime;
	var int SourceId;
};

// 颜色表（可按需扩展）
var color ColorTitle;
var color ColorWhite;
var color ColorYellow;
var color ColorBlue;
var color ColorGreen;
var color ColorRed;
var color ColorOrange;

// 允许显示的最大行数（0 表示不限制）
var int MaxShowLines;

// 新增变量统一放在变量块末尾
var BrowserSection ActivitySection;
var BrowserSection RankingSection;
const RANKING_TIMEOUT = 8.0;

function OnInit()
{
}

function OnFlush()
{
	ClearSection(ActivitySection, True);
	ClearSection(RankingSection, True);
	SaveConfig();
}

// 外部调用：设置内容并可控制显示/隐藏
function SetContent(string InContent, optional bool bShow)
{
	SetSectionContent(ActivitySection, InContent, bShow);
}

function ClearContent()
{
	ClearSection(ActivitySection, False);
}

function SetVisible(bool bInVisible)
{
	// 仅控制显示状态，不改动内容
	ActivitySection.bVisible = bInVisible;
}

function bool IsVisible()
{
	// 查询当前显示状态
	return ActivitySection.bVisible;
}

function SetCollapsed(bool bInCollapsed)
{
	ActivitySection.bCollapsed = bInCollapsed;
}

function bool IsCollapsed()
{
	return ActivitySection.bCollapsed;
}

function SetRankingContent(string InContent, int InSourceId, optional bool bShow)
{
	RankingSection.SourceId = InSourceId;
	SetSectionContent(RankingSection, InContent, bShow);
	RankingSection.LastUpdateTime = Level.TimeSeconds;
}

function ClearRankingContent()
{
	ClearSection(RankingSection, True);
}

function SetRankingVisible(bool bInVisible, int InSourceId)
{
	if ( bInVisible )
	{
		RankingSection.SourceId = InSourceId;
		RankingSection.bVisible = True;
		return;
	}

	// SourceId=0 作为强制隐藏；否则只隐藏当前来源，避免不同业务互相覆盖
	if ( InSourceId != 0 && RankingSection.SourceId != InSourceId )
		return;

	ClearSection(RankingSection, True);
}

function bool IsRankingVisible()
{
	return RankingSection.bVisible;
}

function OnPreRender(Canvas C)
{
	// 当前版本无需预渲染处理
}

function OnPostRender(HUD H, Canvas C)
{
	local float YLine;

	if ( RankingSection.bVisible && Level.TimeSeconds - RankingSection.LastUpdateTime > RANKING_TIMEOUT )
		ClearSection(RankingSection, True);

	YLine = 0;
	DrawSection(C, ActivitySection, YLine);
	DrawSection(C, RankingSection, YLine);
}

function bool PointCheck()
{
	if ( ActivitySection.bVisible && ActivitySection.TitleLineIndex != -1 && IsCursorInsideAt(Components[0].X, ActivitySection.TitleLineY, Components[0].XL, LINE_HEIGHT + LINE_GAP) )
		return True;
	if ( RankingSection.bVisible && RankingSection.TitleLineIndex != -1 && IsCursorInsideAt(Components[0].X, RankingSection.TitleLineY, Components[0].XL, LINE_HEIGHT + LINE_GAP) )
		return True;
	return False;
}

function Layout(Canvas C)
{
	// 左边界保持不变，仅利用原右侧预留空间增加单行显示宽度
	MoveComponent(Components[0], True, C.ClipX - Components[0].XL - 5, C.ClipY - Components[0].YL - 100);
}

function bool IsCursorInsideInterface()
{
	return False;
}

function bool OnKeyEvent(Interaction.EInputKey Key, Interaction.EInputAction Action, float Delta)
{
	if ( Key == IK_LeftMouse && PointCheck() )
	{
		if ( Action != IST_Release )
			return True;
		if ( ActivitySection.bVisible && ActivitySection.TitleLineIndex != -1 && IsCursorInsideAt(Components[0].X, ActivitySection.TitleLineY, Components[0].XL, LINE_HEIGHT + LINE_GAP) )
			ActivitySection.bCollapsed = !ActivitySection.bCollapsed;
		else if ( RankingSection.bVisible && RankingSection.TitleLineIndex != -1 && IsCursorInsideAt(Components[0].X, RankingSection.TitleLineY, Components[0].XL, LINE_HEIGHT + LINE_GAP) )
			RankingSection.bCollapsed = !RankingSection.bCollapsed;
		return True;
	}

	return False;
}

// --------------------- 解析与绘制 ---------------------

function SetSectionContent(out BrowserSection Section, string InContent, optional bool bShow)
{
	Section.RawContent = InContent;
	if ( bShow )
		Section.bVisible = True;
	ParseSection(Section);
}

function ClearSection(out BrowserSection Section, bool bHide)
{
	Section.ParsedLines.Remove(0, Section.ParsedLines.Length);
	Section.RawContent = "";
	Section.TitleLineIndex = -1;
	Section.LastUpdateTime = 0;
	Section.SourceId = 0;
	if ( bHide )
		Section.bVisible = False;
}

function DrawSection(Canvas C, out BrowserSection Section, out float YLine)
{
	local float X, Y, XL, YL, UsedY;
	local int i, nShown;
	local string CollapseMark, TitleText;

	Section.TitleLineY = -1;
	if ( !Section.bVisible )
		return;

	X = Components[0].X;
	Y = Components[0].Y;
	XL = Components[0].XL;
	YL = Components[0].YL;
	nShown = 0;
	for ( i = 0; i < Section.ParsedLines.Length; i++ )
	{
		if ( i == Section.TitleLineIndex )
		{
			Section.TitleLineY = Y + YLine;
			if ( Section.bCollapsed )
				CollapseMark = "[+]";
			else
				CollapseMark = "[-]";
			TitleText = CollapseMark@GetLinePlainText(Section.ParsedLines[i]);
			C.SetDrawColor(ColorTitle.R, ColorTitle.G, ColorTitle.B, 255);
			UsedY = DrawKoreanTextMultiLine(C, X, Y + YLine, XL, LINE_HEIGHT, 0, LINE_HEIGHT + LINE_GAP, TitleText);
			// DrawKoreanTextMultiLine 返回额外换行高度，单行标题仍需加上基础行高
			YLine += UsedY + LINE_HEIGHT;
			nShown++;
			if ( Section.bCollapsed )
				break;
			continue;
		}
		if ( Section.TitleLineIndex != -1 && i > Section.TitleLineIndex && Section.bCollapsed )
			continue;
		if ( Section.ParsedLines[i].bEmpty )
		{
			YLine += LINE_HEIGHT + LINE_GAP;
			continue;
		}
		if ( Section.ParsedLines[i].Segments.Length == 0 )
			continue;
		if ( MaxShowLines > 0 && nShown >= MaxShowLines )
			break;
		UsedY = DrawLine(C, Section.ParsedLines[i], X, Y + YLine, XL);
		YLine += UsedY;
		nShown++;
		if ( YLine > YL )
			break;
	}
}

function ParseSection(out BrowserSection Section)
{
	local array<string> Lines;
	local int i;
	local RichLine Line;
	local string RawLine;
	local string NormalizedContent;
	local bool bWasCollapsed;	// 保存当前的折叠状态，避免更新内容时自动展开

	// 保存当前的折叠状态，避免更新内容时自动展开
	bWasCollapsed = Section.bCollapsed;

	// 先将所有换行符替换为 |，统一处理
	NormalizedContent = ReplaceNewlinesWithPipe(Section.RawContent);

	// 将原始内容拆分为多行并解析
	Section.ParsedLines.Remove(0, Section.ParsedLines.Length);
	Lines = SplitByPipe(NormalizedContent);

	for ( i = 0; i < Lines.Length; i++ )
	{
		RawLine = TrimLine(Lines[i]);
		Line = BuildLine(RawLine);
		Section.ParsedLines[Section.ParsedLines.Length] = Line;
	}

	// 查找 [F] 折叠标记行（全局只有一个）
	
	Section.TitleLineIndex = -1;
	for ( i = 0; i < Section.ParsedLines.Length; i++ )
	{
		if ( Section.ParsedLines[i].bTitle )
		{
			if ( Section.TitleLineIndex == -1 )
			{
				Section.TitleLineIndex = i;
			}
			else
			{
				// 如果已经有折叠标记，清除多余的 [F] 标记，作为普通内容显示
				Section.ParsedLines[i].bTitle = False;
				// 如果颜色是 ColorTitle（只有[F]标记），则改为默认白色
				if ( Section.ParsedLines[i].LineColor.R == ColorTitle.R &&
					Section.ParsedLines[i].LineColor.G == ColorTitle.G &&
					Section.ParsedLines[i].LineColor.B == ColorTitle.B )
				{
					Section.ParsedLines[i].LineColor = ColorWhite;
				}
			}
		}
	}
	
	// 如果找到了折叠标记，保持之前的折叠状态；如果没有折叠标记，默认展开
	if ( Section.TitleLineIndex == -1 )
		Section.bCollapsed = False;	// 没有折叠标记时，默认展开
	else
		Section.bCollapsed = bWasCollapsed;	// 有折叠标记时，保持之前的折叠状态
}

function string GetLinePlainText(RichLine Line)
{
	local int i;
	for ( i = 0; i < Line.Segments.Length; i++ )
		if ( Line.Segments[i].Text != "" )
			return Line.Segments[i].Text;
	return "";
}

function RichLine BuildLine(string RawLine)
{
	local RichLine Line;
	local string Prefix, Content;
	local int ColonPos;

	// 默认颜色为白色
	Line.LineColor = ColorWhite;

	if ( RawLine == "" )
	{
		// 空行直接占位
		Line.bEmpty = True;
		return Line;
	}

	ColonPos = InStr(RawLine, ":");
	if ( ColonPos > 0 && Left(RawLine, 1) == "[" )
	{
		// 行首样式前缀：[X][Y]:Text
		Prefix = Left(RawLine, ColonPos);
		Content = Mid(RawLine, ColonPos + 1);
		ApplyPrefixTokens(Prefix, Line);
	}
	else
	{
		// 无前缀则整行按默认颜色处理
		Content = RawLine;
	}

	Content = TrimLine(Content);
	if ( Line.bColumns )
	{
		ParseColumnTexts(Content, Line.ColumnTexts);
		if ( Line.ColumnTexts.Length != Line.ColumnOffsets.Length )
			Line.bColumns = False;
		Content = JoinColumnTexts(Line.ColumnTexts);
	}
	// 解析行内颜色标记并生成分段
	ParseInlineSegments(Content, Line.LineColor, Line.Segments);

	return Line;
}

function ApplyPrefixTokens(string Prefix, out RichLine Line)
{
	local string Token;
	local int ClosePos;
	local string Rest;

	// 扫描所有 [X] 标记
	Rest = Prefix;
	while ( True )
	{
		if ( Left(Rest, 1) != "[" )
			break;

		ClosePos = InStr(Rest, "]");
		if ( ClosePos <= 1 )
			break;

		Token = Mid(Rest, 1, ClosePos - 1);
		ApplyToken(Token, Line);
		Rest = Mid(Rest, ClosePos + 1);
	}
}

function ApplyToken(string Token, out RichLine Line)
{
	local string UpperToken;
	UpperToken = Caps(Token);
	if ( Left(UpperToken, 2) == "C=" )
	{
		ParseColumnOffsets(Mid(Token, 2), Line.ColumnOffsets);
		Line.bColumns = Line.ColumnOffsets.Length > 0;
		return;
	}

	// 将标记映射为样式
	switch ( UpperToken )
	{
		case "F":
			// [F] 折叠标记：标记该行为折叠标题行
			Line.bTitle = True;
			Line.LineColor = ColorTitle;
			break;
		case "T":
			// [T] 是历史兼容标记，不创建新的折叠标题
			break;
		case "Y": Line.LineColor = ColorYellow; break;
		case "B": Line.LineColor = ColorBlue; break;
		case "W": Line.LineColor = ColorWhite; break;
		case "G": Line.LineColor = ColorGreen; break;
		case "R": Line.LineColor = ColorRed; break;
		case "O": Line.LineColor = ColorOrange; break;
		case "1": Line.Indent = 1; break;
		case "2": Line.Indent = 2; break;
		case "3": Line.Indent = 3; break;
		case ">": Line.bBullet = True; break;
	}
}

function ParseColumnOffsets(string Spec, out array<int> Offsets)
{
	local int CommaPos, Offset, PreviousOffset;
	local string Part, Rest;
	local bool bFirst;

	Offsets.Remove(0, Offsets.Length);
	Rest = Spec;
	bFirst = True;
	while ( Rest != "" )
	{
		CommaPos = InStr(Rest, ",");
		if ( CommaPos == -1 )
		{
			Part = Rest;
			Rest = "";
		}
		else
		{
			Part = Left(Rest, CommaPos);
			if ( CommaPos == Len(Rest) - 1 )
			{
				Offsets.Remove(0, Offsets.Length);
				return;
			}
			Rest = Mid(Rest, CommaPos + 1);
		}

		Part = TrimLine(Part);
		if ( !IsNonNegativeInteger(Part) )
		{
			Offsets.Remove(0, Offsets.Length);
			return;
		}
		Offset = int(Part);
		if ( Offset < 0 || (!bFirst && Offset <= PreviousOffset) )
		{
			Offsets.Remove(0, Offsets.Length);
			return;
		}
		Offsets[Offsets.Length] = Offset;
		PreviousOffset = Offset;
		bFirst = False;
	}
}

function bool IsNonNegativeInteger(string Value)
{
	local int i;

	if ( Value == "" )
		return False;
	for ( i = 0; i < Len(Value); i++ )
		if ( InStr("0123456789", Mid(Value, i, 1)) == -1 )
			return False;
	return True;
}

function ParseColumnTexts(string Content, out array<string> Texts)
{
	local int MarkerPos;
	local string Part, Rest;

	Texts.Remove(0, Texts.Length);
	Rest = Content;
	while ( True )
	{
		MarkerPos = InStr(Rest, "[C]");
		if ( MarkerPos == -1 )
		{
			Texts[Texts.Length] = TrimLine(Rest);
			return;
		}
		Part = Left(Rest, MarkerPos);
		Texts[Texts.Length] = TrimLine(Part);
		Rest = Mid(Rest, MarkerPos + 3);
	}
}

function string JoinColumnTexts(array<string> Texts)
{
	local int i;
	local string Result;

	for ( i = 0; i < Texts.Length; i++ )
	{
		if ( i > 0 )
			Result = Result$" ";
		Result = Result$Texts[i];
	}
	return Result;
}

function ParseInlineSegments(string Content, color BaseColor, out array<RichSegment> Segs)
{
	local int OpenPos, ClosePos;
	local string Before, Tag, Rest;
	local color CurColor;

	// 解析 [Y]...[/] 形式的行内颜色切换
	CurColor = BaseColor;
	while ( True )
	{
		OpenPos = InStr(Content, "[");
		if ( OpenPos == -1 )
		{
			// 无更多标签，直接追加剩余文本
			AppendSegment(Content, CurColor, Segs);
			break;
		}

		Before = Left(Content, OpenPos);
		if ( Before != "" )
			AppendSegment(Before, CurColor, Segs);

		Rest = Mid(Content, OpenPos + 1);
		ClosePos = InStr(Rest, "]");
		if ( ClosePos == -1 )
		{
			// 标签不闭合则按普通文本处理
			AppendSegment("["$Rest, CurColor, Segs);
			break;
		}

		Tag = Left(Rest, ClosePos);
		Content = Mid(Rest, ClosePos + 1);

		if ( Tag == "/" )
			CurColor = BaseColor;
		else
			CurColor = ColorFromTag(Tag, BaseColor);
	}
}

function AppendSegment(string Text, color DrawColor, out array<RichSegment> Segs)
{
	local RichSegment Seg;
	// 空文本不加入
	if ( Text == "" )
		return;
	Seg.Text = Text;
	Seg.DrawColor = DrawColor;
	Segs[Segs.Length] = Seg;
}

function color ColorFromTag(string Tag, color DefaultColor)
{
	local string UpperTag;
	UpperTag = Caps(Tag);
	// 行内标记颜色表
	switch ( UpperTag )
	{
		case "Y": return ColorYellow;
		case "B": return ColorBlue;
		case "W": return ColorWhite;
		case "G": return ColorGreen;
		case "R": return ColorRed;
		case "O": return ColorOrange;
		default:  return DefaultColor;
	}
}

function float DrawLine(Canvas C, RichLine Line, float X, float Y, float XL)
{
	local float DrawX, UsedY, AvailableWidth, ColumnX, ColumnWidth;
	local int i;
	local float SegW, SegH;
	local float LineUsedY;
	local string Bullet;

	// 空行直接占据一行高度
	if ( Line.bEmpty )
		return float(LINE_HEIGHT + LINE_GAP);

	DrawX = X + float(Line.Indent) * INDENT_WIDTH;

	if ( Line.bBullet )
	{
		// 画前缀箭头
		Bullet = ">";
		C.SetDrawColor(Line.LineColor.R, Line.LineColor.G, Line.LineColor.B, 255);
		C.TextSize(Bullet, SegW, SegH);
		C.DrawKoreanText(Bullet, DrawX, Y, XL, LINE_HEIGHT);
		DrawX += SegW + 4;
	}

	AvailableWidth = XL - (DrawX - X);
	if ( Line.bColumns && AreColumnsDrawable(Line, AvailableWidth) )
	{
		C.SetDrawColor(Line.LineColor.R, Line.LineColor.G, Line.LineColor.B, 255);
		for ( i = 0; i < Line.ColumnTexts.Length; i++ )
		{
			ColumnX = DrawX + float(Line.ColumnOffsets[i]);
			if ( i + 1 < Line.ColumnOffsets.Length )
				ColumnWidth = float(Line.ColumnOffsets[i + 1] - Line.ColumnOffsets[i]);
			else
				ColumnWidth = AvailableWidth - float(Line.ColumnOffsets[i]);
			C.DrawKoreanText(Line.ColumnTexts[i], ColumnX, Y, ColumnWidth, LINE_HEIGHT);
		}
		return float(LINE_HEIGHT);
	}

	if ( Line.Segments.Length == 1 )
	{
		// 单色单段走自动换行
		C.SetDrawColor(Line.Segments[0].DrawColor.R, Line.Segments[0].DrawColor.G, Line.Segments[0].DrawColor.B, 255);
		LineUsedY = DrawKoreanTextMultiLine(C, DrawX, Y, XL - (DrawX - X), LINE_HEIGHT, 0, LINE_HEIGHT + LINE_GAP, Line.Segments[0].Text);
		return LineUsedY + LINE_HEIGHT;
	}

	UsedY = 0;
	for ( i = 0; i < Line.Segments.Length; i++ )
	{
		// 多色分段：手动换行
		C.SetDrawColor(Line.Segments[i].DrawColor.R, Line.Segments[i].DrawColor.G, Line.Segments[i].DrawColor.B, 255);
		C.TextSize(Line.Segments[i].Text, SegW, SegH);

		if ( SegW > XL )
		{
			// 段落超长时回退到自动换行
			LineUsedY = DrawKoreanTextMultiLine(C, X, Y + UsedY, XL, LINE_HEIGHT, 0, LINE_HEIGHT + LINE_GAP, Line.Segments[i].Text);
			UsedY += LineUsedY + LINE_HEIGHT;
			DrawX = X + float(Line.Indent) * INDENT_WIDTH;
			continue;
		}

		if ( DrawX + SegW > X + XL )
		{
			// 当前行放不下，换行
			UsedY += LINE_HEIGHT + LINE_GAP;
			DrawX = X + float(Line.Indent) * INDENT_WIDTH;
		}

		C.DrawKoreanText(Line.Segments[i].Text, DrawX, Y + UsedY, XL - (DrawX - X), LINE_HEIGHT);
		DrawX += SegW;
	}

	return UsedY + LINE_HEIGHT;
}

function bool AreColumnsDrawable(RichLine Line, float AvailableWidth)
{
	local int i;

	if ( Line.ColumnOffsets.Length == 0 || Line.ColumnOffsets.Length != Line.ColumnTexts.Length )
		return False;
	for ( i = 0; i < Line.ColumnOffsets.Length; i++ )
	{
		if ( Line.ColumnOffsets[i] < 0 || float(Line.ColumnOffsets[i]) >= AvailableWidth )
			return False;
		if ( i > 0 && Line.ColumnOffsets[i] <= Line.ColumnOffsets[i - 1] )
			return False;
	}
	return True;
}

function string ReplaceNewlinesWithPipe(string S)
{
	local string Result;
	local int i;
	local string Ch;
	local string NextCh;
	local string CR, LF;

	// 使用 Chr() 函数获取换行符（UE2 可能不支持 \r 和 \n 转义序列）
	CR = Chr(13);  // 回车符 \r
	LF = Chr(10);  // 换行符 \n

	// 将所有换行符（\n、\r\n、\r）替换为 |
	Result = "";
	for ( i = 0; i < Len(S); i++ )
	{
		Ch = Mid(S, i, 1);
		if ( Ch == CR )
		{
			// 处理 \r\n 或单独的 \r
			if ( i + 1 < Len(S) )
			{
				NextCh = Mid(S, i + 1, 1);
				if ( NextCh == LF )
				{
					// \r\n 组合，替换为 |
					Result = Result$"|";
					++i; // 跳过 \n
					continue;
				}
			}
			// 单独的 \r，替换为 |
			Result = Result$"|";
		}
		else if ( Ch == LF )
		{
			// Unix 换行符，替换为 |
			Result = Result$"|";
		}
		else
		{
			// 普通字符，保留
			Result = Result$Ch;
		}
	}
	return Result;
}

function array<string> SplitByPipe(string S)
{
	local array<string> Result;
	local int i;
	local string Cur;
	local string Ch;

	// 只处理 '|' 分隔符，UE2 默认支持 | 换行，无需处理其他换行符
	for ( i = 0; i < Len(S); i++ )
	{
		Ch = Mid(S, i, 1);
		if ( Ch == "|" )
		{
			// 管道符分隔
			Result[Result.Length] = Cur;
			Cur = "";
		}
		else
		{
			// 普通字符，添加到当前行
			Cur = Cur$Ch;
		}
	}
	// 添加最后一行（如果有内容）
	if ( Cur != "" || Result.Length == 0 )
		Result[Result.Length] = Cur;
	return Result;
}


function string TrimLine(string S)
{
	local string CR, LF;

	// 使用 Chr() 函数获取换行符（UE2 可能不支持 \r 和 \n 转义序列）
	CR = Chr(13);  // 回车符 \r
	LF = Chr(10);  // 换行符 \n

	// 去除首尾空格与换行符
	while ( Len(S) > 0 && (Left(S, 1) == " ") )
		S = Mid(S, 1);
	while ( Len(S) > 0 && (Right(S, 1) == " " || Right(S, 1) == CR || Right(S, 1) == LF) )
		S = Left(S, Len(S) - 1);
	return S;
}

defaultproperties
{
	MaxShowLines=30
	ColorTitle=(R=255,G=214,B=102,A=255)
	ColorWhite=(R=255,G=255,B=255,A=255)
	ColorYellow=(R=245,G=197,B=71,A=255)
	ColorBlue=(R=148,G=194,B=230,A=255)
	ColorGreen=(R=120,G=220,B=140,A=255)
	ColorRed=(R=255,G=120,B=120,A=255)
	ColorOrange=(R=255,G=180,B=120,A=255)
	Components(0)=(XL=260.000000,YL=450.000000)
}

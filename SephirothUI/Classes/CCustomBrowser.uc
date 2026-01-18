// 自定义提示浏览器：根据后端下发的轻量标记文本绘制到主UI
// 约定：
// 1) 使用 '|' 作为分隔符（UE2 默认支持 | 换行），支持连续分隔产生空行
// 2) 行首样式前缀使用 "[X]" 标记，多个标记可叠加，最后以 ":" 结束
//    例：[F][Y][1]:折叠标题（黄色一级缩进）
//    支持：F(折叠标记，全局只有一个) Y(黄) B(蓝) W(白) G(绿) R(红) O(橙) 1/2/3(缩进) >(前缀箭头)
//    注意：[F] 标记的行会显示为折叠标题（[-] 或 [+]），点击可折叠/展开后续内容
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
};

// 是否显示、折叠状态、原始内容、解析后的行数据
var bool bVisible;
var bool bCollapsed;				// 全局折叠状态（默认展开）
var string RawContent;
var array<RichLine> ParsedLines;
// 折叠标题行索引（全局只有一个，-1 表示没有折叠标记）
var int TitleLineIndex;
var float TitleLineY;				// 标题行的 Y 坐标（用于点击检测）

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

function OnInit()
{
}

function OnFlush()
{
	// 清理缓存内容
	ParsedLines.Remove(0, ParsedLines.Length);
	RawContent = "";
	bVisible = False;
	TitleLineIndex = -1;
	SaveConfig();
}

// 外部调用：设置内容并可控制显示/隐藏
function SetContent(string InContent, optional bool bShow)
{
	// 设置原始内容并立即解析
	RawContent = InContent;
	if ( bShow )
		bVisible = True;
	ParseContent();
}

function ClearContent()
{
	// 清空当前解析结果
	ParsedLines.Remove(0, ParsedLines.Length);
	RawContent = "";
}

function SetVisible(bool bInVisible)
{
	// 仅控制显示状态，不改动内容
	bVisible = bInVisible;
}

function bool IsVisible()
{
	// 查询当前显示状态
	return bVisible;
}

function SetCollapsed(bool bInCollapsed)
{
	bCollapsed = bInCollapsed;
}

function bool IsCollapsed()
{
	return bCollapsed;
}

function OnPreRender(Canvas C)
{
	// 当前版本无需预渲染处理
}

function OnPostRender(HUD H, Canvas C)
{
	local float X, Y, XL, YL;
	local int i, nShown;
	local float YLine, UsedY;
	local string CollapseMark;
	local string TitleText;

	// 隐藏时不渲染
	if ( !bVisible )
		return;

	// 取绘制区域
	X = Components[0].X;
	Y = Components[0].Y;
	XL = Components[0].XL;
	YL = Components[0].YL;

	YLine = 0;
	nShown = 0;

	for ( i = 0; i < ParsedLines.Length; i++ )
	{
		// 如果是折叠标题行，显示折叠标记和内容文本
		if ( i == TitleLineIndex )
		{
			TitleLineY = Y + YLine;
			if ( bCollapsed )
				CollapseMark = "[+]";
			else
				CollapseMark = "[-]";

			// 显示折叠标记和标题内容
			TitleText = CollapseMark@GetLinePlainText(ParsedLines[i]);
			C.SetDrawColor(ColorTitle.R, ColorTitle.G, ColorTitle.B, 255);
			UsedY = DrawKoreanTextMultiLine(C, X, Y + YLine, XL, LINE_HEIGHT, 0, LINE_HEIGHT + LINE_GAP, TitleText);
			YLine += UsedY;
			nShown++;

			// 如果折叠，跳过后续所有内容
			if ( bCollapsed )
				break;
			continue;
		}

		// 折叠状态下，跳过标题行之后的所有内容
		if ( TitleLineIndex != -1 && i > TitleLineIndex && bCollapsed )
			continue;

		// 跳过空行
		if ( ParsedLines[i].bEmpty )
		{
			YLine += LINE_HEIGHT + LINE_GAP;
			continue;
		}

		// 检查是否有内容可显示
		if ( ParsedLines[i].Segments.Length == 0 )
			continue;

		// 达到显示上限则停止
		if ( MaxShowLines > 0 && nShown >= MaxShowLines )
			break;

		UsedY = DrawLine(C, ParsedLines[i], X, Y + YLine, XL);
		YLine += UsedY;
		++nShown;

		// 超出组件高度则停止
		if ( YLine > YL )
			break;
	}
}

function bool PointCheck()
{
	// 仅折叠标题行区域可点击（折叠/展开）
	if ( TitleLineIndex == -1 )
		return False;
	return IsCursorInsideAt(Components[0].X, TitleLineY, Components[0].XL, LINE_HEIGHT + LINE_GAP);
}

function Layout(Canvas C)
{
	// 与任务提示一致的默认位置（固定，不可拖动）
	MoveComponent(Components[0], True, C.ClipX - Components[0].XL - 45, C.ClipY - Components[0].YL - 100);
}

function bool IsCursorInsideInterface()
{
	return False;
}

function bool OnKeyEvent(Interaction.EInputKey Key, Interaction.EInputAction Action, float Delta)
{
	if ( Key == IK_LeftMouse && PointCheck() )
	{
		if ( Action == IST_Release )
		{
			// 切换全局折叠状态
			bCollapsed = !bCollapsed;
			return True;
		}
	}

	return False;
}

// --------------------- 解析与绘制 ---------------------

function ParseContent()
{
	local array<string> Lines;
	local int i;
	local RichLine Line;
	local string RawLine;
	local string NormalizedContent;

	// 先将所有换行符替换为 |，统一处理
	NormalizedContent = ReplaceNewlinesWithPipe(RawContent);

	// 将原始内容拆分为多行并解析
	ParsedLines.Remove(0, ParsedLines.Length);
	Lines = SplitByPipe(NormalizedContent);

	for ( i = 0; i < Lines.Length; i++ )
	{
		RawLine = TrimLine(Lines[i]);
		Line = BuildLine(RawLine);
		ParsedLines[ParsedLines.Length] = Line;
	}

	// 查找 [F] 折叠标记行（全局只有一个）
	TitleLineIndex = -1;
	bCollapsed = False;	// 默认展开
	for ( i = 0; i < ParsedLines.Length; i++ )
	{
		if ( ParsedLines[i].bTitle )
		{
			// 找到 [F] 标记行，记录索引（全局只有一个）
			if ( TitleLineIndex == -1 )
			{
				TitleLineIndex = i;
			}
			else
			{
				// 如果已经有折叠标记，清除多余的 [F] 标记，作为普通内容显示
				ParsedLines[i].bTitle = False;
				// 如果颜色是 ColorTitle（只有[F]标记），则改为默认白色
				if ( ParsedLines[i].LineColor.R == ColorTitle.R && 
				     ParsedLines[i].LineColor.G == ColorTitle.G && 
				     ParsedLines[i].LineColor.B == ColorTitle.B )
				{
					ParsedLines[i].LineColor = ColorWhite;
				}
			}
		}
	}
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

	// 将标记映射为样式
	switch ( UpperToken )
	{
		case "F":
			// [F] 折叠标记：标记该行为折叠标题行
			Line.bTitle = True;
			Line.LineColor = ColorTitle;
			break;
		case "T":
			// [T] 保留作为兼容（向后兼容，但建议使用 [F]）
			Line.bTitle = True;
			Line.LineColor = ColorTitle;
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
	local float DrawX, UsedY;
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

function string ReplaceNewlinesWithPipe(string S)
{
	local string Result;
	local int i;
	local string Ch;
	local string NextCh;

	// 将所有换行符（\n、\r\n、\r）替换为 |
	Result = "";
	for ( i = 0; i < Len(S); i++ )
	{
		Ch = Mid(S, i, 1);
		if ( Ch == "\r" )
		{
			// 处理 \r\n 或单独的 \r
			if ( i + 1 < Len(S) )
			{
				NextCh = Mid(S, i + 1, 1);
				if ( NextCh == "\n" )
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
		else if ( Ch == "\n" )
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
	// 去除首尾空格与换行符
	while ( Len(S) > 0 && (Left(S, 1) == " ") )
		S = Mid(S, 1);
	while ( Len(S) > 0 && (Right(S, 1) == " " || Right(S, 1) == "\r" || Right(S, 1) == "\n") )
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
	Components(0)=(XL=175.000000,YL=450.000000)
}

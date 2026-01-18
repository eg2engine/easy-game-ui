// 任务浏览器：负责将进行中的任务提示绘制到主UI右侧
class CQuestBrowser extends CInterface;

// 主界面最多同时显示的任务数量
const MAX_SHOW_NUM = 5;

// 任务条目闪烁方向与透明度
var int bAlphaDir;
var int nPointAlpha;

// 首次渲染时清理旧的显示标记（防止切场景后残留）
var bool bOnTimeClear;

function OnInit()
{

}

function OnFlush()
{

}

function OnPreRender(Canvas C)
{
	local int i;

	// 进入界面后第一次预渲染：把所有任务的主UI显示标记清掉
	// 之后 bOnTimeClear 置为 False，避免每帧重复清理
	if( bOnTimeClear )
	{
		for( i = 0; i < SephirothPlayer(PlayerOwner).LiveQuests.Length; i++ )
			if( SephirothPlayer(PlayerOwner).LiveQuests[i].bShowMain )
				SephirothPlayer(PlayerOwner).LiveQuests[i].bShowMain = False;

		bOnTimeClear = False;
	}
}

function OnPostRender(HUD H, Canvas C)
{
	local int i, nAlpha;
	local float X,Y,XL,YL,YLine, AddY;
	local string sDesc, sTemp;
	local int nShowNum;

	// 基础绘制区域（组件0控制尺寸与位置）
	X = Components[0].X;
	Y = Components[0].Y;
	XL = Components[0].XL;
	YL = Components[0].YL;

//	C.SetPos(X, Y);
//	C.DrawRect1fix(XL, YL);

	// 文本对齐：左对齐，垂直居中
	C.KTextFormat = ETextAlign.TA_MiddleLeft;

	
	// 闪烁透明度在 235~255 之间往返变化
	if( bAlphaDir == 1 )
	{
		if( nPointAlpha > 235 )
			nPointAlpha -= 1;
		else		
			bAlphaDir = 0;
	}
	else
	{
		if( nPointAlpha < 255 )
			nPointAlpha += 1;
		else
			bAlphaDir = 1;
	}
	


	// 遍历进行中任务列表，将 bShowMain 的任务绘制到主UI
	if( SephirothPlayer(PlayerOwner).LiveQuests.Length != 0 )
	{
		YLine = 0;
		for( i = 0; i < SephirothPlayer(PlayerOwner).LiveQuests.Length; i++ )
		{
			// 超过显示上限直接停止
			if( nShowNum > MAX_SHOW_NUM )
				break;
				
			if( SephirothPlayer(PlayerOwner).LiveQuests[i].bShowMain )
			{
				// 步骤值为0则不再显示（任务结束或无效）
				if( SephirothPlayer(PlayerOwner).LiveQuests[i].nStepValue == 0 )
					SephirothPlayer(PlayerOwner).LiveQuests[i].bShowMain = False;

				// 刚更新的任务会闪烁
				if( Level.TimeSeconds - SephirothPlayer(PlayerOwner).LiveQuests[i].nLastUpdateTime < 1 )
					nAlpha = 155 + (nPointAlpha * 20);
				else
					nAlpha = 255;

				// 任务标题
				C.SetDrawColor(245,197,71,nAlpha);
				//sTemp = SephirothPlayer(PlayerOwner).LiveQuests[i].strHudTitle;
				sTemp = SephirothPlayer(PlayerOwner).LiveQuests[i].Name; //cs changed
				if( sTemp == "" )
				{
					//SephirothPlayer(PlayerOwner).Net.NotiQuestInfo();   //��ȡ����״̬ cs changed
					//sTemp = "None Desc";
				}
				// 多行标题绘制并返回实际占用高度
				AddY = DrawKoreanTextMultiLine(C,X,Y + YLine,XL,14,0,18,sTemp);
				//PlayerOwner.myHud.AddMessage(1,"quest strHudTitle:"@SephirothPlayer(PlayerOwner).LiveQuests[i].strHudTitle,class'Canvas'.static.MakeColor(200,100,200));
				//C.DrawKoreanText(sTemp,X,Y+YLine,XL,14);
				YLine += AddY + 14;

				// 任务描述/下一步
				//C.DrawKoreanText(SephirothPlayer(PlayerOwner).LiveQuests[i].strHudTitle, X, Y+YLine, XL, 14); YLine += 15;
				C.SetDrawColor(148,194,230,nAlpha);
				//sDesc = SephirothPlayer(PlayerOwner).LiveQuests[i].strHudDesc;
				//sDesc = SephirothPlayer(PlayerOwner).LiveQuests[i].CurrentStep;//cs changed
				sDesc = SephirothPlayer(PlayerOwner).LiveQuests[i].NextStep;
//				nCur = SephirothPlayer(PlayerOwner).LiveQuests[i].nProgessCount - 1; // sd ���� ���ǿ� ���� -1 ����� ���ڰ� �´�
//				nMax = SephirothPlayer(PlayerOwner).LiveQuests[i].nHudMax;
//				if(nMax > 0 && nCur != -1 && nCur < 200)
//y					sDesc = sDesc $ " (" $ nCur $ "/" $ nMax $ ")";
				//C.DrawKoreanText(">" $ sDesc $ " (" $ nCur $ "/" $ nMax $ ")", X, Y+YLine, XL, 14);
				// 描述前加“>”作为视觉层级标记
				AddY = DrawKoreanTextMultiLine(C,X,Y + YLine,XL,14,0,18,">"$sDesc);
				YLine += AddY + 14 + 7;
				
				// 计入已显示的任务数
				++nShowNum;
			}

			// 超出组件高度则停止，避免绘制到屏幕外
			if( YLine > YL )
				break;
		}
	}

	// 恢复默认透明度
	C.DrawColor.A = 255;
}

function bool PointCheck()
{
//	if(IsCursorInsideAt(Components[1].X, Components[1].Y, 32, 32))
//		return true;

	return False;
}

function Layout(Canvas C)
{
	// 默认锚定到屏幕右侧偏下位置
	MoveComponent(Components[0],True,C.ClipX - Components[0].XL - 45,C.ClipY - Components[0].YL - 100);

}

function bool IsCursorInsideInterface()
{
	return False;
//	return IsCursorInsideAt(Components[3].X, Components[3].Y, SephirothPlayer(PlayerOwner).PSI.EnchantMagics.Length * 35, 34);
}

defaultproperties
{
	// 初始闪烁透明度与启动清理开关
	nPointAlpha=235
	bOnTimeClear=True
	// 绘制区域大小（位置由 Layout 决定）
	Components(0)=(XL=175.000000,YL=450.000000)
}

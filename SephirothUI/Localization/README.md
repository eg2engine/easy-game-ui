# 换线名称增量语言资源

本目录是 Git 可跟踪的线路名称翻译源，仅维护 `[ServerSetNames]` 的 `LocalLine`、`CrossBattle`；四份片段使用无 BOM 的 UTF-8。它们不是完整的客户端语言文件，不能直接覆盖运行目录中的 `SephirothUI.chn/.cht/.kor/.int`。

使用标准库脚本合并到本地项目 `Bin`：

```powershell
python .\SephirothUI\Localization\merge_locales.py --backup-dir .\.weapon-fx-work\builds\server-set-names-localized\locale-backups
```

指定已有完整语言资源所在目录，例如准备好的本地交付目录：

```powershell
python .\SephirothUI\Localization\merge_locales.py --bin-dir .\.weapon-fx-work\current\server-set-names-localized\Bin --backup-dir .\.weapon-fx-work\builds\server-set-names-localized\locale-backups
```

脚本仅更新目标节中的两个键或添加缺失节，保留其他节、键和原有编码。所有文件先完成检查，再开始写入；重复的目标节或目标键会报错。已有文件只在内容改变时替换，备份写入 `--backup-dir` 下本次时间戳子目录；未指定该参数时不备份。不存在的文件以 UTF-16LE BOM、CRLF 创建。已有无 BOM 文件只接受纯 ASCII；新增内容不能用原 ASCII 编码表示时会明确报错，不猜测旧文件的非 ASCII 编码。

交付前先把目标客户端的完整语言资源复制到交付目录，再运行合并工具；英文 `.int` 缺失时可由工具新建。交付须包含合并后的完整语言文件和对应 UI 包，不能用本目录片段替代完整文件。新增资源键须同步维护四种语言并核对客户端语言选择、缺失键回退和实际文字显示。

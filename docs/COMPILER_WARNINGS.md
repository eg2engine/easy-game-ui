# 编译警告检查与修复

针对首次同步后的 166 条 UCC 警告逐条检查，修复两处代码问题后重新编译，结果为 **0 错误、164 条已分类提示**。

| 类型 | 修复前 | 修复后 | 功能影响与处理 |
| --- | ---: | ---: | --- |
| 类名以数字结尾 | 96 | 96 | 编译器命名建议。引擎已接受这些类，名称用于武器效果、资源和 UI 类型引用，保持现有名称。 |
| 未使用局部变量 | 68 | 68 | 58 个源代码局部变量提示，加上校验派生类重复报出的 10 条。逐个函数确认只有声明，没有实际读取或写入；保留不改变功能。 |
| 局部名称遮蔽继承成员 | 1 | 0 | `CCustomBrowser.ParseInlineSegments` 的局部字符串 `Tag` 与继承的 `Actor.Tag` 同名；改为 `InlineTag`。 |
| 函数缺少返回值 | 1 | 0 | `SephirothController.DisableAutoAttack()` 声明返回 `bool`，原来没有返回语句；补齐每条路径。 |

命名提示中有 1 条来自校验派生类；因此 166 条警告不是 166 处不同的游戏问题。原始路径、方法、变量和每条检查结论保存在 [compiler-warning-audit.json](compiler-warning-audit.json)。完整编译日志继续留在 `.weapon-fx-work/source-validation/`。

## 两处源码修正

`DisableAutoAttack()` 在实际关闭自动攻击或自动施法后返回 `True`，没有关闭任何状态时返回 `False`。已有的开关条件、两种模式的选择顺序和提示消息保持。检查到当前 5 处调用均为独立调用语句，没有依赖返回值，所以未发现这条警告导致当前战斗异常的证据；本次修复补全了函数返回契约。

行内颜色解析的局部变量由 `Tag` 改为 `InlineTag`，其赋值、结束标签判断和 `ColorFromTag` 参数一起更新。没有修改角色的 `Actor.Tag`，也没有修改颜色、标签语法或浏览器显示逻辑。

编译后的指令对照也做了检查：自动攻击函数原有状态写入和消息调用保持，仅增加显式布尔返回；行内解析函数在规范化局部变量名称后，161 个指令项和 9 个跳转目标一致。这是字节码对照，不是联网实机测试。

## 未使用变量的检查方式

警告涉及旧调试变量、替换移动算法后残留的中间变量，以及 UI、装备、随机箱等函数中的旧声明。检查器先定位所属函数和 `local` 声明，再去掉注释、字符串，并排除 `.A`、`.XL`、`.ModelName` 这类成员访问。全部 68 条都只剩局部声明，没有发现“仍在赋值但没有读取”或名字无法对应的情况。它们不会因为未使用而执行移动、发包、特效创建或对象保留逻辑；这次不据此调整这些行为。

## 后续检查

`tools/validate_client_sources.py` 现在自动生成 `warnings.json`，检查所有编译警告。缺少返回值、名称遮蔽、新类型警告，或者无法证明只含声明的“未使用局部变量”，都会让校验失败，需要人工复查。

可以单独检查一份成功编译的日志：

```powershell
python tools/audit_compile_warnings.py `
  --log .weapon-fx-work/source-validation/compile.txt `
  --runtime-bin .weapon-fx-work/source-validation/Bin `
  --stage .weapon-fx-work/source-validation `
  --output .weapon-fx-work/source-validation/warnings.json
```

修复后重新检查了 98 个源码文件、2141 个方法；隔离编译检查 480 个方法／状态体通过，武器／金龙检查及 12 项 Python 测试通过。没有更换游戏成品、原生 DLL 或资源，也没有执行 PR 合并。合并后的联网回归仍待审核后进行。

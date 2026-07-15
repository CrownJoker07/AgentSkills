---
name: unity-bugfix
description: 诊断和修复任意 Git 管理的 Unity 项目 BUG，覆盖 C#、场景、Prefab、资源、Package、编译错误、运行时异常、UI 和数据绑定问题。用户要求分析 Unity BUG 时只读诊断；用户明确要求修复时，要求其提供项目路径，创建独立 worktree，优先使用 OpenCode 修改，由当前 Agent 强制 Review 和测试后提交并推送。输入来自飞书消息、截图或附件时也使用本 Skill。
---

# Unity Bugfix

按照“确认项目 → 读取材料 → 诊断 → 授权门槛 → 创建 worktree → 修复 → Review → 测试 → 提交推送”的顺序处理 Unity BUG。

## 确认项目

要求用户明确提供 Unity 项目目录。不要扫描常用目录、猜测项目或选择名称相近的仓库。

将路径解析为绝对路径并确认同时存在：

```text
Assets/
ProjectSettings/ProjectVersion.txt
```

读取 `ProjectVersion.txt`、`Packages/manifest.json`、项目说明和适用的 `AGENTS.md`，确认 Unity 版本、依赖、项目约定和验证命令。

检查项目所属 Git 仓库：

```bash
git -C "$UNITY_PROJECT_PATH" rev-parse --show-toplevel
git -C "$UNITY_PROJECT_PATH" status --short --branch
```

有效 Unity 项目不是 Git 仓库时只允许诊断，不修改文件。

## 读取输入

读取任务中已经提供的全部相关材料：

- BUG 标题、当前表现、预期表现和复现步骤
- 当前消息、引用消息和相关上下文
- 截图、录屏、标注、日志、堆栈和附件
- 相关配置、测试结果和参照功能

输入来自飞书时，使用可用的飞书能力读取引用消息和下载资源。先读取已有内容，不要要求用户重复提供。

分析图片时说明界面、可见文字和数值、标注位置、当前表现、预期表现、可能模块和不确定信息。不要只做 OCR，不要编造无法确认的内容。

必要材料无法获取时，说明失败原因并请求补充，然后停止。

## 诊断

修改前确认：

1. 当前表现是否违反可验证的预期。
2. 是否可能属于正常规则、配置、数据延迟、平台差异或显示口径。
3. 根因位于脚本、场景、Prefab、资源、Package、配置、服务器还是其他模块。
4. 当前 Unity 项目是否包含可以修复根因的源文件。
5. 是否缺少复现条件、目标数值或业务规则。

从日志和堆栈向调用方追踪，结合界面、功能名、序列化数据和相似实现定位。结论引用当前证据，并尽可能给出：

- 文件、类、方法和当前有效行号
- 字段、类型、序列化属性或资源引用
- 事件、生命周期、异步任务和调用链
- 正常实现与异常实现的差异
- 可执行的最小修复方案

处理结果：

- 不是 BUG：解释当前表现后停止。
- 证据不足：列出缺失信息后停止。
- 根因不在当前项目：说明证据指向的模块后停止。
- 可以在项目中修复：根据授权门槛继续。

没有明确依据时不得猜测业务规则或目标数值。

## 授权门槛

- 用户只要求判断、分析或定位：只输出诊断，不创建 worktree，不修改、提交或推送。
- 用户明确要求修复：创建 worktree，并在 Review 和测试通过后提交、推送分支。

不要把诊断请求自动升级为修复。

## 创建 Worktree

优先遵循仓库文档中的基础分支和分支命名约定。没有命名约定时使用：

```text
fix/<bug-name>
```

将 BUG 名称转换为简短的小写英文连字符名称。同名本地或远程分支已经存在时追加 `YYYYMMDD-HHMM`。

从 Skill 根目录运行：

```bash
scripts/create-worktree.sh "$UNITY_PROJECT_PATH" "$BRANCH"
```

默认基础分支来自 `origin/HEAD`。仓库没有 `origin/HEAD` 时，要求用户明确提供基础引用：

```bash
scripts/create-worktree.sh "$UNITY_PROJECT_PATH" "$BRANCH" origin/main
```

脚本输出 `WORKTREE_PATH` 和 `WORKTREE_UNITY_PROJECT_PATH`。后续所有修改、Review、测试、提交和推送都在 worktree 中执行。

不得切换原仓库分支，不得清理、删除或复用未知 worktree。

## 修复

优先检查 OpenCode：

```bash
opencode --version
opencode auth list
```

OpenCode 可用且已认证时，在 `WORKTREE_UNITY_PROJECT_PATH` 中运行：

```bash
opencode run '<任务指令>'
```

任务指令包含 BUG 材料、附件路径、诊断证据、仓库约定和 worktree 路径，并要求：

- 搜索相关脚本、asmdef、场景、Prefab、资源、Package 和调用链。
- 只修改当前 BUG 所需文件，保持项目风格。
- 修复根因，不添加硬编码特例或无关重构。
- 不创建分支、提交、推送、重置、清理或删除未知文件。
- 运行项目已有的相关检查或测试。

OpenCode 不可用、未认证、失败或没有产生修改时，由当前 Agent 接管并完成最小修复，不因 OpenCode 缺失而停止。

## Unity 修改约束

- 不修改 `Library/`、`Temp/`、`Logs/`、`obj/` 或其他生成缓存。
- 不手工修改生成代码；定位并修改生成源或生成配置。
- 保持资源文件和 `.meta` 文件的 GUID 对应关系。
- 避免打开或保存无关场景、Prefab 和 ScriptableObject，防止大范围 YAML 重序列化。
- 不删除未知资源，不改变无关序列化字段或引用。
- 尊重 Unity 主线程、对象生命周期、Domain Reload、程序集边界和平台条件编译约束。
- 不增加无依据的兼容、回退、重试或防御分支。

## 强制 Code Review

OpenCode 或当前 Agent 完成修改后，由当前 Agent 独立 Review 全部 diff。不能直接接受修改者的结论。

执行：

```bash
git -C "$WORKTREE_PATH" status --short
git -C "$WORKTREE_PATH" diff --stat
git -C "$WORKTREE_PATH" diff
git -C "$WORKTREE_PATH" diff --check
```

Review 必须确认：

- 修改解决根因，没有隐藏症状或加入只适用于当前案例的特例。
- 没有空引用、生命周期、异步、线程、事件未解绑、资源释放或状态同步缺陷。
- 序列化字段、Prefab/Scene 引用、`.meta` 和 GUID 安全。
- 公共 API、存档、协议、配置格式和既有调用方保持兼容，除非任务明确要求改变。
- 没有生成文件、第三方代码、缓存、调试日志、临时文件、密钥或无关改动。
- 修改范围是解决当前 BUG 所需的最小范围。

发现问题时修正并重新执行完整 Review。Review 不通过时禁止提交和推送。

## 测试

优先运行仓库文档、CI 或现有脚本指定的验证。根据修改范围选择：

- Unity Test Framework 的 EditMode 或 PlayMode 测试
- 项目已有编译、静态检查或自动化测试
- 与复现步骤直接相关的最小验证
- `git diff --check`

不要猜测 Unity 可执行文件路径。Unity 或项目测试环境不可用时，完成可执行的静态检查，并在最终结果中明确未执行项及原因。

测试失败时修复问题，然后重新 Review 和测试，最多两轮。两轮后仍有阻断问题时不提交、不推送，保留 worktree 并报告。

## 提交与推送

仅在 Review 和测试通过后执行。根据 `git diff --name-only` 审查文件列表，只暂存本次相关路径；不要使用 `git add -A`。

```bash
git -C "$WORKTREE_PATH" add -- <已审查的文件路径...>
git -C "$WORKTREE_PATH" commit -m "fix: <bug summary>"
git -C "$WORKTREE_PATH" push -u origin "$BRANCH"
```

禁止 force push。认证失败时停止并报告，不把凭据写入 remote URL。不自动创建 MR 或合并分支。

## 进度与最终结果

任务来自飞书且具有消息上下文时，使用可用的飞书能力在原话题发送阶段进度和最终结果；不要在 Skill 中假设固定 CLI 命令。其他来源只在当前会话更新。

最终结果包含：

- 状态、BUG 名称和诊断结论
- 根因及证据
- 修改内容、分支和文件
- Code Review 结论
- Review 中发现并修正的问题
- 测试命令、结果和未执行项
- 推送结果、未解决问题及人工检查风险

失败时额外说明失败阶段、具体错误、是否修改、是否提交、是否推送和 worktree 路径。

## 安全约束

- 不覆盖原仓库已有的未提交修改。
- 不自动删除 worktree、分支或未知文件。
- 不自动创建 MR、合并或 force push。
- 不保存或输出凭据。
- Review 或测试失败时不提交、不推送。
- 不扩展当前 BUG 之外的修改范围。

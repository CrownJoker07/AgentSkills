---
name: query-repository
description: 在独立 Git worktree 中只读查询远程仓库源码、配置或文档，并给出 commit、文件和行号证据。用于从指定仓库查询规则、数值、位置或行为；不用于修改代码。
metadata: {"openclaw":{"requires":{"bins":["git"]}}}
---

# Query Repository

按照“定位仓库 → 读取约束 → 创建查询 worktree → 搜索证据 → 验证结论 → 清理 worktree → 带来源回答”的顺序执行。不切换、更新或读取 `<workspace>/repos/<repo>` 的工作区内容。

## 定位仓库

按以下顺序确认目标：

1. 使用用户明确提供的仓库路径。
2. 使用当前运行环境明确提供的 workspace 根目录，在 `<workspace>/repos` 的直接子目录中，将用户给出的名称与仓库根目录名、`origin` 仓库名精确比较。
3. 当前目录位于 Git 仓库时，使用同样的精确比较。

比较时可忽略大小写和末尾的 `.git`，不做部分匹配，不因为代码内出现仓库名就认定候选。不扫描整个用户目录、磁盘或未向 Agent 公开的路径。不在输出中显示完整 remote URL。

如果运行环境没有提供 workspace，不根据 Agent 产品名或常见路径猜测。使用 `git -C "$REPO_PATH" rev-parse --show-toplevel` 确认目录是 Git 仓库。候选为零个或多个时，只请求用户补充仓库路径；不猜测、不自行选择、不克隆或拉取仓库。

## 读取仓库约束

创建 worktree 前只读取运行环境已经提供的全局约束，不从 `repos/<repo>` 工作区读取可能属于其他分支的仓库文件。查询 worktree 创建后，从其中读取适用的 `AGENTS.md`、`AGENT.md` 和仓库文档，并遵守其中的访问、敏感信息和生成文件约束。

只执行读取、搜索、Git 元数据检查、fetch 和查询 worktree 的创建与清理。不编辑代码，不安装依赖，不执行 switch、merge、rebase、reset 或强制删除。

## 创建查询 Worktree

要求仓库存在 `origin`。用户指定分支时使用该分支；未指定时将 `main` 设为查询分支。不继承本地当前分支，因为它可能是修复分支或其他临时分支。

确定查询分支后，使用 Skill 自身目录中的脚本执行：

```bash
"{baseDir}/scripts/prepare-query.sh" "$REPO_PATH" "$WORKSPACE_ROOT" "$BRANCH"
```

用户未指定分支时省略第三个参数，由脚本使用 `main`：

```bash
"{baseDir}/scripts/prepare-query.sh" "$REPO_PATH" "$WORKSPACE_ROOT"
```

脚本 fetch `origin`，然后在 `<workspace>/worktrees/query/<repo>/<unique-run-id>` 中从 `origin/$BRANCH` 创建独立 detached worktree。脚本输出 `REPO_ROOT`、`BRANCH_NAME`、`QUERY_REF`、`COMMIT_ID` 和 `WORKTREE_PATH`。后续所有文件读取和搜索都在 `WORKTREE_PATH` 中执行。

`fetch` 运行前遵守宿主 Agent 的网络与权限规则。认证、网络、`fetch` 或远程分支校验失败时停止并报告；默认的 `origin/main` 不存在时要求用户指定分支，不猜测 `master` 或其他分支。不悄悄回退到可能过期的本地内容。不在输出中回显凭据或完整 remote URL。

## 搜索与取证

先使用 `rg` 在 `WORKTREE_PATH` 中搜索用户原词，再根据仓库的命名与技术栈扩展为直接相关的中英文同义词、类名、字段名、配置键和文件名。

只搜索该远程快照中 Git 跟踪的源码、配置、测试和文档，避免本地未跟踪文件、第三方依赖、缓存和构建产物干扰结果。

从命中位置追踪到数值或规则的源头，同时检查它的使用位置、覆盖关系和适用条件。区分：

- 直接定义的常量或配置值。
- 需要计算、累加或条件分支才得到的值。
- 运行时由服务端、远程配置或外部数据提供，无法仅从当前仓库确定的值。

不把注释、测试样例、过期文档或生成产物中的数值单独当作最终结论。证据冲突时，继续追踪实际读取链路；仍无法确定时报告冲突，不自行选值。

## 清理 Query Worktree

完成读取和取证后、输出最终回答前，执行：

```bash
"{baseDir}/scripts/cleanup-query.sh" "$REPO_PATH" "$WORKSPACE_ROOT" "$WORKTREE_PATH"
```

清理脚本只允许移除当前仓库在 `<workspace>/worktrees/query/<repo>` 下已登记且干净的 worktree，不使用 `--force`。清理失败时保留 worktree 并在结果中报告，不扩大删除范围。

## 回答

先给出直接结论，再列出最小必要证据。说明实际查询的分支和 commit ID。对每个关键结论提供仓库相对文件路径、符号或配置键、该快照中的行号，并简要说明推导过程。

如果只能确定部分结论，明确区分“已确认”和“无法从当前仓库确定”。如果没有找到证据，说明已检查的关键范围和缺失的信息，不用常识或相似项目补全答案。不回显凭据、私有地址、完整 remote URL 或与问题无关的仓库内容。

---
name: query-repository
description: 只读查询远程 Git 仓库最新分支中的源码、配置或文档，并给出 commit、文件和行号证据。用于从指定仓库查询规则、数值、位置或行为；不创建 worktree、不切换分支、不修改代码。
metadata: {"openclaw":{"requires":{"bins":["git"]}}}
---

# Query Repository

按照“定位仓库 → 获取最新远程分支 → 读取约束 → 搜索证据 → 验证结论 → 带来源回答”的顺序执行。直接查询远程跟踪分支的 Git 对象，不创建 worktree，不切换或修改本地分支，也不读取当前工作区文件作为仓库证据。

## 定位仓库

按以下顺序确认目标：

1. 使用用户明确提供的仓库路径。
2. 使用当前运行环境明确提供的 workspace 根目录，在 `<workspace>/repos` 的直接子目录中，将用户给出的名称与仓库根目录名、`origin` 仓库名精确比较。
3. 当前目录位于 Git 仓库时，使用同样的精确比较。

比较时可忽略大小写和末尾的 `.git`，不做部分匹配，不因为代码内出现仓库名就认定候选。不扫描整个用户目录、磁盘或未向 Agent 公开的路径。不在输出中显示完整 remote URL。

如果运行环境没有提供 workspace，不根据 Agent 产品名或常见路径猜测。使用 `git -C "$REPO_PATH" rev-parse --show-toplevel` 确认目录是 Git 仓库。候选为零个或多个时，只请求用户补充仓库路径；不猜测、不自行选择、不克隆仓库。

## 获取最新远程分支

要求仓库存在 `origin`。用户指定分支时使用该分支；未指定时使用 `main`，不继承本地当前分支。

使用 Skill 自身目录中的脚本 fetch 并解析远程快照：

```bash
"{baseDir}/scripts/prepare-query.sh" "$REPO_PATH" "$BRANCH"
```

用户未指定分支时省略第二个参数：

```bash
"{baseDir}/scripts/prepare-query.sh" "$REPO_PATH"
```

脚本输出 `REPO_ROOT`、`BRANCH_NAME`、`QUERY_REF` 和 `COMMIT_ID`。`QUERY_REF` 固定指向刚 fetch 的 `refs/remotes/origin/<branch>`；后续查询只针对该 ref，不使用本地分支或工作区文件。

`fetch` 运行前遵守宿主 Agent 的网络与权限规则。认证、网络、`fetch` 或远程分支校验失败时停止并报告；默认的 `origin/main` 不存在时要求用户指定分支，不猜测 `master` 或其他分支，不回退到可能过期的本地内容。

## 读取仓库约束

先读取运行环境已提供的全局约束。然后用 `git ls-tree` 在 `QUERY_REF` 中定位适用的 `AGENTS.md`、`AGENT.md` 和仓库文档，并用 `git show "$QUERY_REF:<path>"` 读取。遵守其中的访问、敏感信息和生成文件约束。

只执行读取、搜索、Git 元数据检查和 fetch。不编辑代码，不安装依赖，不执行 checkout、switch、merge、rebase、reset、pull 或 worktree 操作。

## 搜索与取证

使用 `git -C "$REPO_ROOT" grep -n -I -e '<pattern>' "$QUERY_REF" --` 在远程快照的 Git 跟踪文件中搜索用户原词，再根据仓库的命名与技术栈扩展为直接相关的中英文同义词、类名、字段名、配置键和文件名。用 `git show "$QUERY_REF:<path>"` 读取文件；需要稳定行号时将内容传给 `nl -ba`。

从命中位置追踪到数值或规则的源头，同时检查它的使用位置、覆盖关系和适用条件。区分：

- 直接定义的常量或配置值。
- 需要计算、累加或条件分支才得到的值。
- 运行时由服务端、远程配置或外部数据提供，无法仅从当前仓库确定的值。

不把注释、测试样例、过期文档或生成产物中的数值单独当作最终结论。证据冲突时，继续追踪实际读取链路；仍无法确定时报告冲突，不自行选值。

## 回答

先给出直接结论，再列出最小必要证据。说明实际查询的远程分支和 commit ID。对每个关键结论提供仓库相对文件路径、符号或配置键、该快照中的行号，并简要说明推导过程。

如果只能确定部分结论，明确区分“已确认”和“无法从当前仓库确定”。如果没有找到证据，说明已检查的关键范围和缺失的信息，不用常识或相似项目补全答案。不回显凭据、私有地址、完整 remote URL 或与问题无关的仓库内容。

---
name: clone-repository
description: 将用户指定的 Git 仓库地址和分支克隆到当前 Agent workspace 根目录下的 repos/ 目录，供后续仓库查询、诊断或修复 Skill 使用。用户要求克隆、下载、准备或拉取某个远程仓库的指定分支时使用。只负责首次克隆，不更新、覆盖或删除已存在的本地仓库。
---

# Clone Repository

按照“确认输入 → 确认 workspace → 检查目标 → 克隆 → 验证”的顺序执行。

## 确认输入

要求用户提供：

- 一个 Git 仓库地址。
- 一个明确的分支名。

任一项缺失时，只请求补充缺失项，不猜测仓库或分支。仓库地址不得内嵌用户名、密码或 token；发现内嵌凭据时要求用户提供不含凭据的地址，并使用宿主环境已有的 Git 认证方式。不在命令、日志或回复中回显地址内的凭据。

## 确认 Workspace

使用当前运行环境明确提供的 workspace 根目录。如果运行环境没有提供，请求用户给出 workspace 路径；不根据 Agent 产品名、用户主目录或常见路径猜测。

将目标根目录固定为：

```text
<workspace>/repos
```

仅当 `repos/` 不存在时创建它。不创建其他 workspace 结构。

## 克隆

使用仓库地址路径的最后一段作为目标目录名，并去掉末尾的 `.git`。如果无法得到非空名称，要求用户更正仓库地址。如果 `<workspace>/repos/<repository-name>` 已存在，立即停止并报告路径；不执行 `pull`、`fetch`、切换分支、覆盖、合并或删除。

在宿主 Agent 的权限规则允许网络和写入后，执行：

```bash
mkdir -p "$WORKSPACE_ROOT/repos"
git -C "$WORKSPACE_ROOT/repos" clone --branch "$BRANCH" -- "$REPO_URL"
```

保留普通 clone 的默认历史和 refspec，不添加浅克隆、单分支、子模块、LFS 或其他未请求选项。认证失败时停止，使用环境已有的 Git 认证方式，不把凭据写入脚本、文件或 remote URL。

## 验证与输出

克隆成功后只读验证：

```bash
git -C "$REPOSITORY_PATH" rev-parse --show-toplevel
git -C "$REPOSITORY_PATH" branch --show-current
git -C "$REPOSITORY_PATH" rev-parse HEAD
```

报告克隆结果、本地仓库路径、当前分支和 commit ID。失败时报告失败阶段与 Git 错误摘要，不回显凭据或完整私有地址。

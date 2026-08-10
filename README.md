# Agent Skills

这是一个面向 OpenClaw 的个人 Agent Skill 仓库。Skill 遵循 [Agent Skills Specification](https://agentskills.io/specification)，并使用 OpenClaw 的依赖门控和 `{baseDir}` 路径约定。

## 仓库内容

- [`clone-repository`](clone-repository/SKILL.md)：将指定 Git 仓库的指定分支克隆到当前 Agent workspace 的 `repos/` 目录，不绑定具体 Agent 产品或本机路径。
- [`repo-bugfix`](repo-bugfix/SKILL.md)：诊断和修复 Git 代码仓库中的 BUG，并通过独立 worktree 完成交付。
- [`query-repository`](query-repository/SKILL.md)：只读定位当前可访问的本地 Git 仓库，从源码、配置或文档中查询业务规则和数值，并给出文件行号证据。
- [`interview-questions`](interview-questions/SKILL.md)：读取文本或 PDF 简历，按固定骨架总结候选人、分析岗位匹配度并生成带考点的面试题清单。

## Skill 结构

每个 Skill 是一个独立目录，并且至少包含 `SKILL.md`：

```text
skill-name/
├── SKILL.md       # 必需：元数据与指令
├── scripts/       # 可选：可执行代码
├── references/    # 可选：按需读取的参考资料
└── assets/        # 可选：模板、图片或数据文件
```

`SKILL.md` 必须由 YAML frontmatter 和 Markdown 正文组成：

```markdown
---
name: skill-name
description: 说明该 Skill 能做什么，以及应在何时使用。
---

# Skill instructions

在此编写供 Agent 执行的指令。
```

## 规范要求

- `name` 必填，长度为 1–64 个字符，只能包含小写字母、数字和连字符；不得以连字符开头或结尾，不得包含连续连字符，并且必须与 Skill 目录名一致。
- `description` 必填，长度为 1–1024 个字符，必须同时描述 Skill 的能力和适用场景。
- `metadata.openclaw` 用于声明 OpenClaw 运行所需的二进制、环境变量或配置。
- Markdown 正文用于编写 Agent 执行任务所需的指令。完整正文会在 Skill 激活后载入，官方建议 `SKILL.md` 少于 500 行。
- 大段细节应拆分到按需读取的资源文件中，并从 `SKILL.md` 使用相对于 Skill 根目录的路径直接引用，避免深层引用链。
- `scripts/`、`references/` 和 `assets/` 仅在 Skill 实际需要时创建。

## 校验

提交前使用官方 `skills-ref` 工具校验目标 Skill：

```bash
skills-ref validate ./skill-name
```

校验通过不代表内容设计一定有效；仍需确认描述能够准确触发 Skill、指令可以完成目标任务，并且资源引用有效。

## 安装到 OpenClaw

安装脚本使用 OpenClaw CLI 将仓库内的 Skill 安装到当前活动 workspace：

```bash
./install.sh
```

也可以单独安装：

```bash
openclaw skills install ./repo-bugfix
```

安装后检查可见性和依赖：

```bash
openclaw skills list
openclaw skills check
```

## 参考

- [Agent Skills Specification](https://agentskills.io/specification)
- [Agent Skills 官方仓库](https://github.com/agentskills/agentskills)
- [OpenClaw Skills](https://docs.openclaw.ai/skills)

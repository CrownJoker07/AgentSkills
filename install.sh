#!/bin/sh

# -e：任意命令执行失败时立即退出，避免在安装失败后继续执行。
# -u：使用未定义变量时立即退出，避免因变量拼写错误产生意外行为。
set -eu

# 获取本脚本所在目录的绝对路径，后续以该目录作为技能仓库根目录。
#
# $0                    表示当前脚本的执行路径。
# dirname -- "$0"       提取脚本所在目录；-- 防止以连字符开头的路径被当作选项。
# CDPATH=                临时清空 CDPATH，避免它改变 cd 的目录解析或输出额外内容。
# cd -- ... && pwd       进入脚本目录，并输出该目录的绝对路径。
# 无论从哪个工作目录运行本脚本，repo_dir 都会指向 install.sh 所在目录。
repo_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)

# 收集仓库根目录下每个包含 SKILL.md 的一级子目录作为待选 skill。
# 利用位置参数承载 skill 目录路径列表（POSIX sh 无数组）。
# 仅匹配一级子目录，不递归查找更深层目录。
set --
for skill_file in "$repo_dir"/*/SKILL.md; do
    # 某些 shell 在通配符没有匹配项时会保留原始字符串，先确认路径存在。
    [ -e "$skill_file" ] || continue
    # ${skill_file%/SKILL.md} 删除路径末尾的 /SKILL.md，得到技能目录。
    set -- "$@" "${skill_file%/SKILL.md}"
done

if [ $# -eq 0 ]; then
    echo "Error: no skills found under $repo_dir" >&2
    exit 1
fi

total=$#

# 选择安装目标。结果写入全局变量 target：1 表示 openclaw，2 表示 ~/.agents/skills。
# 不使用命令替换，避免函数内菜单输出被一起捕获。
select_target() {
    while true; do
        printf 'Select installation target:\n'
        printf '  1) openclaw (active workspace)\n'
        printf '  2) ~/.agents/skills\n'
        printf 'Enter choice [1-2]: '
        read -r target
        case "$target" in
            1|2) return 0 ;;
            *) printf 'Invalid choice: %s\n' "$target" >&2 ;;
        esac
    done
}

# 安装到 openclaw 活动工作区。调用方已在选择目标时校验过 openclaw 可用性。
install_to_openclaw() {
    skill_dir=$1
    openclaw skills install "$skill_dir"
}

# 安装到 ~/.agents/skills：软链接到仓库目录，仓库内改动即时生效。
# rm -rf 兼容从旧版复制安装迁移过来的真实目录，ln -s 使用绝对路径，任意 cwd 均可用。
install_to_agents() {
    skill_dir=$1
    dest="$HOME/.agents/skills/${skill_dir##*/}"
    mkdir -p "$HOME/.agents/skills"
    rm -rf "$dest"
    ln -s "$skill_dir" "$dest"
}

# 主流程：先选目标，再选 skills。
select_target

# 选择 openclaw 目标时立即检查命令可用性，失败早退，避免白做 skill 选择。
if [ "$target" = 1 ] && ! command -v openclaw >/dev/null 2>&1; then
    echo "Error: openclaw is not installed or not in PATH" >&2
    exit 1
fi

# 选择要安装的 skills：输入 all 全选，或输入逗号分隔的编号。
# 内联实现以便直接重置位置参数为选中的 skill 列表。
while true; do
    printf 'Available skills:\n'
    i=1
    for skill_dir in "$@"; do
        printf '  %d) %s\n' "$i" "${skill_dir##*/}"
        i=$((i + 1))
    done
    printf "Select skills to install (comma-separated numbers, or 'all'): "
    read -r input
    case "$input" in
        all|ALL|All)
            # 保持位置参数为全部 skill。
            break
            ;;
        *)
            # 把逗号归一为空格，按空白拆分；token 仅可能为纯数字。
            norm=$(printf '%s' "$input" | tr ',' ' ')
            # 校验每个 token 为 1..total 范围内的整数。
            ok=1
            set -f
            for token in $norm; do
                case "$token" in
                    ''|*[!0-9]*) ok=0; break ;;
                esac
                if [ "$token" -lt 1 ] || [ "$token" -gt "$total" ]; then
                    ok=0; break
                fi
            done
            set +f
            if [ "$ok" -eq 0 ]; then
                printf 'Invalid selection: %s\n' "$input" >&2
                continue
            fi
            # 按编号去重构建选中列表。
            selected=
            set -f
            for token in $norm; do
                idx=1
                for skill_dir in "$@"; do
                    if [ "$idx" -eq "$token" ]; then
                        dup=0
                        for s in $selected; do
                            [ "$s" = "$skill_dir" ] && { dup=1; break; }
                        done
                        [ "$dup" -eq 0 ] && selected="$selected $skill_dir"
                        break
                    fi
                    idx=$((idx + 1))
                done
            done
            set +f
            if [ -z "$selected" ]; then
                printf 'No skills selected\n' >&2
                continue
            fi
            # 重置位置参数为选中的 skill 列表。
            set -- $selected
            break
            ;;
    esac
done

# 对选中的每个 skill 执行安装。
for skill_dir in "$@"; do
    case "$target" in
        1) install_to_openclaw "$skill_dir" ;;
        2) install_to_agents "$skill_dir" ;;
    esac
done

# 所有选中的 skill 均成功安装后，输出完成提示。
# 由于启用了 set -e，任何一次安装失败都会提前终止，不会执行到这里。
case "$target" in
    1) printf 'Agent Skills installed into the active OpenClaw workspace\n' ;;
    2) printf 'Agent Skills installed into %s\n' "$HOME/.agents/skills" ;;
esac

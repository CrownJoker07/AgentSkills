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

# 检查 openclaw 命令是否已安装并且可以通过 PATH 找到。
# command -v 用于查询命令位置；标准输出和标准错误都重定向到 /dev/null。
# 如果命令不存在，则向标准错误输出提示，并以非零状态码终止脚本。
if ! command -v openclaw >/dev/null 2>&1; then
    echo "Error: openclaw is not installed or not in PATH" >&2
    exit 1
fi

# 遍历仓库根目录下每个一级子目录中的 SKILL.md 文件。
# 例如 "$repo_dir/example/SKILL.md" 会被识别为一个待安装技能。
# 这里只匹配一级子目录，不会递归查找更深层目录。
for skill_file in "$repo_dir"/*/SKILL.md; do
    # 某些 shell 在通配符没有匹配项时会保留原始字符串。
    # 因此先确认路径确实存在；不存在时跳过本次循环。
    [ -e "$skill_file" ] || continue

    # ${skill_file%/SKILL.md} 删除路径末尾的 /SKILL.md，得到技能目录。
    # 将该目录交给 OpenClaw，安装到当前活动的工作区。
    openclaw skills install "${skill_file%/SKILL.md}"
done

# 所有匹配到的技能均成功安装后，输出完成提示。
# 由于启用了 set -e，任何一次安装失败都会提前终止，不会执行到这里。
printf 'Agent Skills installed into the active OpenClaw workspace\n'

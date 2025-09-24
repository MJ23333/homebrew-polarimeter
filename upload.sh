#!/bin/bash

# 当任何命令失败时，立即退出脚本
set -e

# --- 检查 Git 工作区状态 ---
# 检查是否在 git 仓库中
if ! git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
    echo "错误：当前目录不是一个 Git 仓库。"
    exit 1
fi

# 检查是否有未暂存的更改 (可选，但推荐)
if [ -z "$(git status --porcelain)" ]; then
    echo "信息：没有需要提交的更改。"
    exit 0
fi

# --- 获取并验证 Commit Message ---
if [ $# -eq 0 ]; then
  echo "错误：请输入 Commit Message 作为参数！"
  echo "用法: ./git-push.sh \"你的提交信息\""
  exit 1
fi

# 将所有参数合并为一个字符串
COMMIT_MESSAGE="$@"

# --- 执行 Git 命令 ---

# 1. 获取当前分支名
CURRENT_BRANCH=$(git branch --show-current)
if [ -z "$CURRENT_BRANCH" ]; then
    echo "错误：无法获取当前分支名。"
    exit 1
fi
echo "当前分支: $CURRENT_BRANCH"

# 2. 添加所有变更
echo "=> 正在执行 git add ."
git add .

# 3. 提交变更
echo "=> 正在提交 (Commit): \"$COMMIT_MESSAGE\""
git commit -m "$COMMIT_MESSAGE"

# 4. 推送到当前分支的远程
# 明确指定远程 (origin) 和分支，更安全
echo "=> 正在推送到 origin/$CURRENT_BRANCH..."
git push origin "$CURRENT_BRANCH"

echo "✅ 操作完成！"
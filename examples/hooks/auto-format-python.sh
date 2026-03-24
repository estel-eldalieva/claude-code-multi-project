#!/usr/bin/env bash
# PostToolUse hook: Python 파일 저장 후 black 자동 포맷
# 대상: Edit, Write

TOOL_NAME="${CLAUDE_TOOL_NAME:-}"
FILE_PATH="${CLAUDE_FILE_PATH:-}"

# Edit/Write가 아니면 무시
if [[ "$TOOL_NAME" != "Edit" && "$TOOL_NAME" != "Write" ]]; then
    exit 0
fi

# .py 파일이 아니면 무시
if [[ "$FILE_PATH" != *.py ]]; then
    exit 0
fi

# black이 설치되어 있으면 자동 포맷
if command -v black &> /dev/null; then
    black --quiet --line-length 100 "$FILE_PATH" 2>/dev/null
fi

exit 0

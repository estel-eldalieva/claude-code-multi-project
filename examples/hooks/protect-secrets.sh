#!/usr/bin/env bash
# PreToolUse hook: 민감 파일 수정 차단
# 대상: Edit, Write, Bash

TOOL_NAME="${CLAUDE_TOOL_NAME:-}"
FILE_PATH="${CLAUDE_FILE_PATH:-}"
COMMAND="${CLAUDE_COMMAND:-}"

# Edit/Write: 민감 파일 패턴 차단
if [[ "$TOOL_NAME" == "Edit" || "$TOOL_NAME" == "Write" ]]; then
    case "$FILE_PATH" in
        *.env|*.env.*|*credentials*|*secrets*|*.pem|*.key|*id_rsa*)
            echo '{"decision":"block","reason":"민감 파일 수정 차단: '"$FILE_PATH"'"}'
            exit 0
            ;;
    esac
fi

# Bash: .env 파일 조작 명령 차단
if [[ "$TOOL_NAME" == "Bash" ]]; then
    if echo "$COMMAND" | grep -qE '(rm|>)\s+.*\.env'; then
        echo '{"decision":"block","reason":"Bash에서 .env 파일 삭제/덮어쓰기 차단"}'
        exit 0
    fi
fi

exit 0

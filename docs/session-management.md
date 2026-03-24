# 세션 관리

## 개요

각 프로젝트를 독립된 Claude Code 세션으로 운영합니다.
세션 간 컨텍스트가 오염되지 않으며, 각 세션은 자신의 CLAUDE.md와 히스토리를 가집니다.

## 세션 런처 (.cmd)

Windows Terminal 탭으로 세션을 엽니다.

### 로컬 프로젝트

```cmd
@echo off
REM 중복 실행 방지
tasklist /fi "WINDOWTITLE eq <이름> [Local] - Claude Code" 2>nul | find "cmd.exe" >nul 2>&1
if not errorlevel 1 (
    echo [!] <이름> session already open.
    pause
    exit /b 1
)
REM 이전 세션이 있으면 이어가기 (-c), 없으면 새로 시작
if exist "%USERPROFILE%\.claude\projects\C--Projects-<이름>\*.jsonl" (
    wt new-tab --title "<이름> [Local]" cmd /k "cd /d C:\Projects\<이름> && claude -c"
) else (
    wt new-tab --title "<이름> [Local]" cmd /k "cd /d C:\Projects\<이름> && claude"
)
exit /b 0
```

### 타이틀 규칙

`이름 [위치]` 형식:
- 로컬: `[Local]`
- 한글 사용 금지 (인코딩 깨짐)

### 필수 규칙

- **CRLF**: .cmd 파일은 반드시 CRLF 줄바꿈 (LF면 cmd가 멈춤)
- **ASCII**: UTF-8이나 이모지 사용하면 cmd 파싱 오류
- **중복 방지**: WINDOWTITLE 체크로 같은 세션 두 번 열리지 않음

## control-tower 패턴

하나의 "조율 세션"에서 전체를 관리:

```
control-tower
├── 프로젝트 상태 파악
├── 메모리 관리 (memory/*.md 갱신)
├── 프로젝트 등록 (projects.md 갱신)
└── 세션 런처 관리 (sessions/*.cmd 생성)
```

## 새 프로젝트 추가 체크리스트

1. `C:\Projects\<이름>\` 폴더 생성
2. `CLAUDE.md` 작성 (templates/ 참고)
3. `sessions/<이름>.cmd` 작성 (CRLF + ASCII)
4. `memory/projects.md`에 추가
5. git 커밋

## macOS / Linux 대응

.cmd 대신 .sh 스크립트:

```bash
#!/bin/bash
SESSION_NAME="my-project"
PROJ_DIR="$HOME/Projects/$SESSION_NAME"

# tmux 또는 새 터미널 탭으로 실행
if tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
    echo "[!] $SESSION_NAME session already open."
    exit 1
fi

cd "$PROJ_DIR"
if ls ~/.claude/projects/*"$SESSION_NAME"*/*.jsonl 1>/dev/null 2>&1; then
    tmux new-session -d -s "$SESSION_NAME" "claude -c"
else
    tmux new-session -d -s "$SESSION_NAME" "claude"
fi
tmux attach -t "$SESSION_NAME"
```

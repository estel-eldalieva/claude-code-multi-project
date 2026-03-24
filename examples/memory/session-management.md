---
name: session-management
description: Claude Code 세션 런처 체계, 역할 분담 규칙
type: reference
---

# Claude Code 세션 관리

## 세션 체계

> 세션별 IP, Working Dir → infra-facts.md 참조

## 세션 런처

`C:\Projects\sessions\` — .cmd 파일.

### 표준 패턴 (로컬)
```cmd
@echo off
tasklist /fi "WINDOWTITLE eq <이름> [Local] - Claude Code" 2>nul | find "cmd.exe" >nul 2>&1
if not errorlevel 1 (
    echo [!] <이름> session already open.
    pause
    exit /b 1
)
if exist "%USERPROFILE%\.claude\projects\C--Projects-<이름>\*.jsonl" (
    wt new-tab --title "<이름> [Local]" cmd /k "cd /d C:\Projects\<이름> && claude -c"
) else (
    wt new-tab --title "<이름> [Local]" cmd /k "cd /d C:\Projects\<이름> && claude"
)
exit /b 0
```

## 역할 분담

- **control-tower**: 전체 조율, 메모리 관리, 프로젝트 등록
- **프로젝트별**: 코드 편집, 빌드, 테스트 (독립 컨텍스트)

## 새 프로젝트 추가

1. 프로젝트 폴더 + CLAUDE.md 생성
2. sessions/<이름>.cmd 작성 (CRLF + ASCII 필수)
3. memory/projects.md 프로젝트 목록에 추가

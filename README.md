# Claude Code Multi-Project Management

> 여러 프로젝트를 Claude Code CLI로 동시 관리하는 실전 패턴.
> 4레이어 설정, 메모리 시스템, 세션 런처, hooks.

---

## 이게 뭔가요?

Claude Code를 단일 프로젝트가 아닌 **여러 프로젝트의 통합 개발 환경**으로 쓰는 방법론입니다.

일반적으로 Claude Code는 하나의 프로젝트 디렉토리에서 실행합니다. 그런데 프로젝트가 10개, 20개로 늘어나면 문제가 생깁니다:

- 프로젝트 A에서 작업하던 컨텍스트가 프로젝트 B로 오염
- 이전에 배운 규칙(피드백)이 세션이 바뀌면 소실
- 어떤 프로젝트가 어디에 있고, 뭘 하고 있는지 파악이 안 됨
- 새 프로젝트를 추가할 때마다 세팅을 처음부터

이 레포는 이런 문제를 해결하는 구조를 공유합니다. 실제로 20개 이상의 프로젝트를 이 방식으로 운영하고 있습니다.

```
control-tower (조율 세션)
├── project-a [Local]        ← 각 프로젝트가 독립 세션
├── project-b [Local]
├── project-c [Local]
├── project-d [Local]
└── ... 20+ 세션 런처
```

---

## 해결하는 문제

| 문제 | 해결 |
|------|------|
| 프로젝트 간 컨텍스트 오염 | 세션 런처로 프로젝트별 독립 세션 |
| 세션 바뀌면 피드백 소실 | 메모리 시스템으로 영구 보존 |
| 글로벌 규칙을 매번 반복 | 4레이어 설정으로 자동 로드 |
| 새 프로젝트 세팅 번거로움 | 템플릿 + 체크리스트 |
| 민감 파일 실수로 수정 | hooks로 자동 차단 |
| 어떤 프로젝트가 어디에 있는지 | 메모리의 프로젝트 레지스트리 |

---

## 핵심 구조

### 1. 4레이어 설정

Claude Code의 설정 파일을 4개 레이어로 분리합니다. 각 레이어는 적절한 범위에서만 로드되어 **토큰 낭비를 최소화**합니다.

```
범위: 넓음 ──────────────────────────────────── 좁음

레이어 1         레이어 2         레이어 3         레이어 4
글로벌           Rules           메모리           프로젝트
CLAUDE.md        *.md            memory/*.md      CLAUDE.md
(모든 세션)      (파일 매칭 시)   (조율 세션)      (해당 세션만)
```

**레이어 1: 글로벌 CLAUDE.md** (`~/.claude/CLAUDE.md`)

모든 세션에서 자동 로드. 모든 프로젝트에 공통 적용되는 규칙만 넣습니다.

```markdown
# Global Settings
## Language
- 항상 한국어로 응답
## Coding Rules
- 기존 기능/에러 핸들링 절대 삭제 금지
- 명시적 Type Hinting, 매직 넘버 금지
- ...
```

→ 예시: [examples/global-claude.md](examples/global-claude.md)

**레이어 2: Rules** (`~/.claude/rules/*.md`)

파일 패턴에 매칭될 때만 로드. Python 작업할 때 TypeScript 규칙이 로드되지 않습니다.

```yaml
---
paths:
  - "**/*.py"
---
# Python / FastAPI 규칙
- PEP 8 + Black (line-length 100)
- async/await 기본
- ...
```

→ 예시: [examples/rules/](examples/rules/)

**레이어 3: 메모리** (`~/.claude/projects/<path>/memory/*.md`)

control-tower 세션에서 자동 로드. 프로젝트 목록, 피드백, 유저 프로필 등 **세션 간 영구 지식**.

→ 예시: [examples/memory/](examples/memory/) | 상세: [docs/memory-system.md](docs/memory-system.md)

**레이어 4: 프로젝트 CLAUDE.md** (각 `<project>/CLAUDE.md`)

해당 프로젝트 세션에서만 로드. 프로젝트 고유 Tech Stack, 디렉토리 구조, 명령어, 규칙.

→ 예시: [examples/project-claude.md](examples/project-claude.md) | 템플릿: [templates/](templates/)

상세: [docs/architecture.md](docs/architecture.md)

---

### 2. 세션 런처

각 프로젝트를 **Windows Terminal 탭**으로 열어서 독립 세션을 유지합니다.

```cmd
@echo off
tasklist /fi "WINDOWTITLE eq my-project [Local] - Claude Code" 2>nul | find "cmd.exe" >nul 2>&1
if not errorlevel 1 (
    echo [!] my-project session already open.
    pause
    exit /b 1
)
if exist "%USERPROFILE%\.claude\projects\C--Projects-my-project\*.jsonl" (
    wt new-tab --title "my-project [Local]" cmd /k "cd /d C:\Projects\my-project && claude -c"
) else (
    wt new-tab --title "my-project [Local]" cmd /k "cd /d C:\Projects\my-project && claude"
)
exit /b 0
```

런처가 하는 일 3가지:

1. **중복 실행 방지** — WINDOWTITLE로 체크해서 같은 세션을 두 번 열지 않음
2. **세션 이어가기** — 이전 세션 기록(jsonl)이 있으면 `claude -c`로 이어가기
3. **독립 컨텍스트** — 프로젝트 디렉토리로 이동 후 실행 → 해당 CLAUDE.md만 로드

macOS/Linux에서는 tmux 기반 쉘 스크립트로 동일한 패턴을 구현할 수 있습니다.

→ 예시: [examples/sessions/](examples/sessions/) | 상세: [docs/session-management.md](docs/session-management.md)

---

### 3. 메모리 시스템

Claude Code의 auto memory를 활용하여 **세션 간 지식을 영구 보존**합니다.

```
memory/
├── MEMORY.md              ← 인덱스 (자동 로드, 200줄 이하 유지)
├── projects.md            ← 프로젝트 레지스트리
├── feedback_*.md          ← 피드백 (실수에서 배운 규칙)
├── user_profile.md        ← 유저 역할, 선호도
└── ...
```

메모리에는 4가지 타입이 있습니다:

| 타입 | 용도 | 저장 시점 | 예시 |
|------|------|----------|------|
| **user** | 유저 역할, 기술 수준, 선호 | 유저 정보를 알게 됐을 때 | "간결한 응답 선호, 변경사항 요약 필수" |
| **feedback** | 교정/확인된 행동 지침 | 실수를 교정하거나 좋은 접근이 확인됐을 때 | "타임아웃 시 재실행 금지 — 중복 실행 위험" |
| **project** | 진행 중인 작업, 의사결정 | 작업 상태가 바뀔 때 | "서비스 A → 서버 이관 예정, Stage 1 완료" |
| **reference** | 외부 시스템 위치 | 외부 리소스를 알게 됐을 때 | "버그 트래커: Linear PROJ-XXX" |

feedback 타입이 특히 중요합니다. **Why**(왜 이 규칙인지)와 **How to apply**(언제/어떻게 적용할지)를 반드시 포함합니다:

```markdown
---
name: long-running-command-rule
type: feedback
---

## 장시간 명령이 타임아웃되면 재실행하지 말 것

**Why:** 빌드 명령 3회 중복 실행 → 시스템 마비 사건.
**How to apply:** 타임아웃 발생 시 유저에게 보고. 같은 접근법 3회 실패 → 멈추고 다른 방법 제안.
```

→ 예시: [examples/memory/](examples/memory/) | 상세: [docs/memory-system.md](docs/memory-system.md)

---

### 4. control-tower 패턴

하나의 **"조율 세션"**에서 전체 프로젝트를 관리합니다.

```
control-tower
├── 프로젝트 상태 파악         ← "project-a 지금 어떤 상태지?"
├── 메모리 관리                ← memory/*.md 갱신
├── 프로젝트 등록              ← 새 프로젝트 추가, projects.md 갱신
├── 세션 런처 관리             ← sessions/*.cmd 생성
└── 크로스 프로젝트 작업 조율   ← "project-a에서 만든 모듈을 project-b에도 적용해"
```

control-tower는 **직접 코드를 수정하지 않습니다**. 대신:
- 전체 프로젝트의 상태를 파악하고
- 메모리를 최신 상태로 유지하고
- 프로젝트 간 작업을 조율하고
- 각 프로젝트 세션에 전달할 내용을 정리합니다

실제 코드 작업은 해당 프로젝트 세션에서 합니다.

---

### 5. Hooks

도구 사용 전후에 자동 실행되는 스크립트:

**protect-secrets.sh** (PreToolUse)

`.env`, `.pem`, `.key`, `credentials` 등 민감 파일을 실수로 수정하는 것을 차단합니다.

```bash
# Edit/Write 시 민감 파일 패턴 감지 → block
case "$FILE_PATH" in
    *.env|*.pem|*.key|*credentials*|*secrets*)
        echo '{"decision":"block","reason":"민감 파일 수정 차단"}'
        ;;
esac
```

**auto-format-python.sh** (PostToolUse)

`.py` 파일을 수정한 후 자동으로 `black` 포매터를 실행합니다.

```bash
# .py 파일 수정 후 black 자동 실행
if command -v black &> /dev/null; then
    black --quiet --line-length 100 "$FILE_PATH"
fi
```

→ 예시: [examples/hooks/](examples/hooks/)

---

## 디렉토리 구조

```
이 레포/
├── README.md                          ← 이 파일
├── examples/
│   ├── global-claude.md               ← 글로벌 CLAUDE.md 예시
│   ├── rules/
│   │   ├── python-fastapi.md          ← Python/FastAPI 규칙
│   │   └── typescript-react.md        ← TypeScript/React 규칙
│   ├── hooks/
│   │   ├── protect-secrets.sh         ← 민감 파일 차단
│   │   └── auto-format-python.sh      ← Python 자동 포맷
│   ├── memory/
│   │   ├── MEMORY.md                  ← 인덱스 예시
│   │   ├── projects.md                ← 프로젝트 레지스트리 예시
│   │   ├── session-management.md      ← 세션 관리 예시
│   │   ├── feedback-example.md        ← 피드백 메모리 예시
│   │   └── user-profile.md            ← 유저 프로필 예시
│   ├── sessions/
│   │   └── local-project.cmd          ← 세션 런처 예시
│   └── project-claude.md              ← 프로젝트 CLAUDE.md 예시
├── docs/
│   ├── architecture.md                ← 4레이어 구조 상세
│   ├── memory-system.md               ← 메모리 시스템 상세
│   └── session-management.md          ← 세션 관리 상세
└── templates/
    └── CLAUDE_TEMPLATE_LOCAL.md        ← 프로젝트 CLAUDE.md 템플릿
```

---

## 빠른 시작

### Step 1: 글로벌 CLAUDE.md 작성

```bash
# ~/.claude/CLAUDE.md 에 공통 규칙 작성
# 예시: examples/global-claude.md 참고
```

모든 세션에 적용될 규칙만 넣습니다. 언어, 코딩 스타일, 작업 원칙 등.

### Step 2: Rules 추가

```bash
# 사용하는 언어별 규칙 파일 추가
# ~/.claude/rules/python-fastapi.md
# ~/.claude/rules/typescript-react.md
```

frontmatter의 `paths:` 패턴에 맞는 파일을 열 때만 로드됩니다.

### Step 3: 프로젝트 CLAUDE.md 작성

```bash
# 각 프로젝트 루트에 CLAUDE.md 생성
# 템플릿: templates/CLAUDE_TEMPLATE_LOCAL.md
```

프로젝트 고유 정보: Tech Stack, 구조, 명령어, 규칙.

### Step 4: 세션 런처 작성

```bash
# sessions/ 디렉토리에 프로젝트별 .cmd 작성
# 예시: examples/sessions/local-project.cmd
```

주의: `.cmd` 파일은 **CRLF 줄바꿈 + ASCII 인코딩** 필수. LF면 cmd가 멈춥니다.

### Step 5: 메모리 도입 (선택)

프로젝트가 5개 이상이면 메모리 시스템을 도입하세요.

```bash
# ~/.claude/projects/<path>/memory/ 에 메모리 파일 작성
# MEMORY.md 인덱스로 관리
```

---

## 이 방법론이 적합한 경우

- 프로젝트가 **5개 이상**이고 동시에 관리해야 할 때
- 프로젝트 간 **컨텍스트 오염** 없이 독립 작업이 필요할 때
- 실수/피드백을 **세션 간 영구 보존**하고 싶을 때
- 프로젝트마다 **다른 규칙**(언어, 프레임워크)이 필요할 때
- 새 프로젝트 세팅을 **빠르고 일관되게** 하고 싶을 때

## 이 방법론이 과한 경우

- 프로젝트 1~2개만 관리할 때 (CLAUDE.md 하나면 충분)
- macOS/Linux만 사용할 때 (세션 런처 .cmd는 Windows용 — [쉘 스크립트 대안](docs/session-management.md#macos--linux-대응) 참고)

---

## 상세 문서

| 문서 | 내용 |
|------|------|
| [docs/architecture.md](docs/architecture.md) | 4레이어 구조 상세, 레이어 간 원칙 |
| [docs/memory-system.md](docs/memory-system.md) | 메모리 타입, 작성 규칙, 저장하면 안 되는 것 |
| [docs/session-management.md](docs/session-management.md) | 세션 런처, control-tower 패턴, macOS/Linux 대응 |

---

## 라이선스

MIT

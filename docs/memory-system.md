# 메모리 시스템

## 개요

Claude Code의 auto memory 기능을 활용하여, 세션 간 지식을 영구 보존합니다.
메모리는 파일 기반이며, MEMORY.md 인덱스를 통해 관리됩니다.

## 메모리 타입

### user (유저 프로필)
유저의 역할, 기술 수준, 선호를 기록.
```markdown
---
name: user-profile
description: 유저 역할과 선호
type: user
---
```

### feedback (피드백)
교정 또는 확인된 행동 지침. **Why**와 **How to apply**를 반드시 포함.
```markdown
---
name: server-build-rule
description: control-tower에서 SSH 경유 빌드 금지
type: feedback
---

## 규칙
...

**Why:** 서버 빌드 중복 실행 사건.
**How to apply:** control-tower는 조회만, 빌드는 서버 세션에서.
```

### project (프로젝트 상태)
진행 중인 작업, 의사결정, 마감.
```markdown
---
name: feature-migration
description: 서비스 A를 서버로 이전하는 계획
type: project
---
```

### reference (참조)
외부 시스템 위치, 도구 경로 등.
```markdown
---
name: infra-facts
description: 인프라 팩트 단일 원천
type: reference
---
```

## MEMORY.md 인덱스

인덱스 파일로 각 메모리의 위치와 한줄 요약을 관리:

```markdown
# Project Memory

## Infrastructure Facts
- 상세: [infra-facts.md](infra-facts.md)
- IP, 포트, 서비스 맵 단일 원천

## Project Registry
- 상세: [projects.md](projects.md)
- 프로젝트 목록, API 현황
```

**200줄 제한**: MEMORY.md는 자동 로드되므로 200줄을 넘기지 않을 것.

## 저장하면 안 되는 것

- 코드에서 직접 알 수 있는 패턴/구조
- git log로 확인 가능한 히스토리
- 디버깅 솔루션 (코드 자체에 답이 있음)
- CLAUDE.md에 이미 있는 내용
- 현재 대화에서만 필요한 임시 정보

## 운영 규칙

1. **단일 원천**: 같은 팩트를 여러 파일에 쓰지 않음. infra-facts.md 하나만.
2. **오래된 메모리 정리**: 프로젝트 상태가 바뀌면 즉시 업데이트.
3. **상대 날짜 금지**: "목요일" → "2026-03-05"로 변환해서 저장.
4. **검증 후 활용**: 메모리에 있는 파일 경로/함수명은 현재 코드와 대조 후 사용.

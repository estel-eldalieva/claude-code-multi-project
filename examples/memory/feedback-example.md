---
name: long-running-command-rule
description: 장시간 명령 실행 후 결과 확인 안 되면 재실행 금지
type: feedback
---

## 장시간 명령이 타임아웃되면 재실행하지 말 것

Claude Code Bash의 타임아웃(2분)에 걸리면 프로세스가 백그라운드로 빠지고,
완료 여부를 모르니 재실행하게 됨. 이러면 중복 실행.

**Why:** 빌드 명령 3회 중복 실행 → CPU load 100+ → 시스템 마비 사건.

**How to apply:**
- 타임아웃 발생 시 재실행하지 말고 유저에게 보고.
- `run_in_background`으로 실행하고 완료 알림 대기.
- 같은 접근법 3회 실패 → 멈추고 다른 방법 제안.

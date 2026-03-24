---
paths:
  - "**/*.tsx"
  - "**/*.ts"
---

# TypeScript / React 규칙

## 스타일
- TypeScript strict mode 필수
- `any` 금지 (`unknown` 또는 구체 타입 사용)
- ESLint + Prettier

## React
- 함수형 컴포넌트만 (class 컴포넌트 금지)
- TanStack Query v5 서버 상태 관리
- shadcn/ui 우선
- React Router v7

## CSS
- Tailwind CSS 유틸리티 클래스 사용
- 인라인 style 지양
- API 호출은 `api/` 디렉토리 분리

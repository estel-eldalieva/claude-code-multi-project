---
paths:
  - "**/*.py"
---

# Python / FastAPI 규칙

## 스타일
- PEP 8 + Black (line-length 100) + isort
- 모든 함수에 type hints 필수
- async/await 기본 (FastAPI 기본 패턴)

## FastAPI
- 라우터는 `api/routes/` 분리
- 의존성 주입: `Depends(get_db)`, `Depends(get_current_user)`
- 에러: `HTTPException` (커스텀 예외 핸들러 남발 금지)
- Pydantic v2 모델로 Request/Response 스키마

## 로깅
- structlog JSON 형식만 사용
- `print()` 금지 — 반드시 `logger.info("operation", key=value)`

## DB
- 서비스별 테이블 접두사 (충돌 방지)
- SQLAlchemy 2.0: `select()`, `AsyncSession`, `Mapped` 타입

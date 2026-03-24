# my-project

한줄 설명.

## Tech Stack
- Python 3.11+, FastAPI, SQLite

## 구조
```
my-project/
├── app/
│   ├── main.py         # FastAPI 앱
│   ├── config.py       # 설정
│   ├── models/         # ORM 모델
│   ├── routers/        # API 라우터
│   └── services/       # 비즈니스 로직
├── tests/
├── Dockerfile
└── docker-compose.yml
```

## Commands
```bash
pip install -e .
uvicorn app.main:app --reload --port 8000
pytest -q
```

## Conventions
- async/await 기본
- structlog JSON 로깅, print() 금지
- Pydantic v2 스키마


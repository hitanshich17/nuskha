# Nuskha

Find out which ingredient is behind your skin reactions, then get safe replacement products and home remedies.

> Nuskha is not medical advice. Severe or unusual reactions should be seen by a dermatologist.

## Architecture

| Service | Stack | Role |
|---|---|---|
| `core-api` | Java 21, Spring Boot | Products, reaction reports, culprit ranking, replacements |
| `ai-service` | Python, FastAPI | Label reading, embeddings, explanations |
| PostgreSQL + pgvector | | Products, canonical ingredients, similarity search |
| Redis | | Caching repeated lookups |
| S3 + SQS (LocalStack locally) | | Label images and async scan jobs |

Locally, everything runs in Docker. In production it runs on a single EC2 instance, with S3/SQS, provisioned by Terraform (see `infra/terraform`).

## Run it locally

Requirements: Docker Desktop.

```bash
cp .env.example .env
docker compose up --build
```

Then check:

- Core API status: http://localhost:8080/api/v1/status  → `{"service":"core-api","status":"up","aiService":"up"}`
- Core API health (DB + Redis): http://localhost:8080/actuator/health
- AI service: http://localhost:8000/health and interactive docs at http://localhost:8000/docs

## Run tests

```bash
# Java (needs JDK 21 + Maven)
cd services/core-api && mvn verify

# Python
cd services/ai-service
python -m venv .venv && source .venv/bin/activate
pip install -r requirements-dev.txt && pytest
```

## Project layout

```
services/core-api/     Spring Boot service (schema migrations in src/main/resources/db/migration)
services/ai-service/   FastAPI service
infra/localstack/      Creates the local S3 bucket and SQS queues
infra/terraform/       AWS deployment (coming later)
.github/workflows/     CI: Java tests, Python tests, Docker builds
```

## Roadmap

1. Foundation: services, local environment, CI ✅
2. Data pipeline: import Open Beauty Facts, ingredient normalization
3. Culprit engine + evaluation set
4. Replacement matching (pgvector)
5. Home remedies, red-flag guardrails, AI features
6. Frontend, AWS deployment, real users

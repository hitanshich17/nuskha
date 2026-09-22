# Nuskha: project context for Claude Code

## What this is
A skincare reaction-analysis app and resume project. The user marks products that caused a reaction
("reacted") and products that were fine ("safe"). Nuskha:
1. Checks for red flags (severe swelling, blistering, spreading rash, eyes) and sends the user to a doctor.
2. Ranks likely culprit ingredients with an honest confidence level (never a diagnosis).
3. Recommends replacement products that do the same job without the suspected triggers.
4. Suggests curated home remedies (many from Indian households), filtered against the user's
   triggers and labeled by evidence level, always with a patch-test reminder.

Not medical advice. Rules and data make safety decisions; the LLM only reads input and explains output.

## Architecture
- services/core-api: Java 21, Spring Boot 3.5, JPA, Flyway, Redis. Products, reports, culprit ranking, replacements.
- services/ai-service: Python 3.12, FastAPI. Label reading (vision LLM), embeddings, explanations.
- PostgreSQL 16 + pgvector, Redis, S3 + SQS (LocalStack locally).
- Deployment later: one EC2 t4g.small running Docker Compose, S3/SQS, IAM, CloudWatch,
  all in Terraform, deployed by GitHub Actions via OIDC (no stored AWS keys). Budget is tight: avoid
  NAT gateways, load balancers, ElastiCache, EKS. Kubernetes manifests run on a local kind/minikube cluster.

## Conventions
- Schema changes go in new Flyway migrations (V2__..., never edit V1).
- Ingredient names are normalized to canonical ingredients via ingredient_aliases.
- Ingredient position matters (earlier = higher concentration).
- Every feature gets tests: JUnit (+ Testcontainers for DB), PyTest.
- Keep secrets in .env only; never commit keys.
- Explain *why* each tool is used; no tools added just for the resume.

## Roadmap
1. Foundation: services, local env, CI (done)
2. Data pipeline: import Open Beauty Facts, ingredient normalization  <- NEXT
3. Culprit engine + evaluation set
4. Replacement matching (pgvector)
5. Home remedies, red-flag guardrails, AI features
6. Frontend (Next.js), AWS deployment, real users

## Author context
The developer is learning Spring Boot, Terraform, AWS, and Kubernetes through this project.
Explain new concepts briefly when introducing them.

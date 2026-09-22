"""Nuskha AI service.

Responsible for the AI-heavy work: reading ingredient lists from label photos,
embeddings for product similarity, and plain-language explanations.
Safety decisions (culprit ranking, red flags, remedy filtering) stay in rule-based code.
"""

from fastapi import FastAPI

from app.config import get_settings

app = FastAPI(title="Nuskha AI Service", version="0.1.0")


@app.get("/health")
def health() -> dict:
    settings = get_settings()
    return {
        "service": "ai-service",
        "status": "up",
        "env": settings.app_env,
        "llm_configured": settings.llm_configured,
    }

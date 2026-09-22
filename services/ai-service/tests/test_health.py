from fastapi.testclient import TestClient

from app.main import app

client = TestClient(app)


def test_health_reports_up():
    response = client.get("/health")
    assert response.status_code == 200
    body = response.json()
    assert body["service"] == "ai-service"
    assert body["status"] == "up"


def test_health_never_exposes_api_key(monkeypatch):
    monkeypatch.setenv("LLM_API_KEY", "super-secret")
    from app.config import get_settings

    get_settings.cache_clear()
    body = client.get("/health").json()
    assert "super-secret" not in str(body)
    assert body["llm_configured"] is True
    get_settings.cache_clear()

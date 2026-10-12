from pydantic_settings import BaseSettings
import os


class Settings(BaseSettings):
    APP_NAME: str = "AgriCAST API"
    VERSION: str = "1.0.0"
    DEBUG: bool = False

    # Paths: config.py is at backend/app/core/config.py
    # BACKEND_DIR is 3 levels up: .../Agricast/backend
    # PROJECT_ROOT is 4 levels up: .../Agricast
    BACKEND_DIR: str = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
    PROJECT_ROOT: str = os.path.dirname(BACKEND_DIR)

    # Allow models to be in PROJECT_ROOT/models or PROJECT_ROOT or /app/models (Docker)
    MODEL_DIR: str = (
        os.path.join(PROJECT_ROOT, "models")
        if os.path.exists(os.path.join(PROJECT_ROOT, "models", "agricast_lambdamart_v1.pkl"))
        else (
            PROJECT_ROOT
            if os.path.exists(os.path.join(PROJECT_ROOT, "agricast_lambdamart_v1.pkl"))
            else os.path.join(BACKEND_DIR, "models")
        )
    )

    # Data dir: backend/data
    DATA_DIR: str = (
        os.path.join(BACKEND_DIR, "data")
        if os.path.exists(os.path.join(BACKEND_DIR, "data"))
        else os.path.join(PROJECT_ROOT, "backend", "data")
    )

    REPORTS_DIR: str = os.path.join(PROJECT_ROOT, "reports")

    MODEL_FILE: str = "agricast_lambdamart_v1.pkl"
    FEATURES_FILE: str = "agricast_features_v1.pkl"

    CORS_ORIGINS: list = ["*"]

    class Config:
        env_file = ".env"


settings = Settings()

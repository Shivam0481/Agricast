"""
Model Loader — loads LambdaMART model and feature list once at startup.
"""
import joblib
import os
import logging
from typing import Optional

logger = logging.getLogger(__name__)


class ModelLoader:
    _model = None
    _features: Optional[list] = None
    _loaded: bool = False
    _error: Optional[str] = None

    @classmethod
    def load(cls, model_dir: str, model_file: str, features_file: str):
        try:
            model_path = os.path.join(model_dir, model_file)
            features_path = os.path.join(model_dir, features_file)

            if not os.path.exists(model_path):
                cls._error = f"Model file not found: {model_path}"
                logger.error(cls._error)
                return

            if not os.path.exists(features_path):
                cls._error = f"Features file not found: {features_path}"
                logger.error(cls._error)
                return

            logger.info(f"Loading model from {model_path}")
            cls._model = joblib.load(model_path)

            logger.info(f"Loading features from {features_path}")
            cls._features = joblib.load(features_path)

            cls._loaded = True
            logger.info(
                f"✅ Model loaded: {cls._model.__class__.__name__} | "
                f"Features: {len(cls._features)}"
            )

        except Exception as e:
            cls._error = str(e)
            logger.exception(f"Failed to load model: {e}")

    @classmethod
    def get_model(cls):
        return cls._model

    @classmethod
    def get_features(cls) -> list:
        return cls._features or []

    @classmethod
    def is_loaded(cls) -> bool:
        return cls._loaded

    @classmethod
    def get_error(cls) -> Optional[str]:
        return cls._error

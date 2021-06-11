from unittest import TestCase
from workers.config import app

class TestCeleryConfig(TestCase):
    def test_config(self):
        self.assertIsNotNone(app.conf.broker_url)
        self.assertIsNotNone(app.conf.result_backend)
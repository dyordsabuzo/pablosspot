from celery import Celery
import os

app = Celery(__name__)

app.conf.update({
    'broker_url': os.environ.get('BROKER', 'amqp://rabbitmq:5673//'),
    'result_backend': os.environ.get('BACKEND', 'amqp://rabbitmq:5673//'),
})
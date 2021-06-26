from .config import app
from entities.thumbnail import Thumbnail

@app.task(bind=True, name='create_thumbnail')
def create(self, url, filename):
    thumbnail = Thumbnail(url, filename)
    thumbnail.create()
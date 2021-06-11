from PIL import Image
from io import BytesIO

import requests
import os
import logging

logger = logging.getLogger(__name__)

class Thumbnail:
    def __init__(self, url, filename):
        self.url = url
        self.filename = filename
        self.SIZE = 128, 128
        self.STATIC_DIR = os.environ.get('STATIC_DIR', '/tmp/static') 

    def create(self):
        logger.info('Begin creation of thumbnal')
        content = requests.get(self.url).content
        with Image.open(BytesIO(content)) as img:
            img.thumbnail(self.SIZE)
            img.save(f'{self.STATIC_DIR}/{self.filename}', 'JPEG')
        logger.info('Finished creation of thumbnal')

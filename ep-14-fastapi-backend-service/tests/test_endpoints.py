from fastapi.testclient import TestClient
from app.main import app

client =  TestClient(app)

def test_create_thumbnail():
    source_url = "https://jpeg.org/images/jpeg-home.jpg"
    response = client.post('/thumbnail', json={"url": source_url})
    assert response.status_code == 200
    assert response.json() != None

    output = response.json()
    assert output["url"] == source_url
    assert output["filename"] != None

    response = client.get(f'/static/{output["filename"]}')
    assert response.status_code == 200

def test_create_thumbnail_exceptions():
    sourceurl = "some url"
    response = client.post('/thumbnail', json={"url": sourceurl})
    assert response.status_code == 400

    sourceurl = "https://www.google.com"
    response = client.post('/thumbnail', json={"url": sourceurl})
    assert response.status_code == 400
FROM python:3.9.4-alpine

WORKDIR /usr/src

ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

COPY ./requirements.txt /usr/src/requirements.txt

RUN set -eux \
    && apk add --no-cache --virtual .build-deps build-base \
    libressl-dev libffi-dev gcc musl-dev python3-dev \
    libressl-dev libffi-dev gcc musl-dev python3-dev \
    tiff-dev jpeg-dev openjpeg-dev zlib-dev freetype-dev lcms2-dev \
    libwebp-dev tcl-dev tk-dev harfbuzz-dev fribidi-dev libimagequant-dev \
    libxcb-dev libpng-dev \
    && pip install --upgrade pip setuptools wheel \
    && pip install -r /usr/src/requirements.txt \
    && rm -rf /root/.cache/pip

COPY ./app/ /usr/src/app/
COPY ./tests/ /usr/src/tests/
FROM python:alpine as base
RUN apk add --no-cache libstdc++

FROM base as build
ARG FUNCTION_DIR=/home/app/
ENV CRYPTOGRAPHY_DONT_BUILD_RUST=1
RUN apk add --no-cache build-base \
    libtool autoconf automake libexecinfo-dev \
    gcc make cmake libcurl libffi-dev libressl-dev musl-dev
RUN mkdir -p ${FUNCTION_DIR}
WORKDIR ${FUNCTION_DIR}
COPY ./app .
COPY ./requirements.txt .
COPY ./requirements-test.txt .
RUN pip install -r requirements.txt -t .
RUN pip install -r requirements-test.txt
RUN python test.py

FROM base
ARG FUNCTION_DIR=/home/app/
WORKDIR ${FUNCTION_DIR}
COPY --from=build ${FUNCTION_DIR} ${FUNCTION_DIR}
ADD https://github.com/aws/aws-lambda-runtime-interface-emulator/releases/latest/download/aws-lambda-rie /usr/bin/aws-lambda-rie
COPY entry.sh .
RUN chmod 755 /usr/bin/aws-lambda-rie entry.sh
ENTRYPOINT [ "/home/app/entry.sh" ]
CMD [ "lambda_function.handler" ]
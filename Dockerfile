ARG ELASTIC_VER
ARG SUDACHI_PLUGIN_VER
# http://sudachi.s3-website-ap-northeast-1.amazonaws.com/sudachidict/
ARG SUDACHI_DICT_VER=20260428


FROM --platform=$BUILDPLATFORM alpine:latest@sha256:5b10f432ef3da1b8d4c7eb6c487f2f5a8f096bc91145e68878dd4a5019afde11 AS plugin-downloader

WORKDIR /work
ARG ELASTIC_VER
ARG SUDACHI_PLUGIN_VER

RUN apk --no-cache --update add curl

RUN curl -OL https://github.com/WorksApplications/elasticsearch-sudachi/releases/download/v${SUDACHI_PLUGIN_VER}/elasticsearch-${ELASTIC_VER}-analysis-sudachi-${SUDACHI_PLUGIN_VER}.zip


FROM --platform=$BUILDPLATFORM alpine:latest@sha256:5b10f432ef3da1b8d4c7eb6c487f2f5a8f096bc91145e68878dd4a5019afde11 AS dict-downloader

WORKDIR /work
ARG SUDACHI_DICT_VER

RUN apk --no-cache --update add curl

RUN curl -OL http://sudachi.s3-website-ap-northeast-1.amazonaws.com/sudachidict/sudachi-dictionary-${SUDACHI_DICT_VER}-core.zip && \
    unzip -o sudachi-dictionary-${SUDACHI_DICT_VER}-core.zip
RUN curl -OL http://sudachi.s3-website-ap-northeast-1.amazonaws.com/sudachidict/sudachi-dictionary-${SUDACHI_DICT_VER}-full.zip && \
    unzip -o sudachi-dictionary-${SUDACHI_DICT_VER}-full.zip


FROM elasticsearch:${ELASTIC_VER}

ARG ELASTIC_VER
ARG SUDACHI_PLUGIN_VER

COPY --from=plugin-downloader /work/elasticsearch-${ELASTIC_VER}-analysis-sudachi-${SUDACHI_PLUGIN_VER}.zip .
RUN bin/elasticsearch-plugin install file://$(pwd)/elasticsearch-${ELASTIC_VER}-analysis-sudachi-${SUDACHI_PLUGIN_VER}.zip && \
    rm elasticsearch-${ELASTIC_VER}-analysis-sudachi-${SUDACHI_PLUGIN_VER}.zip

COPY --from=dict-downloader --chown=elasticsearch:root /work/sudachi-dictionary-*/*.dic ./config/sudachi/

COPY ./sudachi.json ./plugins/analysis-sudachi/

ARG ELASTIC_VER
ARG SUDACHI_PLUGIN_VER
ARG SUDACHI_DICT_VER=20230110


FROM --platform=$BUILDPLATFORM alpine:latest AS plugin-downloader

WORKDIR /work
ARG ELASTIC_VER
ARG SUDACHI_PLUGIN_VER

RUN apk --no-cache --update add curl

RUN curl -OL https://github.com/WorksApplications/elasticsearch-sudachi/releases/download/v${SUDACHI_PLUGIN_VER}/analysis-sudachi-${ELASTIC_VER}-${SUDACHI_PLUGIN_VER}.zip


FROM --platform=$BUILDPLATFORM alpine:latest AS dict-downloader

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

COPY --from=plugin-downloader /work/analysis-sudachi-${ELASTIC_VER}-${SUDACHI_PLUGIN_VER}.zip .
RUN bin/elasticsearch-plugin install file://$(pwd)/analysis-sudachi-${ELASTIC_VER}-${SUDACHI_PLUGIN_VER}.zip && \
    rm analysis-sudachi-${ELASTIC_VER}-${SUDACHI_PLUGIN_VER}.zip

COPY --from=dict-downloader --chown=elasticsearch:root /work/sudachi-dictionary-*/*.dic ./config/sudachi/

COPY ./sudachi.json ./plugins/analysis-sudachi/

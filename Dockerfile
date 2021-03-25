ARG ELASTIC_VER
ARG SUDACHI_PLUGIN_VER
ARG SUDACHI_DICT_VER=20201223


FROM alpine:latest as dict-builder

ARG SUDACHI_DICT_VER
RUN apk --no-cache --update add curl && \
    curl -OL http://sudachi.s3-website-ap-northeast-1.amazonaws.com/sudachidict/sudachi-dictionary-${SUDACHI_DICT_VER}-core.zip && \
    curl -OL http://sudachi.s3-website-ap-northeast-1.amazonaws.com/sudachidict/sudachi-dictionary-${SUDACHI_DICT_VER}-full.zip && \
    unzip -o sudachi-dictionary-${SUDACHI_DICT_VER}-core.zip && \
    unzip -o sudachi-dictionary-${SUDACHI_DICT_VER}-full.zip


FROM docker.elastic.co/elasticsearch/elasticsearch-oss:${ELASTIC_VER}

ARG ELASTIC_VER
ARG SUDACHI_PLUGIN_VER
COPY analysis-sudachi-${ELASTIC_VER}-${SUDACHI_PLUGIN_VER}.zip .
RUN bin/elasticsearch-plugin install file://$(pwd)/analysis-sudachi-${ELASTIC_VER}-${SUDACHI_PLUGIN_VER}.zip && \
    rm analysis-sudachi-${ELASTIC_VER}-${SUDACHI_PLUGIN_VER}.zip
COPY --chown=elasticsearch:root --from=dict-builder ./sudachi-dictionary-*/*.dic ./config/sudachi/
COPY ./sudachi.json ./plugins/analysis-sudachi/

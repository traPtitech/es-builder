ARG ELASTIC_VER=7.10.1
ARG SUDACHI_PLUGIN_VER=2.1.0
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
RUN curl -OL https://github.com/WorksApplications/elasticsearch-sudachi/releases/download/v${SUDACHI_PLUGIN_VER}/analysis-sudachi-${ELASTIC_VER}-${SUDACHI_PLUGIN_VER}.zip && \
    bin/elasticsearch-plugin install file://$(pwd)/analysis-sudachi-${ELASTIC_VER}-${SUDACHI_PLUGIN_VER}.zip && \
    rm analysis-sudachi-${ELASTIC_VER}-${SUDACHI_PLUGIN_VER}.zip
COPY --chown=elasticsearch:root --from=dict-builder ./sudachi-dictionary-*/*.dic ./config/sudachi/

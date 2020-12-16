# vim:set ft=dockerfile:
ARG UBUNTU=rolling
FROM ubuntu:$UBUNTU
MAINTAINER Sebastian Braun <sebastian.braun@fh-aachen.de>

ENV DEBIAN_FRONTEND noninteractive
ENV LANG en_US.UTF-8

RUN apt-get update && apt-get install --no-install-recommends -y -q \
    ca-certificates \
    ruby \
    ruby-http-parser.rb \
    ruby-json \
    ruby-msgpack \
    ruby-serverengine \
    ruby-sigdump \
    ruby-strptime \
    ruby-tzinfo \
    ruby-yajl \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

# https://rubygems.org/gems/fluentd
ARG VERSION=1.11.5
# https://rubygems.org/gems/fluent-plugin-mqtt-io
ARG PLUGIN_MQTT=0.4.4
# https://rubygems.org/gems/fluent-plugin-elasticsearch
ARG PLUGIN_ELASTICSEARCH=4.3.2

# TODO: we use HTTP for rubygems.org instead of HTTPS, as arm/v7 has problems with SSL certificates
# TODO: perhabs we can add :ssl_verify_mode: 0 to /etc/gemrc and change the 0 according to the architecture
RUN apt-get update && apt-get install --no-install-recommends -y -q \
    ruby-dev \
    build-essential \
 && echo 'gem: --no-document' >> /etc/gemrc \
 && echo ':ssl_verify_mode: 0' >> /etc/gemrc \
 && gem install fluentd -v $VERSION \
 && gem install fluent-plugin-mqtt-io -v $PLUGIN_MQTT \
 && gem install fluent-plugin-elasticsearch -v $PLUGIN_ELASTICSEARCH \
 && rm -rf /tmp/* /var/tmp/* /usr/lib/ruby/gems/*/cache/*.gem \
 && apt-get purge -y \
    ruby-dev \
    build-essential \
 && apt-get autoremove -y \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

# COPY entrypoint.sh /entrypoint.sh
# RUN chmod +x /entrypoint.sh
COPY fluent.conf /etc/fluent/fluent.conf

EXPOSE 24224/tcp

# ENTRYPOINT ["/entrypoint.sh"]
CMD ["fluentd", "--suppress-config-dump", "--no-supervisor", "-q"]

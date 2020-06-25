FROM alpine:3.11.3
MAINTAINER Sebastian Braun <sebastian.braun@fh-aachen.de>

RUN apk add --no-cache \
    ruby ruby-irb ruby-etc ruby-webrick ruby-json

# https://rubygems.org/gems/fluentd
ARG VERSION=1.11.1
# https://rubygems.org/gems/fluent-plugin-mqtt-io
ARG PLUGIN_MQTT=0.4.4

RUN apk add --no-cache --virtual build-dependencies build-base ruby-dev \
 && echo 'gem: --no-document' >> /etc/gemrc \
 && gem install fluentd -v $VERSION \
 && gem install fluent-plugin-mqtt-io -v $PLUGIN_MQTT \
 && apk del build-dependencies \
 && fluent-gem install fluent-plugin-elasticsearch \
 && rm -rf /tmp/* /var/tmp/* /usr/lib/ruby/gems/*/cache/*.gem

COPY run.sh /startup/run.sh
COPY fluent.conf /etc/fluent/fluent.template
RUN chmod +x /startup/run.sh

EXPOSE 24224/tcp

ENTRYPOINT ["/startup/run.sh"]

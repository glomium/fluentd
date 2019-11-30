FROM alpine:3.10.3
MAINTAINER Sebastian Braun <sebastian.braun@fh-aachen.de>
RUN apk add --no-cache ca-certificates
# base alpine template

# Download requirements
RUN apk add --no-cache \
    ruby ruby-irb ruby-etc ruby-webrick ruby-json
    
ARG VERSION

RUN apk add --no-cache --virtual build-dependencies build-base ruby-dev \
 && echo 'gem: --no-document' >> /etc/gemrc \
 && gem install fluentd -v $VERSION \
 && apk del build-dependencies \
 && fluent-gem install fluent-plugin-elasticsearch \
 && rm -rf /tmp/* /var/tmp/* /usr/lib/ruby/gems/*/cache/*.gem

COPY docker/fluentd/run.sh /startup/run.sh
COPY docker/fluentd/fluent.conf /etc/fluent/fluent.template
RUN chmod +x /startup/run.sh

EXPOSE 24224/tcp

ENTRYPOINT ["/startup/run.sh"]

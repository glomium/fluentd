FROM alpine:3.11.3
MAINTAINER Sebastian Braun <sebastian.braun@fh-aachen.de>
# base alpine template

# Download requirements
RUN apk add --no-cache \
    ruby ruby-irb ruby-etc ruby-webrick ruby-json
    
ARG VERSION=1.8.1

RUN apk add --no-cache --virtual build-dependencies build-base ruby-dev \
 && echo 'gem: --no-document' >> /etc/gemrc \
 && gem install fluentd -v $VERSION \
 && apk del build-dependencies \
 && fluent-gem install fluent-plugin-elasticsearch \
 && rm -rf /tmp/* /var/tmp/* /usr/lib/ruby/gems/*/cache/*.gem

COPY run.sh /startup/run.sh
COPY fluent.conf /etc/fluent/fluent.template
RUN chmod +x /startup/run.sh

EXPOSE 24224/tcp

ENTRYPOINT ["/startup/run.sh"]

FROM rabbitmq:3.7.4-alpine
MAINTAINER Jo Vandeginste <jo.vandeginste@gmail.com>

CMD ["/run.sh"]
VOLUME /config /etc/rabbitmq

# Add scripts
ADD run.sh set_rabbitmq_password.sh /
ADD docker-entrypoint.sh /usr/local/bin

RUN apk add --update pwgen
RUN rabbitmq-plugins --offline enable rabbitmq_management rabbitmq_stomp rabbitmq_shovel rabbitmq_shovel_management

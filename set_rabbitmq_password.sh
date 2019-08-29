#!/bin/bash

if [ -f /config/.rabbitmq_password_set ]; then
	echo "RabbitMQ password already set!"
	exit 0
fi

PASS=${RABBITMQ_PASS:-$(pwgen -s 12 1)}
USER=${RABBITMQ_USER:-"admin"}
MGMTPORT=${RABBITMQ_MGMT_PORT:-15672}
STOMPPORT=${RABBITMQ_STOMP_PORT:-61613}
ERLANG_COOKIE=${RABBITMQ_ERLANG_COOKIE:-ERLANGCOOKIE}

_word=$([ "${RABBITMQ_PASS}" ] && echo "preset" || echo "random")
echo "=> Securing RabbitMQ with a ${_word} password"
cat >/etc/rabbitmq/rabbitmq.conf <<EOF
default_user = $USER
default_pass = $PASS
listeners.tcp.default = :::5672
stomp.listeners.tcp.1 = :::$STOMPPORT
stomp.implicit_connect = true
management.listener.port = $MGMTPORT
management.listener.ip = ::
EOF
echo "=> Setting erlang cookie"
echo "$ERLANG_COOKIE" >/var/lib/rabbitmq/.erlang.cookie
echo "=> configuring plugins"
cat >/etc/rabbitmq/enabled_plugins <<EOF
[rabbitmq_management,rabbitmq_stomp].
EOF
chown rabbitmq:rabbitmq /var/lib/rabbitmq/.erlang.cookie /etc/rabbitmq/*
chmod 400 /var/lib/rabbitmq/.erlang.cookie /etc/rabbitmq/*
echo "=> Done!"
touch /config/.rabbitmq_password_set

echo "========================================================================"
echo "You can now connect to this RabbitMQ server using, for example:"
echo ""

if [ "${_word}" == "random" ]; then
	echo "    curl --user $USER:$PASS http://<host>:<port>/api/vhosts"
	echo ""
	echo "Please remember to change the above password as soon as possible!"
else
	echo "    curl --user $USER:<RABBITMQ_PASS> http://<host>:<port>/api/vhosts"
	echo ""
fi

echo "========================================================================"

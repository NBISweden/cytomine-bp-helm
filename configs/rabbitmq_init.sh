#!/bin/bash

( rabbitmqctl wait -t 60 $RABBITMQ_PID_FILE; \
    rabbitmqctl add_user {{ .Values.rabbitmq.username }} {{ .Values.rabbitmq.password }} 2>/dev/null; \
    rabbitmqctl set_user_tags {{ .Values.rabbitmq.username }} administrator; \
    rabbitmqctl set_permissions -p / {{ .Values.rabbitmq.username }} ".*" ".*" ".*";
) &

echo "Starting rabbitmq server"
rabbitmq-server

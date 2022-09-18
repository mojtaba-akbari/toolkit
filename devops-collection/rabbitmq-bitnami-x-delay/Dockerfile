FROM docker.io/bitnami/rabbitmq:3.7-debian-9
ADD rabbitmq_delayed_message_exchange-20171201-3.7.x.ez /opt/bitnami/rabbitmq/plugins/
RUN rabbitmq-plugins enable rabbitmq_mqtt \
 && rabbitmq-plugins enable rabbitmq_delayed_message_exchange

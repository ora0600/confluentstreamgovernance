#!/bin/bash
source source-vars
# set title
export PROMPT_COMMAND='echo -ne "\033]0;consume from users\007"'
echo -e "\033];consume from users\007"

# Terminal 4
# Produce data to source from local laptop and check how fast both consumer windows are reading (almost real-time)
echo "consume from users: "
kafka-avro-console-consumer --bootstrap-server $CCLOUD_CLUSTERID1_BOOTSTRAP --topic users \
 --consumer.config ../ccloud_user1.properties \
 --group consumerUSERS \
 --property basic.auth.credentials.source=USER_INFO \
 --property schema.registry.url=$CCLOUD_SRURL1 \
 --property schema.registry.basic.auth.user.info=$CCLOUD_SRKEY1:$CCLOUD_SRSECRET1
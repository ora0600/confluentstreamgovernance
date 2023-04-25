#!/bin/bash
source source-vars
# Set title
export PROMPT_COMMAND='echo -ne "\033]0;Consume from cmtest1\007"'
echo -e "\033];Consume from cmtest1\007"

# Terminal 3
echo "consume from cmtest1: "
kafka-avro-console-consumer --bootstrap-server $CCLOUD_CLUSTERID1_BOOTSTRAP --topic cmtest1 \
 --consumer.config ../ccloud_user1.properties \
 --group consumerCMTEST \
 --property basic.auth.credentials.source=USER_INFO \
 --property schema.registry.url=$CCLOUD_SRURL1 \
 --property schema.registry.basic.auth.user.info=$CCLOUD_SRKEY1:$CCLOUD_SRSECRET1

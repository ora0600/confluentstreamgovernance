#!/bin/bash
# Set title
source source-vars
export PROMPT_COMMAND='echo -ne "\033]0;Consume from Topic schemarule\007"'
echo -e "\033];Consume from Topic schemarule\007"
echo "Consumer with Schem Rule started, wait for Event:"
# Terminal 3
# Consume 
kafka-avro-console-consumer \
  --topic schemarule \
  --bootstrap-server ${CCLOUD_CLUSTERID1_BOOTSTRAP}  \
  --consumer.config ../ccloud_user1.properties \
  --property schema.registry.url=${CCLOUD_SRURL1} \
  --property basic.auth.credentials.source=USER_INFO \
  --property basic.auth.user.info=${CCLOUD_SRKEY1}:${CCLOUD_SRSECRET1}

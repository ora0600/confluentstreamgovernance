#!/bin/bash
source source-vars
# Set title
export PROMPT_COMMAND='echo -ne "\033]0;Consume from PAGEVIEWS\007"'
echo -e "\033];Consume from PAGEVIEWS\007"

# Terminal 3
# Consume from Destination Cluster (AWS in Franfurt)
echo "consume from PAGEVIEWS: "
kafka-avro-console-consumer --bootstrap-server $CCLOUD_CLUSTERID1_BOOTSTRAP --topic pageviews \
 --consumer.config ../ccloud_user1.properties \
 --group HACKTHEWORLD \
 --property basic.auth.credentials.source=USER_INFO \
 --property schema.registry.url=$CCLOUD_SRURL1 \
 --property schema.registry.basic.auth.user.info=$CCLOUD_SRKEY1:$CCLOUD_SRSECRET1
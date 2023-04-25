#!/bin/bash
# Set title
source source-vars
export PROMPT_COMMAND='echo -ne "\033]0;Consume from Topic webinar\007"'
echo -e "\033];Consume from Topic webinar\007"

# Terminal 3
# Consume 
echo "Consume from Topic webinar: "
kafka-avro-console-consumer --bootstrap-server $CCLOUD_CLUSTERID1_BOOTSTRAP --topic webinar --group validavroconsumer --consumer.config ../ccloud_user1.properties \
 --from-beginning \
 --property basic.auth.credentials.source=USER_INFO \
 --property schema.registry.url=$CCLOUD_SRURL1  \
 --property schema.registry.basic.auth.user.info=$CCLOUD_SRKEY1:$CCLOUD_SRSECRET1

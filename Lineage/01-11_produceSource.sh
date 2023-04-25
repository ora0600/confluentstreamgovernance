#!/bin/bash
source source-vars
# set title
export PROMPT_COMMAND='echo -ne "\033]0;Produce to Source cmtest1\007"'
echo -e "\033];Produce to Source cmtest1\007"

# Terminal 4
# Produce data to source from local laptop and check how fast both consumer windows are reading (almost real-time)
echo '{"name":"Apple Magic Mouse","count":1}'
echo '{"name":"Mac Book Pro","count":1}'
echo "produce into cmtest1:"
kafka-avro-console-producer --bootstrap-server $CCLOUD_CLUSTERID1_BOOTSTRAP --topic cmtest1 \
 --producer.config ../ccloud_user1.properties \
 --property value.schema='{"type":"record","name":"schema","fields":[{"name":"name","type":"string"},{"name":"count", "type": "int"}]}' \
 --property basic.auth.credentials.source=USER_INFO \
 --property schema.registry.url=$CCLOUD_SRURL1 \
 --property schema.registry.basic.auth.user.info=$CCLOUD_SRKEY1:$CCLOUD_SRSECRET1
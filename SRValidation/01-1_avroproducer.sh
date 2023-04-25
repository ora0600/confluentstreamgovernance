#!/bin/bash
# set title
source source-vars
export PROMPT_COMMAND='echo -ne "\033]0;Avro producer - Schema compliant\007"'
echo -e "\033];Avro producer - Schema compliant\007"

# Terminal 1
# Produce data to source from local laptop and check how fast both consumer windows are reading (almost real-time)
echo "Produce data with correct Schema"
echo '{"speaker": "Evi","quality": "Super"}'
echo '{"speaker": "Suvad","quality": "Viel Luft nach oben!"}'
echo '{"speaker": "Carsten","quality": "Geht so"}'
kafka-avro-console-producer --bootstrap-server $CCLOUD_CLUSTERID1_BOOTSTRAP --topic webinar --producer.config ../ccloud_user1.properties \
 --property value.schema='{"type":"record",  "namespace": "io.confluent.examples.clients.basicavro","name":"webinar","fields":[{"name":"speaker","type":"string"},{"name": "quality","type": "string"}]}' \
 --property basic.auth.credentials.source=USER_INFO \
 --property schema.registry.url=$CCLOUD_SRURL1 \
 --property schema.registry.basic.auth.user.info=$CCLOUD_SRKEY1:$CCLOUD_SRSECRET1

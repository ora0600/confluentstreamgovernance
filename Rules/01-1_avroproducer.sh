#!/bin/bash
# set title
source source-vars
export PROMPT_COMMAND='echo -ne "\033]0;Avro producer - SchemaRule - String must <10 compliant\007"'
echo -e "\033];Avro producer - SchemaRule - String must <10 compliant\007"

# Terminal 1
# Produce data to source from local laptop and check how fast both consumer windows are reading (almost real-time)
echo "Produce data with correct SchemaRule - SchemaRule - String must <10 compliant"
echo '{"f1": "success"}'
echo '{"f1": "this will fail, because lengtg is >=10"}'
echo "Producer with Schem Rule started, enter Event:"
kafka-avro-console-producer \
  --topic schemarule \
  --broker-list ${CCLOUD_CLUSTERID1_BOOTSTRAP} \
  --producer.config ../ccloud_user1.properties \
  --property schema.registry.url=${CCLOUD_SRURL1} \
  --property basic.auth.credentials.source=USER_INFO \
  --property basic.auth.user.info=${CCLOUD_SRKEY1}:${CCLOUD_SRSECRET1} \
  --property value.schema='{"type":"record","name":"schemarule","fields": [{"name":"f1","type":"string"}]}' \
  --property value.rule.set='{ "domainRules": [{ "name": "checkLen", "kind": "CONDITION", "type": "CEL", "mode": "WRITE", "expr": "size(message.f1) < 10", "onFailure": "ERROR"}]}' \
  --property rule.executors=checkLen \
  --property rule.executors.checkLen.class=io.confluent.kafka.schemaregistry.rules.cel.CelExecutor


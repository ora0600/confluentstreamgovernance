#!/bin/bash
# Schema Validierung autostart script

## Internal variables
pwd > basedir
export BASEDIR=$(cat basedir)
source source-vars

# create topic
echo "create topic webinar"
kafka-topics --create --bootstrap-server $CCLOUD_CLUSTERID1_BOOTSTRAP --topic webinar \
--replication-factor 3 --partitions 2 --command-config ../ccloud_user1.properties 
echo "topic webinar created"
# create Schema
echo "create Schema webinar"
curl --silent -u $CCLOUD_SRKEY1:$CCLOUD_SRSECRET1 -X POST -H "Content-Type: application/json" \
--data @../data/webinar.json $CCLOUD_SRURL1/subjects/webinar/versions
echo "Schema webinar created"

# open Producer and Consumer Terminals
echo "Open producer and consumer Terminals with iterm...."
open -a iterm
sleep 10
osascript 01_schemavalidierung.scpt $BASEDIR
echo ">>>>>>>>>> Switch to iTerm 2 and see producing and consuming"
echo ">>>>>>>>>>>>> Enable Schema Validation on topic webinar in a different terminal"
echo ">>>>>>>>>>>>> confluent kafka topic update webinar --config confluent.value.schema.validation=true --environment $CCLOUD_ENVID1 --cluster $CCLOUD_CLUSTERID1"
echo ">>>>>>>>>>>>> confluent kafka topic describe webinar --environment $CCLOUD_ENVID1 --cluster $CCLOUD_CLUSTERID1"
echo ""
echo ">>>>>>>>>>>>> stop this demo kill iterm2 and stop Confluent Cloud : ../02_drop_ccloudcluster.sh "


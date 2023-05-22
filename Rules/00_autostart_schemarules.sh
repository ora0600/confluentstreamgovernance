#!/bin/bash
# Schema Rules autostart script

## Internal variables
pwd > basedir
export BASEDIR=$(cat basedir)
source source-vars

# create topic
echo "create topic schemarule"
kafka-topics --create --bootstrap-server $CCLOUD_CLUSTERID1_BOOTSTRAP --topic schemarule --replication-factor 3 --partitions 2 --command-config ../ccloud_user1.properties 
echo "topic schemarule created"
# create Schema
echo "create Schema schemarule"
curl --silent -u $CCLOUD_SRKEY1:$CCLOUD_SRSECRET1 -X POST -H "Content-Type: application/json" --data @../data/schemarule.json $CCLOUD_SRURL1/subjects/schemarule/versions
echo "Schema schemarule created"

# open Producer and Consumer Terminals
echo "Open producer and consumer Terminals with iterm...."
open -a iterm
sleep 10
osascript 01_schemarule.scpt $BASEDIR
echo ">>>>>>>>>> Switch to iTerm 2 and see producing and consuming"
echo ">>>>>>>>>>>>> stop this demo kill iterm2 and stop Confluent Cloud : ../02_drop_ccloudcluster.sh "


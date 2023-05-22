#!/bin/bash

###### set environment variables
# CCloud new environment, have to be created before
source env-vars
# new parameters
touch env-vars-new

pwd > basedir
export BASEDIR=$(cat basedir)
echo $BASEDIR

###### Create cluster automatically

# CREATE CCLOUD cluster 
#confluent update
confluent login
# environment create
confluent environment create $XX_CCLOUD_ENV -o yaml > environmnent1
export CCLOUD_ENVID1=$(awk '/id:/{print $NF}' environmnent1)
echo "envid=$CCLOUD_ENVID1" >> env-vars-new
confluent environment use $CCLOUD_ENVID1

# Create SR in environment
confluent schema-registry cluster enable --cloud gcp --geo eu --package advanced --environment $CCLOUD_ENVID1 -o yaml > srclusterid1
export CCLOUD_SRCLUSTERID1=$(awk '/id:/{print $NF}' srclusterid1)
export CCLOUD_SRURL1=$(awk '/endpoint_url:/{print $NF}' srclusterid1)
echo "srid=$CCLOUD_SRCLUSTERID1" >> env-vars-new
echo "srurl=$CCLOUD_SRURL1" >> env-vars-new
# Create SR APIKEY
confluent api-key create --resource $CCLOUD_SRCLUSTERID1 --description "APKKEY for SR $CCLOUD_SRCLUSTERID1" -o yaml > srapi_key1
export CCLOUD_SRKEY1=$(awk '/key/{print $NF}' srapi_key1)
export CCLOUD_SRSECRET1=$(awk '/secret/{print $NF}' srapi_key1)
echo "srkey=$CCLOUD_SRKEY1" >> env-vars-new
echo "srsecret=$CCLOUD_SRSECRET1" >> env-vars-new

# Cluster1
echo "Create new cluster $XX_CCLOUD_CLUSTERNAME"
confluent kafka cluster create $XX_CCLOUD_CLUSTERNAME --cloud "$XX_CCLOUD" --region "$XX_CCREGION" --type "basic" --environment $CCLOUD_ENVID1 -o yaml > clusterid1
#confluent kafka cluster create $XX_CCLOUD_CLUSTERNAME --cloud "$XX_CCLOUD" --region "$XX_CCREGION" --type "dedicated" --availability "single-zone" --cku 1 --environment $CCLOUD_ENVID1 -o yaml > clusterid1
# set cluster id as parameter
export CCLOUD_CLUSTERID1=$(awk '/id:/{print $NF}' clusterid1)
echo "clusterid=$CCLOUD_CLUSTERID1" >> env-vars-new
echo "⌛ Give cluster 15 minutes..."
sleep 900
#echo "⌛ Give cluster 2 minutes..."
#sleep 120
confluent kafka cluster describe $CCLOUD_CLUSTERID1 -o yaml > clusterid1
export CCLOUD_CLUSTERID1_BOOTSTRAP=$(awk '/endpoint: SASL_SSL:\/\//{print $NF}' clusterid1 | sed 's/SASL_SSL:\/\///g')
export CCLOUD_CLUSTERID1_REST=$(awk '/rest_endpoint:/{print $NF}' clusterid1)
echo "clusterbootstrap=$CCLOUD_CLUSTERID1_BOOTSTRAP" >> env-vars-new
echo "cluster-rest=$CCLOUD_CLUSTERID1_REST" >> env-vars-new
confluent kafka cluster use $CCLOUD_CLUSTERID1
confluent kafka cluster describe $CCLOUD_CLUSTERID1 -o human

# create API Keys
confluent api-key create --resource $CCLOUD_CLUSTERID1 --description "User API Key for cluster $XX_CCLOUD_CLUSTERNAME" -o yaml > apikey1
export CCLOUD_KEY1=$(awk '/key/{print $NF}' apikey1)
export CCLOUD_SECRET1=$(awk '/secret/{print $NF}' apikey1)
echo "clusterkey=$CCLOUD_KEY1" >> env-vars-new
echo "clustersecret=$CCLOUD_SECRET1"  >> env-vars-new

echo "*************************************"
echo "*****      CLUSTER CREATED     ******"
echo "*************************************"

# create property-file for ccloud user1
echo "ssl.endpoint.identification.algorithm=https
sasl.mechanism=PLAIN
request.timeout.ms=20000
bootstrap.servers=$CCLOUD_CLUSTERID1_BOOTSTRAP
retry.backoff.ms=500
sasl.jaas.config=org.apache.kafka.common.security.plain.PlainLoginModule required username=\"$CCLOUD_KEY1\" password=\"$CCLOUD_SECRET1\";
security.protocol=SASL_SSL
client.dns.lookup=use_all_dns_ips
session.timeout.ms=45000
acks=all" > ccloud_user1.properties

echo "*************************************"
echo "*****      CREATE TOPICS      ******"
echo "*************************************"
# create topic
# topic in ccloud in source
kafka-topics --create --bootstrap-server $CCLOUD_CLUSTERID1_BOOTSTRAP --topic users \
--replication-factor 3 --partitions 1 --command-config ./ccloud_user1.properties 
echo "Topic users created"
kafka-topics --create --bootstrap-server $CCLOUD_CLUSTERID1_BOOTSTRAP --topic pageviews \
--replication-factor 3 --partitions 1 --command-config ./ccloud_user1.properties 
echo "Topic pageviews created"
kafka-topics --create --bootstrap-server $CCLOUD_CLUSTERID1_BOOTSTRAP --topic cmtest1 \
--replication-factor 3 --partitions 1 --command-config ./ccloud_user1.properties 
echo "Topic cmtest1 created"
echo "*************************************"
echo "*****      TOPICS  CREATED     ******"
echo "*************************************"

echo "*************************************"
echo "*****      CREATE CONNECTORS   ******"
echo "*************************************"
# create connectors
echo "{
  \"connector.class\": \"DatagenSource\",
  \"name\": \"datagen-users\",
  \"kafka.api.key\": \"$CCLOUD_KEY1\",
  \"kafka.api.secret\": \"$CCLOUD_SECRET1\",
  \"kafka.topic\": \"users\",
  \"output.data.format\": \"AVRO\",
  \"quickstart\": \"USERS\",
  \"max.interval\": \"1000\",
  \"tasks.max\": \"1\"
}" > datagen-users.json
confluent  connect cluster create --cluster $CCLOUD_CLUSTERID1 --environment $CCLOUD_ENVID1 --config-file datagen-users.json  -o yaml > datagen-users
export CCLOUD_DGENUSERSID=$(awk '/id:/{print $NF}' datagen-users)
echo "connectorid1=$CCLOUD_DGENUSERSID" >> env-vars-new
echo "datagen-users connector created"

echo "{
  \"connector.class\": \"DatagenSource\",
  \"name\": \"datagen-pageviews\",
  \"kafka.api.key\": \"$CCLOUD_KEY1\",
  \"kafka.api.secret\": \"$CCLOUD_SECRET1\",
  \"kafka.topic\": \"pageviews\",
  \"output.data.format\": \"AVRO\",
  \"quickstart\": \"PAGEVIEWS\",
  \"max.interval\": \"1000\",
  \"tasks.max\": \"1\"
}" > datagen-pageviews.json
confluent  connect cluster create --cluster $CCLOUD_CLUSTERID1 --environment $CCLOUD_ENVID1 --config-file datagen-pageviews.json -o yaml > datagen-pageviews
export CCLOUD_DGENPAGEVIEWSID=$(awk '/id:/{print $NF}' datagen-pageviews)
echo "connectorid2=$CCLOUD_DGENPAGEVIEWSID" >> env-vars-new
echo "datagen-pageviews connector created"
echo "*************************************"
echo "*****      CONNECTORS CREATED  ******"
echo "*************************************"

echo "*************************************"
echo "*****      CREATE KSQLDB       ******"
echo "*************************************"
# Create Service account for ksqlDB
confluent iam service-account create "ksqldbSA1" --description "ksqldbSA1 service account." -o yaml > sa1
export SA1ID=$(awk '/id:/{print $NF}' sa1)
echo "sa1id=$SA1ID" >> env-vars-new
confluent kafka acl create --allow --service-account "$SA1ID" --cluster "$CCLOUD_CLUSTERID1" --environment "$CCLOUD_ENVID1" --operations ALTER --prefix --consumer-group "*"
confluent kafka acl create --allow --service-account "$SA1ID" --cluster "$CCLOUD_CLUSTERID1" --environment "$CCLOUD_ENVID1" --operations ALTER --prefix --topic "*"
confluent kafka acl create --allow --service-account "$SA1ID" --cluster "$CCLOUD_CLUSTERID1" --environment "$CCLOUD_ENVID1" --operations ALTER --topic "*"
confluent kafka acl create --allow --service-account "$SA1ID" --cluster "$CCLOUD_CLUSTERID1" --environment "$CCLOUD_ENVID1" --operations ALTER_CONFIGS --prefix --consumer-group "*"
confluent kafka acl create --allow --service-account "$SA1ID" --cluster "$CCLOUD_CLUSTERID1" --environment "$CCLOUD_ENVID1" --operations ALTER_CONFIGS --prefix --topic "*"
confluent kafka acl create --allow --service-account "$SA1ID" --cluster "$CCLOUD_CLUSTERID1" --environment "$CCLOUD_ENVID1" --operations CREATE --prefix --consumer-group "*"
confluent kafka acl create --allow --service-account "$SA1ID" --cluster "$CCLOUD_CLUSTERID1" --environment "$CCLOUD_ENVID1" --operations CREATE --prefix --topic "*"
confluent kafka acl create --allow --service-account "$SA1ID" --cluster "$CCLOUD_CLUSTERID1" --environment "$CCLOUD_ENVID1" --operations CREATE --topic "*"
confluent kafka acl create --allow --service-account "$SA1ID" --cluster "$CCLOUD_CLUSTERID1" --environment "$CCLOUD_ENVID1" --operations DELETE --prefix --consumer-group "*"
confluent kafka acl create --allow --service-account "$SA1ID" --cluster "$CCLOUD_CLUSTERID1" --environment "$CCLOUD_ENVID1" --operations DELETE --prefix --topic "*"
confluent kafka acl create --allow --service-account "$SA1ID" --cluster "$CCLOUD_CLUSTERID1" --environment "$CCLOUD_ENVID1" --operations DESCRIBE --cluster-scope
confluent kafka acl create --allow --service-account "$SA1ID" --cluster "$CCLOUD_CLUSTERID1" --environment "$CCLOUD_ENVID1" --operations DESCRIBE --consumer-group "*"
confluent kafka acl create --allow --service-account "$SA1ID" --cluster "$CCLOUD_CLUSTERID1" --environment "$CCLOUD_ENVID1" --operations DESCRIBE --prefix --consumer-group "*"
confluent kafka acl create --allow --service-account "$SA1ID" --cluster "$CCLOUD_CLUSTERID1" --environment "$CCLOUD_ENVID1" --operations DESCRIBE --topic "*"
confluent kafka acl create --allow --service-account "$SA1ID" --cluster "$CCLOUD_CLUSTERID1" --environment "$CCLOUD_ENVID1" --operations DESCRIBE --transactional-id "*"
confluent kafka acl create --allow --service-account "$SA1ID" --cluster "$CCLOUD_CLUSTERID1" --environment "$CCLOUD_ENVID1" --operations DESCRIBE_CONFIGS --cluster-scope
confluent kafka acl create --allow --service-account "$SA1ID" --cluster "$CCLOUD_CLUSTERID1" --environment "$CCLOUD_ENVID1" --operations DESCRIBE_CONFIGS --consumer-group "*"
confluent kafka acl create --allow --service-account "$SA1ID" --cluster "$CCLOUD_CLUSTERID1" --environment "$CCLOUD_ENVID1" --operations DESCRIBE_CONFIGS --prefix --consumer-group "*"
confluent kafka acl create --allow --service-account "$SA1ID" --cluster "$CCLOUD_CLUSTERID1" --environment "$CCLOUD_ENVID1" --operations DESCRIBE_CONFIGS --topic "*"
confluent kafka acl create --allow --service-account "$SA1ID" --cluster "$CCLOUD_CLUSTERID1" --environment "$CCLOUD_ENVID1" --operations DESCRIBE_CONFIGS --prefix --topic "*"
confluent kafka acl create --allow --service-account "$SA1ID" --cluster "$CCLOUD_CLUSTERID1" --environment "$CCLOUD_ENVID1" --operations READ --prefix --consumer-group "*"
confluent kafka acl create --allow --service-account "$SA1ID" --cluster "$CCLOUD_CLUSTERID1" --environment "$CCLOUD_ENVID1" --operations READ --topic "*"
confluent kafka acl create --allow --service-account "$SA1ID" --cluster "$CCLOUD_CLUSTERID1" --environment "$CCLOUD_ENVID1" --operations READ --prefix --topic "*"
confluent kafka acl create --allow --service-account "$SA1ID" --cluster "$CCLOUD_CLUSTERID1" --environment "$CCLOUD_ENVID1" --operations WRITE --prefix --consumer-group "*"
confluent kafka acl create --allow --service-account "$SA1ID" --cluster "$CCLOUD_CLUSTERID1" --environment "$CCLOUD_ENVID1" --operations WRITE --topic "*"
confluent kafka acl create --allow --service-account "$SA1ID" --cluster "$CCLOUD_CLUSTERID1" --environment "$CCLOUD_ENVID1" --operations WRITE --prefix --topic "*"
confluent kafka acl create --allow --service-account "$SA1ID" --cluster "$CCLOUD_CLUSTERID1" --environment "$CCLOUD_ENVID1" --operations WRITE --transactional-id "*"
# add rolebindung
confluent iam rbac role-binding create --principal User:$SA1ID --role ResourceOwner --environment $CCLOUD_ENVID1 --schema-registry-cluster $CCLOUD_SRCLUSTERID1 --resource Subject:* -o yaml

# create api keys
confluent api-key create --service-account "$SA1ID" --resource "$CCLOUD_CLUSTERID1" --environment "$CCLOUD_ENVID1" -o yaml > sakey1
export SA1KEY=$(awk '/key:/{print $NF}' sakey1)
export SA1SECRET=$(awk '/secret:/{print $NF}' sakey1)
echo "sa1key=$SA1KEY" >> env-vars-new
echo "sa1secret=$SA1SECRET" >> env-vars-new
confluent api-key create --resource $CCLOUD_SRCLUSTERID1 --service-account "$SA1ID" --description "APIKEY for SR $CCLOUD_SRCLUSTERID1 and SA $SA1ID" -o yaml > srsa1api_key1
export CCLOUD_SRSA1KEY1=$(awk '/key/{print $NF}' srsa1api_key1)
export CCLOUD_SRSA1SECRET1=$(awk '/secret/{print $NF}' srsa1api_key1)
echo "srsa1key=$CCLOUD_SRSA1KEY1" >> env-vars-new
echo "srsa1secret=$CCLOUD_SRSA1SECRET1" >> env-vars-new


# Create KSQLDB APP
confluent ksql cluster create ksqlDB01 --csu 1 --credential-identity $SA1ID --environment $CCLOUD_ENVID1 --cluster $CCLOUD_CLUSTERID1 -o yaml > ksqldbid
export CCLOUD_KSQLDB_ID=$(awk '/id:/{print $NF}' ksqldbid)
echo "ksqldbid=$CCLOUD_KSQLDB_ID" >> env-vars-new
echo "Create API Key for REST Access"
confluent api-key create --resource $CCLOUD_KSQLDB_ID --description "API KEY for KSQLDB cluster $CCLOUD_KSQLDB_ID" -o yaml > ksqldbapi
export CCLOUD_KSQLDBKEY1=$(awk '/key:/{print $NF}' ksqldbapi)
export CCLOUD_KSQLDBSECRET1=$(awk '/secret:/{print $NF}' ksqldbapi)
echo "ksqldbkey=$CCLOUD_KSQLDBKEY1" >> env-vars-new
echo "ksqldbsecret=$CCLOUD_KSQLDBSECRET1" >> env-vars-new
echo "************************************************"
echo "⌛ Give KSQLDB APP 10 Minutes to start..."
sleep 600
confluent ksql cluster describe  $CCLOUD_KSQLDB_ID --environment $CCLOUD_ENVID1 -o yaml > ksqldbid
export CCLOUD_KSQLDB_REST=$(awk '/endpoint:/{print $NF}' ksqldbid)
echo "ksqldbrest=$CCLOUD_KSQLDB_REST" >> env-vars-new

#echo "Add acl to topics for ksqldb"
confluent ksql cluster configure-acls $CCLOUD_KSQLDB_ID users pageviews --cluster $CCLOUD_CLUSTERID1
echo "*************************************"
echo "*****      KSQLDB CREATED      ******"
echo "*************************************"


echo "*************************************"
echo "*****      CREATE STREAMS      ******"
echo "*************************************"
curl -X "POST" "$CCLOUD_KSQLDB_REST/ksql" \
     -H "Content-Type: application/vnd.ksql.v1+json; charset=utf-8" \
     -u $CCLOUD_KSQLDBKEY1:$CCLOUD_KSQLDBSECRET1\
     -d $'{"ksql": "CREATE STREAM pageviews_original (viewtime bigint, userid varchar, pageid varchar) WITH (kafka_topic=\'pageviews\', value_format=\'AVRO\');", "streamsProperties": {"ksql.streams.auto.offset.reset": "earliest"}}'|jq
echo "⌛ Streams created give it 1 minute..."
sleep 60
curl -X "POST" "$CCLOUD_KSQLDB_REST/ksql" \
     -H "Content-Type: application/vnd.ksql.v1+json; charset=utf-8" \
     -u $CCLOUD_KSQLDBKEY1:$CCLOUD_KSQLDBSECRET1\
     -d $'{"ksql": "CREATE TABLE users (userid VARCHAR PRIMARY KEY, registertime BIGINT, id VARCHAR, regionid VARCHAR, gender VARCHAR) WITH (KAFKA_TOPIC=\'users\', VALUE_FORMAT=\'AVRO\');", "streamsProperties": {"ksql.streams.auto.offset.reset": "earliest"}}'|jq
echo "⌛ Table created give it 1 minute..."
sleep 60
curl -X "POST" "$CCLOUD_KSQLDB_REST/ksql" \
     -H "Content-Type: application/vnd.ksql.v1+json; charset=utf-8" \
     -u $CCLOUD_KSQLDBKEY1:$CCLOUD_KSQLDBSECRET1 \
     -d $'{"ksql": "CREATE STREAM pageviews_enriched AS SELECT users.userid AS userid, pageid, regionid, gender FROM pageviews_original LEFT JOIN users ON pageviews_original.userid = users.userid EMIT CHANGES;", "streamsProperties": {"ksql.streams.auto.offset.reset": "earliest"}}'|jq

echo "*************************************"
echo "*****    STREAMS CREATED       ******"
echo "*************************************"

# create tags
echo "*************************************"
echo "*****    CREATE TAGS          ******"
echo "*************************************"
# Private
curl --silent -u $CCLOUD_SRKEY1:$CCLOUD_SRSECRET1 --header 'Content-Type: application/json' \
--data '[ { "entityTypes" : [ "cf_entity" ],"name" :  "CMPrivate", "description" : "Private tag description"} ]' \
--url $CCLOUD_SRURL1/catalog/v1/types/tagdefs | jq . 
# PII
curl --silent -u $CCLOUD_SRKEY1:$CCLOUD_SRSECRET1 --header 'Content-Type: application/json' \
--data '[ { "entityTypes" : [ "cf_entity" ],"name" :  "CMPII", "description" : "Personally identifiable information"} ]' \
--url $CCLOUD_SRURL1/catalog/v1/types/tagdefs | jq . 
#GDPR
curl --silent -u $CCLOUD_SRKEY1:$CCLOUD_SRSECRET1 --header 'Content-Type: application/json' \
--data '[ { "entityTypes" : [ "cf_entity" ],"name" :  "CMGDPR", "description" : "Data data proctect law (EU)"} ]' \
--url $CCLOUD_SRURL1/catalog/v1/types/tagdefs | jq . 
# Public
curl --silent -u $CCLOUD_SRKEY1:$CCLOUD_SRSECRET1 --header 'Content-Type: application/json' \
--data '[ { "entityTypes" : [ "cf_entity" ],"name" :  "CMPublic", "description" : "Public tag description"} ]' \
--url $CCLOUD_SRURL1/catalog/v1/types/tagdefs | jq . 
# Sensitiv
curl --silent -u $CCLOUD_SRKEY1:$CCLOUD_SRSECRET1 --header 'Content-Type: application/json' \
--data '[ { "entityTypes" : [ "cf_entity" ],"name" :  "CMSensitive", "description" : "Sensitive tag description"} ]' \
--url $CCLOUD_SRURL1/catalog/v1/types/tagdefs | jq . 
# Schema hamburgers
curl --silent -u $CCLOUD_SRKEY1:$CCLOUD_SRSECRET1 -X POST -H "Content-Type: application/json" \
--data @data/hamburgers.json $CCLOUD_SRURL1/subjects/Hamburgers/versions
# Business Metadata for schema
curl --silent -u  $CCLOUD_SRKEY1:$CCLOUD_SRSECRET1  -X POST -H "Content-Type: application/json" \
--data @data/teamsr.txt $CCLOUD_SRURL1/catalog/v1/types/businessmetadatadefs | jq .
### Geht noch nicht muss ich nochmal testen see https://docs.confluent.io/cloud/current/stream-governance/stream-catalog-rest-apis.html#add-business-metadata-to-a-topic
# Business Data for a topic 
curl --silent -u  $CCLOUD_SRKEY1:$CCLOUD_SRSECRET1  -X POST -H "Content-Type: application/json" \
--data @data/teamtopic.txt $CCLOUD_SRURL1/catalog/v1/types/businessmetadatadefs | jq .
# Business Data to Schema see https://docs.confluent.io/cloud/current/stream-governance/stream-catalog-rest-apis.html#add-business-metadata-to-a-schema-related-entity
curl --silent -u $CCLOUD_SRKEY1:$CCLOUD_SRSECRET1 GET $CCLOUD_SRURL1/subjects/Hamburgers/versions/1 | jq .
echo "Change Schema ID in data/team-data.txt and execute curl"
echo "curl --silent -u $CCLOUD_SRKEY1:$CCLOUD_SRSECRET1  -X POST -H \"Content-Type: application/json\" --data @data/team-data.txt $CCLOUD_SRURL1/catalog/v1/entity/businessmetadata | jq ."
### Business Metadata setup noch mal testen
echo "*************************************"
echo "*****    TAGS CREATED          ******"
echo "*************************************"

# Finish
echo "Cluster, Topics, SA, ACLs, Schema, Tags, Connectors, ksqlDB, started..."
echo "Delete Cluster extensions with ./02_drop_ccloudcluster.sh"
echo "***************************************************"
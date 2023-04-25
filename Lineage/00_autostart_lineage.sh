#!/bin/bash

###### set environment variables
source source-vars
pwd > basedir
export BASEDIR=$(cat basedir)

echo "#########  Following actions for you ############"
echo "Add the following Code to KSQLDB to add a stream and a table"
PRETTY_CODE="\e[1;100;37m"
printf "${PRETTY_CODE}%s\e[0m\n" "${1}"
# Add streams to KSQLDB
echo "Create Streams and Tables first: see github webinar3 readme"
echo "Try ksqldb cli..."
KSQLCLI="ksql -u $CCLOUD_KSQLDBKEY1  -p $CCLOUD_KSQLDBSECRET1 $CCLOUD_KSQLDB_REST"
printf "${PRETTY_CODE}%s\e[0m\n" "${KSQLCLI}"
echo "Try ksqldb rest via curl..."
CURLREST="curl -X \"POST\" \"$CCLOUD_KSQLDB_REST/query\" \
     -H \"Content-Type: application/vnd.ksql.v1+json; charset=utf-8\" \
     -u '$CCLOUD_KSQLDBKEY1:$CCLOUD_KSQLDBSECRET1' \
     -d $'{
           \"ksql\": \"SELECT * from pageviews_original emit changes limit 1;\",
           \"streamsProperties\": {}
        }'|jq"
printf "${PRETTY_CODE}%s\e[0m\n" "${CURLREST}"

# install some errors 
curl -X "POST" "$CCLOUD_KSQLDB_REST/ksql" \
     -H "Content-Type: application/vnd.ksql.v1+json; charset=utf-8" \
     -u $CCLOUD_KSQLDBKEY1:$CCLOUD_KSQLDBSECRET1 \
     -d $'{"ksql": "CREATE STREAM pageviews_enriched_female AS SELECT * from PAGEVIEWS_ENRICHED where gender = \'SHE/HER\' EMIT CHANGES;", "streamsProperties": {"ksql.streams.auto.offset.reset": "earliest"}}'|jq

# Install Tags
# Deprecated
curl --silent -u $CCLOUD_SRKEY1:$CCLOUD_SRSECRET1 --header 'Content-Type: application/json' \
--data '[ { "entityTypes" : [ "sr_schema", "sr_record", "sr_field", "sr_schema" ],"name" :  "CMDeprecated", "description" : "Deprecated tag description"} ]' \
--url $CCLOUD_SRURL1/catalog/v1/types/tagdefs | jq . 
# Deprecated
curl --silent -u $CCLOUD_SRKEY1:$CCLOUD_SRSECRET1 --header 'Content-Type: application/json' \
--data '[ { "entityTypes" : [ "sr_schema", "sr_record", "sr_field", "sr_schema" ],"name" :  "CMDONOTUSE", "description" : "do not use tag description"} ]' \
--url $CCLOUD_SRURL1/catalog/v1/types/tagdefs | jq . 
# change field to deprecated
curl --silent -u $CCLOUD_SRKEY1:$CCLOUD_SRSECRET1 GET $CCLOUD_SRURL1/subjects/users-value/versions/1 | jq . > schemaid
export SCHEMAID=$(awk '/"id":/{print $NF}' schemaid | sed 's/,//g')
# set tags for schema users-value, gender
echo $SCHEMAID
echo $CCLOUD_SRCLUSTERID1
# change the clusterid and schemaid
curl --silent -u $CCLOUD_SRKEY1:$CCLOUD_SRSECRET1 \
--request POST \
--url $CCLOUD_SRURL1/catalog/v1/entity/tags \
--header 'Content-Type: application/json' \
--data '[ {  "entityType" : "sr_field","entityName" : "'$CCLOUD_SRCLUSTERID1':.:'$SCHEMAID':ksql.users.gender","typeName" : "CMDeprecated"} ]' | jq .


# open Producer and Consumer Terminals
echo "Open producer and consumer Terminals with iterm...."
open -a iterm
sleep 10
osascript 01_clients.scpt $BASEDIR

# Finish
echo "Clients are started"
echo "***************************************************"
#!/bin/bash

###### set environment variables
# CCloud environment CMWORKSHOPS, have to be created before
export CCLOUD_ENVID1=$(awk '/id:/{print $NF}' environmnent1)
export CCLOUD_SRCLUSTERID1=$(awk '/id:/{print $NF}' srclusterid1)
export CCLOUD_SRKEY1=$(awk '/key/{print $NF}' srapi_key1)
export CCLOUD_CLUSTERID1=$(awk '/id:/{print $NF}' clusterid1)
export CCLOUD_CLUSTERID1_BOOTSTRAP=$(awk '/endpoint: SASL_SSL:\/\//{print $NF}' clusterid1 | sed 's/SASL_SSL:\/\///g')
export CCLOUD_CLUSTERID1_REST=$(awk '/rest_endpoint:/{print $NF}' clusterid1)
export CCLOUD_KEY1=$(awk '/key/{print $NF}' apikey1)
export CCLOUD_DGENUSERSID=$(awk '/id:/{print $NF}' datagen-users)
export CCLOUD_DGENPAGEVIEWSID=$(awk '/id:/{print $NF}' datagen-pageviews)
export SA1ID=$(awk '/id:/{print $NF}' sa1)
export SA1KEY=$(awk '/key:/{print $NF}' sakey1)
export CCLOUD_SRSA1KEY1=$(awk '/key/{print $NF}' srsa1api_key1)
export CCLOUD_KSQLDB_ID=$(awk '/id:/{print $NF}' ksqldbid)
export CCLOUD_KSQLDB_REST=$(awk '/endpoint:/{print $NF}' ksqldbid)
export CCLOUD_KSQLDBKEY1=$(awk '/key:/{print $NF}' ksqldbapi)

# drop connectors
confluent connect cluster delete $CCLOUD_DGENUSERSID --cluster $CCLOUD_CLUSTERID1 --force
confluent connect cluster delete $CCLOUD_DGENPAGEVIEWSID --cluster $CCLOUD_CLUSTERID1 --force
echo "fully managed Connectors deleted"

# delete ksqldb cluster
confluent ksql cluster delete $CCLOUD_KSQLDB_ID --environment $CCLOUD_ENVID1 --force

# Delete SA and keys
confluent api-key delete $CCLOUD_SRKEY1 --force
confluent api-key delete $CCLOUD_KEY1 --force
confluent api-key delete $SA1KEY --force
confluent api-key delete $CCLOUD_SRSA1KEY1 --force
confluent api-key delete $CCLOUD_KSQLDBKEY1 --force
confluent iam service-account delete $SA1ID --force

# delete cluster
confluent kafka cluster delete $CCLOUD_CLUSTERID1 --force 

# Delete schema registry
confluent schema-registry cluster delete --environment $CCLOUD_ENVID1 --force

# delete environment
confluent environment delete $CCLOUD_ENVID1 --force

# Delete files
rm environmnent1
rm srclusterid1
rm srapi_key1
rm clusterid1
rm apikey1
rm datagen-users
rm datagen-pageviews
rm sa1
rm sakey1
rm srsa1api_key1
rm ksqldbid
rm ksqldbapi
rm datagen-users.json
rm datagen-pageviews.json
rm env-vars-new 
rm ccloud_user1.properties
rm basedir
rm SRValidation/basedir
rm Lineage/schemaid
rm Lineage/basedir


# Finish
echo "Cluster deleted"

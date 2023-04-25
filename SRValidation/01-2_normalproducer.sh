#!/bin/bash
# set title
source source-vars
export PROMPT_COMMAND='echo -ne "\033]0;Normal producer - Non Schema compliant\007"'
echo -e "\033];Normal producer - Non Schema compliant\007"

# Terminal 1
# Produce data to source from local laptop and check how fast both consumer windows are reading (almost real-time)
echo "Produce data with wrong data and see what is happening on consumer side"
echo '{"speaker": "Carsten","quality": 1.0}'
echo 'Bla bla'
kafka-console-producer --bootstrap-server $CCLOUD_CLUSTERID1_BOOTSTRAP --topic webinar --producer.config ../ccloud_user1.properties


#!/usr/bin/env bash
set -e
echo $* 1>&2

ES_SERVICE_NAME=`echo $DOCKERCLOUD_SERVICE_HOSTNAME | sed "s/-scaledown//"`
LAST_ES_IP=`set | egrep -ie "${ES_SERVICE_NAME}_[0-9]+_PORT_9200_TCP_ADDR" | cut -d'=' -f2 | tail -1`
LAST_ES_NAME=`set | egrep -ie "${ES_SERVICE_NAME}_[0-9]+_PORT_9200_TCP_ADDR" | sed "s/_PORT.*//" | tail -1 | awk '{print tolower($0)}'`
NUM_ES_CONTAINERS=`set | egrep -ie "${ES_SERVICE_NAME}_[0-9]+_PORT_9200_TCP_ADDR" | wc -l`

echo -e "es_service_name: $ES_SERVICE_NAME\nlast_es_ip: $LAST_ES_IP\nlast_es_name: $LAST_ES_NAME\nnum_es_containers: $NUM_ES_CONTAINERS\n"


# Evacuate shards
curl -s -XPUT "http://${ES_SERVICE_NAME}:9200/_cluster/settings" -d "{ \"transient\" : { \"cluster.routing.allocation.exclude._ip\" : \"$LAST_ES_IP\" } }"

# Wait for shards to finished evacuating
echo "Evacuating shards"
while true; do curl -s http://${ES_SERVICE_NAME}:9200/_cat/shards | egrep -e "${LAST_ES_NAME}$" || break; sleep 5; done

# Get service UUID
ES_SERVICE_UUID=`\
	curl -s -H "Authorization: $DOCKERCLOUD_AUTH" -H "Accept: application/json" ${DOCKERCLOUD_REST_HOST}/api/app/v1/${ORG_NAME}service/?limit=250 |\
	jq '.objects[] | .name + " " +.uuid' |\
	egrep -ie "$ES_SERVICE_NAME "|\
	cut -d$' ' -f2 |
	sed 's/"//g'`


# Scale Service
echo "Scaling down cluster"
TARGET_NUM_CONTAINERS=`echo "$NUM_ES_CONTAINERS - 1" | bc`
curl -s -H "Content-Type: application/json" -H "Authorization: $DOCKERCLOUD_AUTH" -H "Accept: application/json" ${DOCKERCLOUD_REST_HOST}/api/app/v1/${ORG_NAME}service/${ES_SERVICE_UUID}/ -XPATCH -d '{ "target_num_containers" : $TARGET_NUM_CONTAINERS }'
curl -s -H "Authorization: $DOCKERCLOUD_AUTH" -H "Accept: application/json" ${DOCKERCLOUD_REST_HOST}/api/app/v1/${ORG_NAME}service/${ES_SERVICE_UUID}/scale/ -XPOST

# Remove exclude
curl -s -XPUT "http://${ES_SERVICE_NAME}:9200/_cluster/settings" -d "{ \"transient\" : { \"cluster.routing.allocation.exclude._ip\" : \"\" } }"

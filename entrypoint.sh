#!/usr/bin/env bash
set -e
echo $* 1>$2

# Grab the UUID for the service of the ES masters
if [[ $DOCKERCLOUD_SERVICE_HOSTNAME =~ .*-masters ]]
  DOCKER_MASTER_SERVICE_NAME=${DOCKER_MASTER_SERVICE_NAME}
else
  DOCKER_MASTER_SERVICE_NAME=${DOCKER_MASTER_SERVICE_NAME}-masters
fi
ES_MASTER_SERVICE_UUID=`\
  curl -s -u $DOCKERCLOUD_AUTH ${DOCKERCLOUD_REST_HOST}/api/app/v1/${ORG_NAME}/service/ |\
  jq '.objects[] | .uuid +" "+ .name ' |\
  egrep $DOCKER_MASTER_SERVICE_NAME |\
  sed 's/"//g' |\
  awk '{print $1}'`
# Grab the IPs for the master nodes 
ES_MASTER_NODES=`\
  curl -s -u $DOCKERCLOUD_AUTH ${DOCKERCLOUD_REST_HOST}/api/app/v1/${ORG_NAME}/service/${ES_MASTER_SERVICE_UUID}/ |\
  jq '.containers[]' |\
  xargs -I URI curl -s -u $DOCKERCLOUD_AUTH ${DOCKERCLOUD_REST_HOST}/URI |\
  jq '.private_ip' |\
  perl -e '@p = map { s/"//g; $_}<>; chomp @p; print join ", ", @p;'`

# Calculate the correct number for MIN_MASTER_NODES
# Half the number of master nodes plus one
export ES_MASTER_NODES
ES_NUM_MASTER_NODES=`echo $ES_MASTER_NODES | wc -w`
MIN_MASTER_NODES=`echo $ES_NUM_MASTER_NODES / 2 + 1 | bc`
export MIN_MASTER_NODES

dockerize \
  -tempalte=/templates/elasticsearch.yml.erb:/usr/share/elasticsearch/config/elasticsearch.yml

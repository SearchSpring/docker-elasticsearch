FROM searchspring/elasticsearch_2_4_1

COPY templates /templates
COPY docker/*.sh /usr/local/bin/

ENV \
# https://www.elastic.co/guide/en/elasticsearch/guide/current/heap-sizing.html
  ES_HEAP_SIZE=1g \
  CLUSTERNAME=elasticsearch \
  MIN_MASTER_NODES=2 \
# https://www.elastic.co/guide/en/elasticsearch/plugins/5.0/discovery-ec2-discovery.html
  DISCOVERY_GROUPS=elasticsearch \
  DISCOVERY_HOSTYPE=private_ip \
  DISCOVERY_REGION=us-east-1 \
  DISCOVERY_AZ=us-east-1b \
  DISCOVERY_ANY_GROUP=true \
  DISCOVERY_NODE_CACHE_TIME=10s \
  DATANODE=true \
  MASTERNODE=false


ENTRYPOINT [ "/usr/local/bin/entrypoint.sh" ]

CMD ["elasticsearch"]


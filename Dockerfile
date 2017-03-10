FROM searchspring/elasticsearch_2_4_4

COPY templates /templates
COPY docker/*.sh /usr/local/bin/

ENV \
# https://www.elastic.co/guide/en/elasticsearch/guide/current/heap-sizing.html
  ES_HEAP_SIZE=1g \
  CLUSTERNAME=elasticsearch \
  DATANODE=true \
  MASTERNODE=false


ENTRYPOINT [ "/usr/local/bin/entrypoint.sh" ]

CMD ["elasticsearch"]


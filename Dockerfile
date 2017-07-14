FROM searchspring/elasticsearch_1_7_6

RUN /usr/share/elasticsearch/bin/plugin install elasticsearch/elasticsearch-lang-mvel/1.7.0

RUN echo -e "vm.max_map_count = 262144" > /etc/sysctl.d/99-elasticsearch.conf

COPY templates /templates
COPY docker/*.sh /usr/local/bin/

ENV \
# https://www.elastic.co/guide/en/elasticsearch/guide/current/heap-sizing.html
  ES_HEAP_SIZE=1024m \
  CLUSTERNAME=elasticsearch \
  DATANODE=true \
  MASTERNODE=false

ENTRYPOINT [ "/usr/local/bin/entrypoint.sh" ]

CMD ["elasticsearch"]


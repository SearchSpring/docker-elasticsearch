
FROM centos:centos6

# Set Java and ES versions
ENV JAVA_VER 1.7.0
ENV ES_VER 1.3.4
# Set Consul-Template version
ENV CT_VER 0.7.0

# Set consul key values
ENV CLUSTERNAME elasticsearch-cluster
ENV DATA /data
ENV PORT 9200
ENV EXPECTED_NODES 1

# Update and Install Dependencies
RUN \
		yum update -y && \
		yum install -y \
			java-${JAVA_VER}-openjdk-devel.x86_64 \
			tar \
			bind-utils 

# Set Java Home
ENV JAVA_HOME /usr/lib/jvm/jre-${JAVA_VER}-openjdk.x86_64

# Install Elasticsearch
RUN \
		cd /tmp && \
		curl "https://download.elasticsearch.org/elasticsearch/elasticsearch/elasticsearch-${ES_VER}.tar.gz" > elasticsearch-${ES_VER}.tar.gz && \
		tar xvzf elasticsearch-${ES_VER}.tar.gz && \
		rm -f elasticsearch-${ES_VER}.tar.gz && \
		mv /tmp/elasticsearch-${ES_VER} /usr/local/elasticsearch-${ES_VER}

# Install head and bigdesk
RUN \
		cd /usr/local/elasticsearch-${ES_VER} && \
		bin/plugin --install mobz/elasticsearch-head && \
		bin/plugin --install lukas-vlcek/bigdesk

# Create directory for logs
RUN \
	mkdir -p /var/log/elasticsearch && \
	touch /var/log/elasticsearch/${SERVICE_9200_CLUSTERNAME}.log

# Links for Elasticsearch
RUN ln -sf /usr/local/elasticsearch-${ES_VER} /usr/local/elasticsearch

# Mount elasticsearch.yml config
ADD config/elasticsearch.yml /usr/local/elasticsearch-${ES_VER}/config/elasticsearch.yml
ADD config/elasticsearch.yml.ctmpl /templates/elasticsearch.yml.ctmpl

# Install Consul-Template
ENV CT_NAME consul-template_${CT_VER}_linux_amd64
ADD https://github.com/hashicorp/consul-template/releases/download/v${CT_VER}/${CT_NAME}.tar.gz /tmp/${CT_NAME}.tgz
RUN \
	cd /tmp/ &&\
	tar -zvxf /tmp/${CT_NAME}.tgz && \
	rm /tmp/${CT_NAME}.tgz && \
	mv /tmp/${CT_NAME}/consul-template /bin/consul-template && \
	rm -rf /tmp/${CT_NAME}
ENV CONSUL_HOST consul


# mount startup script
ADD start /bin/start

# Define default entrypoint
ENTRYPOINT ["/bin/start"]


# Install dockerize
ADD https://github.com/jwilder/dockerize/releases/download/v0.0.2/dockerize-linux-amd64-v0.0.2.tar.gz /tmp/
RUN \
	tar -C /usr/local/bin -xzf /tmp/dockerize-linux-amd64-v0.0.2.tar.gz && \
	rm /tmp/dockerize-linux-amd64-v0.0.2.tar.gz


# Define default command.
CMD ["dockerize","-stdout=/var/log/elasticsearch/${CLUSTERNAME}.log", "/usr/local/elasticsearch/bin/elasticsearch"]

# Expose ports.
#   - 9200: HTTP
#   - 9300: transport
EXPOSE $PORT
EXPOSE 9300

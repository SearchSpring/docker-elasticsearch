FROM centos:centos6

# Update and Install Dependencies
RUN \
	yum update -y && \
	yum install -y \
	java-1.7.0-openjdk-devel.x86_64 \
	tar

# Set Java Home
ENV JAVA_HOME /usr/lib/jvm/jre-1.7.0-openjdk.x86_64

# Install Elasticsearch 1.1.1
RUN \
	cd /tmp && \
	curl 'https://download.elasticsearch.org/elasticsearch/elasticsearch/elasticsearch-1.1.1.tar.gz' > elasticsearch-1.1.1.tar.gz && \
	tar xvzf elasticsearch-1.1.1.tar.gz && \
	rm -f elasticsearch-1.1.1.tar.gz && \
	mv /tmp/elasticsearch-1.1.1 /usr/local/elasticsearch

# Install head and bigdesk
RUN \
	cd /usr/local/elasticsearch-1.1.1 && \
	bin/plugin --install mobz/elasticsearch-head && \
	bin/plugin --install lukas-vlcek/bigdesk

# Define mountable directories.
VOLUME ["/data"]

# Mount elasticsearch.yml config
ADD config/elasticsearch.yml /usr/local/elasticsearch/config/elasticsearch.yml

# Define working directory.
WORKDIR /data

# Define default command.
ENTRYPOINT ["/usr/local/elasticsearch/bin/elasticsearch"]

# Expose http port
EXPOSE 9200

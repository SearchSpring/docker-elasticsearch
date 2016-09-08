FROM centos:centos6

# Update and Install Dependencies
ENV \
	JAVAVER="1.8.0" \
	ESVER="2.3.5"

RUN \
	yum update -y && \
	yum install -y \
	java-${JAVAVER}-openjdk-devel.x86_64 \
	tar

# Set Java Home
ENV JAVA_HOME /usr/lib/jvm/jre-${JAVAVER}-openjdk.x86_64

# Install Elasticsearch
RUN rpm -ihv https://download.elastic.co/elasticsearch/release/org/elasticsearch/distribution/rpm/elasticsearch/${ESVER}/elasticsearch-${ESVER}.rpm

# Install head
RUN /usr/share/elasticsearch/bin/plugin install mobz/elasticsearch-head

VOLUME /var/lib/elasticsearch

# Make directory for scripts
RUN	mkdir -p /usr/share/elasticsearch/config/scripts

# Mount elasticsearch.yml config
ADD config/elasticsearch.yml /usr/share/elasticsearch/config/elasticsearch.yml

USER elasticsearch

# Define default command.
ENTRYPOINT [ "/usr/share/elasticsearch/bin/elasticsearch" ]

# Expose http port
EXPOSE 9200

FROM gcr.io/google-samples/cassandra:v12
MAINTAINER xtophs
LABEL Name=azcassandra Version=0.0.2
RUN apt update && apt install curl -y
COPY startcassandra.sh /usr/local/bin/startcassandra.sh
CMD [ "/sbin/dumb-init", "/bin/bash",  "/usr/local/bin/startcassandra.sh"]

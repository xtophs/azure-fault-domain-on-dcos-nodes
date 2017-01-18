FROM cassandra:latest
MAINTAINER xtophs
LABEL Name=azcanssandra Version=0.0.1
RUN apt update && apt install curl -y
COPY startcassandra.sh /usr/local/bin/startcassandra.sh
ENTRYPOINT /bin/bash '/usr/local/bin/startcassandra.sh'
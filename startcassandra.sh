#!/bin/bash
set -e

echo checking metadata
meta=$( curl http://169.254.169.254/metadata/v1/InstanceInfo )
echo got $meta

fd=$( echo $meta | cut -d\" -f 12)

if [ -z $fd ]
then
  echo No FD
  exit 1
fi

echo Deleteing properties file
rm -f /etc/cassandra/cassandra-rackdc.properties

echo dc=dc1 > /etc/cassandra/cassandra-rackdc.properties
echo rack=rack$fd >> /etc/cassandra/cassandra-rackdc.properties
if [ ! -z $CASSANDRA_RACK ]
then
     CASSANDRA_RACK=rack$fd
     export CASSANDRA_RACK
     echo set env $CASSANDRA_RACK
fi
. /docker-entrypoint.sh cassandra -f
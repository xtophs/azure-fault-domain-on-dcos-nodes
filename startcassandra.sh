#!/bin/bash
set -e

echo checking metadata
fd=$( "http://169.254.169.254/metadata/instance/compute/platformFaultDomain?api-version=2017-04-02&format=text" )
echo got fault domain $fd

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
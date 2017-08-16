#!/bin/bash
set -e

echo checking metadata
fd=$( curl -H Metadata:true "http://169.254.169.254/metadata/instance/compute/platformFaultDomain?api-version=2017-04-02&format=text" )
echo got fault domain $fd
location=$(curl -H Metadata:true "http://169.254.169.254/metadata/instance/compute/location?api-version=2017-07-01&format=text")
echo got location $location
if [ -z $fd ]
then
  echo No Azure Fault Domain
  exit 1
fi

echo Deleteing properties file
rm -f /etc/cassandra/cassandra-rackdc.properties

echo dc=dc-$location > /etc/cassandra/cassandra-rackdc.properties
echo rack=rack-$fd >> /etc/cassandra/cassandra-rackdc.properties
export CASSANDRA_RACK=rack-$fd
echo set env CASSANDRA_RACK=$CASSANDRA_RACK
export CASSANDRA_DC=dc-$location
echo set env CASSANDRA_DC=dc-$location

. /run.sh
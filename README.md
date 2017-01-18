# Azure Fault Domains on DCOS Nodes

We recently ported a Cassandra cluster to a DCOS cluster running in Azure.
Cassandra requieres knowledge about the rack a node is running in to place replicas ??? properly (link). 

In Azure, we have the metadata endpoint which will provide information about the fault domain (FD) a VM is running in - which corresponds to the rack information that Cassandra needs. I've seen a couple of different approaches how to make this work in DCOS clusters.

1. Some customers have containers with HA config baked in already and want to target specific agents for deployment
2. Other customers want containers to configure themselves at start up.  

We can support both approaches in the Azure Container Service when we provision the DCOS using [acs-engine](http://github.com/Azure/acs-engine). Acs-engine gives us a couple of options to run scripts on each node to customize an agent. 

One would be adding ```runcmd```s to the cloud config YAML template, e.g. ```parts/dcoscustomdata184.sh ``` to customize the VM at provisioning time. However, since the we needed to more than just one or two lines of script, we used the provision script hook in ans-engine.

For the first approach, configuring placement constraints, we can add a few lines of script to add the FD number as a Mesos attribute to the node.

Attributes are stored in ```/var/lib/dcos/mesos-slave-common```.

```
meta=$( curl http://169.254.169.254/metadata/v1/InstanceInfo )

ud=$( echo $meta | cut -d\" -f 8)
fd=$( echo $meta | cut -d\" -f 12)

mkdir -p  /var/lib/dcos
echo "MESOS_ATTRIBUTES=rack:rack$fd" >> /var/lib/dcos/mesos-slave-common
```

Now a deployment can target a VM in a fault domain with [marathon contraints](https://mesosphere.github.io/marathon/docs/constraints.html) like:

Alternatively, a Cassandra container starting up could query the metadata endpoint directly upon startup and write the rack property to ```$CASS_HOME/conf/cassandra-rackdc.properties```.
The call to the metadata endpoint can easily be added to the container

```
echo dc=dc1, rack=rack$fd >> /etc/cassandra/cassandra-rackdc.properties 
```

The ```Dockerfile``` in this repo creates a container from ```cassandra:latest```, which will create ```cassandra-rackdc.properties``` and set CASSANDRA_RACK from the Azure Fault Domain.
You can run the container in the same way you'd run a cassandra container:
``` docker run -d azcassandra:latest```. For more information see the [cassandra container documentation](https://hub.docker.com/_/cassandra/).

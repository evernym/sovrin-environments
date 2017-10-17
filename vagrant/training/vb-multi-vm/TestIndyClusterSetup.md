# Setting Up a Test Indy Network in VMs

This document will guide you in configuring a private network of Indy
Validator nodes for testing and learning about Indy.  Additional servers
acting as Indy Agents can also be provisioned on an ad-hoc basis, using this
framework.  Using this guide, VirtualBox VMs will be used as the basis for
creating a four-Validator network appropriate for completing the [*Getting
Started Guide*](https://github.com/hyperledger/indy-node/blob/master/getting-started.md)
and for other purposes.

### Assumptions

These instructions assume that you have an Internet connection, and are using a
computer with ample memory, CPU cores, and storage available.  A MacBook Pro
was used while writing this, but it should be easily adapted to other capable
computers.

### Installing VirtualBox

VirtualBox is a (FREE!) hypervisor technology similar to VMware's ESX that runs
on OSX, Linux and Windows PCs.  

* [Download VirtualBox](https://www.virtualbox.org/wiki/Downloads) and install
  it using the normal procedures for your OS. 

### Install Vagrant

Vagrant is a (FREE!) scriptable orchestrator for provisioning VMs with
VirtualBox, ESX, AWS, and others.  We will be using it to run scripts provided
to you for creating VirtualBox VMs that will be our Indy Validator and Agent
nodes.  In addition to controlling VM provisioning, the Vagrant script will
remotely execute a configuration script on each node.  You will also be able to
use Vagrant commands to ssh login to the nodes, and to halt them or even to
destroy them when you are done. [Vagrant Command
Help](https://www.vagrantup.com/docs/cli/)

* [Download Vagrant](https://www.vagrantup.com/downloads.html) and install it
  using the normal procedures for your OS.
* run this command from a terminal window:
  ```sh
  $ vagrant box add bento/ubuntu-16.04
  ```
This downloads a Vagrant "box" for Ubuntu 16.04 (LTS) onto your PC.  Think of
your "box" as an VM image, similar to an AWS AMI or a VMware OVA.
 
> **Tip:** Try this if you get the error "The box 'bento/ubuntu-1604' could not be found"
>   * `git clone https://github.com/chef/bento`
>   * `cd bento/ubuntu`
>   * `packer build ubuntu-16.04-i386.json` # adjust for your environment
>   * `vagrant box add ../builds/ubuntu-16.04-i386.virtualbox.box --name bento/ubuntu1604`
 
## Download Vagrant script and bash scripts

Scripts to spin up Indy Validator and Agent nodes are available on github, in
the same location as this document.  If you have not already done so, install
git on your machine, then clone the repository to your local machine.  This is
the quickest way to get all the necessary files (plus more).  Then go into the
directory containing the scripts.
 
```sh
$ git clone https://github.com/evernym/sovrin-environments.git
$ cd sovrin-environments/vagrant/training/vb-multi-vm
```

At this point, you have all the artifacts necessary to create an Indy cluster
on VMs in your PC. Next, we will proceed to set up the cluster.
 
## Set Up Cluster of Indy Validator Nodes

The file that you see in the current directory, called "Vagrantfile", contains
the instructions that Vagrant will follow to command VirtualBox to provision
your VMs.  In addition, it instructs Vagrant to execute a bash file called
scripts/validator.sh on each of the Validator VMs to install and configure the
required Validator software.  It also has instructions for provisioning of
three Agent VMs and one for use as a CLI client, with the required bash
configuration file for that purpose.
 
The script assumes that a 10.20.30.00/24 virtual network can be created in your
PC without conflicting with your external network configuration.  The addresses
of the VMs that will be provisioned will be taken from this network's address
range.  The Vagrantfile script also assumes that a bridged network connection
can be made over the 'en0: Wi-Fi (AirPort)' network adapter, which is correct
if you are running in a Mac, and you use Wi-Fi instead of a wired ethernet
connection.  It assumes that you are in the US:Mountain timezone.  All of these
settings, and more, can be changed in the Vagrantfile using a text editor.  You
may be able to run this script as-is, or you may want to:

* Change the timezone. For a list of candidates, refer to `/usr/share/zoneinfo`
  on an Ubuntu system.
* Change the network adapter for bridging. For interactive selection, remove
  this line entirely.
* Change the IP addresses of the VMs
  * Change the Vagrantfile in each place that an IP address is designated for a
    Validator or an Agent
  * Change the list of Validator IP addresses on line 48 of
    `scripts/validator.sh` accordingly
  * Likewise, change the list of Validator IP addresses on line 42 of
    `scripts/agent.sh`
  * Change the IP addresses in the template hosts file at etc/hosts

After the configuration file has the correct settings, provision your
Validator, Agent and CLI client nodes:

```sh
$ vagrant up
```

This command will take several minutes to complete, as each VM is provisioned
and its vagrant.sh script is executed.  After provisioning, each of these nodes
automatically joins the Indy Validator cluster.


> **Tip:** It may be instructive to examine the scripts/vagrant.sh file to see
> the steps taken to install, configure, and run the Validator nodes.


If at any time you need to log in to a Validator node to check logs or do other
administrative tasks, you can ssh into it easily.  For example, to access the
first Validator node, which has the name `validator01`, go into the directory
with your Vagrantfile script and enter the following on the command line. 

```sh
$ vagrant ssh validator01
```

Login is seamless since Vagrant automatically generates and configures an ssh
key pair for access.

## Setting Up a CLI Client and Configuring the Agents in the Indy Cluster

You will need to have a term session to ssh into one of these nodes, which will
be used as an interactive CLI client.  With this you will be able to interact
with the Indy Validator cluster and with the Agents.  If you are doing the
Getting Started Guide, two roles will be performed using the CLI client.
First, you will use it in the role of an Indy Steward, a privileged user who
will be used to register and configure the Agents on the Indy Validator
cluster that we have set up.  Later, you will use the CLI client in the role of
Alice, a user who has various interactions with the Agents that are facilitated
by Indy.

In a term window, you will now ssh into `cli01`, bring up the CLI, and
configure the CLI to communicate with the "test" Indy Validator cluster that
we have configured here. 

```sh
$ vagrant ssh cli01
vagrant@cli01:~$ indy
indy> connect test
```

The next task is to register the Agents that we will be using with Indy.  We
must do this before starting the Agent processes in the other nodes, since
these processes expect to be registered in Indy before starting. In order to
do the registration, we must be able to authenticate to Indy as a Steward.
In our test cluster, there is a pre-configured user called `Steward1` with a
known key that we are able to use.  In the CLI, type:

```
indy@test> new key with seed 000000000000000000000000Steward1
```

Now that the CLI client can authenticate as the `Steward1` user, we can put
transactions into the Indy Validator cluster that will register each agent
and establish its endpoint attribute.  To register the agents used in the
Getting Started Guide, first, as the Steward, add each of the three agent's
Trust Anchor to the ledger.:

```
indy@test> send NYM dest=ULtgFQJe6bjiFbs7ke3NJD role=TRUST_ANCHOR verkey=~5kh3FB4H3NKq7tUDqeqHc1
indy@test> send NYM dest=CzkavE58zgX7rUMrzSinLr role=TRUST_ANCHOR verkey=~WjXEvZ9xj4Tz9sLtzf7HVP
indy@test> send NYM dest=H2aKRiDeq8aLZSydQMDbtf role=TRUST_ANCHOR verkey=~3sphzTb2itL2mwSeJ1Ji28
```

In the first of the above commands, `~5kh3FB4H3NKq7tUDqeqHc1` is the
verification key of the "Faber College" Trust Anchor.  A corresponding private
key is retained by the agent process. `ULtgFQJe6bjiFbs7ke3NJD` is the "Faber
College" Trust Anchor ID.  The other two lines put the Trust Anchors for "Acme
Corp" and "Thrift Bank" onto the ledger as well.

Next, we provide information on the nodes that these Trust Anchors will use to
interact with clients.  If necessary, replace the IP addresses and ports in
these commands with what you are using.  Since only the Trust Anchor can modify
his information on the ledger, we must assume the proper identity before
posting each transaction.

```
indy@test> new key with seed Faber000000000000000000000000000
indy@test> send ATTRIB dest=ULtgFQJe6bjiFbs7ke3NJD raw={"endpoint": {"ha": "10.20.30.101:5555", "pubkey": "5hmMA64DDQz5NzGJNVtRzNwpkZxktNQds21q3Wxxa62z"}}
indy@test> new key with seed Acme0000000000000000000000000000
indy@test> send ATTRIB dest=CzkavE58zgX7rUMrzSinLr raw={"endpoint": {"ha": "10.20.30.102:6666", "pubkey": "C5eqjU7NMVMGGfGfx2ubvX5H9X346bQt5qeziVAo3naQ"}}
indy@test> new key with seed Thrift00000000000000000000000000
indy@test> send ATTRIB dest=H2aKRiDeq8aLZSydQMDbtf raw={"endpoint": {"ha": "10.20.30.103:7777", "pubkey": "AGBjYvyM3SFnoiDGAEzkSLHvqyzVkXeMZfKDvdpEsC2x"}}
```

### Starting the Agent Processes

Now that the Agents are registered with the Indy cluster, the Agent processes
can be started on their respective nodes.  You will need to `vagrant ssh` into
each one of them and start the agent process manually.  If you are setting up
to run through the getting started guide, bring up a terminal, go into the
directory with your `Vagrantfile` script, and execute the following to start up
the "Faber College" agent process.

````sh
$ vagrant ssh agent01
vagrant@agent01:~$ python3 /usr/local/lib/python3.5/dist-packages/indy_client/test/agent/faber.py  --port 5555
```

You will see logging output to the screen.  In another term window (or tab),
ssh into agent02 and bring up the "Acme Corp" agent process:

````sh
$ vagrant ssh agent02
vagrant@agent02:~$ python3 /usr/local/lib/python3.5/dist-packages/indy_client/test/agent/acme.py  --port 6666
```

In another term window (or tab), ssh into agent03 and bring up the "Thrift
Bank" agent process:

```sh
$ vagrant ssh agent03
vagrant@agent03:~$ python3 /usr/local/lib/python3.5/dist-packages/indy_client/test/agent/thrift.py  --port 7777
````

Congratulations!  Your Indy four-Validator cluster, along with Agent nodes as
desired, is complete.  Now, in the CLI client on `cli01`, type quit to exit the
CLI.  If you are doing the Getting Started Guide you are ready to proceed,
using `cli01` for the interactive 'Alice' client.  In `cli01`, type indy
once again to bring up the CLI prompt, and continue with the guide.

```
vagrant@cli01:~$ indy
Loading module /usr/local/lib/python3.5/dist-packages/config/config-crypto-example1.py
Module loaded.

Indy-CLI (c) 2017 Evernym, Inc.
Node registry loaded.
    Node1: 10.20.30.201:9701
    Node2: 10.20.30.202:9703
    Node3: 10.20.30.203:9705
    Node4: 10.20.30.204:9707
Type 'help' for more information.
Running Indy 0.3.15

indy>
```

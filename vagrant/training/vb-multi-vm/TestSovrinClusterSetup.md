# Setting Up a Test Sovrin Network
This document will guide you in configuring a private network of Sovrin Validator nodes for testing and learning about Sovrin.  Additional servers acting as Sovrin Agents can also be provisioned on an ad-hoc basis, using this framework.  Using this guide, VrtualBox VMs will be used as the basis for creating a four-Validator network appropriate for completing the [*Getting Started Guide*](https://github.com/sovrin-foundation/sovrin-client/blob/master/getting-started.md) and for other purposes.  Future editions of this guide will include the ability to provision the Validator and Agent nodes in AWS and other environments.

### Assumptions
These instructions assume that you have an Internet connection, and are using a computer with ample memory, CPU cores, and storage available.  A MacBook Pro was used while writing this, but it should be easily adapted to other capable computers.

### Installing VirtualBox
VirtualBox is a (FREE!) hypervisor technology similar to VMware's ESX that runs on OSX, Linux and Windows PCs.  
   - [Download VirtualBox](https://www.virtualbox.org/wiki/Downloads) and install it using the normal procedures for your OS. 

### Install Vagrant
Vagrant is a (FREE!) scriptable orchestrator for provisioning VMs with VirtualBox, ESX, AWS, and others.  We will be using it to run scripts provided to you for creating VirtualBox VMs that will be our Sovrin Validator and Agent nodes.  In addition to controlling VM provisioning, the Vagrant script will remotely execute a configuration script on each node.  You will also be able to use Vagrant commands to ssh login to the nodes, and to halt them or even to destroy them when you are done.
   - [Download Vagrant](https://www.vagrantup.com/downloads.html) and install it using the normal procedures for your OS.
   - run this command from a terminal window:
     ```sh
     $ vagrant box add boxcutter/ubuntu1604
     ```
 This downloads a Vagrant "box" for Ubuntu 16.04 (LTS) onto your PC.  Think of your "box" as an VM image, similar to an AWS AMI or a VMware OVA.
 
 ## Download Vagrant script and bash scripts
 Scripts to spin up Sovrin Validator and Agent nodes are available on github, in the same location as this document.  If you have not already done so, install git on your machine, then clone the repository to your local machine.  This is the quickest way to get all the necessary files (plus more).  Then go into the directory containing the scripts.
 
 **TODO:**  Update the repository location.
 ```sh
 $ git clone https://github.com/mgbailey/sovrin-environments.git
 $ cd sovrin-environments/vagrant/training/vb-multi-vm
 ```
 At this point, you have all the artifacts necessary to create a Sovrin cluster on VMs in your PC. Next, we will proceed to set up the cluster.
 
 ## Set Up Cluster of Sovrin Validator Nodes
 The file that you see in the current directory, called "Vagrantfile", contains the instructions that Vagrant will follow to command VirtualBox to provision your VMs.  In addition, it instructs Vagrant to execute a bash file called scripts/validator.sh on each of the Validator VMs to install and configure the required Validator software.  It also has instructions for ad-hoc provisioning of up to four Agent or client VMs, with the required bash configuration file for that purpose.
 
 The script assumes that a 10.20.30.00/24 virtual network can be created in your PC without conflicting with your external network configuration.  The addresses of the VMs that will be provisioned will be taken from this network's address range.  The Vagrantfile script also assumes that a bridged network connection can be made over the 'en0: Wi-Fi (AirPort)' network adapter, which is correct if you are running in a Mac, and you use Wi-Fi instead of a wired ethernet connection.  It assumes that you are in the US:Mountain timezone.  All of these settings, and more, can be changed in the Vagrantfile using a text editor.  You may be able to run this script as-is, or you may want to:
   - Change the timezone  (for a list of candidates, refer to /usr/share/zoneinfo on an Ubuntu system)
   - Change the network adapter for bridging.  (For interactive selection, remove this line entirely)
   - Change the IP addresses of the VMs
   -- Change the Vagrantfile in each place that an IP address is designated for a Validator or an Agent
   -- Change the list of Validator IP addresses on line 48 of scripts/validator.sh accordingly
   -- Likewise, change the list of Validator IP addresses on line 42 of scripts/agent.sh
   -- Change the IP addresses in the template hosts file at etc/hosts

**TODO:** configure scripts so that IP address changes can all happen in 1 spot, in the Vagrantfile

After the configuration file has the correct settings, provision your Validator nodes:
```sh
$ vagrant up
```
This command will take several minutes to complete, as each VM is provisioned and its vagrant.sh script is executed.  After provisioning, each of these nodes automatically joins the Sovrin Validator cluster.  
____
**Tip:** It may be instructive to examine the scripts/vagrant.sh file to see the steps taken to install, configure, and run the Validator nodes.
____

If at any time you need to log in to a Validator node to check logs or do other administrative tasks, you can ssh into it easily.  For example, to access the first Validator node, which has the name 'validator01', go into the directory with your Vagrantfile script and enter the following on the command line. 
```sh
$ vagrant ssh validator01
```
Login is seamless since Vagrant automatically generates and configures an ssh key pair for access.

## Provision Agent and Client Nodes
The Vagrantfile has configuration settings for provisioning up to four Agent (or client) nodes.  These can be used to play the role of remote entities like "Faber College", in the Getting Started Guide.  They can also be used for CLI interactive client sessions, such as the "Alice" user in the same guide.  If your Sovrin network is to be used with the Getting Started Guide, you will want to provision four Agent nodes, one each for "Faber College", "Acme Corp", and "Thrift Bank", as well as one that can be used as an interactive client.

Since Agent nodes are not configured to provision automatically with a simple "vagrant up" command, you must instruct Vagrant to provision each one specifically, adding the name of the desired node after the "vagrant up" command.  To spin up all four, add all four names to the command line:
```sh
$ vagrant up agent01 agent02 agent03 agent04
```
## Setting Up a CLI Client and Configuring the Agents in the Sovrin Cluster
You will need to have a term session to ssh into one of these nodes, which will be used as an interactive CLI client.  With this you will be able to interact with the Sovrin Validator cluster and with the Agents.  If you are doing the Getting Started Guide, two roles will be performed using the CLI client.  First, you will use it in the role of a Sovrin Steward, a privileged user who will be used to register and configure the Agents on the Sovrin Validator cluster that we have set up.  Later, you will use the CLI client in the role of Alice, a user who has various interactions with the Agents that are facilitated by Sovrin.

In a term window, you will now ssh into agent04, bring up the CLI, and configure the CLI to communicate with the "test" Sovrin Validator cluster that we have configured here. Note that even though we are using a node named agent04, we will actually be using it as a CLI client instead.
````
$ vagrant ssh agent04
vagrant@agent04:~$ sovrin
sovrin> connect test
````
The next task is to register the Agents that we will be using with Sovrin.  We must do this before starting the Agent processes in the other nodes, since these processes expect to be registered in Sovrin before starting. In order to do the registration, we must be able to authenticate to Sovrin as a Steward.  In our test cluster, there is a pre-configured user called Steward1 with a known key that we are able to use.  In the CLI, type:
```
sovrin@test> new key with seed 000000000000000000000000Steward1
```
Now that the CLI client can authenticate as the Steward1 user, we can put transactions into the Sovrin Validator cluster that will register each Agent and establish its endpoint attribute.  To register the Agents used in the Getting Started Guide, first, do the following for "Faber College":
```
sovrin@test> send NYM dest=FuN98eH2eZybECWkofW6A9BKJxxnTatBCopfUiNxo6ZB role=TRUST_ANCHOR
sovrin@test> send ATTRIB dest=FuN98eH2eZybECWkofW6A9BKJxxnTatBCopfUiNxo6ZB raw={"endpoint": {"ha": "10.20.30.101:5555", "pubkey": "5hmMA64DDQz5NzGJNVtRzNwpkZxktNQds21q3Wxxa62z"}}
```
In the above commands, 'FuN98eH2eZybECWkofW6A9BKJxxnTatBCopfUiNxo6ZB' is the validator key of the Agent.  A corresponding private key is retained by the agent process.  

The "Acme Corp" and the "Thrift Bank" Agents are registered and configured in like manner:
```
sovrin@test> send NYM dest=7YD5NKn3P4wVJLesAmA1rr7sLPqW9mR1nhFdKD518k21 role=TRUST_ANCHOR
sovrin@test> send ATTRIB dest=7YD5NKn3P4wVJLesAmA1rr7sLPqW9mR1nhFdKD518k21 raw={"endpoint": {"ha": "10.20.30.102:5555", "pubkey": "C5eqjU7NMVMGGfGfx2ubvX5H9X346bQt5qeziVAo3naQ"}}
sovrin@test> 
sovrin@test> send NYM dest=9jegUr9vAMqoqQQUEAiCBYNQDnUbTktQY9nNspxfasZW role=TRUST_ANCHOR
sovrin@test> send ATTRIB dest=9jegUr9vAMqoqQQUEAiCBYNQDnUbTktQY9nNspxfasZW raw={"endpoint": {"ha": "10.20.30.103:5555", "pubkey": "AGBjYvyM3SFnoiDGAEzkSLHvqyzVkXeMZfKDvdpEsC2x"}}
```
### Starting the Agent Processes
Now that the Agents are registered with the Sovrin cluster, the Agent processes can be started on their respective nodes.  You will need to "vagrant ssh" into each one of them and start the agent process manually.  If you are setting up to run through the getting started guide, bring up a terminal, go into the directory with your Vagrantfile script, and execute the following to start up the "Faber College" agent process.
````sh
$ vagrant ssh agent01
vagrant@agent01:~$ python3 /usr/local/lib/python3.5/dist-packages/sovrin_client/test/agent/faber.py  --port 5555
````
You will see logging output to the screen.  In another term window (or tab), ssh into agent02 and bring up the "Acme Corp" agent process:
````sh
$ vagrant ssh agent02
vagrant@agent02:~$ python3 /usr/local/lib/python3.5/dist-packages/sovrin_client/test/agent/acme.py  --port 5555
````
In another term window (or tab), ssh into agent03 and bring up the "Thrift Bank" agent process:
````sh
$ vagrant ssh agent03
vagrant@agent03:~$ python3 /usr/local/lib/python3.5/dist-packages/sovrin_client/test/agent/thrift.py  --port 5555
````

Congratulations!  Your Sovrin four-Validator cluster, along with Agent nodes as desired, is complete.  Now, in the CLI client on agent04, type quit to exit the CLI.  If you are doing the Getting Started Guide you are ready to proceed, using agent04 for the interactive 'Alice' client.
    

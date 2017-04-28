# Setting Up a Test Sovrin Network
This guide will guide you in configuring a private network of Sovrin Validator nodes for testing and learning about Sovrin.  Additional servers acting as Sovrin agents can also be provisioned on an ad-hoc basis, using this framework.  Using this guide, virtualbox VMs will be used as the basis for createing a 4-validator network.  Future editions of this guide will include the ability to provision the validator and agent nodes in AWS and other environments.

### Assumptions
These instructions assume that you have an internet connection, and are using a computer with ample memory, CPU cores, and storage available.  A MacBook Pro was used while writing this, but it should be easily adapted to other capable computers.

### Installing VirtualBox
VirtualBox is a (FREE!) hypervisor technology similar to VMware's ESX that runs on OSX, Linux and Windows PCs.  
   - [Download VirtualBox](https://www.virtualbox.org/wiki/Downloads) and install it using the normal procedures for your OS. 

### Install Vagrant
Vagrant is a (FREE!) scriptable orchestrator for provisioning VMs with VirtualBox, ESX, AWS, and others.  We will be using it to run scripts that are provided to you for creating VirtualBox VMs that will be our Sovrin validator and agent nodes.  In addition to controlling VM provisioning, the Vagrant script will remotely execute a configuration script on each node.  You will also be able to use Vagrant commands to ssh login to the nodes, and to halt them or even to destroy them when you are done.
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
 $ cd sovrin-environments/vagrant/training/vb-multi-vm/
 ```
 At this point, you have all the artifacts necessary to create a Sovrin cluster on VMs in your PC. Next, we will proceed to set up the cluster.
 
 ## Set Up Cluster of Sovrin Validator Nodes
 The file that you see in the current directory, called "Vagrantfile", contains the instructions that Vagrant will follow to command VirtualBox to provision your VMs.  In addition, it instructs Vagrant to execute a bash file called scripts/validator.sh on each of the Validator VMs to install and configure the required Validator software.  It also has instructions for ad-hoc provisioning of up to four Agent VMs, with the required bash configuration file for that purpose.
 
 The script assumes that a 10.20.30/24 virtual network can be created in your PC without conflicting with your external network configuration.  The addresses of the VMs that will be provisioned will be taken from this network's address range.  It also assumes that a bridged network connection can be made over the 'en0: Wi-Fi (AirPort)' network adapter, which is correct if you are running in a Mac, and you use Wi-Fi instead of a wired ethernet connection.  It assumes that you are in the US:Mountain timezone.  All of these settings, and more, can be changed in the Vagrantfile using a text editor.  You may be able to run this script as-is, or you may want to:
   - Change the timezone  (for a list of candidates, refer to /usr/share/zoneinfo on an Ubuntu system)
   - Change the network adapter for bridging.  (To select interactive selection, remove this line entierly)
   - Change the IP addresses of the VMs.
   -- Change the Vagrantfile in each place that an IP address is designated for a Validator or an Agent file
   -- Change the list of Validator IP addresses on line 48 of scripts/validator.sh accordingly.
   -- Likewise, change the list of Validator IP addresses on line 42 of scripts/agent.sh
   -- Change the IP addresses in the template hosts file at etc/hosts

**TODO:** configure scripts so that IP address changes can all happen in 1 spot in the Vagrantfile

After the configuration file has the correct settings, provision your Validator nodes:
```sh
$ vagrant up
```
This command will take several minutes to complete, as each VM is provisioned and its vagrant.sh script is executed.  After provisioning, each of these nodes automatically joins the Sovrin Validator cluster.  
____
**Tip:** It may be instructive to examine the scripts/vagrant.sh file to see the steps taken to install, configure, and run the Validator nodes.
____

If at any time you need to log in to a validator node to check logs or do other administrative tasks, you can ssh into it easily.  For example, to access the first validator node, which has the name 'validator01', enter the following on the command line. 
```sh
$ vagrant ssh validator01
```
Login is seamless since Vagrant automatically generates and configures an ssh keypair for access.

## Set Up Agent Nodes
The Vagrantfile has configuration settings for provisioning up to four Agent nodes.  These can be used to play the role of remote entities like "Faber College", in the Getting Started Guide.  They can also be used for CLI interactive sessions, such as the "Alice" user in the same guide.  If your Sovrin network is to be used with the Getting Started Guide, you will want to provision four Agent nodes, one each for "Faber College", "Acme Corp", and "Thrift Bank", as well as one that we can use interactively.

Since Agent nodes are not configured to provision automatically with as simple "vagrant up" command, you must instruct Vagrant to provision each one specifically, adding the name of the desired node after the "vagrant up" command.  To spin up all four, add all four names to the command line:
```sh
$ vagrant up agent01 agent02 agent03 agent04
```
Unlike the Sovrin Validator nodes, Agent nodes do not start the agent process automatically upon provisioning.  You will need to "vagrant ssh" into each one of them and start the agent process manually.
````sh
$ vagrant ssh agent01
agent01 $ 
````

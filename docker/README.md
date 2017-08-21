# Prerequisites
* Docker
* Current used added to 'docker' group

# Start pool
```
./pool_start.sh [number of nodes in pool] [IP addresses of nodes] [number of clients] [port for the first node]
```
Defaults:
* Number of nodes is 4
* IP addresses are generated consequently starting from 10.0.0.2
** Format: 10.0.0.2,10.0.0.3,10.0.0.4,10.0.0.5
* Number of clients is 10
* Ports are generated consequently starting from 9701

# Start client
```
./client_for_pool_start.sh [file with pool data] [client's IP address] [number of clients]
```
Defaults:
* File is pool_data
* IP address is the next in sequence of IP addresses read from pool data (e.g. 10.0.0.6)
* Number of clients is 10

Container is removed automatically after sovrin shell is closed.

# Start agents (optional - if you are running the Sovrin Tutorial)

See the file StartingAgents.md in this folder.

# Stop pool
```
./pool_stop.sh [file with pool data] [pool newtwork name]
```
Defaults:
* File is pool_data
* Network name is pool-network

# Running on Windows and using the git bash shell

Using the git bash shell is usually the preferred command line for those familiar with Unix/Linux to run applications/environments like Sovrin, however, it can create problems with pathnames. By default git bash converts absolute path names to the Windows path name (e.g. C:\...), which is helpful if it is expected by an app, but not always.  In particular, [it's not helpful with Docker](https://github.com/moby/moby/issues/24029) creating problems with volume mounting on docker run and build commands. For this application - the client_build.sh, node_build.sh, client_start.sh and node_start.sh are all affected by this. When just run, docker build/run commands error off with messages like:

```
C:\Program Files\Docker\Docker\Resources\bin\docker.exe: Error response from daemon: invalid bind mount spec "/C/Program Files/Git/sys/fs/cgroup;C:\\Program Files\\Git\\sys\\fs\\cgroup;ro": invalid volume specification: '/C/Program Files/Git/sys/fs/cgroup;C:\Program Files\Git\sys\fs\cgroup;ro': invalid mount config for type "bind": invalid mount path: '\Program Files\Git\sys\fs\cgroup;ro' mount path must be absolute.
```

The easiest way to deal with this is to preface the pool and client commands with *MSYS_NO_PATHCONV=1*, for example:

```
MSYS_NO_PATHCONV=1 ./pool_start.sh
```

Alternatively, you can edit the scripts and on the docker run and build scripts, change leading slashes (/) in pathnames to double slashes (//).

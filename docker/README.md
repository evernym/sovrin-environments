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
* Number of clients is 10
* Ports are generated consequently starting from 9701

# Start client
```
./client_for_pool_start.sh [file with pool data] [client's IP address] [number of clients]
```
Defaults:
* File is pool_data
* IP address is the next in sequence of IP addresses read from pool data
* Number of clients is 10

Container is removed automatically after sovrin shell is closed.    

# Stop pool
```
./pool_stop.sh [file with pool data] [pool newtwork name]
```
Defaults:
* File is pool_data
* Network name is pool-network

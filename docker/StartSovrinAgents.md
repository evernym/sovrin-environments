Starting the Sovrin Agent Scripts on a Docker Sovrin Test Deployment
------

Once you have the Sovrin test nodes and client running, and before you run through the Sovrin tutorial script, you need to start the Sovrin Agents that represent the organizations in the scenario - Faber College, Acme Corp. and Thrift Bank. The steps to run to start the agents are outlined below.

## Open terminal and exec into the client docker container:
When you start up the Sovrin client for testing, you will be in a shell running the Sovrin CLI. Leave that command line as is (we'll return to it after these steps) and start up a new shell to carry out the series of steps here.

Within that command line, log into the Sovrin Client docker container:


```docker exec -i -t sovrinclient bash```

### Start up Sovrin and carry out the next series of commands with Sovrin.

To start sovrin:

```sovrin```

Connect to the test network - the nodes that you are running on docker:

```connect test```

#### Create Steward

Create an initial Sovrin Steward for the test network. The Steward will be used to add the three organizations as Trust Anchors in the network. The commands in this script need to be typed in exactly as specified here.

```new key with seed 000000000000000000000000Steward1```

#### Register Faber DID and endpoint

```send NYM dest=ULtgFQJe6bjiFbs7ke3NJD role=TRUST_ANCHOR verkey=~5kh3FB4H3NKq7tUDqeqHc1```

```new key with seed Faber000000000000000000000000000```

In this last step, we're using the IP address of the Sovrin client (10.0.0.6), and a unique port for the agent. If you used a different IP in starting up Sovrin, you need to replace your IP/Port in the following command:

```send ATTRIB dest=ULtgFQJe6bjiFbs7ke3NJD raw={"endpoint": {"ha": "10.0.0.6:5555", "pubkey": "5hmMA64DDQz5NzGJNVtRzNwpkZxktNQds21q3Wxxa62z"}}
```

#### Register ACME DID and endpoint
That's it for Faber...on to Acme.  Before starting, we have to go back to using the Steward identity.

# use Steward1 ID
```use DID Th7MpTaRZVRYnPiabds81Y```

Once that's done, repeat the steps for Acme (with different parameters).

```send NYM dest=CzkavE58zgX7rUMrzSinLr role=TRUST_ANCHOR verkey=~WjXEvZ9xj4Tz9sLtzf7HVP```

```new key with seed Acme0000000000000000000000000000```

As with Faber, we're using the IP address of the Sovrin client (10.0.0.6), and a unique port for the agent. If you used different IPs in starting up Sovrin, you need to replace your IP/Port in the following command:

```send ATTRIB dest=CzkavE58zgX7rUMrzSinLr raw={"endpoint":{"ha": "10.0.0.6:6666", "pubkey": "C5eqjU7NMVMGGfGfx2ubvX5H9X346bQt5qeziVAo3naQ"}}```

#### Register Thrift Bank DID and endpoint
And on to Thrift.  Before starting, we have to go back to using the Steward identity.

# use Steward1 ID
```use DID Th7MpTaRZVRYnPiabds81Y```

Once that's done, repeat the steps, using different IDs.

```send NYM dest=H2aKRiDeq8aLZSydQMDbtf role=TRUST_ANCHOR verkey=~3sphzTb2itL2mwSeJ1Ji28```

```new key with seed Thrift00000000000000000000000000```

```send ATTRIB dest=H2aKRiDeq8aLZSydQMDbtf raw={"endpoint": {"ha": "10.0.0.6:7777", "pubkey":"AGBjYvyM3SFnoiDGAEzkSLHvqyzVkXeMZfKDvdpEsC2x"}}```

#### Sovrin steps complete - Exit
Exit from Sovrin, but stay in the bash shell in the docker container. To do that, just run at the 'sovrin' prompt:

```exit```

You should be back to the bash prompt within the Sovrinclient container.

## Start the Sovrin Agents

We'll now invoke the Sovrin Agents from the command line, redirecting the output to different files. We can then review the logs as commands are executed.

#### Invoke the clients
Use these commands to invoke each of the clients:

```python3 /usr/local/lib/python3.5/dist-packages/sovrin_client/test/agent/faber.py --port 5555 >faber.log &```

```python3 /usr/local/lib/python3.5/dist-packages/sovrin_client/test/agent/acme.py --port 6666 >acme.log &```

```python3 /usr/local/lib/python3.5/dist-packages/sovrin_client/test/agent/thrift.py --port 7777 >thrift.log &```

For those not familiar with Linux - the trailing "&" runs the command in the background.

If you want to monitor one of the logs while executing the rest of the tutorial, you can use the command:

```tail -f faber.log```

To stream the end of the log. Ctrl-C to execute out of that.

Note that when the sovrinclient container stops, the agents will stop automatically.

Leave this command line running while you complete the rest of the tutorial - the story of Emily, her transcripts, job and banking.

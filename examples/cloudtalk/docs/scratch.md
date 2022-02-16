# Scratch

Scratch pad for commands and investigations.

## New debugging info

### Test from terminal in some ironrsl container

```shell
/workspace# dotnet /workspace/Ironclad/ironfleet/bin/IronRSLKVClient.dll certs/certs.IronRSLKV.service.txt nthreads=10 duration=30 setfraction=0.25 deletefraction=0.05 print=true verbose=true
Client process starting 10 threads running for 30 s...
[[READY]]
Starting I/O scheduler as client with certificate CN=client (key pYvA232m)
Starting I/O scheduler as client with certificate CN=client (key 2AUl+qgE)
Waiting for the next send to dispatch
Creating sender thread to send to remote public key certs.IronRSLKV.server1 (key vz92KEuQ) @ ironrslkv001.cloudtalk001:4001
Starting I/O scheduler as client with certificate CN=client (key rxP+YFvY)
Starting I/O scheduler as client with certificate CN=client (key wc2Zt6d3)
Starting I/O scheduler as client with certificate CN=client (key 4CjD3jCA)
Starting I/O scheduler as client with certificate CN=client (key yhjH3B8O)
Waiting for the next send to dispatch
Creating sender thread to send to remote public key certs.IronRSLKV.server1 (key vz92KEuQ) @ ironrslkv001.cloudtalk001:4001
Starting I/O scheduler as client with certificate CN=client (key nstk+66E)
Starting I/O scheduler as client with certificate CN=client (key qq/CVvnN)
Creating sender thread to send to remote public key certs.IronRSLKV.server2 (key 4PtsaYAm) @ ironrslkv002.cloudtalk002:4002
Waiting for the next send to dispatch
Creating sender thread to send to remote public key certs.IronRSLKV.server1 (key vz92KEuQ) @ ironrslkv001.cloudtalk001:4001
Starting connection to certs.IronRSLKV.server1 (key vz92KEuQ) @ ironrslkv001.cloudtalk001:4001
Waiting for the next send to dispatch
Creating sender thread to send to remote public key certs.IronRSLKV.server1 (key vz92KEuQ) @ ironrslkv001.cloudtalk001:4001
Starting I/O scheduler as client with certificate CN=client (key xYSVZlEU)
Creating sender thread to send to remote public key certs.IronRSLKV.server1 (key vz92KEuQ) @ ironrslkv001.cloudtalk001:4001
Starting connection to certs.IronRSLKV.server1 (key vz92KEuQ) @ ironrslkv001.cloudtalk001:4001
Creating sender thread to send to remote public key certs.IronRSLKV.server2 (key 4PtsaYAm) @ ironrslkv002.cloudtalk002:4002
Starting I/O scheduler as client with certificate CN=client (key n9KUf8PC)
Waiting for the next send to dispatch
Creating sender thread to send to remote public key certs.IronRSLKV.server1 (key vz92KEuQ) @ ironrslkv001.cloudtalk001:4001
Waiting for the next send to dispatch
Creating sender thread to send to remote public key certs.IronRSLKV.server1 (key vz92KEuQ) @ ironrslkv001.cloudtalk001:4001
Waiting for the next send to dispatch
Starting connection to certs.IronRSLKV.server1 (key vz92KEuQ) @ ironrslkv001.cloudtalk001:4001
Creating sender thread to send to remote public key certs.IronRSLKV.server2 (key 4PtsaYAm) @ ironrslkv002.cloudtalk002:4002
Creating sender thread to send to remote public key certs.IronRSLKV.server3 (key raq5/vew) @ ironrslkv003.cloudtalk003:4003
Starting connection to certs.IronRSLKV.server2 (key 4PtsaYAm) @ ironrslkv002.cloudtalk002:4002
Creating sender thread to send to remote public key certs.IronRSLKV.server1 (key vz92KEuQ) @ ironrslkv001.cloudtalk001:4001
Waiting for the next send to dispatch
Waiting for the next send to dispatch
Creating sender thread to send to remote public key certs.IronRSLKV.server1 (key vz92KEuQ) @ ironrslkv001.cloudtalk001:4001
Creating sender thread to send to remote public key certs.IronRSLKV.server2 (key 4PtsaYAm) @ ironrslkv002.cloudtalk002:4002
Creating sender thread to send to remote public key certs.IronRSLKV.server2 (key 4PtsaYAm) @ ironrslkv002.cloudtalk002:4002
Starting connection to certs.IronRSLKV.server1 (key vz92KEuQ) @ ironrslkv001.cloudtalk001:4001
Starting connection to certs.IronRSLKV.server1 (key vz92KEuQ) @ ironrslkv001.cloudtalk001:4001
Stopped connecting to certs.IronRSLKV.server1 (key vz92KEuQ) @ ironrslkv001.cloudtalk001:4001 because the connection was refused. Will try again later if necessary.
Starting connection to certs.IronRSLKV.server2 (key 4PtsaYAm) @ ironrslkv002.cloudtalk002:4002
Stopped connecting to certs.IronRSLKV.server2 (key 4PtsaYAm) @ ironrslkv002.cloudtalk002:4002 because the connection was refused. Will try again later if necessary.
Stopped connecting to certs.IronRSLKV.server1 (key vz92KEuQ) @ ironrslkv001.cloudtalk001:4001 because the connection was refused. Will try again later if necessary.
Stopped connecting to certs.IronRSLKV.server2 (key 4PtsaYAm) @ ironrslkv002.cloudtalk002:4002 because the connection was refused. Will try again later if necessary.
```

## Previous debugging info

Issue: lack of the `verbose=true`. Requests were submitted but never answered.

### Test from terminal in some ironrsl container

```shell
root@:/workspace# dotnet /workspace/Ironclad/ironfleet/bin/IronRSLKVClient.dll certs/certs.IronRSLKV.service.txt nthreads=10 duration=30 setfraction=0.25 deletefraction=0.05 print=true
[[READY]]
Submitting get request for iii
Submitting get request for zzz
Submitting set request for kkk => KKKK96271
Submitting get request for rrr
Submitting get request for ooo
Submitting get request for jjj
Submitting get request for uuu
Submitting get request for zzz
Submitting get request for ppp
Submitting set request for qqq => QQQQ30575
[[DONE]]
```

### Copy binaries from the ironrslkv container and certs from the ironrsl-certs container to the grava container

Using namespace "001" below. Below commands for PowerShell (`pwsh`). Go to some `temp` folder.

```shell
$_ironpod001 = $(kubectl get pods --selector=app=ironrslkv001 --all-namespaces --no-headers -o custom-columns=":metadata.name")
$_gravapod001 = $(kubectl get pods --selector=app=cloudtalk001-grava --all-namespaces --no-headers -o custom-columns=":metadata.name")

kubectl cp ${_ironpod001}:/workspace/Ironclad/ironfleet/bin/ ./bin --namespace cloudtalk001
kubectl cp ironrslkv-certs:/workspace/certs ./certs --namespace default
kubectl cp ./ ${_gravapod001}:/workspace --namespace cloudtalk001
```

### Test from terminal in the grava container

```shell
cd /workspace

# First install .NET 5.0 (used by ironrslkv) - Reference: https://www.makeuseof.com/install-dotnet-5-ubuntu-linux/
apt-get -y install wget
wget https://packages.microsoft.com/config/ubuntu/20.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
dpkg -i packages-microsoft-prod.deb
apt-get update
apt-get -y install apt-transport-https
apt-get -y install dotnet-sdk-5.0

# Test with IronRSLKVClient
root@:/workspace# dotnet /workspace/bin/IronRSLKVClient.dll certs/certs.IronRSLKV.service.txt nthreads=10 duration=30 setfraction=0.25 deletefraction=0.05 print=true
[[READY]]
Submitting get request for ccc
Submitting get request for ooo
Submitting get request for ccc
Submitting get request for eee
Submitting get request for fff
Submitting set request for ccc => CCCC54164
Submitting set request for eee => EEEE46928
Submitting get request for fff
Submitting get request for kkk
Submitting get request for lll
[[DONE]]

# Test with the irontest.dll
cd /app
root@:/app# /app# dotnet irontest.dll a
Starting test!
-- RslDictionary.ContainsKey(a): -- RslDictionary.EnsureConnected()
Connected()
KVRequest request = new KVGetRequest(_key);
byte[] requestBytes = request.Encode();
byte[] replyBytes = _rslClient.SubmitRequest(requestBytes, isVerbose);
Sending a request with sequence number 0 to IronfleetIoFramework.PublicIdentity
#timeout; rotating to server 1
#timeout; rotating to server 2
#timeout; rotating to server 0
#timeout; rotating to server 1
#timeout; rotating to server 2
#timeout; rotating to server 0
#timeout; rotating to server 1
#timeout; rotating to server 2
#timeout; rotating to server 0
```

Back to main [readme](../README.md)

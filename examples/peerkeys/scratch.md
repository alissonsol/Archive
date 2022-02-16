# Scratch

Scratch pad for commands and investigations.

## etcd

[etcd](https://etcd.io) is a distributed, reliable key-value store. There is integration support for several [languages](https://etcd.io/docs/current/integrations/). Trying with [dotnet-etcd](https://github.com/shubhamranjan/dotnet-etcd) and the [Bitnami](https://docs.bitnami.com/kubernetes/infrastructure/etcd/get-started/add-repo/) charts.

TODO: try [gRPC shared with HTTP in a single ingress](https://github.com/kubernetes/ingress-nginx/issues/2492)

### Manual container tests

```shell
$ helm repo add bitnami https://charts.bitnami.com/bitnami
$ helm install my-etcd bitnami/etcd
$ export POD_NAME=$(kubectl get pods --namespace default -l "app.kubernetes.io/name=etcd,app.kubernetes.io/instance=my-etcd" -o jsonpath="{.items[0].metadata.name}")
$ export ETCD_ROOT_PASSWORD=$(kubectl get secret --namespace default my-etcd -o jsonpath="{.data.etcd-root-password}" | base64 --decode)
$ kubectl exec -it $POD_NAME -- etcdctl put /message HelloAgain --user root:$ETCD_ROOT_PASSWORD
$ kubectl exec -it $POD_NAME -- etcdctl get /message --user root:$ETCD_ROOT_PASSWORD

# Another option
$ helm install --set auth.rbac.enabled=false my-etcd bitnami/etcd
```

### etcd and C#

Some considerations
- *Why .NET 6.0?*
  - Because it was the only one working in Apple M1 when development started, enabling the cross-platform test scenarios.
  - Need to download .NET 6.0 from <https://aka.ms/dotnet-download>
  - Need to download Visual Studio 2019 from <https://visualstudio.microsoft.com/downloads/>
  - In Visual Studio 2019, enable [Use previews of the .NET Core SDK](https://docs.microsoft.com/en-us/dotnet/core/tools/sdk-errors/netsdk1045).
- Getting restore errors?
  - error NU1100: Unable to resolve 'dotnet-etcd (>= 4.2.0)' for 'net6.0'.
  - Get latest nuget in path: <https://dist.nuget.org/win-x86-commandline/latest/nuget.exe>
  - Try `nuget restore grava.csproj` followed by `dotnet restore grava.csproj`
- Path to etcd debugging
  - Grava to localhost:2739 works when port forward enabled
  - Check if service is there? <http://url/version>. Example:<http://localhost:2379/version> or <http://localhost/srs001/version>
  - Static configuration
    - Hint to helm change: <https://docs.gitlab.com/charts/advanced/external-nginx/>
    - etcdserver: publish error: etcdserver: request timed out W | rafthttp: health check for peer could not connect: EOF
    - Working basis: <https://github.com/yogeek/etcd-demo>
    - Path to Azure: [Exposing multiple TCP/UDP services using a single LoadBalancer on K8s](https://stackoverflow.com/questions/61430311/exposing-multiple-tcp-udp-services-using-a-single-loadbalancer-on-k8s)


```shell
Investigation

https://etcd.io/docs/v3.4.0/op-guide/runtime-configuration/

etcdctl member list -w table
+------------------+---------+---------------------+-------------------------------------------------------------------------------------------+-------------------------------------------------------------------------------------------+------------+
|        ID        | STATUS  |        NAME         |                                        PEER ADDRS                                         |                                       CLIENT ADDRS                                        | IS LEARNER |
+------------------+---------+---------------------+-------------------------------------------------------------------------------------------+-------------------------------------------------------------------------------------------+------------+
| 2eb6b4a44b444278 | started | cloudtalk001-etcd-0 | http://cloudtalk001-etcd-0.cloudtalk001-etcd-headless.cloudtalk001.svc.cluster.local:2380 | http://cloudtalk001-etcd-0.cloudtalk001-etcd-headless.cloudtalk001.svc.cluster.local:2379 |      false | 10.1.0.32
+------------------+---------+---------------------+-------------------------------------------------------------------------------------------+-------------------------------------------------------------------------------------------+------------+
| 9527fdaff188a7ab | started | cloudtalk002-etcd-0 | http://cloudtalk002-etcd-0.cloudtalk002-etcd-headless.cloudtalk002.svc.cluster.local:2380 | http://cloudtalk003-etcd-0.cloudtalk002-etcd-headless.cloudtalk002.svc.cluster.local:2379 |      false | 10.1.0.35
+------------------+---------+---------------------+-------------------------------------------------------------------------------------------+-------------------------------------------------------------------------------------------+------------+
| 2b701c04ec71fe2a | started | cloudtalk003-etcd-0 | http://cloudtalk003-etcd-0.cloudtalk003-etcd-headless.cloudtalk003.svc.cluster.local:2380 | http://cloudtalk003-etcd-0.cloudtalk003-etcd-headless.cloudtalk003.svc.cluster.local:2379 |      false | 10.1.0.38
+------------------+---------+---------------------+-------------------------------------------------------------------------------------------+-------------------------------------------------------------------------------------------+------------+

001: etcdctl member update 2eb6b4a44b444278 --peer-urls=http://$MY_POD_IP:2380

In other container (grava or website)
apt-get update
apt-get install -y iputils-ping
ping cloudtalk001-etcd-0.cloudtalk001-etcd-headless.cloudtalk001.svc.cluster.local
PING cloudtalk001-etcd-0.cloudtalk001-etcd-headless.cloudtalk001.svc.cluster.local (10.1.0.32) 56(84) bytes of data.
64 bytes from cloudtalk001-etcd-0.cloudtalk001-etcd-headless.cloudtalk001.svc.cluster.local (10.1.0.32): icmp_seq=1 ttl=64 time=0.020 ms

from 001
etcdctl member add cloudtalk002-etcd-0 --peer-urls=http://cloudtalk002-etcd-0.cloudtalk002-etcd-headless.cloudtalk002.svc.cluster.local:2380 --learner
Member e1c52c2e9944f1e0 added to cluster dcbc8989a24e86cb

ETCD_NAME="cloudtalk002-etcd-0"
ETCD_INITIAL_CLUSTER="cloudtalk001-etcd-0=http://cloudtalk001-etcd-0.cloudtalk001-etcd-headless.cloudtalk001.svc.cluster.local:2380,cloudtalk002-etcd-0=http://cloudtalk002-etcd-0.cloudtalk002-etcd-headless.cloudtalk002.svc.cluster.local:2380"
ETCD_INITIAL_ADVERTISE_PEER_URLS="http://cloudtalk002-etcd-0.cloudtalk002-etcd-headless.cloudtalk002.svc.cluster.local:2380"
ETCD_INITIAL_CLUSTER_STATE="existing"

etcdctl member list -w table
+------------------+-----------+---------------------+-------------------------------------------------------------------------------------------+-------------------------------------------------------------------------------------------+------------+
|        ID        |  STATUS   |        NAME         |                                        PEER ADDRS                                         |                                       CLIENT ADDRS                                        | IS LEARNER |  
+------------------+-----------+---------------------+-------------------------------------------------------------------------------------------+-------------------------------------------------------------------------------------------+------------+  
| 2eb6b4a44b444278 |   started | cloudtalk001-etcd-0 | http://cloudtalk001-etcd-0.cloudtalk001-etcd-headless.cloudtalk001.svc.cluster.local:2380 | http://cloudtalk001-etcd-0.cloudtalk001-etcd-headless.cloudtalk001.svc.cluster.local:2379 |      false |  
| e1c52c2e9944f1e0 | unstarted |                     | http://cloudtalk002-etcd-0.cloudtalk002-etcd-headless.cloudtalk002.svc.cluster.local:2380 |                                                                                           |       true |  
+------------------+-----------+---------------------+-------------------------------------------------------------------------------------------+-------------------------------------------------------------------------------------------+------------+ 

Cycle is: send vote requests. Won't receive votes from peers.
raft2021/03/20 22:17:18 INFO: db8155aeab14304c became candidate at term 241
raft2021/03/20 22:17:18 INFO: db8155aeab14304c received MsgVoteResp from db8155aeab14304c at term 241
raft2021/03/20 22:17:18 INFO: db8155aeab14304c [logterm: 1, index: 3] sent MsgVote request to 3773da85ae72d60e at term 241
raft2021/03/20 22:17:18 INFO: db8155aeab14304c [logterm: 1, index: 3] sent MsgVote request to 3e54fd442da44b69 at term 241
2021-03-20 22:17:19.608226 W | rafthttp: health check for peer 3773da85ae72d60e could not connect: EOF
2021-03-20 22:17:19.608246 W | rafthttp: health check for peer 3e54fd442da44b69 could not connect: EOF
```

Back to main [readme](README.md)

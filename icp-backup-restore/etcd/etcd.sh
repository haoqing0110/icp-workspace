#export org=ibmcom
#export repo=etcd
#export tag=v3.2.14
#export endpoint=9.111.255.130
alias etcdctl2="etcdctl --endpoints=https://${endpoint}:4001 --ca-file=/etc/cfc/conf/etcd/ca.pem --cert-file=/etc/cfc/conf/etcd/client.pem --key-file=/etc/cfc/conf/etcd/client-key.pem"
alias etcdctl3="ETCDCTL_API=3 etcdctl --endpoints=https://${endpoint}:4001 --cacert=/etc/cfc/conf/etcd/ca.pem --cert=/etc/cfc/conf/etcd/client.pem --key=/etc/cfc/conf/etcd/client-key.pem"

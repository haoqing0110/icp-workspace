# Backup and restore etcd in IBM Cloud Private

This README shows you how to bakckup and restore etcd in IBM Cloud Private. 
Mainly includes 3 parts:
1. Backup cluster.
2. Backup etcd data.
3. Restore etcd data.

  i.  Restore etcd data in a local cluster. You can use this option when the data center infrastructure goes down and you are able to rebuild the cluster. After rebuilding the cluster, you can restore the etcd data in the original cluster.

  ii. Restore etcd in a remote cluster. You can use this option when the data center infrastructure goes down, and you are not able to restore the original cluster. In this case, you need to restore the etcd data in another data center.

Some useful scripts are provied in this repository.

|script|usage|
|----|------|
|etcd.sh |Setup alias to backup etcd|
|1-config-kubectl.sh | setup kubectl|
|2-save-yaml.sh | save configurations when restore etcd in remote cluster|
|3-purge.sh |stop kubernetes on master and purge etcd data|
|purge_kubelet_pods.sh |used in 3-purge.sh|
|4-restore.sh | restore etcd and start kubernetes on all nodes|
|multimaster-etcd-restore.sh |used in 4-restore.sh|
|5-update-node.sh |update nodes when restore etcd in remote cluster|
|6-update-yaml.sh |update secrets, configmaps and persistentvolumes when restore etcd in remote cluster|
|7-update-ip.sh |update ip when restore etcd in remote cluster|

## Backup cluster
After installation completes, you need to save a copy of the cluster/cfc-certs and cluster/cfc-keys. Saved certificates and keys can be used in local cluster restores.

To save the certificates and keys, copy the entire installation directory to a separate location. For example, if your installation directory is /opt/icp-2.1.0.3, run the following command:
```
cp -r /opt/icp-2.1.0.3 /opt/icp-2.1.0.3-bk
```
## Backup etcd
Whether you're running a single master or a multi-master configuration of IBM Cloud Private, in both cases the etcd backup is always taken from a single node, to ensure consistency on restore. 

For a multi-node cluster, all nodes are restored from the same (single sourced) backup copy.

To backup etcd: 
1. Log on to a master node, 
2. Export a few  environment variables, 
```
export org=ibmcom
export repo=etcd
export tag=v3.2.14
export endpoint=9.111.255.72
```
3. Copy etcdctl to /user/local/bin/
```
sudo docker run --rm -v /usr/local/bin:/data $org/$repo:$tag cp /usr/local/bin/etcdctl /data
```
4. Source the etcd.sh script.
```
. ./etcd.sh
```
5. Validate the etcd cluster status by running the following commands.
```
# etcdctl2 cluster-health
member 7a5703380976f596 is healthy: got healthy result from https://9.111.255.179:4001
member 7c2ce9ea4a75caaa is healthy: got healthy result from https://9.111.255.178:4001
member fd529306e0ed0813 is healthy: got healthy result from https://9.111.255.72:4001
cluster is healthy

# etcdctl2 member list
7a5703380976f596: name=etcd1 peerURLs=https://9.111.255.179:2380 clientURLs=https://9.111.255.179:4001 isLeader=false
7c2ce9ea4a75caaa: name=etcd2 peerURLs=https://9.111.255.178:2380 clientURLs=https://9.111.255.178:4001 isLeader=true
fd529306e0ed0813: name=etcd0 peerURLs=https://9.111.255.72:2380 clientURLs=https://9.111.255.72:4001 isLeader=false
```
6. Take a snapshot of the etcd data.
```
# etcdctl3 snapshot save /data/etcd.db
Snapshot saved at /data/etcd.db
```
The etcd data file is now available in the /data directory on the master node. You should do a periodic backup of this etcd.db file and save it in a safe location. 
## Restore etcd in a local cluser
### Reinstall cluster
If your entire cluster goes down and you can't recover, you might need to reinstall your cluster.
**Important**: Copy the cfc-certs and cfc-keys files from your backup location to your installation directory before you reinstall. 
```
cp -r /opt/icp-2.1.0.3-bk/cluster/cfc-certs /opt/icp-2.1.0.3/cluster/
cp -r /opt/icp-2.1.0.3-bk/cluster/cfc-keys /opt/icp-2.1.0.3/cluster/
```
### Restore etcd
Restore etcd to your original cluster, in this case the host name and host IP of your cluster is kept the same.
After you have your original cluster running again, you can now perform these steps to restore etcd. 
1. Save secret “metering-service-id” for later use. This is not necessary, read “Trouble Shooting” section for more information.
```
# kubectl get secret metering-service-id -n kube-system -oyaml > metering-service-id.yaml
```
2. Define the following environment variable, based on your installation environment. 
```
export CLUSTER_DIR=/opt/icp-2.1.0.3/cluster
```
3. Overwrite the /data/etcd.db with the backed up etcd.db file.
4. Run the 3-purge.sh script.
```
./3-purge.sh
```
5. Run the 4-restore.sh script to restore etcd on your cluster. 
```
./4-restore.sh
```
For more information about the more details of purge and restore process see [icp-backup on GitHub](https://github.com/ibm-cloud-architecture/icp-backup/blob/master/docs/etcd_restore_multi.md).
## Restore etcd in remote cluster
Restore etcd in a remote or different cluster from the original cluster. In this case the host name and host IP are different from those used in the original cluster. 

**Important**: To restore etcd in a remote cluster, you first need to install a new cluster. **Do not** copy the cfc-certs and cfc-keys files from your backup location to your new installation directory. 

After you have your new cluster running, you can then perform these steps to restore etcd. 

1. Define the following environment variable, according to your installation.
```
export CLUSTER_DIR=/opt/icp-2.1.0.3/cluster
```
2. Save the current cluster's ConfigMap and Secret that are in the kube-system, and istio-system namespaces. Also save any DaemonSet and deployments that have hard coded IP addresses. To save these data, run the following scripts.  
```
./1-config-kubelet.sh
./2-save-yaml.sh
```
3. Overwrite the /data/etcd.db with the backed up etcd.db file.
4. Run the 3-purge.sh script
```
./3-purge.sh
```
5. Run the 4-restore.sh script to restore etcd on your cluster. 
```
./4-restore.sh
```
For more information about the more details of purge and restore process see [icp-backup on GitHub](https://github.com/ibm-cloud-architecture/icp-backup/blob/master/docs/etcd_restore_multi.md).
6. View the nodes, use `kubectl get nodes --show-labels`. You can see that there are both old and new nodes. Remove the old nodes. To remove the old nodes, run the 5-update.sh script.
```
./5-update-node.sh
```
7. Use the ConfigMap and Secrets that you saved in step 2, to replace the data in etcd. To do this, run the 6-update-yaml.sh script.  
```
./6-update-yaml.sh
```
The persistent volume configuration of some management service might also be updated in this step.
8. Restart pods to ensure that the Secret configuration takes effect.
```
kubectl delete pod -n kube-system `kubectl get pods -n kube-system |  awk '{print $1}'`
kubectl delete pod -n istio-system `kubectl get pods -n istio-system |  awk '{print $1}'`
```
9. Use the 7-update-ip.sh script to modify  the IPs in affected DaemonSet and deployments. 
```
./7-update-ip.sh
```
10. Wait for the pods to start running. If any pods hang, you can try to delete them, they will re-run automatically.
```
kubectl delete pod -n kube-system `kubectl get pods -n kube-system | grep -v Running | awk '{print $1}'`
```

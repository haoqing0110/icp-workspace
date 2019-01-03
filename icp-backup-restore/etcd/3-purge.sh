#!/bin/bash
# Purge
echo "------Install ansible on the boot node.------"
apt-get install ansible
echo "------Install jq on all the master node.------"
ansible master -i $CLUSTER_DIR/hosts -e @$CLUSTER_DIR/config.yaml --private-key=$CLUSTER_DIR/ssh_key -m package -a "use=apt name=jq state=present"
echo "------Stop Kubernetes on all nodes------"
ansible master -i $CLUSTER_DIR/hosts -e @$CLUSTER_DIR/config.yaml --private-key=$CLUSTER_DIR/ssh_key -a "mkdir -p /etc/cfc/podbackup"
ansible master -i $CLUSTER_DIR/hosts -e @$CLUSTER_DIR/config.yaml --private-key=$CLUSTER_DIR/ssh_key -m shell -a "mv /etc/cfc/pods/*.json /etc/cfc/podbackup"
echo "------Wait for etcd to shut down on all nodes.------"
ansible master -i $CLUSTER_DIR/hosts -e @$CLUSTER_DIR/config.yaml --private-key=$CLUSTER_DIR/ssh_key -m wait_for -a  "port=4001 state=stopped"
echo "------Shut down kubelet on all master nodes.------"
ansible master -i $CLUSTER_DIR/hosts -e @$CLUSTER_DIR/config.yaml --private-key=$CLUSTER_DIR/ssh_key -m service -a "name=kubelet state=stopped"
echo "------Restart the docker service.------"
ansible master -i $CLUSTER_DIR/hosts -e @$CLUSTER_DIR/config.yaml --private-key=$CLUSTER_DIR/ssh_key -m service -a "name=docker state=restarted"
echo "------Purge etcd data.------"
ansible master -i $CLUSTER_DIR/hosts -e @$CLUSTER_DIR/config.yaml --private-key=$CLUSTER_DIR/ssh_key -m shell -a "mv /var/lib/etcd /var/lib/etcd-bk"
ansible master -i $CLUSTER_DIR/hosts -e @$CLUSTER_DIR/config.yaml --private-key=$CLUSTER_DIR/ssh_key -m shell -a "mv /var/lib/etcd-wal /var/lib/etcd-wal-bk"

#!/bin/bash
docker run -e LICENSE=accept --net=host --rm -v /usr/local/bin:/data ibmcom/icp-inception:2.1.0.3-ee cp /usr/local/bin/kubectl /data
mv ~/.kube ~/.kube.bk
mkdir ~/.kube
cp /var/lib/kubelet/kubelet-config ~/.kube/config
sed -i -e 's/kubelet.crt/kubecfg.crt/' -e 's/kubelet.key/kubecfg.key/g' ~/.kube/config
kubectl get nodes

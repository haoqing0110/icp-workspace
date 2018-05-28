#!/bin/bash
# re-genereate default secret
kubectl get secret -n kube-system -owide | grep "\-token-" | awk '{system("kubectl delete secret "$1 " -n kube-system")}'
kubectl get secret -n services -owide | grep "\-token-" | awk '{system("kubectl delete secret "$1 " -n services")}'
kubectl get secret -n istio-system -owide | grep "\-token-"| awk '{system("kubectl delete secret "$1 " -n istio-system")}'

namespaces=(kube-system services istio-system)

for ns in ${namespaces[@]}
do
    #secret
    for s in $(ls $ns.secret/ | grep -v "\-token-")
    do
        kubectl delete -f $ns.secret/$s && kubectl create -f $ns.secret/$s
    done

    #configmap
    for s in $(ls $ns.configmap/)
    do
        kubectl delete -f $ns.configmap/$s && kubectl create -f $ns.configmap/$s
    done
done

#pv
kubectl delete pv `kubectl get pv | grep -e "image-manager-image-manager-" -e "mongodbdir-icp-mongodb-" -e "data-logging-elk-data-" -e "-vulnerability-advisor-" | awk '{print $1}'`
kubectl delete pvc -n kube-system `kubectl get pvc -n kube-system | grep -e "image-manager-image-manager-" -e "mongodbdir-icp-mongodb-" -e "data-logging-elk-data-" -e "-vulnerability-advisor-" | awk '{print $1}'`
kubectl apply -f $CLUSTER_DIR/cfc-components/storage/

#!/bin/bash
namespaces=(kube-system services istio-system)

for ns in ${namespaces[@]}
do
    mkdir $ns.configmap $ns.secret $ns.deployment.extensions $ns.daemonset.extensions
    # save configmap, secret, deployment, daemonset
    for n in $(kubectl get -o=name configmap,secret,ds,deployment -n $ns)
    do
        kubectl get -oyaml -n $ns $n > $ns.$n.yaml
    done
done

kubectl get APIService -n kube-system -oyaml v1beta1.servicecatalog.k8s.io > kube-system.servicecatalog.yaml

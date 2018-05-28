#!/bin/bash
kubectl delete node $(kubectl get nodes | grep NotReady | awk '{print $1}')

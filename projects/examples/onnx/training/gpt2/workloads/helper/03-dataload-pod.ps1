# Dataload pod. Normally executes "/app/dataload.sh"
kubectl create -f 03-dataload-pod.yml
kubectl get pod dataload-pod --namespace yrn42onnxtraingpt2-namespace
kubectl wait --for=condition=ready --timeout=60s pod/dataload-pod --namespace yrn42onnxtraingpt2-namespace

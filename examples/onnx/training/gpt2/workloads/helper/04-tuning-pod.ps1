# Tuning pod. Run adapted "/app/launch.sh"
kubectl create -f 04-tuning-pod.yml
kubectl get pod tuning-pod --namespace yrn42onnxtraingpt2-namespace
kubectl wait --for=condition=ready --timeout=60s pod/tuning-pod --namespace yrn42onnxtraingpt2-namespace

kubectl get pod tuning-pod --namespace yrn42onnxtraingpt2-namespace
kubectl exec -it tuning-pod --namespace yrn42onnxtraingpt2-namespace -- /bin/bash
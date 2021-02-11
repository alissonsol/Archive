# Create helper pod to ease inspection of the persistent volume claim content
kubectl create -f 02-dataview-pod.yml
kubectl get pod dataview-pod --namespace yrn42onnxtraingpt2-namespace
kubectl wait --for=condition=ready --timeout=60s pod/dataview-pod --namespace yrn42onnxtraingpt2-namespace
kubectl get pod dataview-pod --namespace yrn42onnxtraingpt2-namespace
kubectl exec -it dataview-pod --namespace yrn42onnxtraingpt2-namespace -- /bin/bash
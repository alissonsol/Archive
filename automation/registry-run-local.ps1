# Docker-generic: run local registry (yuruna)

kubectl config rename-context "docker-desktop" "yuruna"
kubectl config use-context "yuruna"
docker pull registry
docker run -d -p 5000:5000 --restart always --name registry registry:latest

Exit 0
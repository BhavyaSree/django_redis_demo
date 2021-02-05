#!/usr/bin/env bash
echo 'This script expects REDIS_PASSWORD env do be defined, otherise uses a defaut one'
REDIS_PASSWORD="${REDIS_PASSWORD:-notSoSecret}"

minikube status | grep 'apiserver: Running' || minikube start

# Setup Helm Repo
helm repo list | grep bitnami || helm repo add bitnami https://charts.bitnami.com/bitnami 
helm repo update

# Deploying Redis Cluster using Helm chart
kubectl create namespace db-ns
helm install my-redis bitnami/redis --set password=$REDIS_PASSWORD --namespace db-ns

echo "Deploying Redis cluster using Helm chart..."
sleep 5

# Deploy django application
kubectl create namespace app-ns
kubectl create serviceaccount --namespace app-ns myapp-sa

kubectl create secret generic my-redis --namespace  app-ns --from-literal=redis-password=`kubectl get secret/my-redis -n db-ns -ojsonpath='{.data.redis-password}' | base64 -D`
kubectl create deploy myapp --image=bhavyabindela/testapp --namespace app-ns --replicas=2 --port=8000
sleep 10

kubectl set serviceaccount deployment myapp --namespace app-ns myapp-sa
echo "TO-DO: Reduce the permissions of service account"
sleep 5
kubectl set env deployment myapp --namespace app-ns --from=secret/my-redis 
sleep 5
kubectl set env deployment myapp --namespace app-ns REDIS_HOST=my-redis-master.db-ns.svc.cluster.local REDIS_PORT=6379 
sleep 5

echo "Setting/limiting resources"
kubectl set resources deployment/myapp --namespace app-ns --limits=cpu=1000m,memory=2058Mi --requests=cpu=500m,memory=1024Mi

echo "TO-DO: Define NetworkPolicy to only allow myapp to access redis"
echo "Deploying our django application..."
sleep 10


echo "Exposing the service and do port-forward"
kubectl expose deployment/myapp --namespace app-ns --port=8000 --name=myapp
open http://localhost:8000/test_view
echo "Open in browser http://localhost:8000/test_view"
echo "Press Ctrl + C to terminate"
kubectl port-forward svc/myapp -napp-ns 8000:8000


echo "Press any key to do cleanup"
read -n1 z

echo 'Cleaning up...'
kubectl delete namespace app-ns db-ns
# kubectl delete pvc/redis-data-my-redis-{master-0,slave-0,slave-1}
# minikube stop
# helm repo remove bitnami
[
  {
    "cloudName": "AzureCloud",
    "homeTenantId": "66093ef8-1067-4946-b1f4-ae0ab7c4d548",
    "id": "4effd691-89f5-468e-ac5f-1e1002e3eb2a",
    "isDefault": true,
    "managedByTenants": [],
    "name": "Pay-As-You-Go",
    "state": "Enabled",
    "tenantId": "66093ef8-1067-4946-b1f4-ae0ab7c4d548",
    "user": {
      "name": "axel.grosse@42css.onmicrosoft.com",
      "type": "user"
    }
  }
]


Merged "platform-demos" as current context in /Users/axl/.kube/config

## start with creatting a namespace
NAME="axl2"

## solution for normal cluster
kubectl create namespace ${name}



## solution for the spot instance issue

cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Namespace
metadata:
  annotations:
    scheduler.alpha.kubernetes.io/defaultTolerations: '[{"Key": "kubernetes.azure.com/scalesetpriority",
      "Operator": "Equal", "Value": "spot", "Effect": "NoSchedule"}]'
  name: ${NAME}
EOF


# Install pixi app
helm upgrade pixiapi --install --dry-run --debug ./42c-pixiapi --namespace axl2 -f ./42c-pixiapi/values-axl.yaml

# check container and pods 
kubectl get pods -n axl2

# update FW props env to your namspace
./42c-firewall/etc/env 
```
RUNTIME_NS=axl2
```

## get your protection FW token from the platform
Token 3b45b7e3-dee2-4324-9268-b680c0d803c6

# upgrade/install helm script for firewall properties 
helm upgrade firewall-props --dry-run --install --debug ./42c-firewall --namespace axl2 --set-string apifirewall.protection_token=3b45b7e3-dee2-4324-9268-b680c0d803c6


# add firewall as sidecar to pod
helm upgrade  pixiapi  --dry-run --debug ./42c-pixiapi --namespace axl2 --set pixiapp.inject_firewall=true --set pixiapp.pod_listen_port=8080 -f ./42c-pixiapi/values-axl.yaml


# prepare data in the db for scan and protect 



curl -s -X POST -H "Content-Type: application/json" -d '{"user": "scanuser@test.com","pass": "hellopixi","name": "Scan Test User","is_admin": false,"account_balance": 1000}' https://api.k8s.orb.local/axl/api/user/register


## to clean helm charts
helm ls -n axl2

helm delete <chart name> -n axl2


# clean up 
helm delete pixiapi -n axl2

## full clean up 
helm uninstall pixiapi  --namespace axl2 


### end 



Get local ingress nginx for Orstack
helm upgrade --install --dry-run ingress-nginx ingress-nginx --repo https://kubernetes.github.io/ingress-nginx --namespace axl



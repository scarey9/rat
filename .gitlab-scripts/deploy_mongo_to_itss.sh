echo "Deploying server"

export KUBE_LATEST_VERSION="v1.17.3"

apk update \
&& apk add --no-cache ca-certificates bash git openssh curl \
&& wget -q https://storage.googleapis.com/kubernetes-release/release/${KUBE_LATEST_VERSION}/bin/linux/amd64/kubectl -O /usr/local/bin/kubectl \

export KUBECONFIG=/builds/${CI_PROJECT_NAMESPACE}/${CI_PROJECT_NAME}/itss.kubeconfig_nossl.yml
chmod +x /usr/local/bin/kubectl \

curl -X GET -u $svc_acct:$svc_pwd https://nexus.forcenex.us/repository/gap-cem-bin/itss/itss.kubeconfig_nossl.yml -O -J

echo $DOCKER_AUTH_CONFIG >> regcred

kubectl create secret generic regcred -n $CI_PROJECT_NAME \
--from-file=.dockerconfigjson=regcred \
--type=kubernetes.io/dockerconfigjson \
--insecure-skip-tls-verify || echo "Check: regcred exists"

kubectl create secret generic rancher-api \
    --from-literal=RANCHER_API_TOKEN=$RANCHER_API_TOKEN \
    --from-literal=RANCHER_CLUSTER_ID=$RANCHER_CLUSTER_ID \
    --insecure-skip-tls-verify || echo "Check: rancher-api-token exists"

export PUSHED_TAG_NAME="$CI_PROJECT_NAME-server":"$CI_COMMIT_REF_NAME"
export CONTAINER_FULLPATH="$CONTAINER_REGISTRY/$PUSHED_TAG_NAME"

export INPUT_JSON="kubernetes/templates/input.json"
echo "Create input.json for mustache template"
echo "{" >> $INPUT_JSON
echo "\"CI_PROJECT_NAME\":\"$CI_PROJECT_NAME\"," >> $INPUT_JSON
echo "\"IMAGE\":\"$CONTAINER_FULLPATH\"" >> $INPUT_JSON
echo "}" >> $INPUT_JSON

echo "Generating deployment from template"
export SERVER="./.gitlab-scripts/server.yml"
docker build -f kubernetes/templates/Dockerfile-mustache.template kubernetes/templates -t server_generator --build-arg TYPE=server-deployment
[ $? -eq 0 ]  || exit 1
docker run server_generator >> $SERVER
[ $? -eq 0 ]  || exit 1
echo "Finished generating template"
echo "Proxy yml is now at: $SERVER"

echo "Deploying workload"
kubectl apply -f $SERVER
[ $? -eq 0 ]  || exit 1
echo "Finished deploying workload"

echo "Generating service from template"
export SERVICE="./.gitlab-scripts/server-service.yml"
docker build -f kubernetes/templates/Dockerfile-mustache.template kubernetes/templates -t service_generator --build-arg TYPE=server-service
docker run service_generator >> $SERVICE
echo "Finished generating template"
echo "Service yml is now at: $SERVICE"

echo "Deploying service"
kubectl apply -f $SERVICE
[ $? -eq 0 ]  || exit 1
echo "Finished deploying service"

echo "Deploy server complete!"

echo "Blue-Green 50/50 Rolling Update"

export KUBE_LATEST_VERSION="v1.17.3"

apk update \
&& apk add --no-cache ca-certificates bash git openssh curl \
&& wget -q https://storage.googleapis.com/kubernetes-release/release/${KUBE_LATEST_VERSION}/bin/linux/amd64/kubectl -O /usr/local/bin/kubectl \

export KUBECONFIG=/builds/${CI_PROJECT_NAMESPACE}/${CI_PROJECT_NAME}/itss.kubeconfig_nossl.yml
chmod +x /usr/local/bin/kubectl \

curl -X GET -u $svc_acct:$svc_pwd https://nexus.forcenex.us/repository/gap-cem-bin/itss/itss.kubeconfig_nossl.yml -O -J

export PODS=$(kubectl get pods --insecure-skip-tls-verify -l=app=$CI_PROJECT_NAME -n $CI_PROJECT_NAME -o go-template \
--template '{{range .items}}{{.metadata.name}} {{"\n"}}{{end}}')
echo $PODS | awk 'NR % 2 == 0' \
| xargs --no-run-if-empty kubectl delete pod -n $CI_PROJECT_NAME --insecure-skip-tls-verify && \
sleep 1m && \
echo $PODS | awk 'NR % 2 != 0' \
| xargs --no-run-if-empty kubectl delete pod -n $CI_PROJECT_NAME --insecure-skip-tls-verify

echo "Rolling update complete!"
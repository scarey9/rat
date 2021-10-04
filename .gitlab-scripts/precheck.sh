echo "Running precheck"

echo $CI_PROJECT_NAME

export KUBE_LATEST_VERSION="v1.17.3"

apk update \
&& apk add --no-cache ca-certificates bash git openssh curl \
&& wget -q https://storage.googleapis.com/kubernetes-release/release/${KUBE_LATEST_VERSION}/bin/linux/amd64/kubectl -O /usr/local/bin/kubectl \
&& chmod +x /usr/local/bin/kubectl

echo "Getting kubeconfig file: $ITSS_KUBECONFIG"
curl -X GET -u $svc_acct:$svc_pwd https://nexus.forcenex.us/repository/gap-cem-bin/itss/itss.kubeconfig_nossl.yml -O -J
export KUBECONFIG=/builds/${CI_PROJECT_NAMESPACE}/${CI_PROJECT_NAME}/itss.kubeconfig_nossl.yml

export FAILED=0

export NAMESPACE_EXISTS=`kubectl get namespace | grep $CI_PROJECT_NAME`
if [ -z "$NAMESPACE_EXISTS" ]
then
    $FAILED=1
    echo "Missing Rancher Namespace - Contact #jade_engineering_external on RocketChat"
    exit 1
else
    echo "Rancher Namespace found!"
fi


if [ -z "$RANCHER_API_TOKEN" ]
then
    $FAILED=1
    echo "Missing RANCHER_API_TOKEN Gitlab CI/CD variable - Check the EPT App readme"
else
    echo "RANCHER_API_TOKEN found!"
fi

[ $FAILED == 1 ] && exit 1

echo "Precheck complete!"
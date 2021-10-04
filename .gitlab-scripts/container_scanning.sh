export DOCKER_CONTAINER_FULLNAME="$CI_APPLICATION_REPOSITORY/${1}:$CI_APPLICATION_TAG"

if [[ -n "$CI_REGISTRY_USER" ]]; then
    echo "Logging to GitLab Container Registry with CI credentials..."
    docker login -u "$CI_REGISTRY_USER" -p "$CI_REGISTRY_PASSWORD" "$CI_REGISTRY"
    echo ""
fi

export DOCKER_HOST='tcp://dind:2375'

docker run -d --name db --restart on-failure arminc/clair-db:latest
docker run -p 6060:6060 --link db:postgres -d --name clair --restart on-failure arminc/clair-local-scan:v2.0.1

apk add -U wget ca-certificates

echo "Begin pulling of container"
docker pull $DOCKER_CONTAINER_FULLNAME
echo "Finished pulling of container"

wget https://github.com/arminc/clair-scanner/releases/download/v8/clair-scanner_linux_amd64

mv clair-scanner_linux_amd64 clair-scanner

chmod +x clair-scanner

touch clair-whitelist.yml

retries=0

echo "Waiting for clair daemon to start"

while( ! wget -T 10 -q -O /dev/null http://dind:6060/v1/namespaces && ps -a && netstat -punta ) ; do sleep 1 ; echo -n "." ; if [ $retries -eq 10 ] ; then echo " Timeout, aborting." ; exit 1 ; fi ; retries=$(($retries+1)) ; done
./clair-scanner -c http://dind:6060 --ip $(hostname -i) -r gl-container-scanning-report.json -l clair.log -w clair-whitelist.yml $DOCKER_CONTAINER_FULLNAME || true
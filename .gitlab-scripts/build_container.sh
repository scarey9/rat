echo "Building container: ${1}"
export DOCKER_CONTAINER_FULLNAME="$CI_APPLICATION_REPOSITORY/${1}:$CI_APPLICATION_TAG"

if [[ -n "$CI_REGISTRY_USER" ]]; then
    echo "Logging to GitLab Container Registry with CI credentials"
    docker login -u "$CI_REGISTRY_USER" -p "$CI_REGISTRY_PASSWORD" "$CI_REGISTRY"
    [ $? -eq 0 ]  || exit 1
    echo ""
fi

export TAG="$(date +%Y%m%d)-${CI_COMMIT_SHORT_SHA}"
echo "TAG= ${TAG}"

if [[ -f Dockerfile ]]; then
    echo "Building $DOCKER_CONTAINER_FULLNAME"
    docker build \
        --build-arg HTTP_PROXY="$HTTP_PROXY" \
        --build-arg http_proxy="$http_proxy" \
        --build-arg HTTPS_PROXY="$HTTPS_PROXY" \
        --build-arg https_proxy="$https_proxy" \
        --build-arg FTP_PROXY="$FTP_PROXY" \
        --build-arg ftp_proxy="$ftp_proxy" \
        --build-arg NO_PROXY="$NO_PROXY" \
        --build-arg no_proxy="$no_proxy" \
        --build-arg version_string="$TAG" \
        --build-arg CI_PROJECT_NAME="$CI_PROJECT_NAME" \
        --build-arg OAUTH2_PROXY_CLIENT_ID="$OAUTH2_PROXY_CLIENT_ID" \
        --build-arg OAUTH2_PROXY_CLIENT_SECRET="$OAUTH2_PROXY_CLIENT_SECRET" \
        -t "$DOCKER_CONTAINER_FULLNAME" .
    [ $? -eq 0 ]  || exit 1
else
    echo "No Dockerfile found"
fi

echo "Pushing container: $DOCKER_CONTAINER_FULLNAME"
docker push "$DOCKER_CONTAINER_FULLNAME"
[ $? -eq 0 ]  || exit 1

echo "Build complete!"
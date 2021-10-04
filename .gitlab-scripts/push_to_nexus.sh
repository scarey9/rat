echo "Pushing to nexus"

export DOCKER_CONTAINER_FULLNAME="$CI_APPLICATION_REPOSITORY/${1}:$CI_APPLICATION_TAG"

export PUSHED_TAG_NAME="$CI_PROJECT_NAME-${1}":"$CI_COMMIT_REF_NAME"
if [[ -n "$CI_REGISTRY_USER" ]]; then
    echo "Logging into GitLab Container Registry with CI credentials"
    docker login -u "$CI_REGISTRY_USER" -p "$CI_REGISTRY_PASSWORD" "$CI_REGISTRY"
    [ $? -eq 0 ]  || exit 1
    echo ""
fi

docker login  $CONTAINER_REGISTRY -u $svc_acct -p $svc_pwd
echo ""
echo "Logging into GitLab Container Registry with CI credentials"
docker login -u "$CI_REGISTRY_USER" -p "$CI_REGISTRY_PASSWORD" "$CI_REGISTRY"
echo ""

echo "Pulling: $DOCKER_CONTAINER_FULLNAME"
docker pull $DOCKER_CONTAINER_FULLNAME
[ $? -eq 0 ]  || exit 1
echo "Tagged with: $PUSHED_TAG_NAME"
echo "$PUSHED_TAG_NAME"
docker tag "$DOCKER_CONTAINER_FULLNAME" $CONTAINER_REGISTRY"/"$PUSHED_TAG_NAME
[ $? -eq 0 ]  || exit 1

docker -v
echo "Pushing tagged image to registry"
docker push $CONTAINER_REGISTRY"/"$PUSHED_TAG_NAME
[ $? -eq 0 ]  || exit 1
echo ""

echo "Push to nexus complete!"
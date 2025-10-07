# /bin/bash

# the docker hub account where the images are hosted
DOCKER_HUB_ACCOUNT="krsyoung"
DEFAULT_IMAGE="rails-dev"

function help () {
  echo "** rails docker image tooling **"
  echo
  echo "commands:"
  echo "  build <image> <version>   - build the image and tag as latest"
  echo "  freshen <image> <version> - build the image, tag as latest and push to Docker Hub"
  echo "  push <image> <version>    - push the version to Docker Hub"
  echo "  release <image> <version> - add the version tag to latest and push to Docker Hub"
  echo "  update <image> <version>  - build, tag with latest, push and tag with the version"
  echo "  images                    - list the available images"
  echo
  echo "example (test and release): "
  echo "1. install latest packages for rails-dev 3.4.6 image"
  echo "   > freshen rails-dev 3.4.6"
  echo "2. after testing, promote latest image to new 3.4.6 tag"
  echo "   > release rails-dev 3.4.6"
  echo
  echo "example (full send, skips testing): "
  echo "1. build, tag and deploy an updated image rails-dev 3.4.6 image"
  echo "   > update rails-dev 3.4.6"
  echo
}

function images () {
  echo "images:"
  echo " - rails-dev"
}

# login to docker
function login () {
  docker login --username=$DOCKER_HUB_ACCOUNT
}

# build image
function build () {
  image=$1
  version=$2
  [ -z "$image" ] && echo "Error: need an image." && return 1
  [ -z "$version" ] && echo "Error: need a version." && return 1

  echo "Building $image:$version"

  dockerfile="$image/Dockerfile-$version"
  if [ ! -f $dockerfile ]; then
    echo "Error: no Dockerfile found at $dockerfile"
    return 1
  fi

  # build, without cache and apply a version tag based on the ruby version
  docker build --no-cache -f $dockerfile -t $DOCKER_HUB_ACCOUNT/$image:$version $image/
}

# build image and tag with current date
function freshen () {
  image=$1
  version=$2
  [ -z "$image" ] && echo "Error: need an image." && return 1
  [ -z "$version" ] && echo "Error: need a version." && return 1

  echo "Freshening $image-$version"

  build $image $version
  push $image latest
}

function push () {
  image=$1
  version=$2
  [ -z "$image" ] && echo "Error: need an image." && return 1
  [ -z "$version" ] && echo "Error: need a version." && return 1

  echo "Pushing $image:$version"
  docker push "$DOCKER_HUB_ACCOUNT/$image:$version"
}

# tag an exiting image as latest and push
function release () {
  image=$1
  version=$2
  [ -z "$image" ] && echo "Error: need an image." && return 1
  [ -z "$version" ] && echo "Error: need a version." && return 1
  echo "Releasing $image:$version"

  # tag the specific version with latest  
  push $image $version
  docker tag $DOCKER_HUB_ACCOUNT/$image:$version $DOCKER_HUB_ACCOUNT/${image}:latest
  push $image latest
}

# build image and tag with current date
function update () {
  image=$1
  version=$2
  [ -z "$image" ] && echo "Error: need an image." && return 1
  [ -z "$version" ] && echo "Error: need a version." && return 1

  echo "Updating $image:$version"

  build $image $version
  release $image $version
}

help
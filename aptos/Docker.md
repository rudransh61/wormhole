# first build the image
DOCKER_BUILDKIT=1 docker build -f Dockerfile.base -t aptos .
# tag the image with the appropriate version
docker tag aptos:latest ghcr.io/wormhole-foundation/aptos:0.3.2
# push to ghcr
docker push ghcr.io/wormhole-foundation/aptos:0.3.2
# Using podman with the podman-docker wrappers.
# Known issue: docker compose seems to cache the container, even when changed or rebuilt with docker build.

cp sample.env .env
# podman image prune -a --build-cache --external
# docker build --cache-ttl=1h .
docker compose up
ssh -p 2222 arch@localhost

ARG DIND_IMAGE=docker:dind-latest
FROM $DIND_IMAGE

ARG DOCKER_ENGINE_VERSION=0.0
ARG DOCKER_COMPOSE_VERSION=0.0.0

LABEL docker.engine.version="${DOCKER_ENGINE_VERSION}" \
  docker.compose.version="${DOCKER_COMPOSE_VERSION}"

RUN curl \
  -L https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-`uname -s`-`uname -m` \
  -o /usr/local/bin/docker-compose && \
  chmod +x /usr/local/bin/docker-compose

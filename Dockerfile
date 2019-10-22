ARG DOCKER_ENGINE_VERSION=0.0
FROM docker:${DOCKER_ENGINE_VERSION}-dind

ARG DOCKER_COMPOSE_VERSION=0.0.0

LABEL docker.engine.version="${DOCKER_ENGINE_VERSION}" \
  docker.compose.version="${DOCKER_COMPOSE_VERSION}"

# based on https://github.com/docker/compose/blob/master/Dockerfile.run

ENV GLIBC 2.28-r0

RUN apk update && apk add --no-cache bash openssl ca-certificates curl libgcc && \
    curl -fsSL -o /etc/apk/keys/sgerrand.rsa.pub https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub && \
    curl -fsSL -o glibc-$GLIBC.apk https://github.com/sgerrand/alpine-pkg-glibc/releases/download/$GLIBC/glibc-$GLIBC.apk && \
    apk add --no-cache glibc-$GLIBC.apk && \
    ln -s /lib/libz.so.1 /usr/glibc-compat/lib/ && \
    ln -s /lib/libc.musl-x86_64.so.1 /usr/glibc-compat/lib && \
    ln -s /usr/lib/libgcc_s.so.1 /usr/glibc-compat/lib && \
    rm /etc/apk/keys/sgerrand.rsa.pub glibc-$GLIBC.apk && \
    curl \
      -L https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-`uname -s`-`uname -m` \
      -o /usr/local/bin/docker-compose && \
    chmod +x /usr/local/bin/docker-compose && \
    chown 1000:1000 /usr/local/bin/docker-compose && \
    apk del curl && \
    docker-compose --version

COPY lib/docker-v1.bash /usr/local/lib/concourse-docker-compose/

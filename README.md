# concourse-docker-compose

## overview

this [docker image](https://hub.docker.com/r/snapkitchen/concourse-docker-compose) and helper library allows running [docker-in-docker](https://hub.docker.com/_/docker) with [docker-compose](https://docs.docker.com/compose/) on [concourse ci](https://concourse-ci.org)

the image also has `bash` to support the helper library

## docker hub build hooks

included in the `hooks` dir, these scripts are executed by docker hub to automatically build and push images for the docker engine versions in `docker-engine-versions`

each image will be tagged with the docker engine version used during the build, e.g. `18.06`

labels `docker.engine.version` and `docker.compose.version` also contain the docker engine and docker compose versions in the image

## bash helper lib

included in the `lib` dir is `docker-v1.bash` which is based on the [common script](https://github.com/concourse/docker-image-resource/blob/master/assets/common.sh) from the [concourse-docker-resource](https://hub.docker.com/r/concourse/docker-image-resource)

### usage

to use the helper script, run `/bin/bash` as your entrypoint and then `source` the script file (installed to `/usr/local/lib/concourse-docker-compose/${LIB_FILE}`):

```yaml
- task: run-hello-world
  image: concourse-docker-compose
  privileged: true
  config:
    platform: linux
    run:
      path: /bin/bash
      args:
      - -c
      - |
        set -e
        source /usr/local/lib/concourse-docker-compose/docker-v1.bash
        start_docker
        docker run hello-world
        stop_docker
```

#### v1 lib api

`start_docker`

- starts the docker engine
  - sanitizes control groups (cgroups) to prevent cruft from previous runs
  - times out after 120 seconds
- registers a trap handler to run `stop_docker` when the process exits

`stop_docker`

- stops the docker engine

`save_image NAME TAG DIR [FILENAME (default: image)] [ID_FILENAME (default: image-id)]`

- checks if image was already saved under `{DIR}/{FILENAME}` with a `{DIR}/{ID_FILENAME}`

- if current `image-id` matches `{DIR}/{ID_FILENAME}`, and `{DIR}/{FILENAME}` exists, does not save (no-op)

- if mismatch, or `{DIR}/{FILENAME}` is missing, saves to `{DIR}/{FILENAME}` and updates `{DIR}/{ID_FILENAME}`

  example for `docker-image`:

  ```bash
  save_image "foo/bar" "latest" "image-output"
  ```

  example for `registry-image`:

  ```bash
  save_image "foo/bar" "latest" "image-output" "image.tar" "digest"
  ```

`load_image NAME TAG DIR [FILENAME (default: image)] [ID_FILENAME (default: image-id)]`

- checks if `{DIR}/{FILENAME}` exists

  - if found, performs a `docker load` on `{DIR}/{FILENAME}`

- checks if `{DIR}/{ID_FILENAME}` exists

  - if found, tags `{DIR}/{ID_FILENAME}` as `{NAME}:{TAG}`

  example for `docker-image`:

  ```bash
  load_image "foo/bar" "build" "image-cache"
  ```

  example for `registry-image`:

  ```bash
  load_image "foo/bar" "build" "image-cache" "image.tar" "digest"
  ```

## build scripts

the script `build` in the `scripts` dir will build the image for the specified docker engine version

this can be used for building the image locally, for development or testing

e.g.:

`./scripts/build 18.06`

# license

see [LICENSE](https://github.com/Snapkitchen/concourse-docker-compose/blob/master/LICENSE)

some parts from [docker-image-resource](https://github.com/concourse/docker-image-resource) licensed under [Apache 2.0](https://github.com/concourse/docker-image-resource/blob/master/LICENSE)

# Corrade Docker Build Script
[![Docker Hub Pulls](https://img.shields.io/docker/pulls/fixedbit/corrade?style=plastic)](https://hub.docker.com/r/fixedbit/corrade) [![Build Status](https://app.travis-ci.com/FixedBit/docker-corrade.svg?branch=main)](https://app.travis-ci.com/FixedBit/docker-corrade)
## What is Corrade?

[Corrade](https://grimore.org/secondlife/scripted_agents/corrade) is an amazing Second Life bot platform by [Wizardry and Steamworks](https://grimore.org/).

There is so much it can do and too much to cover here but check out the links above for more information.

## Building

You can build this on a local Docker machine quite easily by just typing `./build.sh`

### Additional Script Commands
```
* ~~ Any of these flags may be combined ~~
* 'build.sh -n' sets no cache so it always pulls latest containers
* 'build.sh -c' sets crossbuilding between all supported Linux platforms
* 'build.sh -l' sets current build as latest
* 'build.sh -p' force pulls latest of every Docker image
* 'build.sh -u' Uploads the image to the registry
* 'build.sh -r docker-registry' Sets a docker registry
* 'build.sh -s source.sh' sets a script to source variables from
* 'build.sh -i name-of-image' overwrites the pre-set image name used for building
* 'build.sh -f Dockerfile' OPTIONAL - allows you to point this script to a different Dockerfile
```

## Running with Docker Compose
I have included an example inside "examples" but for TL;DR:

```
version: "3"

services:
  corrade:
    image: fixedbit/corrade:latest
    container_name: corrade
    tty: true
    restart: unless-stopped
    ports:
      - "54377:54377"
      - "8080:8080"
    volumes:
      - "./data/config:/config"
      - "./data/Cache:/corrade/Cache"
      - "./data/Logs:/corrade/Logs"
      - "./data/State:/corrade/State"
      - "./data/Databases:/corrade/Databases"
```
## Extra info

Contributions and feedback welcome, in world or [email](mailto:jason@fixedbit.com)!

Me in Second Life: [Coal Edge](https://my.secondlife.com/coal.edge)

Prebuilt Docker Image: [fixedbit/corrade](https://hub.docker.com/r/fixedbit/corrade)

[Latest Changes/Updates](https://github.com/FixedBit/docker-corrade/blob/main/CHANGELOG.md)
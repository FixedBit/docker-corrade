# Corrade Docker Build Script
## What is Corrade?
[![Docker Hub Pulls](https://img.shields.io/docker/pulls/fixedbit/corrade?style=plastic)](https://hub.docker.com/r/fixedbit/corrade)

[Corrade](https://grimore.org/secondlife/scripted_agents/corrade) is an amazing Second Life bot platform by [Wizardry and Steamworks](https://grimore.org/).

There is so much it can do and too much to cover here but check out the links above for more information.

## Building

```
1) Open Terminal
2) Type: ./build.sh
3) ... success?
```
This uses my custom build script which will build for your system without modification but you are free to override or change anything you wish.

Inside the script you can use certain `pre-set` overrides such as:
* "CROSS_BUILD_OVERRIDE" which accepts true or false.
* "IMAGE_UPLOAD_OVERRIDE" which accepts true or false.
* "IMAGE_NAME_OVERRIDE" which accepts any custom image name you want to use.
* "DOCKER_REGISTRY_OVERRIDE" which accepts any custom docker registry such as your own.

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
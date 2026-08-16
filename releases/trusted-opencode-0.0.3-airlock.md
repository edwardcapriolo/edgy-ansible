# Trusted-Opencode 0.0.3: Airlock

![Trusted-Opencode Airlock](assets/trusted-opencode-airlock.svg)

Trusted-Opencode `0.0.3`, codenamed **Airlock**, is about making opencode a practical isolated build room. It is a container runtime for doing real Java, C/C++, container, and cloud operations work while keeping a barrier, an airlock, between the agent and the host.

## Why Airlock?

An airlock is a controlled boundary. Agents running directly as your user inherently reach the things your user can reach: source trees, environment files, documents, sockets, caches, and credentials. Running the agent in a container does not make magic security claims, but it does make the boundary explicit. You choose the bind mounts, devices, ports, and environment variables that cross into the workspace.

This release keeps that idea even when the agent needs containers. Instead of mounting the host Docker socket, opencode starts its own rootless Docker daemon inside the container boundary. The agent can build and test with containers, while the host daemon stays outside the airlock.

## What Changed

- Builds opencode from `v1.18.15`.
- Uses the `ecapriolo/jdk-25:0.0.6` Java base images.
- Adds rootless Docker support to the `devel` and `cdevel` opencode variants.
- Adds the `cloudops` variant for Kubernetes and infrastructure workflows.
- Adds `start-rootless-docker` for one-command nested Docker startup.
- Keeps the host Docker socket out of the opencode container.
- Publishes multi-arch `amd64` and `arm64` image tags.

## Image Variants

- `ecapriolo/trusted-opencode:0.0.3-devel`
- `ecapriolo/trusted-opencode:0.0.3-cdevel`
- `ecapriolo/trusted-opencode:0.0.3-minimal`
- `ecapriolo/trusted-opencode:0.0.3-cloudops`

The `cloudops` variant is the cdevel workspace plus cloud-native tools:

- OpenTofu
- Helm
- kubectl
- kind

## Rootless Docker

The `devel` and `cdevel` images include the runtime pieces needed for Docker-in-container:

- Docker CLI and daemon packages
- Buildx
- RootlessKit
- slirp4netns
- fuse-overlayfs
- subordinate UID/GID ranges for `acoder`

Start a container with the repo entry script, then inside it run:

```sh
start-rootless-docker bash
docker run --rm hello-world
```

The verified storage driver is:

```text
fuse-overlayfs
```

## Boundary

Airlock requires the outer container runtime to provide a few kernel interfaces when you want Docker-in-Docker support:

```text
/dev/fuse
/dev/net/tun
systempaths=unconfined
net.ipv4.ip_forward=1
```

Those permissions enable rootless storage and networking for the nested daemon. They are not required when you only want the opencode workspace, Java tools, C/C++ tools, or cloud CLIs. They do not mount the host Docker socket.

## Goal

The goal is not to make a universal VM replacement. The goal is a reproducible, inspectable, open source opencode workspace that can build software, compile native code, run Java workflows, and launch test containers while keeping the host boundary explicit.

## Getting Started

Run the published image directly when you want the standard container user and a quick isolated workspace:

```sh
cd imaging/opencode
IMAGE_VARIANT=-cloudops sh enter_container.sh
```

Inside the container, start rootless Docker when you need container tests:

```sh
start-rootless-docker bash
docker run --rm hello-world
```

Use the bindmount workspace when you want the web UI, host UID/GID matching, Maven/config bind mounts, and the full `cloudops` toolset:

```sh
cd imaging/opencode/compositions/bindmount-workspace
cp .env.example .env
```

Edit `.env` for your machine. Use `id -u`, `id -g`, and `whoami` to find the values:

```text
duid=502
dgid=20
dusername=edward.capriolo
```

Then run:

```sh
docker compose up --build
```

Visit the opencode UI at:

```text
http://localhost:4097
```

Here's how we developed Airlock while peer coding with the previous version:

![opencode UI while developing Airlock](assets/opencode.png)

The compose build creates a small derived image from `trusted-opencode:0.0.3-cloudops` just for your host user, then starts opencode with your bind mounts and rootless Docker runtime settings.

## Network Egress

The compose workspace enables `net.ipv4.ip_forward=1` because rootless Docker uses RootlessKit/slirp4netns networking. Without it, the nested daemon may start but containers can fail to reach registries or the outside network.

That setting is not meant to be an egress policy. If you need tighter control, put the outer opencode container on a controlled Docker network, use an HTTP proxy, or point Docker at an internal registry/mirror. In an airgapped environment, pre-load the images or use a private registry inside the allowed network boundary instead of relying on Docker Hub.

## Recipes

Share Maven dependencies with the host:

```yaml
- ./m2:/home/${dusername}/.m2
```

This keeps the image smaller and avoids downloading the same Maven artifacts repeatedly. The tradeoff is that the host and container share a writable dependency cache, so bad files or permission mistakes can affect both sides.

Share large local model assets:

```yaml
- ./.deliverance:/home/${dusername}/.deliverance
```

Large language model assets are too expensive to duplicate into every image or workspace. Bind mounting them keeps the image practical and lets multiple containers reuse the same local model directory.

Share project workspaces:

```yaml
- ./ai-code:/ai-code
- ./ai-code:/bi-code
```

Mounting source trees keeps edits visible to both the host editor and the opencode agent. Matching the container UID/GID to the host user keeps generated files, build outputs, and cleanup manageable.

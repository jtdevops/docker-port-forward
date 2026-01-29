# Docker Port Forward

Simple port forwarding of ports not exposed by a container

![Build sidecar docker image](https://github.com/jtdevops/docker-port-forward/workflows/Build%20sidecar%20docker%20image/badge.svg)
![Build example docker image](https://github.com/jtdevops/docker-port-forward/workflows/Build%20example%20docker%20image/badge.svg)

## Installing the tool

### Option 1: Run with Docker (no local install)

Build the image (from the repo root):

```bash
docker build -t docker-port-forward .
```

Or pull the pre-built image from Docker Hub or GitHub Container Registry:

```bash
docker pull jtdev0ps/docker-port-forward
# or
docker pull ghcr.io/jtdevops/docker-port-forward
```

Run it (mount the Docker socket and expose the forward port):

```bash
docker run --rm -t \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -p 4000:4000 \
  docker-port-forward <containerid/name> <containerport> [hostport]
```

Example: forward port 80 of container `pf-test` to host port 4000:

```bash
docker run --rm -t \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -p 4000:4000 \
  docker-port-forward pf-test 80 4000
```

Alternatively, use `--net host` so the container shares the host network—no port mapping needed:

```bash
docker run --rm -t \
  -v /var/run/docker.sock:/var/run/docker.sock \
  --net host \
  docker-port-forward pf-test 80 4000
```

**Note:** The container needs access to the host Docker socket so it can create the sidecar container and network. The sidecar image is pulled from the Docker daemon. Default: `ghcr.io/jtdevops/docker-port-forward/sidecar`. Also available on Docker Hub: `jtdev0ps/docker-port-forward-sidecar`. To override, set:

```bash
-e DOCKER_PORT_FORWARD_SIDECAR_IMAGE=jtdev0ps/docker-port-forward-sidecar
# or
-e DOCKER_PORT_FORWARD_SIDECAR_IMAGE=ghcr.io/your-org/docker-port-forward/sidecar
```

**Short command via scripts:** You can run a short command (like the original Node.js app) using the wrapper scripts in the `scripts/` folder. Add `scripts` to your `PATH`, then run:

```bash
docker-port-forward pf-test 80 4000
# or with host network:
docker-port-forward --net-host pf-test 80 4000
```

See [scripts/README.md](scripts/README.md) for details (bash and Windows CMD).

**Publishing images (GitHub Actions):** All image builds are manual-only. In the [Actions](https://github.com/jtdevops/docker-port-forward/actions) tab, run:

- **Build app docker image** – builds the CLI image from the root `Dockerfile`
- **Build sidecar docker image** – builds the sidecar image
- **Build example docker image** – builds the nginx example image

Images are pushed to GitHub Container Registry (`ghcr.io/jtdevops/docker-port-forward/...`). To also push to Docker Hub, add repository secrets `DOCKERHUB_USERNAME` (e.g. `jtdev0ps`) and `DOCKERHUB_TOKEN`; the workflows will then push to Docker Hub as:

| Image | GHCR | Docker Hub |
|-------|------|------------|
| App (CLI) | `ghcr.io/jtdevops/docker-port-forward` | `jtdev0ps/docker-port-forward` |
| Sidecar | `ghcr.io/jtdevops/docker-port-forward/sidecar` | `jtdev0ps/docker-port-forward-sidecar` |
| Example (nginx) | `ghcr.io/jtdevops/docker-port-forward/example` | `jtdev0ps/docker-port-forward-example` |

### Option 2: Install globally

NPM:  
`npm install -g docker-port-forward`  
Yarn:  
`yarn global add docker-port-forward`

## How do I run the tool

Its as easy as running this inside your terminal:  
`docker-port-forward <containerid/name> <containerport> <hostport(default:4000,optional)>`

## What does this tool do?

This tool allows you to setup a port forwarding for any port inside a docker container, even when it has not been exposed.
`docker-port-forward test-container 80 6060` will expose port `80` of the container on port `6060` where you run the tool.

## How does the tool do this?

It connects first the container to a newly created network and starts a sidecar, this sidecar now has access to all the ports on the container.
Once you connect to the portforwarded port it will use `STDIO` using the docker engine api to forward the traffic over the sidecar (which starts an `socat` process) to the target container.

## Why do we need this?

Normally its not possible to gain access to a port on a running docker container without restarting it (but sometimes you dont want to), so this tool circumvents this. Alternative usecase is getting access to a containers port when you only have access to the docker engine api (this means also when the docker engine is running on another machine and you cant access any other port than the docker engine).

## Test the tool

First start a container which listens on a port but does not expose (in this case were using an nginx server, image can be found in the `example` folder):

```bash
docker run --name pf-test ghcr.io/jtdevops/docker-port-forward/example
# or from Docker Hub:
docker run --name pf-test jtdev0ps/docker-port-forward-example
```

Now start the tool (with Docker, port mapping):

```bash
docker run --rm -t -v /var/run/docker.sock:/var/run/docker.sock -p 4000:4000 jtdev0ps/docker-port-forward pf-test 80 4000
# or use ghcr.io or a local build: docker-port-forward
```

Or with host network (no port mapping):

```bash
docker run --rm -t -v /var/run/docker.sock:/var/run/docker.sock --net host jtdev0ps/docker-port-forward pf-test 80 4000
```

Or if installed globally:  
`docker-port-forward pf-test 80 4000`

You should see the following inside your terminal:

```
🔌 Connecting to pf-test...
🚀 Forwarding pf-test:80 to localhost:4000
```

When you visit now `localhost:4000` with your webbrowser you should see a nginx start page :)

## Credits

This project was forked from [iammathew/docker-port-forward](https://github.com/iammathew/docker-port-forward). Enhancements in this fork include:

- **Docker image for the CLI** — Run the tool without installing Node.js or npm; only Docker is required.
- **Wrapper scripts** — Bash and Windows CMD scripts in `scripts/` for a short command (`docker-port-forward <container> <port> [hostport]`) and optional `--net-host` for host networking.
- **Docker Hub and GHCR** — Pre-built images published to Docker Hub (`jtdev0ps/docker-port-forward`, etc.) and GitHub Container Registry; image references use default tags (no `:latest` in docs).
- **Sidecar image override** — Env var `DOCKER_PORT_FORWARD_SIDECAR_IMAGE` to use a custom sidecar image.
- **GitHub Actions** — Manual-only workflows to build and push the app, sidecar, and example images to GHCR and optionally to Docker Hub (via `DOCKERHUB_USERNAME` and `DOCKERHUB_TOKEN` secrets).
- **Run options** — Examples for port mapping (`-p`) and `--net host`; container runs with `-t` only (TTY for Ctrl+C and colored output, no stdin).

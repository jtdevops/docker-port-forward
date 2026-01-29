# Docker Port Forward wrapper scripts

These scripts run the docker-port-forward tool inside Docker so you don’t have to type long `docker run` commands. They use the same image and options (Docker socket mount, optional port mapping or host network) every time.

## What’s included

| File                   | Platform              |
|------------------------|-----------------------|
| `docker-port-forward`  | Linux / macOS (bash)  |
| `docker-port-forward.cmd` | Windows (Command Prompt) |

Both scripts do the same thing; only the shell syntax differs.

## How they work

1. **Arguments**  
   `docker-port-forward [--net-host|-n] <container> <containerport> [hostport]`  
   - `--net-host` or `-n` (optional): use host network so no port mapping is needed.  
   - `container`: container ID or name.  
   - `containerport`: port inside the container to forward.  
   - `hostport` (optional): host port to listen on; defaults to 4000.

2. **Image and run options**  
   - Image: `jtdev0ps/docker-port-forward`  
   - The container is run with: `--rm`, `-t` (TTY for Ctrl+C and colored output; no stdin), and Docker socket mounted at `/var/run/docker.sock`.  
   - Without `--net-host`: `-p hostport:hostport` is added.  
   - With `--net-host`: `--net host` is used instead.  
   - If the image isn’t present locally, it’s pulled first.

## Usage

**Linux / macOS**

```bash
# Make executable once (if needed)
chmod +x docker-port-forward

# Forward container pf-test port 80 to host port 4000
./docker-port-forward pf-test 80

# Forward to host port 6060
./docker-port-forward pf-test 80 6060

# Use host network (no port mapping)
./docker-port-forward --net-host pf-test 80 4000
./docker-port-forward -n pf-test 80
```

**Windows (Command Prompt)**

```cmd
REM Forward container pf-test port 80 to host port 4000
docker-port-forward.cmd pf-test 80

REM Forward to host port 6060
docker-port-forward.cmd pf-test 80 6060

REM Use host network
docker-port-forward.cmd --net-host pf-test 80 4000
docker-port-forward.cmd -n pf-test 80
```

## PATH setup

To run the short command from anywhere (e.g. `docker-port-forward pf-test 80`):

- **Linux / macOS:** Add the `scripts` directory to your `PATH`, or copy/symlink the script to a directory already on your `PATH` (e.g. `~/bin`).
- **Windows:** Add the `scripts` directory to your `PATH`, or copy `docker-port-forward.cmd` to a directory already on your `PATH`.

## Changing the image

Edit the `IMAGE` variable at the top of each script (e.g. to use `ghcr.io/jtdevops/docker-port-forward` instead of Docker Hub).

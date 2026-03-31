<p align="center">
  <img src="https://raw.githubusercontent.com/blackoutsecure/docker-mlat-client/main/logo.png" alt="mlat-client logo" width="200">
</p>

# docker-mlat-client

> LinuxServer.io–style containerized client forwarding Mode S messages for aircraft multilateration

[![GitHub Stars](https://img.shields.io/github/stars/blackoutsecure/docker-mlat-client.svg?style=flat-square&color=E68523&logo=github&logoColor=FFFFFF)](https://github.com/blackoutsecure/docker-mlat-client/stargazers)
[![Docker Pulls](https://img.shields.io/docker/pulls/blackoutsecure/mlat-client.svg?style=flat-square&color=E68523&logo=docker&logoColor=FFFFFF)](https://hub.docker.com/r/blackoutsecure/mlat-client)
[![GitHub Release](https://img.shields.io/github/release/blackoutsecure/docker-mlat-client.svg?style=flat-square&color=E68523&logo=github&logoColor=FFFFFF)](https://github.com/blackoutsecure/docker-mlat-client/releases)
[![Release CI](https://img.shields.io/github/actions/workflow/status/blackoutsecure/docker-mlat-client/release.yml?style=flat-square&logo=github&label=release)](https://github.com/blackoutsecure/docker-mlat-client/actions/workflows/release.yml)
[![Publish CI](https://img.shields.io/github/actions/workflow/status/blackoutsecure/docker-mlat-client/publish.yml?style=flat-square&logo=github&label=publish)](https://github.com/blackoutsecure/docker-mlat-client/actions/workflows/publish.yml)
[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg?style=flat-square)](https://www.gnu.org/licenses/gpl-3.0)

Unofficial community image for [mlat-client](https://github.com/wiedehopf/mlat-client), built with [LinuxServer.io](https://linuxserver.io/) style container patterns (s6, hardened defaults, practical runtime options) for
ADS-B multilateration workloads.

Sponsored and maintained by [Blackout Secure](https://blackoutsecure.com/).

> **Important**
> This repository is not an official LinuxServer.io image release.

## Overview

This project packages upstream [wiedehopf/mlat-client](https://github.com/wiedehopf/mlat-client) into an easy-to-run, LinuxServer.io-style container image with practical
defaults for Mode S multilateration clients.

Quick links:

- Docker Hub listing: [blackoutsecure/mlat-client](https://hub.docker.com/r/blackoutsecure/mlat-client)
- Balena block listing: [mlat-client block on Balena Hub](https://hub.balena.io/blocks/2353923/mlat-client)
- GitHub repository: [blackoutsecure/docker-mlat-client](https://github.com/blackoutsecure/docker-mlat-client)
- Upstream application: [wiedehopf/mlat-client](https://github.com/wiedehopf/mlat-client)

## Table of Contents

- [Quick Start](#quick-start)
- [Image Availability](#image-availability)
- [About The mlat-client Application](#about-the-mlat-client-application)
- [Supported Architectures](#supported-architectures)
- [Usage](#usage)
  - [Docker Compose](#docker-compose-recommended)
  - [Docker CLI](#docker-cli)
  - [Balena Deployment](#balena-deployment)
- [Parameters](#parameters)
- [Configuration](#configuration)
- [Application Setup](#application-setup)
- [Troubleshooting](#troubleshooting)
- [Release & Versioning](#release--versioning)
- [Support & Getting Help](#support--getting-help)
- [References](#references)

## Quick Start

5-minute multilateration client setup:

```bash
docker run -d \
  --name=mlat-client \
  --restart unless-stopped \
  -e TZ=Etc/UTC \
  -e MLAT_CLIENT_INPUT_CONNECT=readsb:30005 \
  -e MLAT_CLIENT_SERVER=feed.adsbexchange.com:31090 \
  -e MLAT_CLIENT_LAT=51.5 \
  -e MLAT_CLIENT_LON=-0.1 \
  -e MLAT_CLIENT_ALT=50m \
  -e MLAT_CLIENT_USER_ID=myuser \
  -e MLAT_CLIENT_RESULTS=beast,connect,readsb:30104 \
  -v mlat-client-config:/config \
  blackoutsecure/mlat-client:latest
```

For compose files, balena, and more examples, see [Usage](#usage) below.

## Image Availability

Docker Hub (Recommended):

- All images published to [Docker Hub](https://hub.docker.com/r/blackoutsecure/mlat-client)
- Simple pull command: `docker pull blackoutsecure/mlat-client:latest`
- Multi-arch support: amd64, arm64
- No registry prefix needed (defaults to Docker Hub)

```bash
# Pull latest
docker pull blackoutsecure/mlat-client:latest

# Pull specific version
docker pull blackoutsecure/mlat-client:0.4.3
```

## About The mlat-client Application

[mlat-client](https://github.com/wiedehopf/mlat-client) is a Mode S multilateration client that selectively forwards Mode S messages to a server that resolves the transmitter position by multilateration of the same message received by multiple clients.

The corresponding server code is available at [wiedehopf/mlat-server](https://github.com/wiedehopf/mlat-server).

Author and maintenance credits (upstream):

- Original author: [Oliver Jowett](mailto:oliver@mutability.co.uk) (mutability)
- Current upstream maintainer: [wiedehopf](https://github.com/wiedehopf) (Matthias Wirth)
- Upstream repository and documentation: [wiedehopf/mlat-client](https://github.com/wiedehopf/mlat-client)

## Supported Architectures

This image is published as a multi-arch manifest. Pulling `blackoutsecure/mlat-client:latest` retrieves the correct image for your host architecture.

The architectures supported by this image are:

| Architecture | Tag |
| --- | --- |
| x86-64 | amd64-latest |
| arm64 | arm64v8-latest |

## Usage

### docker-compose (recommended, [click here for more info](https://docs.linuxserver.io/general/docker-compose))

```yaml
---
services:
  mlat-client:
    image: blackoutsecure/mlat-client:latest
    container_name: mlat-client
    environment:
      - TZ=Etc/UTC
      - MLAT_CLIENT_INPUT_CONNECT=readsb:30005
      - MLAT_CLIENT_SERVER=feed.adsbexchange.com:31090
      - MLAT_CLIENT_LAT=51.5
      - MLAT_CLIENT_LON=-0.1
      - MLAT_CLIENT_ALT=50m
      - MLAT_CLIENT_USER_ID=myuser
      - MLAT_CLIENT_RESULTS=beast,connect,readsb:30104
    volumes:
      - /path/to/mlat-client/config:/config
    restart: unless-stopped
    tmpfs:
      - /tmp
      - /run
```

### docker-compose with readsb (full ADS-B + MLAT stack)

```yaml
---
services:
  readsb:
    image: blackoutsecure/readsb:latest
    container_name: readsb
    environment:
      - TZ=Etc/UTC
      - READSB_ARGS=--net --device-type rtlsdr
    volumes:
      - readsb-config:/config
      - readsb-json:/run/readsb
    ports:
      - 30003:30003
      - 30005:30005
    devices:
      - /dev/bus/usb:/dev/bus/usb
    restart: unless-stopped

  mlat-client:
    image: blackoutsecure/mlat-client:latest
    container_name: mlat-client
    depends_on:
      - readsb
    environment:
      - TZ=Etc/UTC
      - MLAT_CLIENT_INPUT_CONNECT=readsb:30005
      - MLAT_CLIENT_SERVER=feed.adsbexchange.com:31090
      - MLAT_CLIENT_LAT=51.5
      - MLAT_CLIENT_LON=-0.1
      - MLAT_CLIENT_ALT=50m
      - MLAT_CLIENT_USER_ID=myuser
      - MLAT_CLIENT_RESULTS=beast,connect,readsb:30104
    volumes:
      - mlat-config:/config
    restart: unless-stopped

volumes:
  readsb-config:
  readsb-json:
  mlat-config:
```

### docker-cli ([click here for more info](https://docs.docker.com/engine/reference/commandline/cli/))

```bash
docker run -d \
  --name=mlat-client \
  -e TZ=Etc/UTC \
  -e MLAT_CLIENT_INPUT_CONNECT=readsb:30005 \
  -e MLAT_CLIENT_SERVER=feed.adsbexchange.com:31090 \
  -e MLAT_CLIENT_LAT=51.5 \
  -e MLAT_CLIENT_LON=-0.1 \
  -e MLAT_CLIENT_ALT=50m \
  -e MLAT_CLIENT_USER_ID=myuser \
  -e MLAT_CLIENT_RESULTS="beast,connect,readsb:30104" \
  -v /path/to/mlat-client/config:/config \
  --restart unless-stopped \
  blackoutsecure/mlat-client:latest
```

### Balena Deployment

This image can be deployed to Balena-powered IoT devices using the included `docker-compose.yml` file (which contains the required Balena labels):

```bash
balena push <your-app-slug>
```

For deployment via the web interface, use the deploy button in this repository.
See [Balena documentation](https://docs.balena.io/) for details.

## Parameters

### Environment Variables (Required)

| Parameter | Description | Example |
| --- | --- | --- |
| `-e MLAT_CLIENT_LAT=` | Receiver latitude in decimal degrees | `51.5` |
| `-e MLAT_CLIENT_LON=` | Receiver longitude in decimal degrees | `-0.1` |
| `-e MLAT_CLIENT_ALT=` | Receiver altitude with unit (m or ft) | `50m` |
| `-e MLAT_CLIENT_USER_ID=` | User identifier for the MLAT server | `myuser` |

### Environment Variables (Optional)

| Parameter | Default | Description |
| --- | --- | --- |
| `-e TZ=Etc/UTC` | `Etc/UTC` | Timezone (TZ database) |
| `-e MLAT_CLIENT_INPUT_CONNECT=` | `readsb:30005` | Beast data source (host:port) |
| `-e MLAT_CLIENT_SERVER=` | `feed.adsbexchange.com:31090` | Multilateration server (host:port) |
| `-e MLAT_CLIENT_RESULTS=` | *(none)* | Results output destination(s) |
| `-e MLAT_CLIENT_UUID=` | *(none)* | UUID sent to the server |
| `-e MLAT_CLIENT_UUID_FILE=` | *(none)* | Path to UUID file |
| `-e MLAT_CLIENT_STATS_JSON=` | *(none)* | Path for stats JSON output |
| `-e MLAT_CLIENT_PRIVACY=` | `false` | Hide receiver on coverage maps |
| `-e MLAT_CLIENT_NO_UDP=` | `false` | Disable UDP transport |
| `-e MLAT_CLIENT_LOG_TIMESTAMPS=` | `true` | Print timestamps in logs |
| `-e MLAT_CLIENT_ARGS=` | *(none)* | Raw arguments (overrides individual env vars) |
| `-e MLAT_CLIENT_USER=` | `root` | Runtime user for the container |
| `-e PUID=911` | `911` | User ID for non-root operation |
| `-e PGID=911` | `911` | Group ID for non-root operation |

### Storage Mounts

| Volume | Description | Required |
| --- | --- | --- |
| `-v /config` | Configuration and persistent data | Recommended |

## Configuration

Environment variables are set using `-e` flags in `docker run` or the `environment:` section in docker-compose.

### Individual Environment Variables vs MLAT_CLIENT_ARGS

You can configure the mlat-client in two ways:

1. **Individual environment variables** (recommended): Set `MLAT_CLIENT_LAT`, `MLAT_CLIENT_LON`, etc. The container service script assembles the command-line arguments.

2. **Raw arguments**: Set `MLAT_CLIENT_ARGS` to the full argument string. This overrides the individual environment variables.

### Results Output Format

The `MLAT_CLIENT_RESULTS` variable accepts output specifications in the format:

```
format,type,address:port
```

Common examples:

| Results Value | Description |
| --- | --- |
| `beast,connect,readsb:30104` | Beast format, connect to readsb on port 30104 |
| `beast,listen,30105` | Beast format, listen on port 30105 |
| `basestation,listen,31003` | SBS/BaseStation format, listen on port 31003 |
| `beast,connect,localhost:30104` | Beast format, connect to localhost |

### Supported Receivers

- Anything that produces Beast-format output with a 12MHz clock:
  - readsb, dump1090-mutability, dump1090-fa
  - an actual Mode-S Beast
  - airspy_adsb in Beast output mode
  - Radarcape in 12MHz mode
  - Radarcape in GPS mode

## User / Group Identifiers

By default, this container runs as `root`.

Root mode (default):
- No `PUID` or `PGID` needed

Non-root mode (advanced):
- Set `MLAT_CLIENT_USER` to your username
- Provide matching `PUID` and `PGID` values
- Defaults to `911:911` if omitted

## Application Setup

The container runs mlat-client, connecting to a Beast-format data source and forwarding Mode S messages to a multilateration server.

### Key Features

- **Multilateration**: Positions resolved by correlating timestamps from multiple receivers
- **Network-only**: No hardware required — connects to readsb/dump1090 via network
- **Multiple Output Formats**: Beast, SBS/BaseStation output support
- **Automatic Reconnection**: Handles connection interruptions gracefully
- **Privacy Mode**: Option to hide receiver location on coverage maps

### Customizing Configuration

Common environment variable combinations:

```bash
# Standard ADSBexchange feed
-e MLAT_CLIENT_INPUT_CONNECT=readsb:30005
-e MLAT_CLIENT_SERVER=feed.adsbexchange.com:31090
-e MLAT_CLIENT_RESULTS=beast,connect,readsb:30104

# Custom MLAT server with privacy
-e MLAT_CLIENT_SERVER=mlat.myserver.com:31090
-e MLAT_CLIENT_PRIVACY=true

# With UUID file for persistent identity
-e MLAT_CLIENT_UUID_FILE=/config/mlat-client/uuid

# With statistics output
-e MLAT_CLIENT_STATS_JSON=/config/mlat-client/stats.json
```

For all available options, see the [mlat-client documentation](https://github.com/wiedehopf/mlat-client).

## Troubleshooting

### Container won't start or exits immediately

Check logs:

```bash
docker logs mlat-client
docker logs mlat-client --tail 50 -f  # Follow last 50 lines
```

Common causes:

- **Missing required arguments**: Ensure `MLAT_CLIENT_LAT`, `MLAT_CLIENT_LON`, `MLAT_CLIENT_ALT`, and `MLAT_CLIENT_USER_ID` are set
- **Invalid altitude format**: Use suffix `m` (metres) or `ft` (feet), e.g. `50m` or `160ft`
- **Configuration error**: Check `MLAT_CLIENT_ARGS` syntax

### Cannot connect to Beast source

Verify the Beast data source is reachable:

```bash
docker exec mlat-client nc -zv readsb 30005
```

If connection fails:

- Check that readsb/dump1090 is running and exposing Beast output on port 30005
- Verify both containers are on the same Docker network
- Check for firewall rules blocking the connection

### Cannot connect to MLAT server

Verify server connectivity:

```bash
docker exec mlat-client nc -zv feed.adsbexchange.com 31090
```

If connection fails:

- Check internet connectivity from the container
- Verify the server address and port
- The MLAT server may be temporarily unavailable

### No MLAT results

If the client connects but no positions are resolved:

- Ensure your location (`LAT`/`LON`/`ALT`) is accurate
- MLAT requires multiple receivers seeing the same aircraft — results depend on receiver density in your area
- Check that your Beast data source is providing valid timestamps
- Review logs for synchronization status

### Getting help

- Check [upstream mlat-client documentation](https://github.com/wiedehopf/mlat-client)
- Review container logs: `docker logs -f mlat-client`
- Open an issue on [GitHub](https://github.com/blackoutsecure/docker-mlat-client/issues)

## Release & Versioning

This project uses [semantic versioning](https://semver.org/):

- Releases published on [GitHub Releases](https://github.com/blackoutsecure/docker-mlat-client/releases)
- Multi-arch images (amd64, arm64v8) built automatically
- Docker Hub tags: version-specific, `latest`, and architecture-specific

Update to latest:

```bash
docker pull blackoutsecure/mlat-client:latest
docker-compose up -d  # if using compose
```

Check image version:

```bash
docker inspect -f '{{ index .Config.Labels "build_version" }}' blackoutsecure/mlat-client:latest
```

## Support & Getting Help

- Questions: [GitHub Issues](https://github.com/blackoutsecure/docker-mlat-client/issues)
- Bug Reports: Include Docker version, container logs, and reproduction steps
- Upstream Documentation: [mlat-client on GitHub](https://github.com/wiedehopf/mlat-client)
- Community: [LinuxServer.io Discord](https://linuxserver.io/discord)

Get help:

```bash
docker logs mlat-client                          # View container logs
docker exec -it mlat-client /bin/bash            # Access container shell
docker inspect blackoutsecure/mlat-client        # Check image details
```

## Sponsor & Credits

Sponsored and maintained by [Blackout Secure](https://blackoutsecure.com/)

Upstream project: [wiedehopf/mlat-client](https://github.com/wiedehopf/mlat-client)
Container patterns: [LinuxServer.io](https://linuxserver.io/)

## References

### Project Resources

| Resource | Link |
| --- | --- |
| Docker Hub | [blackoutsecure/mlat-client](https://hub.docker.com/r/blackoutsecure/mlat-client) |
| Balena Hub | [mlat-client block](https://hub.balena.io/blocks/2353923/mlat-client) |
| GitHub Issues | [Report bugs or request features](https://github.com/blackoutsecure/docker-mlat-client/issues) |
| GitHub Releases | [Download releases](https://github.com/blackoutsecure/docker-mlat-client/releases) |

### Upstream & Related

| Resource | Link |
| --- | --- |
| mlat-client | [wiedehopf/mlat-client](https://github.com/wiedehopf/mlat-client) |
| mlat-server | [wiedehopf/mlat-server](https://github.com/wiedehopf/mlat-server) |
| readsb | [wiedehopf/readsb](https://github.com/wiedehopf/readsb) |
| LinuxServer.io | [linuxserver.io](https://linuxserver.io/) |

### Technical Resources

- [Multilateration (Wikipedia)](https://en.wikipedia.org/wiki/Multilateration)
- [ADS-B Overview](https://en.wikipedia.org/wiki/Automatic_Dependent_Surveillance%E2%80%93Broadcast)
- [Docker Documentation](https://docs.docker.com/)

## License

This project is licensed under the GNU General Public License v3.0 or later -
see the [LICENSE](LICENSE) file for details.

The mlat-client application itself is also licensed under GPL-3.0-or-later. For more
information, see the [mlat-client repository](https://github.com/wiedehopf/mlat-client).

Made with ❤️ by [Blackout Secure](https://blackoutsecure.com/)

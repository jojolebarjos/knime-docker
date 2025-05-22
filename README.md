# KNIME Analytics Platform in Docker

This repository is an attempt at running the [KNIME Analytics Platform](https://www.knime.com/knime-analytics-platform), which is a desktop application, in the browser.

Note that [an official Docker image](https://hub.docker.com/r/knime/knime-full) is provided to deploy executors; these do not include the workbench.

The code is open source, available on GitHub.
The main entry point is the [`knime-sdk-setup`](https://github.com/knime/knime-sdk-setup).
As indicated in their documentation, KNIME is essentially an Eclipse plug-in.

Similar, but outdated, initiatives:

 * https://hub.docker.com/r/openkbs/knime-docker


## Getting started

The current solution is based on [Xpra](https://github.com/Xpra-org/xpra), exposing a Web remote desktop session.

```sh
docker build -t knime-docker .
docker run --rm -p 14500:14500 knime-docker
```

Connect to `0.0.0.0:14500` and run:

```sh
/opt/knime/knime
```

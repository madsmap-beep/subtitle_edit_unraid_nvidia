# Subtitle Edit for Unraid (NVIDIA, VNC, and browser UI)

This image packages the Linux x64 release of Subtitle Edit `v5.3.0-rc2`.
It starts the GUI in a virtual X display and makes it available both as VNC
and through noVNC in a web browser.

## Build

Build on the Unraid host or another Docker host:

```bash
docker build -t subtitleedit-unraid:5.3.0-rc2 .
```

The Dockerfile checks the downloaded release against its published SHA-256
digest. To use another release, update `SUBTITLEEDIT_VERSION` and
`SUBTITLEEDIT_SHA256` in the Dockerfile to the matching release and digest.

## Run

```bash
docker run -d \
  --name=SubtitleEdit \
  --gpus=all \
  -p 6080:6080 \
  -p 5900:5900 \
  -e NVIDIA_VISIBLE_DEVICES=all \
  -e NVIDIA_DRIVER_CAPABILITIES=all \
  -e VNC_PASSWORD='edit1234' \
  -v /mnt/user/appdata/subtitleedit:/config \
  -v /mnt/user/media:/data \
  --restart unless-stopped \
  subtitleedit-unraid:5.3.0-rc2
```

Open `http://UNRAID-IP:6080/vnc.html?autoconnect=true&resize=scale` for the
browser UI, or connect a VNC client to `UNRAID-IP:5900`.

`VNC_PASSWORD` is optional. If it is omitted or empty, VNC works without a
password. To use a mounted password file instead, set `VNC_PASSWORD_FILE` to
its path; the file must be readable by container UID 99. VNC passwords must
be 1-8 printable ASCII characters, as required by traditional VNC password
authentication. The no-password mode is unauthenticated; only expose either
port to trusted networks.

Subtitle Edit settings are kept in `/config`; mount your media folder at
`/data` (or use another container path) so files remain accessible after
recreating the container.

## Unraid template

Copy `unraid-template.xml` to
`/boot/config/plugins/dockerMan/templates-user/my-SubtitleEdit.xml` on Unraid,
then add it from the Docker tab's **Add Container** → **Template** menu. Build
the image first with the command above. The template requests all NVIDIA GPUs
and maps the web UI, VNC, `/config`, and `/data`.

The host must have a working NVIDIA driver and NVIDIA Container Toolkit/runtime
configured for Docker. The image sets `NVIDIA_VISIBLE_DEVICES=all` and
`NVIDIA_DRIVER_CAPABILITIES=all`; `--gpus=all` requests GPU access from Docker.
If an older Unraid NVIDIA runtime does not support `--gpus=all`, replace that
argument with `--runtime=nvidia`.

GPU access makes supported NVIDIA features and libraries available inside the
container; it does not make every Subtitle Edit operation GPU-accelerated.
The virtual desktop uses Xvfb, so its UI rendering is not NVIDIA display
rendering. Actual CUDA/NVENC/NVDEC use depends on the Subtitle Edit feature,
models, and media tools being used.

# Subtitle Edit for Unraid (NVIDIA, VNC, and browser UI)

The published image includes Subtitle Edit `v5.3.0-rc2`, its Linux runtime
dependencies, a virtual desktop, VNC, noVNC, and Xpra browser audio streaming.
GitHub Actions builds and publishes it to GitHub Container Registry whenever
the `main` branch changes.

## Install on Unraid

Use the Unraid template at `unraid-template.xml`, or pull the prebuilt image:

```bash
docker pull ghcr.io/madsmap-beep/sutitle_edit_unraid_nvidia:5.3.0-rc2
```

No local Docker build is required.

## Run manually

```bash
docker run -d \
  --name=SubtitleEdit \
  --gpus=all \
  -p 10000:10000 \
  -p 6080:6080 \
  -p 5900:5900 \
  -e NVIDIA_VISIBLE_DEVICES=all \
  -e NVIDIA_DRIVER_CAPABILITIES=all \
  -e WEB_PASSWORD='choose-a-web-password' \
  -e VNC_PASSWORD='edit1234' \
  -v /mnt/user/appdata/subtitleedit:/config \
  -v /mnt/user/media:/data \
  --restart unless-stopped \
  ghcr.io/madsmap-beep/sutitle_edit_unraid_nvidia:5.3.0-rc2
```

Open `http://UNRAID-IP:10000/` for the browser desktop **with audio**, or
`http://UNRAID-IP:6080/vnc.html?autoconnect=true&resize=scale` for noVNC.
Traditional VNC clients can connect to `UNRAID-IP:5900`.
The Xpra browser client carries the desktop audio to your browser; noVNC and
traditional VNC do not transport audio. Your browser may require a click or
the Xpra audio control to start playback.

`WEB_PASSWORD` protects the audio-enabled Xpra browser desktop. `VNC_PASSWORD`
is optional; if omitted or empty, VNC works without a password. VNC passwords
must be 1-8 printable ASCII characters, as required by traditional VNC
authentication. VNC/noVNC passwordless mode and an unset `WEB_PASSWORD` are
unauthenticated; only expose those ports to trusted networks.
To use a mounted VNC password file instead, set `VNC_PASSWORD_FILE` to its
path; the file must be readable by container UID 99.

Subtitle Edit settings are kept in `/config`; mount your media folder at
`/data` (or use another container path) so files remain accessible after
recreating the container.

## Unraid template

Copy `unraid-template.xml` to
`/boot/config/plugins/dockerMan/templates-user/my-SubtitleEdit.xml` on Unraid,
then add it from the Docker tab's **Add Container** → **Template** menu. The
template pulls the ready-to-run GHCR image and maps the audio-enabled web UI,
noVNC, VNC, `/config`, and `/data`.

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

## Published image

GitHub Actions publishes both `latest` and `5.3.0-rc2` tags to
`ghcr.io/madsmap-beep/sutitle_edit_unraid_nvidia`. If GitHub marks the package
private on first publish, open the repository's **Packages** section, select
the container package, then use **Package settings** → **Change visibility** →
**Public** so Unraid can pull it without logging in.

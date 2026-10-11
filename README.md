# Subtitle Edit for Unraid (NVIDIA, VNC, and browser UI)

The published image includes Subtitle Edit `v5.3.0-rc2`, its Linux runtime
dependencies, and the jlesage browser desktop with VNC and browser audio.
GitHub Actions builds and publishes it to GitHub Container Registry whenever
the `main` branch changes.

## Install on Unraid

Use the Unraid template at `unraid-template.xml`, or pull the prebuilt image:

```bash
docker pull ghcr.io/madsmap-beep/subtitle_edit_unraid_nvidia:5.3.0-rc2
```

No local Docker build is required.

The correct image name is `ghcr.io/madsmap-beep/subtitle_edit_unraid_nvidia:5.3.0-rc2`.
Do not use `subtitleedit-unraid:5.3.0-rc2`; that was an old local-build tag
and Docker will try (and fail) to pull it from Docker Hub.

## Run manually

```bash
docker run -d \
  --name=SubtitleEdit \
  --gpus=all \
  -p 3001:5800 \
  -p 5900:5900 \
  -e NVIDIA_VISIBLE_DEVICES=all \
  -e NVIDIA_DRIVER_CAPABILITIES=all \
  -e WEB_AUDIO=1 \
  -e VNC_PASSWORD='edit1234' \
  -v /mnt/user/appdata/subtitleedit:/config \
  -v /mnt/user/media:/data \
  --restart unless-stopped \
  ghcr.io/madsmap-beep/subtitle_edit_unraid_nvidia:5.3.0-rc2
```

Open `http://UNRAID-IP:3001/` for the browser desktop and audio.
Traditional VNC clients can connect to `UNRAID-IP:5900`.
Browser audio is streamed through the web UI on port 3001; **no extra audio
port is needed**. As with the example image, raw VNC clients on port 5900 do
not carry audio. Your browser may require a click before it allows playback.

`VNC_PASSWORD` is optional. If omitted or empty, VNC works without a password.
VNC passwords are limited to eight characters. The browser interface is
unauthenticated by default; only expose it to trusted networks or put it behind
a trusted HTTPS reverse proxy.

Subtitle Edit settings are kept in `/config`; mount your media folder at
`/data` (or use another container path) so files remain accessible after
recreating the container.

## Unraid template

Copy `unraid-template.xml` to
`/boot/config/plugins/dockerMan/templates-user/my-SubtitleEdit.xml` on Unraid,
then add it from the Docker tab's **Add Container** → **Template** menu. The
template pulls the ready-to-run GHCR image and maps the audio-enabled browser
UI, optional direct VNC port, `/config`, and `/data`.

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
`ghcr.io/madsmap-beep/subtitle_edit_unraid_nvidia`. If GitHub marks the package
private on first publish, open the repository's **Packages** section, select
the container package, then use **Package settings** → **Change visibility** →
**Public** so Unraid can pull it without logging in.

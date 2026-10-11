# Subtitle Edit for Unraid (NVIDIA, VNC, and browser UI)

The published image includes the stable Subtitle Edit `v5.2.0`, its Linux runtime
dependencies, and the jlesage browser desktop with VNC and browser audio.
GitHub Actions builds and publishes it to GitHub Container Registry whenever
the `main` branch changes.

## Install on Unraid

Use the Unraid template at `unraid-template.xml`, or pull the prebuilt image:

```bash
docker pull ghcr.io/madsmap-beep/subtitle_edit_unraid_nvidia:5.2.0
```

No local Docker build is required.

## Run manually

```bash
docker run -d \
  --name=SubtitleEdit \
  --gpus=all \
  -p 3001:5800 \
  -p 5900:5900 \
  -e USER_ID=99 \
  -e GROUP_ID=100 \
  -e NVIDIA_VISIBLE_DEVICES=all \
  -e NVIDIA_DRIVER_CAPABILITIES=all \
  -e WEB_AUDIO=1 \
  -e VNC_PASSWORD='edit1234' \
  -v /mnt/user/appdata/subtitleedit:/config \
  -v /mnt/user/media:/data \
  --restart unless-stopped \
  ghcr.io/madsmap-beep/subtitle_edit_unraid_nvidia:5.2.0
```

Open `http://UNRAID-IP:3001/` for the browser desktop and audio.
Traditional VNC clients can connect to `UNRAID-IP:5900`.
Browser audio is streamed through the web UI on port 3001; **no extra audio
port is needed**. Raw VNC clients do not carry audio.

`VNC_PASSWORD` is optional. If omitted or empty, VNC works without a password.
VNC passwords are limited to eight characters. The browser interface is
unauthenticated by default; expose it only to trusted networks or use a trusted
HTTPS reverse proxy.

## Unraid media permissions

The Unraid template defaults `USER_ID=99` and `GROUP_ID=100` (`nobody:users`),
matching standard Unraid share ownership. If the media files have different
ownership, override both values in the template's advanced settings to match
the owner and group that have write access. Recreate the container after
changing IDs. A read/write Docker mapping alone does not override host
filesystem permissions.

## Linux file picker sorting

The image now starts a D-Bus session and prefers the GTK desktop portal, matching the sortable native chooser used by gMKVExtractGUI. This is a container-side fix attempt; please update/recreate the container and check whether the file-list headers now sort. The existing jlesage base already provides both noVNC and direct VNC, so changing VNC implementations is not necessary.

## Unraid template

Copy `unraid-template.xml` to
`/boot/config/plugins/dockerMan/templates-user/my-SubtitleEdit.xml` on Unraid,
then add it from the Docker tab's **Add Container** → **Template** menu. The
template maps the browser UI, optional direct VNC, `/config`, and `/data`.

The host must have a working NVIDIA driver and NVIDIA Container Toolkit/runtime
configured for Docker. The image sets NVIDIA device/capability variables and
`--gpus=all` requests GPU access. Older Unraid NVIDIA runtimes may need
`--runtime=nvidia` instead. GPU access does not mean every Subtitle Edit
operation is GPU-accelerated; the virtual desktop uses Xvfb for UI rendering.

## Published image

GitHub Actions publishes `latest` and `5.2.0` tags to
`ghcr.io/madsmap-beep/subtitle_edit_unraid_nvidia`. If the package is private,
make it public in the repository's **Packages** → **Package settings**.

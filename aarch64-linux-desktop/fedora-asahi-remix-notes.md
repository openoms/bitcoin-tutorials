<!-- omit in toc -->
# Fedora Asahi Remix on M1 Apple Silicon Mac

<!-- TOC -->

- [KEYBASE](#keybase)
  - [build from source](#build-from-source)
  - [alternatively download the binaries](#alternatively-download-the-binaries)
  - [initialize and set kbfs dir](#initialize-and-set-kbfs-dir)
  - [compile gui](#compile-gui)
  - [start the gui](#start-the-gui)
  - [create launcher icon](#create-launcher-icon)
- [SIGNAL](#signal)
- [SIMPLEX\_CHAT](#simplex_chat)
  - [download AppImage](#download-appimage)
  - [launcher icon](#launcher-icon)
- [FIX MEDIA PLAYER](#fix-media-player)
  - [add rpmfusion repo](#add-rpmfusion-repo)
  - [install codecs](#install-codecs)
  - [vlc](#vlc)
- [Swap the Fn and Control keys](#swap-the-fn-and-control-keys)
  - [Temporary Solution](#temporary-solution)
  - [Permanent Solution](#permanent-solution)
  - [Verification](#verification)
  - [Alternative Method](#alternative-method)

<!-- /TOC -->

## KEYBASE

### build from source

```
sudo dnf install golang yarnpkg fusermount

git clone https://github.com/keybase/client
cd client

KEYBASE_BUILD_ARM_ONLY=1 ./packaging/linux/build_binaries.sh prerelease
sudo find / -name keybase-redirector
sudo ls -la /tmp/keybase_build_2024_12_26_115006/binaries/arm64/usr/bin/
sudo cp  /tmp/keybase_build_2024_12_26_115006/binaries/arm64/usr/bin/* /usr/bin/
```

### alternatively download the binaries

- <https://opensuse.pkgs.org/tumbleweed/opensuse-oss-aarch64/kbfs-6.3.1-2.3.aarch64.html.rpm>
- <https://opensuse.pkgs.org/tumbleweed/opensuse-oss-aarch64/keybase-client-6.3.1-2.3.aarch64.rpm.html>

```
wget https://ftp.lysator.liu.se/pub/opensuse/ports/aarch64/tumbleweed/repo/oss/aarch64/keybase-client-6.3.1-2.3.aarch64.rpm
wget https://ftp.lysator.liu.se/pub/opensuse/ports/aarch64/tumbleweed/repo/oss/aarch64/kbfs-6.3.1-2.3.aarch64.rpm
```

### initialize and set kbfs dir

```
keybase config set mountdir ~/kbfs
run_keybase 
```

### compile gui

```
cd shared
yarn install
yarn run package -- --arch arm64
```

### start the gui

```
/run/media/s/dev_storage/client/shared/desktop/release/linux-arm64/Keybase-linux-arm64/Keybase
```

### create launcher icon

To create a desktop icon for the Keybase application on Fedora GNOME, follow these steps:

1. Create a new .desktop file:

Open a text editor and create a new file named `keybase.desktop` in the following directory:

```bash
~/.local/share/applications/
```

2. Add the following content to the `keybase.desktop` file:

```
[Desktop Entry]
Name=Keybase
Comment=Keybase Application
Exec=/run/media/s/dev_storage/client/shared/desktop/release/linux-arm64/Keybase-linux-arm64/Keybase
Icon=/run/media/s/dev_storage/client/browser/images/icon-keybase-logo-128.png
Type=Application
Categories=Utility;
```

Make sure to replace the `Icon` path with the actual path to the Keybase icon file if it's different from what's shown above.

3. Save the file and make it executable:

```bash
chmod +x ~/.local/share/applications/keybase.desktop
```

## SIGNAL

<https://copr.fedorainfracloud.org/coprs/useidel/signal-desktop/>

```
sudo dnf copr enable useidel/signal-desktop 
sudo dnf install signal-desktop
```

## SIMPLEX_CHAT

### download AppImage

```
muvm -- $PWD/simplex-desktop-x86_64.AppImage --appimage-extract
muvm -- simplex-chat/AppRun
```

### launcher icon

```
echo "[Desktop Entry]
Name=simplex-chat-x86_64
Comment=simplex-chat-x86_64 Application
Exec=muvm -- simplex-chat/AppRun
Icon=/home/s/Pictures/icons/simplex.svg
Type=Application
Categories=Utility;" | tee ~/.local/share/applications/simplex-chat-x86_64.desktop
```

## FIX MEDIA PLAYER

### add rpmfusion repo

- <https://rpmfusion.org/Configuration>

```
sudo dnf install https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
```

### install codecs

```
sudo dnf config-manager setopt fedora-cisco-openh264.enabled=1
sudo dnf swap ffmpeg-free ffmpeg --allowerasing
```

### vlc

```
sudo dnf install vlc
```

## Swap the Fn and Control keys

To swap the Fn and Control keys on an M1 Mac running Asahi Linux Fedora, you can use the `hid_apple` kernel module option. Here's how to do it:

### Temporary Solution

For an immediate, temporary change, you can use the following command:

```bash
echo 1 | sudo tee /sys/module/hid_apple/parameters/swap_fn_leftctrl
```

This will swap the Fn and left Control keys, but the change won't persist after a reboot[6].

### Permanent Solution

To make the change permanent, follow these steps:

1. Create or edit the `hid_apple.conf` file:

```bash
sudo nano /etc/modprobe.d/hid_apple.conf
```

2. Add the following line to the file:

```
options hid_apple swap_fn_leftctrl=1
```

3. Save and exit the text editor[7][8].

4. Regenerate the initramfs to apply the changes:

```bash
sudo dracut --regenerate-all --force
```

5. Reboot your system for the changes to take effect[8].

### Verification

To verify that the module option has been correctly inserted into the initramfs, you can run:

```bash
lsinitrd /boot/initramfs-$(uname -r).img | grep modprobe.d/hid_apple.conf
```

You should see the `hid_apple.conf` file in the output[6].

### Alternative Method

Another way to apply this change is by using the `grubby` command:

```bash
sudo grubby --update-kernel=ALL --args="hid_apple.swap_fn_leftctrl=1"
```

This method updates the kernel parameters directly[6].

Remember that these changes will swap the Fn key with the left Control key. If you need to swap it with the right Control key specifically, you might need to explore additional keyboard remapping tools or custom configurations, as the `hid_apple` module doesn't provide a direct option for that[4].

Citations:

- [1] <https://www.reddit.com/r/AsahiLinux/comments/wg9v0a/swap_fn_and_ctrl_key_on_a_macbook_air_m1/>
- [2] <https://discussion.fedoraproject.org/t/how-to-swap-option-and-command-in-italian-layout/87034>
- [3] <https://github.com/AsahiLinux/docs/issues/29>
- [4] <https://discussion.fedoraproject.org/t/way-to-switch-fn-and-right-control-key/107703>
- [5] <https://superuser.com/questions/1863262/how-do-you-remap-keyboard-keys-in-linux>
- [6] <https://www.reddit.com/r/AsahiLinux/comments/18nnc5n/persistent_remap_of_ctrl_and_fn_on_fedora_asahi/>
- [7] <https://wiki.archlinux.org/title/Apple_Keyboard>
- [8] <https://discussion.fedoraproject.org/t/way-to-switch-fn-and-right-control-key/107703/6>
- [9] <https://askubuntu.com/questions/131900/how-do-i-switch-the-command-key-and-control-key-on-a-macbook-pro>
- [10] <https://superuser.com/questions/79822/how-to-swap-the-fn-use-of-function-keys-on-an-apple-keyboard-in-linux>

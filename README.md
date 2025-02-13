This script will help you to install RetroArch from a Lakka image to an already working OS LibreELEC with Kodi.

Original post: https://forum.libreelec.tv/thread/29500-libreelec-kodi-lakka-retroarch

# Gatting Started
Connect to LibreElec device by ssh.
```bash
ssh root@LibreElec
```

Once there, run the script.
```bash
wget -q -O - https://raw.githubusercontent.com/basilean/retroarch_install/refs/heads/main/retroarch_install.sh | bash
```
> It takes approx 25 minutes to complete.

Now you have a RetroArch link in your favourites, click on it and wait 10 seconds (first time takes longer).

# Hacking It
Download the script.
```bash
wget -q https://raw.githubusercontent.com/basilean/retroarch_install/refs/heads/main/retroarch_install.sh
```

Edit it.
```bash
vi retroarch_install.sh
```

```bash
VERSION=6.x-20250207-0af7dae
DIR_INSTALL=${HOME}/retroarch
DEVICE=
ARCH=
```

Run it.
```bash
bash retroarch_install.sh
```

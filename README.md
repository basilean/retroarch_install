This script will help you to install RetroArch from a Lakka image to an already working OS LibreELEC with Kodi.

Original post: https://forum.libreelec.tv/thread/29500-libreelec-kodi-lakka-retroarch

# Getting Started
Connect to LibreElec device by ssh.
```bash
ssh root@LibreElec
```

Once there, run the script.
```bash
wget -q -O - https://raw.githubusercontent.com/basilean/retroarch_install/refs/heads/main/retroarch_install.sh | bash
```
> It takes approx 25 minutes to complete.

Now you have a RetroArch link in your favourites, click on it and wait 5 seconds (first time takes longer).

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
```
> It needs to be a valid version from releases or nightly.  
> https://github.com/libretro/Lakka-LibreELEC/releases  
> https://nightly.builds.lakka.tv/latest  

```bash
DIR_INSTALL=${HOME}/retroarch
```
> Destination for retroarch.  
> Also used as temporal over installation by default.  
>> DIR_TMP=${DIR_INSTALL}/tmp

```bash
DEVICE=
ARCH=
```
> Empty DEVICE or ARCH will get it from the "/etc/release" file.

Run it.
```bash
bash retroarch_install.sh
```

# Clean to Start Over
Remove install directory.  
${DIR_INSTALL}  
> Usually: /storage/retroarch

Remove link.  
${HOME}/.config/retroarch  
> Usually: /storage/.config/retroarch

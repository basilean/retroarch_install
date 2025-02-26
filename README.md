This script will help you to install RetroArch from a Lakka image to an already working OS LibreELEC with Kodi.

Original post:  
https://forum.libreelec.tv/thread/29500-libreelec-kodi-lakka-retroarch

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

# Troubleshoot RetroArch
Edit systemd service.
```bash
vi /storage/.config/system.d/retroarch.service
```

Change this line adding arguments.
```bash
ExecStart=/storage/retroarch/retroarch -v --log-file=/tmp/retroarch.log
```

Reload systemd
```bash
systemctl daemon-reload
```

Next time you run it it will create log file.
```bash
tail /tmp/retroarch.log
```
# BIOS
I wrote this script to help download BIOS from a Internet Archive collection.
```bash
wget -q -O - https://raw.githubusercontent.com/basilean/retroarch_install/refs/heads/main/retrobios_install.py | python3
```

# Run as IAGL External Command
It came from the original post.

Create a wrapper script to handle environment variables for service.
```bash
vi  /storage/retroex.sh 
```
```bash
echo "SYSTEM=${1}" > /tmp/iagl.conf # Manual for list.
echo "ROM=${2}" >> /tmp/iagl.conf # XXROM_PATHXX

systemctl start retroarch
```

Make it executable.
```bash
chmod 755 /storage/retroex.sh
```

Change service
```bash
vi /storage/.config/system.d/retroarch.service
```
```bash
# Comment old exec line.
# ExecStart=/storage/retroarch/retroarch

# Add script output file with vars.
EnvironmentFile=/tmp/iagl.conf

# Customize retroarch init flags to your like!
ExecStart=/storage/retroarch/retroarch -L ${SYSTEM} ${ROM}
```

Remember to reload systemd
```bash
systemctl daemon-reload
```

When set external command for a list at IAGL, follow this pattern:
```bash
/storage/retroex.sh SYSTEM "ROM"
```
SYSTEM -> Whatever goes with -L indicating core to use, set it manually for that list.  
ROM -> It is replaced by iagl with rom path of your choice. Note that is important to use quotes to avoid issues with white spaces.
NOTE: XXROM_PATHXX is an IAGL meta variable representing rom path.

```bash
/storage/retroex.sh fbneo "XXROM_PATHXX"
```

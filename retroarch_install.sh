#!/bin/bash
#
# Andres Basile (https://github.com/basilean)
# GNU/GPL v3
# 
# This script will help you to install RetroArch from Lakka image
# to an already working operative system LibreELEC with Kodi.
# It takes approx 25 minutes to complete.
#
####### HELP
### Connect to device, paste the content in a file and run it.
# ssh root@LibreElec
# vi retroarch_install.sh
# bash retroarch_install.sh
#
####### SETTINGS
### Choose a Lakka version.
# Release https://github.com/libretro/Lakka-LibreELEC/releases
# VERSION=5.0
# Nightly https://nightly.builds.lakka.tv/latest
VERSION=6.x-20250207-0af7dae
#
### Target directory to install.
DIR_INSTALL=${HOME}/retroarch
#
### If DEVICE or ARCH are not set
### it will try to guess them from LibreELEC release.
DEVICE=
ARCH=
########

if [ "${#DEVICE}" -lt 1 ]; then
	echo "Guessing device..."
	DEVICE=`cut -f1 -d. /etc/release`
	echo "DEVICE = ${DEVICE}"
fi

if [ "${#ARCH}" -lt 1 ]; then
	echo "Guessing arch..."
	ARCH=`cut -f2 -d. /etc/release | cut -f1 -d-`
	echo "ARCH = ${ARCH}"
fi

echo "Defining temporal variables..."
DIR_TMP=${DIR_INSTALL}/tmp
DIR_ROOTFS=${DIR_TMP}/rootfs
DIR_START=${PWD}
TRIPLET=Lakka-${DEVICE}.${ARCH}-${VERSION}
TARFILE=${TRIPLET}.tar
if [ "${#VERSION}" -lt 14 ]; then
	TARURL=https://github.com/libretro/Lakka-LibreELEC/releases/download/v${VERSION}/${TARFILE}
else
	TARURL=https://nightly.builds.lakka.tv/latest/${DEVICE}.${ARCH}/${TARFILE}
fi

echo "--- Settings ---"
echo "DEVICE = ${DEVICE}"
echo "ARCH = ${ARCH}"
echo "VERSION = ${VERSION}"
echo "URL = ${TARURL}"
echo "DIRECTORY = ${DIR_INSTALL}"
echo "--- -------- ---"

echo "Starting..."
date

echo "Checking configuration directory doesn't exists..."
if [[ -e "${HOME}/.config/retroarch" ]]; then
	echo "${HOME}/.config/retroarch already exists."
	echo "Rename or remove it and start over."
	exit 1
fi

echo "Checking installation directory doesn't exists..."
if [[ -e ${DIR_INSTALL} ]]; then
	echo "${DIR_INSTALL} already exists."
	echo "Rename or remove it and start over."
	exit 1
fi

echo "Creating install directory..."
mkdir ${DIR_INSTALL}
echo "Checking if there is 9G of free space on target filesystem..."
echo "(only 6.5G will be used after installation)"
FREESPACE=`df -m ${DIR_INSTALL} | grep -v Filesystem | awk '{print $4}'`
if [ "${FREESPACE}" -lt 9000 ]; then
	echo "Only ${FREESPACE}M of free space available in ${DIR_INSTALL}."
	echo "Reclaim some space and start over."
	exit 1
fi

echo "Creating more directories..."
mkdir ${DIR_INSTALL}/filters
mkdir ${DIR_TMP}
mkdir ${DIR_ROOTFS}
cd ${DIR_TMP}

echo "Getting Lakka image..."
wget ${TARURL}

echo "Extracting root filesystem image..."
tar --strip-components=1 -xvf ${TARFILE} ${TRIPLET}/target/SYSTEM.md5 ${TRIPLET}/target/SYSTEM

echo "Checking that it has a valid md5..."
md5sum -c target/SYSTEM.md5
if [ $? -ne 0 ]; then
    echo "md5sum failed, bad SYSTEM content."
    exit 1
fi

echo "Attaching image to loop device..."
LOOPSYSTEM=`losetup --show -f target/SYSTEM`
echo "LOOP = ${LOOPSYSTEM}"

echo "Mounting loop device with brtfs root filesystem..."
mount ${LOOPSYSTEM} ${DIR_ROOTFS}

echo "Starting with copy..."
echo "(be patient and don't interrupt)"
echo "Copying binary..."
du -sh ${DIR_ROOTFS}/usr/bin/retroarch
cp -a ${DIR_ROOTFS}/usr/bin/retroarch ${DIR_INSTALL}

echo "Copying assets..."
du -sh ${DIR_ROOTFS}/usr/share/retroarch
cp -a ${DIR_ROOTFS}/usr/share/retroarch/assets ${DIR_INSTALL}
cp -a ${DIR_ROOTFS}/usr/share/retroarch/overlays ${DIR_INSTALL}
cp -a ${DIR_ROOTFS}/usr/share/retroarch/shaders ${DIR_INSTALL}
cp -a ${DIR_ROOTFS}/usr/share/retroarch/system ${DIR_INSTALL}

echo "Copying cores..."
du -sh ${DIR_ROOTFS}/usr/lib/libretro
cp -a ${DIR_ROOTFS}/usr/lib/libretro ${DIR_INSTALL}/cores

echo "Copying libretro database..."
du -sh ${DIR_ROOTFS}/usr/share/libretro-database
cp -a ${DIR_ROOTFS}/usr/share/libretro-database ${DIR_INSTALL}/database

echo "Copying filter..."
du -sh ${DIR_ROOTFS}/usr/share/*_filters
cp -a ${DIR_ROOTFS}/usr/share/video_filters ${DIR_INSTALL}/filters/video
cp -a ${DIR_ROOTFS}/usr/share/audio_filters ${DIR_INSTALL}/filters/audio

echo "Syncing filesystem..."
sync

echo "Creating a systemd service for RetroArch..."
cat <<EOF > ${HOME}/.config/system.d/retroarch.service
[Unit]
Description=Retroarch
After=network-online.target graphical.target
Requires=graphical.target
Wants=network-online.target

[Service]
EnvironmentFile=/usr/lib/kodi/kodi.conf
ExecStartPre=systemctl stop kodi
ExecStart=${DIR_INSTALL}/retroarch
ExecStopPost=systemctl start kodi
TimeoutStopSec=10
Restart=no
StartLimitInterval=0
LimitNOFILE=16384

[Install]
WantedBy=kodi.target
EOF

echo "Reloading systemd daemon to get changes..."
systemctl daemon-reload

echo "Disabling retroarch service..."
echo "(it will be started on demand by wrapper script)"
systemctl disable retroarch

echo "Creating a wrapper script..."
echo "(it will be executed from kodi)"
cat <<EOF > ${DIR_INSTALL}/retroarch.py
from xbmc import executebuiltin
from subprocess import run

executebuiltin('Notification(RetroArch, Loading..., 5000, ${DIR_INSTALL}/assets/xmb/monochrome/png/retroarch.png)')
run(["/usr/bin/systemctl", "start", "retroarch"])
EOF

echo "Creating a favorite shortcut..."
echo "(this will execute script from kodi)"
xml ed \
	-L \
	-s "/favourites" -t elem -n "favourite" -v "RunScript(${DIR_INSTALL}/retroarch.py)" \
	-i "/favourites/favourite[last()]" -t attr -n "name" -v "RetroArch" \
	-i "/favourites/favourite[last()]" -t attr -n "thumb" -v "${DIR_INSTALL}/assets/xmb/monochrome/png/retroarch.png" \
	${HOME}/.kodi/userdata/favourites.xml

echo "Creating symbolic link to installed directory..."
ln -s ${DIR_INSTALL} ${HOME}/.config/retroarch

echo "Cleaning..."
umount ${DIR_ROOTFS}
losetup -d ${LOOPSYSTEM}
rm -r ${DIR_TMP}
cd ${DIR_START}

echo "Ending..."
date

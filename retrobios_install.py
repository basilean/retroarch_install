#!/usr/bin/python3
#
# Andres Basile (https://github.com/basilean)
# GNU/GPL v3
# 
# Install retroarch BIOS roms from Internet Archive collection
#
from os import environ, path, makedirs
from shlex import split
from urllib.request import Request, urlopen
from hashlib import md5
from multiprocessing import Pool, cpu_count

INSTALL = environ["HOME"] + "/retroarch/system"
ARCHIVE = "https://archive.org/download/retroarch_bios"
LIST = "https://raw.githubusercontent.com/libretro/libretro-database/refs/heads/master/dat/System.dat"
PROCS = cpu_count() * 4

def get(url):
    print("Getting:", url)
    try:
        response = urlopen(url, timeout=5)
    except Exception as err:
        print(err, url)
        return
    return response.read()

def save(arr):
    [url, romfile, md5sum] = arr
    content = get(url)
    if not content:
        return
    if md5sum != None:
        md5check = md5(content).hexdigest()
        if md5sum != md5check:
            print("Error md5sum:", url, md5sum, md5check)
            return
    folder = path.dirname(romfile)
    if not path.exists(folder):
        try:
            makedirs(folder)
        except Exception as err:
            print(err, folder)
            return
    try:
        print("Saving:", romfile)
        file = open(romfile, 'wb')
        file.write(content)
    except Exception as err:
        print(err, romfile)
    else:
        file.close()

print("Install directory:", INSTALL)
print("RetroArch BIOS list:", LIST)
print("Internet Archive collection", ARCHIVE)
print("Process:", PROCS)
print()

content = get(LIST)
if not content:
    print("Can't continue without a list.")
    quit()
content = content.decode('utf8')
romlist = []
for line in content.splitlines():
    col = split(line, posix=False)
    if len(col) == 0 or col[0] != "rom":
        continue
    url = ARCHIVE + '/' + path.basename(col[3])
    romfile = INSTALL + '/' + col[3]
    md5sum = None
    for i in range(4, len(col)):
        if col[i] == "md5":
            md5sum = col[i + 1]
            break
    romlist.append([url, romfile, md5sum])

pool = Pool(processes=PROCS)
pool.map(save, romlist)

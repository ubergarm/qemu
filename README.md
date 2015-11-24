ubergarm/qemu
===
Forked from [tianon/qemu](https://github.com/tianon/dockerfiles/tree/master/qemu)

### Overview

Docker image to run arm executables or chroot into a target arm root file system image.

### Requirements

Docker Host kernel needs `CONFIG_BINFMT_MISC` enabled or module loaded. You can check this with:

    grep BINFMT /usr/src/linux-headers-$(uname -r)/.config

If you need to install the module do:

    sudo modprobe binfmtmisc

### Usage

From inside the directory with the ARM executables:

	$ docker run -it --rm \
	      -v $(pwd):/home/arm
	      ubergarm/qemu /bin/bash

Now inside the container:

    $ cd /home/arm
    $ ./my_arm_binary

To chroot into an ARM image:

    # mount image loopback from Docker host
    $ sudo fdisk -lu ubuntu-14.04lts-server-odroid-xu3-20150725.img 
    Disk ubuntu-14.04lts-server-odroid-xu3-20150725.img: 3384 MB, 3384803328 bytes
    255 heads, 63 sectors/track, 411 cylinders, total 6610944 sectors
    Units = sectors of 1 * 512 = 512 bytes
    Sector size (logical/physical): 512 bytes / 512 bytes
    I/O size (minimum/optimal): 512 bytes / 512 bytes
    Disk identifier: 0x0003f9f7
                                            Device Boot      Start         End      Blocks   Id  System
    ubuntu-14.04lts-server-odroid-xu3-20150725.img1            4096      208895      102400    c  W95 FAT32 (LBA)
    ubuntu-14.04lts-server-odroid-xu3-20150725.img2          208896     6610943     3201024   83  Linux

    $ mkdir target_fs
    $ sudo mount -t auto -o loop,offset=$((208896*512)) ubuntu-14.04lts-server-odroid-xu3-20150725.img ./target_fs
    $ ls ./target_fs
    bin   dev  home  lost+found  mnt  proc  run   srv  tmp  var
    boot  etc  lib   media       opt  root  sbin  sys  usr

    # start qemu container with volume mounted
	$ docker run -it --rm \
	      -v $(pwd)/target_fs:/target_fs
	      ubergarm/qemu /bin/bash
    # put qemu-arm-static in place if necessary
    cp /usr/bin/qemu-arm-static /target_fs/usr/bin
    # go directly to jail do not pass go ;)
    chroot /target_fs/
    # try it out!
    $ uname -a
    Linux e9a210200d9c 3.10-2-amd64 #1 SMP Debian 3.10.7-1 (2013-08-17) armv7l armv7l armv7l GNU/Linux

### Conclusion

If you want to automate builds or do consistent work between an ARM target hardware and a x86-64 dev/build system then binfmtmisc, qemu, and chroot seem like the way to go.

Also I've seen other similar images, it may be possible to build a *very* tiny Docker image with just qemu-arm-static and /usr/share/binfmts/qemu-arm to speed up builds e.g. [philipz/docker-arm-circleci](https://github.com/philipz/docker-arm-circleci).

### TODO:

1. Check about fixing / suppressing: `qemu: Unsupported syscall: 374` error.
2. Setup Docker Hub trusted build.


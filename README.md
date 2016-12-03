# livesys

###Rolling your own LiveUSB/LiveCD!

With this you can also:

1. Compress the OS
2. Toggle Persistence On/Off
3. Switch Profiles

---

Basically, the way it works is: 

When you start your OS, there will be multiple File Systems stacked on top of each other. They are flattened together so the OS just sees 1 FS like normal. (Think transparent papers with files drawn on them. That's what the OS will see. The higher the layer, the higher the precedence.)

With this, you can create many layers, and even temporary layers, which only exist in memory for one session.

---

Basically, the steps (for every distro) are:

0. __Install File Systems__ ................................. Layered FS, Compressed FS, Temporary FS

1. __Prepare the OS Image__ .............................. Compress it (optional)

2. __Rebuild the Boot Image__ ................................ to include this Script -- and the kernel/modules it needs

3. __Reinstall Boot Loader__ ....................................... to point to the Boot Image

---

Each distro is slightly different. The 2 main components are:

1. The Script
2. The Bootloader Entry

Really, the only difference is how to install it.

---

###Arch Linux

1. Install File Systems

```
pacman -S squashfs overlay
```
```
modprobe squashfs overlay
```

2. Prepare OS Image

Make a layered fs with your root fs on the bottom, and an empty folder on the top.

```
mkdir {/.image,/.empty,/.work}
```
```
mount -n -t overlay OS_Image -o lowerdir=/,upperdir=/.empty,workdir=/.work /.image
```

Now we virtually have a copy of your root fs. 
 
 - We can safely work on this as an image of the OS, without having to actually touch it or take up space. 

We need to modify/delete some system files from the image so it will boot.

 - What's neat about overlay fs is that it already does some of this for us, like deleting /proc/*

```
rm -rf /.image/etc/mtab
```
```
echo ${MOUNT_LIVESYSTEM} > /.image/etc/fstab
```

Finally, we can compress the image

```
squashfs /.image/ /.image.fs
```

3. Rebuild the Boot Image

Here's where we install the livesystem script. 

Each distro has a boot image tool. 
For Arch Linux, use Dracut.

```
pacman -S dracut
```

Install the livesystem:
```
cp install ...
```
```
cp hook ...
```
```
cp preset ...
```

Rebuild the boot image.

```
dracut ...
```

4. Reinstall the Boot Loader

We need a boot loader. 
GRUB is a good choice.

```
pacman -S grub
```

Install our bootloader entry

```
cat grub ...
```

Install the bootloader to the USB

```
grub-install ...
```

---
##Dependencies

1. Overlay / OverlayFS
2. SquashFS
3. TmpFS

---
##Glossary

1. InitRAMFS -> Initial RAM FileSystem -> What the bootloader boots to initially, to set up Linux. (It itself is actually a minimal linux image.)

2. Grub -> Boot Loader -> The entry point of the system. It selects the OS from a disk and loads it to run.

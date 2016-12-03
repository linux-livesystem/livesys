# livesys

###Rolling your own LiveUSB/LiveCD!

With this you can also:

1. Compress the Core OS
2. Toggle Persistence On/Off
3. Switch Profiles

---

Basically, the steps (for every distro) are:

0. __Install Dependencies__ ................................. Layered FS, Compressed FS, Temporary FS

1. __Initialize the OS Image__ .............................. Compress it (optional)

2. __Rebuild the InitRAMFS__ ................................ to include the LiveSYSTEM Script -- and the kernel/modules it needs

3. __Reinstall Grub__ ....................................... to point to the Initramfs

---

Each distro is slightly different. The 2 main components are:

1. The Script
2. The Grub Entry

---

##Terminology

1. InitRAMFS -> Initial RAM FileSystem -> What the bootloader boots to initially, to set up Linux. (It itself is actually a minimal linux image.)

2. Grub -> Boot Loader -> The entry point of the system. It selects the OS from a disk and loads it to run.

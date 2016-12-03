# livesys

###Rolling your own LiveUSB/LiveCD!

With this you can also:

1. Compress the Core OS
2. Toggle Persistence On/Off
3. Switch Profiles

---

Basically, the steps (for every distro) are:

0. __Install Dependencies__

 a. Layered FS
 b. Compressed FS
 c. Temporary FS

1. __Initialize the OS Image__
 
 a. Compress it (optional)

2. __Rebuild the InitRAMFS__

 b. To include the LiveSYSTEM Script -- and the kernel/modules it needs

3. __Reinstall Grub__

 a. To point to the Initramfs

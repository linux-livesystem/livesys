# livesys

###Rolling your own LiveUSB/LiveCD!

With this you can also:

1. Compress the Core OS
2. Toggle Persistence On/Off
3. Switch Profiles

---

Basically, the steps (for every distro) are:

0. Install Dependencies



1. Initialize the OS Image
 
 a. Compress it (optional)

2. Rebuild the InitRAMFS

 b. To include the LiveSYSTEM Script -- and the kernel/modules it needs

3. Reinstall Grub

 a. To point to the Initramfs

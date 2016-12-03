#/bin/sh -e

SETTING_DISTRO=$(getarg distro=);	if [ -z "$SETTING_DISTRO" ]; then
SETTING_DISTRO=Fedora/22/Workstation;	fi

SETTING_PROFILE=$(getarg profile=);	if [ -z "$SETTING_PROFILE" ]; then
SETTING_PROFILE=default;		fi

SETTING_USE_RAM=$(getarg noram=);	if [ -z "$SETTING_USE_RAM" ]; then
SETTING_USE_RAM=true;			fi

SETTING_SESSION=$(getarg session=);	if [ -z "$SETTING_SESSION" ]; then
SETTING_SESSION=ro;			fi



dev_root=${root#block:}			#/dev/disk/by-label/SD-LIVESYSTEM
mnt_root=/sysroot
opt_root=rw,relatime			#rw,noatime,nodiratime
opt_live=rw				#nosuid,nodev,data=writeback



err_out() {
echo $1; dmesg|tail; sleep 30
}

grep -q $mnt_root /proc/mounts ||
panic "$mnt_root does not seem to be mounted, check /proc/mounts"

modprobe squashfs
modprobe loop
modprobe overlay



mnt_live="/livesysroot/"
mkdir -p $mnt_live

echo "Move the real root to $mnt_live"
umount $mnt_root
#tune2fs -O ^has_journal $dev_root
#tune2fs -o journal_data_writeback $dev_root
mount -o $opt_root -o $opt_live	\
	$dev_root		\
	$mnt_live



if [ ! -d "${mnt_live}/dist/${SETTING_DISTRO}" ]; then
	echo "distro ${SETTING_DISTRO} missing. Falling back to default."
	SETTING_DISTRO=$DEFAULT_DISTRO
fi
echo "Selected distro: ${SETTING_DISTRO}"

if [ ! -d "${mnt_live}/dist/${SETTING_DISTRO}/1_profile/${SETTING_PROFILE}" ]; then
        echo "profile ${SETTING_PROFILE} missing. Falling back to default."
        SETTING_PROFILE=$DEFAULT_PROFILE
        mkdir -p "${mnt_live}/dist/${SETTING_DISTRO}/1_profile/${SETTING_PROFILE}/session.rw.fs"
fi
echo "Selected profile: ${SETTING_PROFILE}"



dir_dist="${mnt_live}/dist/${SETTING_DISTRO}/"
dir_prof="${dir_dist}/1_profile/${SETTING_PROFILE}/"
dir_sess="${dir_prof}/session.rw.fs"

mkdir -p					\
	$mnt_live/tmp/.fs			\
	$mnt_live/var/.fs

mkdir -p					\
        $mnt_live/mnt/.fs/0/ro/ram		\
        $mnt_live/mnt/.fs/0/ro/disk		\
	$mnt_live/mnt/.fs/1/ro/cartridge	\
        $mnt_live/mnt/.fs/1/rw/session



echo "Mount tmpfs"
mount -n -t tmpfs tmpfs $mnt_live/tmp
test $? -ne 0 && err_out "Failed to mount tmpfs"

if [ "$SETTING_USE_RAM" == true ];
then
	cmd_copy="rsync -a --progress"
else
	cmd_copy="ln -s"
fi

$cmd_copy				\
	$dir_dist/0_stock/ram.ro.fs	\
	$mnt_live/tmp/ram.ro.fs
		


echo "Mount squashfs on [0][ro][ram]"
mount -t squashfs 			\
	$mnt_live/tmp/ram.ro.fs		\
	$mnt_live/mnt/.fs/0/ro/ram
test $? -ne 0 && err_out "Failed to mount squashfs on .../ram"

echo "Mount squashfs on [0][ro][disk]"
mount -t squashfs 			\
	$dir_dist/0_stock/disk.ro.fs	\
	$mnt_live/mnt/.fs/0/ro/disk
test $? -ne 0 && err_out "Failed to mount squashfs on .../disk"



# TODO: Cartridge



if [ "$SETTING_SESSION" == "ro" ];
then
	fs_var=$mnt_live/tmp/var/.fs
	fs_rw=$mnt_live/tmp/.fs
	fs_ro=$dir_sess
else
	fs_var=$mnt_live/var/.fs
	fs_rw=$dir_sess
	fs_ro=$mnt_live/tmp/.fs
fi

mkdir -p $fs_rw $fs_ro $fs_var
rm -rf $fs_var/{.*,*}



echo "Unite on $mnt_root"
mount -n -t overlay LIVESYSTEM \
-o $opt_root \
-o\
 workdir=$fs_var\
,upperdir=$fs_rw\
,lowerdir=$fs_ro\
:$mnt_live/mnt/.fs/0/ro/ram\
:$mnt_live/mnt/.fs/0/ro/disk\
 $mnt_root
test $? -ne 0 && err_out "Failed to mount overlay on $mnt_root"



cat /proc/mounts	>	$mnt_live/var/.fs.log
df 			>> 	$mnt_live/var/.fs.log
free			>> 	$mnt_live/var/.fs.log
cat /proc/meminfo 	>>	$mnt_live/var/.fs.log
# NixOS for Turris routers

This repository contains nix flake to get NixOS running on Turris routers.

Using NixOS on router has few shortcomings, and you should know about them right
away so here is a list of issues you should expect:

* NixOS is pretty memory hungry. There are few reasons for this such as Systemd
  and specially Journald as those simply required more memory than other
  alternatives. But but but... The biggest issue is NixOS itself. The wide range
  of configuration options in NixOS result in pretty significant memory being
  required on evaluation. The peak is around 2 GB and thus device with 512 MB is
  pretty much screwed. Thankfully Nix is not using that memory most of the time,
  and thus we can use swap without hampering the performance that much.
* Firewall configuration right now expects at most one NAT network thus forget
  about multiple networks. There can't be dedicated network for you IOT devices
  or for your guests.
* Hostapd configuration is pretty stupid and is prepared pretty much only for
  single Wi-Fi card with single wireless network. Forget about multiple Wi-Fi
  networks.

**Warning**: This repository required Nix with flakes support thus update your
Nix to the latest version and allow flakes.


## Turris Mox

Deploying NixOS to the Turris Mox is pretty easy and fast. The advantage is that
aarch64 packages cache is provided by official Hydra builds.

At minimum, you should use micro SD card with size 8 GB. It is highly suggested
to use some high quality one as we have to use it for swap and that can reduce
lifetime a lot and kill the low quality one very fast. 

### Prepare the SD card

You need to format the SD card first. The GPT is suggested as the partition
table. You can use only one partition that should be formatted with BTRFS. The
important thing is to set label `NixTurris` so boot can locate the correct
parition by it.

It is up to you which tool are you going to use. The instructions here are going
to be for GNU Parted. The following shell log should give you an idea of what
you should do to get the correct layout:

```
~# parted /dev/mmcblk1
(parted) mktable gpt
(parted) mkpart NixTurris 0% 100%
(parted) set 1 boot on
(parted) quit
~# mkfs.btrfs /dev/mmcblk1p1
```

Next we need the initial system tarball to unpack to the SD card. Add nixturris
repository to your local Nix registry and build it. The image is cross compiled
in this case (unless you are running on Aarch64 platform). You can also build it
natively and this is discussed in the chapter "Native build using Qemu" in this
document.

```
~$ nix registry add nixturris git+https://git.cynerd.cz/nixturris
~$ nix build nixturris#crossTarballMox
```

The last step is to unpack the tarball to the SD card.

```
~# mkdir -p mnt
~# mount /dev/mmcblk1p1 mnt
~# tar -xf result/tarball/nixos-system-aarch64-linux.tar.xz -C mnt
~# umount mnt
~# eject /dev/mmcblk1
```

Now you can take this micro SD card and insert it to your Mox. Before you start
it you should also check the following chapter as it won't most likely boot
unless you modify the default boot environment.

### System fails to boot due to invalid initrd

The issue is caused by initrd start being overwritten by kernel image's tail.

The kernel image in NixOS can be pretty large and default Mox's configuration
expects kernel of maximum size 48MB. To increase this to 64MB you have to use
serial console and run:

```
setenv ramdisk_addr_r 0x9000000
saveenv
```

### Know issues with Turris Mox support without known fix for now

* Router won't reboot by software. Power cycle is required.
* Access to the serial number and other crypto functionalities seems to not work


## Turris Omnia

### Botting from the USB

Requires updated U-Boot!

```
run usb_boot

setenv boot_targets usb0 mmc0 nvme0 scsi0 pxe dhcp
saveenv
boot
```

## Updating / rebuilding NixOS and pushing update

The suggested way to update NixOS on Turris is to build system on more powerful
device and push only resulting build to the device. The reason for this are
memory requirements for Nix itself. NixOS and its packages repository evaluation
consumes a lot of memory and thus doing that on different PC is just faster.

Prepare directory where you are going to be managing your Turris device(s) and
paste this `flake.nix` file in it:

```
{
  description = "Turris system management flake";

  inputs = {
    nixturris = {
      url = "git+https://git.cynerd.cz/nixturris";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, flake-utils, nixturris }:
    with flake-utils.lib;
    {
      nixosConfigurations = let 

        turrisSystem = board: hostname: {
          ${hostname} = nixturris.lib.nixturrisSystem {
            nixpkgs = nixpkgs;
            board = board;
            modules = [
              # Place for your modules
            ];
          };
        };

      in
        turrisSystem "mox" "moxhost" //
        turrisSystem "omnia" "omniahost";

    };
}
```

**TODO** describe here how to generate key, sign build and distribute it to the
device.

To update system before build run `nix flake update`. To update system 


## Updating / rebuilding NixOS on device

To rebuild NixOS directly on device something like 2GB of memory is required.
This pretty much is covered only by Turris Omnia 2G version and even that might
not be enough. Thus if you want to rebuild NixOS on the device you need the
swap. There is in default configure zram swap but that won't be enough. It is
highly suggested to create swap file of something like 2GB or 4GB size.

The creation and first addition of swap can be done like this (this expects that
used file-system is BTRFS):

```
sudo truncate -s 4G /run/swap
sudo chattr +C /run/swap
sudo btrfs property set /run/swap compression none
sudo chmod 600 /run/swap
sudo mkswap /run/swap
sudo swapnon -p 0 /run/swap
```

Few notes here... Swap file is created by root and set to be accessible only by
root. For BTRFS the copy-on-write functionality is disabled and compression for
it. The swap itself is then added with lowest priority to prefer zram swap and
thus reduce real swap usage.

Do not forget to add this swap file to your NixOS configuration so it is added
on every boot.

Then you can pretty much manage it as any other NixOS device using
`nixos-rebuild` script running directly on the device, just very slowly.


## Native build using Qemu

This document references cross compilation in default but there are good reasons
for not using it. It can be broken much more often for some packages. It also
requires complete rebuild when later updating natively on the platform as cross
build is just not compatible with native build in Nix.

To get native build work you need the Nix with ability to run aarch64 binaries.
That is in general option `extra-platform` with value `aarch64-linux` for Turris
Mox and `armv7l-linux` for Turris Omnia. To actually allow access to the
emulator you need something like `extra-sandbox-paths` with value such as
`/usr/bin/qemu-aarch64` (for Turris Mox) or `/usr/bin/qemu-arm` (for Turris
Omnia). This way you can build aarch64 or armv7l package on other platforms.
With this setup you should be able to build tarball natively and instead of
`.#crossTarball*` you can now use just `.#tarbal*`.

## Custom tarball or system build

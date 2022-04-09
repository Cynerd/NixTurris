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


## Turris Mox

Deploying NixOS to the Turris Mox is pretty easy and fast. The advantage is that
aarch64 packages cache is provided by official Hydra builds.

At minimum, you should use micro SD card with size 8 GB. It is highly suggested
to use some high quality one as we have to use it for swap and that can reduce
lifetime a lot and kill the low quality one very fast. 

### Prepare the SD card

You need to format the SD card first. The GPT is suggested as the partition
table. You should create two partitions. The second partition is going to be
Swap that should be at least 2GB but 4GB would be better. The first partition
can take the rest of the space and should be formated to the BTRFS.

It is up to you which tool are you going to use. The instructions here are going
to be for GNU Parted. The following shell log should give you an idea of what
you should do to get the correct layout:

```
~# parted /dev/mmcblk1
(parted) mktable gpt
(parted) mkpart NixTurris 0% -4G
(parted) set 1 boot on
(parted) mkpart NixTurrisSwap -4G 100%
(parted) set 2 swap on
(parted) quit
~# mkfs.btrfs /dev/mmcblk1p1
~# mkswap /dev/mmcblk1p2
```

Next we need the initial system tarball to unpack to the SD card. For this you
need the Nix with flake support be available on your system with ability to run
aarch64 binaries. That is in general option `extra-platform` with value
`aarch64-linux` and to actually allow access to the interpreter you need
something like `extra-sandbox-paths` with value such as `/usr/bin/qemu-aarch64`.
This way you can build aarch64 package on other platforms. If you are running on
aarch64 then of course you do not have to do this. With all that setup you
should be able to build tarball by navigating to this directory.

```
~$ nix registry add nixturris git+https://git.cynerd.cz/nixturris
~$ nix build nixturris#tarball-mox
```

The last step is to unpack the tarball to the SD card.

```
~# mount /dev/mmcblk1p1 mnt
~# tar -xf result/tarball/nixos-system-aarch64-linux.tar.xz -C mnt
~# umount mnt
~# eject /dev/mmcblk1
```

Now you can take this micro SD card and insert it to your Mox.

#!/usr/bin/env bash
set -eu

die() {
	echo "${0##*/}:" "$@" >&2
	exit 1
}

[ -n "$TURRIS_BOARD" ] || die "Missing TURRIS_BOARD"
[ -n "$TURRIS_FIRMWARE" ] || die "Missing TURRIS_FIRMWARE"
[ "$(id -u)" == 0 ] || die "It is required to run this script as root"



flash() {
	local flashing="$1"
	local part="$2"
	local image="$3"

	[ -c "/dev/$part" ] || \
		die "/dev/$part is missing!"

	echo "Checking $flashing..."

	# Note: The write seems to be alligned to page and thus there are bytes at
	# the end of the mtd device that are no in image.
	# TODO: this check for some reason sometimes decides that it is not the same
	# but it is!
	if cmp -sn "$(stat -c '%s' "$image")" "/dev/${part}ro" "$image"; then
		echo "Partition with $flashing was up to date already."
	else
		local response
		read -r -p "Do you want to reflash $flashing? Y/n: " response
		if [[ "$response" =~ ^(y|Y|)$ ]]; then
			echo "Flashing $flashing partition: /dev/$part"
			# TODO we might not have to erase and always start from beginning.
			# By comparing and locating offset we might continue write after
			# failure (which happpens regularlly).
			flash_erase "/dev/$part" 0 0 || \
				die "Initial erase of '$flashing' partition (/dev/$part) failed!"
			nandwrite "/dev/$part" "$image" || \
				die "Flashing '$flashing' partition (/dev/$part) failed!"
		fi
	fi
}

case "$TURRIS_BOARD" in
	mox)
		flash "secure firmware" "mtd0" "$TURRIS_FIRMWARE/secure-firmware.bin"
		flash "U-Boot" "mtd1" "$TURRIS_FIRMWARE/uboot"
		flash "rescue system" "mtd3" "$TURRIS_FIRMWARE/rescue"
		# TODO possibly flash dtb to mtd4
		;;
	omnia)
		flash "U-Boot" "mtd0" "$TURRIS_FIRMWARE/uboot"
		flash "rescue system" "mtd1" "$TURRIS_FIRMWARE/rescue"
		;;
	*)
		die "Unsupported board: $TURRIS_BOARD"
		;;
esac

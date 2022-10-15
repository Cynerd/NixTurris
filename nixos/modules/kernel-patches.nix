{ config, lib, pkgs, ... }:

with builtins;
with lib;

{
  config = {
    # Kernel patches from Turris OS
    boot.kernelPatches = map (p: {
      name = toString p;
      patch = p;
    }) [
      ./kernel-patches/0001-net-dsa-mv88e6xxx-disable-ATU-violation.patch
      ./kernel-patches/0002-dt-bindings-Add-slot-power-limit-milliwatt-PCIe-port.patch
      ./kernel-patches/0003-PCI-pci-bridge-emul-Set-position-of-PCI-capabilities.patch
      ./kernel-patches/0004-PCI-mvebu-Use-devm_request_irq-for-registering-inter.patch
      ./kernel-patches/0005-PCI-mvebu-Dispose-INTx-irqs-prior-to-removing-INTx-d.patch
      ./kernel-patches/0006-PCI-Assign-PCI-domain-by-ida_alloc.patch
      ./kernel-patches/0007-PCI-mvebu-Fix-endianity-when-accessing-pci-emul-brid.patch
      ./kernel-patches/0008-ARM-dts-armada-38x-Fix-assigned-addresses-for-every-.patch
      ./kernel-patches/0009-dt-bindings-PCI-mvebu-Update-information-about-error.patch
      ./kernel-patches/0010-PCI-mvebu-Implement-support-for-interrupts-on-emulat.patch
      ./kernel-patches/0011-ARM-dts-armada-38x.dtsi-Add-node-for-MPIC-SoC-Error-.patch
      ./kernel-patches/0012-PCI-pciehp-Enable-DLLSC-interrupt-only-if-supported.patch
      ./kernel-patches/0013-PCI-pciehp-Enable-Command-Completed-Interrupt-only-i.patch
      ./kernel-patches/0014-PCI-mvebu-Add-support-for-PCI_EXP_SLTSTA_DLLSC-via-h.patch
      ./kernel-patches/0015-PCI-mvebu-use-BIT-and-GENMASK-macros-instead-of-hard.patch
      ./kernel-patches/0016-PCI-mvebu-For-consistency-add-_OFF-suffix-to-all-reg.patch
      ./kernel-patches/0017-PCI-aardvark-Add-support-for-PCI-Bridge-Subsystem-Ve.patch
      ./kernel-patches/0018-PCI-aardvark-Dispose-INTx-irqs-prior-to-removing-INT.patch
      #./kernel-patches/0019-PCI-aardvark-Add-support-for-AER-registers-on-emulat.patch
      ./kernel-patches/0020-PCI-aardvark-Dispose-bridge-irq-prior-to-removing-br.patch
      ./kernel-patches/0021-PCI-aardvark-Add-support-for-DLLSC-and-hotplug-inter.patch
      ./kernel-patches/0022-PCI-aardvark-Send-Set_Slot_Power_Limit-message.patch
      ./kernel-patches/0023-PCI-aardvark-Add-clock-support.patch
      ./kernel-patches/0024-PCI-aardvark-Add-suspend-to-RAM-support.patch
      ./kernel-patches/0025-PCI-aardvark-Replace-custom-PCIE_CORE_ERR_CAPCTL_-ma.patch
      ./kernel-patches/0026-PCI-aardvark-Don-t-write-read-only-bits-explicitly-i.patch
      ./kernel-patches/0027-compiler.h-only-include-asm-rwonce.h-for-kernel-code.patch
      ./kernel-patches/0028-swab-use-stddefs.h-instead-of-compiler.h.patch
      ./kernel-patches/0029-net-sfp-move-quirk-handling-into-sfp.c.patch
      ./kernel-patches/0030-net-sfp-move-Alcatel-Lucent-3FE46541AA-fixup.patch
      ./kernel-patches/0031-net-sfp-move-Huawei-MA5671A-fixup.patch
      ./kernel-patches/0032-net-sfp-redo-soft-state-polling.patch
      ./kernel-patches/0033-mm-Fix-alloc_node_mem_map-with-ARCH_PFN_OFFSET-calcu.patch
      #./kernel-patches/0034-rtc-rs5c372-support-alarms-up-to-1-week.patch
      #./kernel-patches/0035-rtc-rs5c372-let-the-alarm-to-be-used-as-wakeup-sourc.patch
      ./kernel-patches/0036-kernel-add-a-config-option-for-keeping-the-kallsyms-.patch
      ./kernel-patches/0037-kernel-when-KALLSYMS-is-disabled-print-module-addres.patch
      ./kernel-patches/0038-usr-sanitize-deps_initramfs-list.patch
      ./kernel-patches/0039-hack-net-wireless-make-the-wl12xx-glue-code-availabl.patch
      #./kernel-patches/0040-generic-platform-mikrotik-build-bits-5.4.patch
      ./kernel-patches/0041-fix-errors-in-unresolved-weak-symbols-on-arm.patch
      ./kernel-patches/0042-arc-add-OWRTDTB-section.patch
      ./kernel-patches/0043-arc-enable-unaligned-access-in-kernel-mode.patch
      #./kernel-patches/0044-mtd-mtdsplit-support.patch
      ./kernel-patches/0045-mtd-spi-nor-write-support-for-minor-aligned-partitio.patch
      ./kernel-patches/0046-add-patch-for-including-unpartitioned-space-in-the-r.patch
      ./kernel-patches/0047-Add-myloader-partition-table-parser.patch
      ./kernel-patches/0048-mtd-bcm47xxpart-check-for-bad-blocks-when-calculatin.patch
      ./kernel-patches/0049-mtd-bcm47xxpart-detect-T_Meter-partition.patch
      ./kernel-patches/0050-kernel-disable-cfi-cmdset-0002-erase-suspend.patch
      ./kernel-patches/0051-Issue-map-read-after-Write-Buffer-Load-command-to-en.patch
      #./kernel-patches/0052-mtd-spinand-add-support-for-ESMT-F50x1G41LB.patch
      ./kernel-patches/0053-mtd-add-EOF-marker-support-to-the-UBI-layer.patch
      ./kernel-patches/0054-mtd-core-add-get_mtd_device_by_node.patch
      ./kernel-patches/0055-dt-bindings-add-bindings-for-mtd-concat-devices.patch
      ./kernel-patches/0056-mtd-mtdconcat-add-dt-driver-for-concat-devices.patch
      ./kernel-patches/0057-fs-add-cdrom-dependency.patch
      ./kernel-patches/0058-fs-add-jffs2-lzma-support-not-activated-by-default-y.patch
      ./kernel-patches/0059-fs-jffs2-EOF-marker.patch
      ./kernel-patches/0060-netfilter-add-support-for-flushing-conntrack-via-pro.patch
      ./kernel-patches/0061-kernel-add-a-new-version-of-my-netfilter-speedup-pat.patch
      ./kernel-patches/0062-netfilter-reduce-match-memory-access.patch
      ./kernel-patches/0063-netfilter-optional-tcp-window-check.patch
      ./kernel-patches/0064-net_sched-codel-do-not-defer-queue-length-update.patch
      ./kernel-patches/0065-net-add-an-optimization-for-dealing-with-raw-sockets.patch
      ./kernel-patches/0066-kernel-add-a-few-patches-for-avoiding-unnecessary-sk.patch
      ./kernel-patches/0067-Add-support-for-MAP-E-FMRs-mesh-mode.patch
      ./kernel-patches/0068-ipv6-allow-rejecting-with-source-address-failed-poli.patch
      ./kernel-patches/0069-net-provide-defines-for-_POLICY_FAILED-until-all-cod.patch
      ./kernel-patches/0070-of_net-add-mac-address-increment-support.patch
      ./kernel-patches/0071-of-of_net-write-back-netdev-MAC-address-to-device-tr.patch
      ./kernel-patches/0072-generic-add-detach-callback-to-struct-phy_driver.patch
      ./kernel-patches/0073-net-dsa-tag_mtk-add-padding-for-tx-packets.patch
      ./kernel-patches/0074-net-dsa-mv88e6xxx-Request-assisted-learning-on-CPU-p.patch
      ./kernel-patches/0075-ARM-kirkwood-add-missing-linux-if_ether.h-for-ETH_AL.patch
      ./kernel-patches/0076-bcma-get-SoC-device-struct-copy-its-DMA-params-to-th.patch
      ./kernel-patches/0077-gpio-gpio-cascade-add-generic-GPIO-cascade.patch
      ./kernel-patches/0078-debloat-add-kernel-config-option-to-disabling-common.patch
      ./kernel-patches/0079-debloat-disable-common-USB-quirks.patch
      ./kernel-patches/0080-w1-gpio-fix-problem-with-platfom-data-in-w1-gpio.patch
      ./kernel-patches/0081-hwrng-bcm2835-set-quality-to-1000.patch
      ./kernel-patches/0082-PCI-aardvark-Make-main-irq_chip-structure-a-static-d.patch
      ./kernel-patches/0083-init-add-CONFIG_MANGLE_BOOTARGS-and-disable-it-by-de.patch
      ./kernel-patches/0084-ARM-dts-armada-385.dtsi-Add-definitions-for-PCIe-err.patch
      ./kernel-patches/0085-PCI-aardvark-Implement-workaround-for-PCIe-Completio.patch
      #./kernel-patches/0086-ARM-dts-turris-omnia-configure-LED-0-pin-function-to.patch
      #./kernel-patches/0087-ARM-dts-turris-omnia-enable-LED-controller-node.patch
      ./kernel-patches/0088-leds-turris-omnia-support-HW-controlled-mode-via-pri.patch
      ./kernel-patches/0089-leds-turris-omnia-initialize-multi-intensity-to-full.patch
      ./kernel-patches/0090-leds-turris-omnia-change-max-brightness-from-255-to-.patch
      ./kernel-patches/0091-generic-Mangle-bootloader-s-kernel-arguments.patch
      ./kernel-patches/0092-ARM-mvebu-385-ap-Add-partitions.patch
      ./kernel-patches/0093-ARM-dts-armada388-clearfog-emmc-on-clearfog-base.patch
      ./kernel-patches/0094-ARM-dts-armada-xp-linksys-mamba-Increase-kernel-part.patch
      ./kernel-patches/0095-phy-marvell-phy-mvebu-a3700-comphy-Change-2500base-x.patch
      ./kernel-patches/0096-cpuidle-mvebu-indicate-failure-to-enter-deeper-sleep.patch
    ];
  };
}

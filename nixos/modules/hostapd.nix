{ config, lib, pkgs, utils, ... }:

# TODO:
#
# asserts
#   ensure that the nl80211 module is loaded/compiled in the kernel
#   wpa_supplicant and hostapd on the same wireless interface doesn't make any sense

with builtins;
with lib;

let

  cfg = config.networking.hostapd;

  options_bss = {

      ssid = mkOption {
        type = types.str;
        default = "nixos";
        example = "mySpecialSSID";
        description = "SSID to be used in IEEE 802.11 management frames.";
      };

      wpa = mkOption {
        type = types.bool;
        default = true;
        description = ''
          Enable WPA (IEEE 802.11i/D3.0) to authenticate with the access point.
        '';
      };

      wpa3 = mkOption {
        type = types.bool;
        default = true;
        description = ''
          Use WPA3 instead of WPA2 for authentication. This changes the key
          management from WPA_PSK to SAE.
        '';
      };

      wpaPassphrase = mkOption {
        type = with types; nullOr str;
        default = null;
        example = "any_64_char_string";
        description = ''
          WPA-PSK (pre-shared-key) passphrase. Clients will need this
          passphrase to associate with this access point.
          Warning: This passphrase will get put into a world-readable file in
          the Nix store! You should use wpaPskFile in most cases.
        '';
      };

      wpaPskFile = mkOption {
        type = with types; nullOr str;
        default = null;
        example = "/etc/hostapd.wpa_psk";
        description = ''
          Optionally, WPA PSKs can be read from a separate text file (containing
          list of (PSK,MAC address) pairs. This allows more than one PSK to be
          configured.  Use absolute path name to make sure that the files can be
          read on SIGHUP configuration reloads.
          This is higly suggested to be used over wpaPassphrase as it won't save
          your password to the Nix store!
        '';
      };

  };

  options_interface = options_bss // {

      enable = mkOption {
        type = types.bool;
        default = true;
        description = ''
          Enable putting a wireless interface into infrastructure mode,
          allowing other wireless devices to associate with the wireless
          interface and do wireless networking. A simple access point will
          <option>enable hostapd.<name>.wpa</option>, set
          <option>hostapd.<name>.wpaPassphrase</option>, and
          <option>hostapd.<name>.ssid</option>, as well as DHCP on the wireless
          interface to provide IP addresses to the associated stations, and
          NAT (from the wireless interface to an upstream interface).
        '';
      };

      group = mkOption {
        default = "wheel";
        example = "network";
        type = types.str;
        description = ''
          Members of this group can control <command>hostapd</command>.
        '';
      };

      logLevel = mkOption {
        default = 2;
        type = types.int;
        description = ''
          Levels (minimum value for logged events):
          0 = verbose debugging
          1 = debugging
          2 = informational messages
          3 = notification
          4 = warning
        '';
      };

      driver = mkOption {
        default = "nl80211";
        example = "hostapd";
        type = types.str;
        description = ''
          Which driver <command>hostapd</command> will use.
          Most applications will probably use the default.
        '';
      };

      channel = mkOption {
        default = 7;
        example = 11;
        type = types.int;
        description = ''
          Channel number (IEEE 802.11)
          Please note that some drivers do not use this value from
          <command>hostapd</command> and the channel will need to be configured
          separately with <command>iwconfig</command>.
        '';
      };

      hwMode = mkOption {
        default = "g";
        type = types.enum [ "a" "b" "g" ];
        description = ''
          Operation mode.
          (a = IEEE 802.11a, b = IEEE 802.11b, g = IEEE 802.11g).
        '';
      };

      countryCode = mkOption {
        default = null;
        example = "US";
        type = with types; nullOr str;
        description = ''
          Country code (ISO/IEC 3166-1). Used to set regulatory domain.
          Set as needed to indicate country in which device is operating.
          This can limit available channels and transmit power.
          These two octets are used as the first two octets of the Country String
          (dot11CountryString).
          This enables IEEE 802.11d. This advertises the countryCode and the set
          of allowed channels and transmit power levels based on the regulatory
          limits.
          This is required in most places by law and thus enforced to be set!
        '';
      };

      ieee80211h = mkOption {
        type = types.bool;
        default = true;
        description = ''
          Enable IEEE 802.11h. This enables radar detection and DFS support if
          available. DFS support is required on outdoor 5 GHz channels in most countries
          of the world.
        '';
      };

      wmm_enabled = mkOption {
        type = types.bool;
        default = true;
        description = ''
          Default WMM parameters (IEEE 802.11 draft; 11-03-0504-03-000e):
          for 802.11a or 802.11g networks
          These parameters are sent to WMM clients when they associate.
          The parameters will be used by WMM clients for frames transmitted to the
          access point.
        '';
      };

      ieee80211n = mkOption {
        type = types.bool;
        default = true;
        description = "Whether IEEE 802.11n (HT) is enabled";
      };

      ht_capab = mkOption {
        type = with types; listOf str;
        default = ["HT40-" "SHORT-GI-20" "SHORT-GI-40"];
        description = ''
        HT capabilities (list of flags)
        LDPC coding capability: [LDPC] = supported
        Supported channel width set: [HT40-] = both 20 MHz and 40 MHz with secondary
          channel below the primary channel; [HT40+] = both 20 MHz and 40 MHz
          with secondary channel above the primary channel
          (20 MHz only if neither is set)
          Note: There are limits on which channels can be used with HT40- and
          HT40+. Following table shows the channels that may be available for
          HT40- and HT40+ use per IEEE 802.11n Annex J:
          freq		HT40-		HT40+
          2.4 GHz		5-13		1-7 (1-9 in Europe/Japan)
          5 GHz		40,48,56,64	36,44,52,60
          (depending on the location, not all of these channels may be available
          for use)
          Please note that 40 MHz channels may switch their primary and secondary
          channels if needed or creation of 40 MHz channel maybe rejected based
          on overlapping BSSes. These changes are done automatically when hostapd
          is setting up the 40 MHz channel.
        HT-greenfield: [GF] (disabled if not set)
        Short GI for 20 MHz: [SHORT-GI-20] (disabled if not set)
        Short GI for 40 MHz: [SHORT-GI-40] (disabled if not set)
        Tx STBC: [TX-STBC] (disabled if not set)
        Rx STBC: [RX-STBC1] (one spatial stream), [RX-STBC12] (one or two spatial
          streams), or [RX-STBC123] (one, two, or three spatial streams); Rx STBC
          disabled if none of these set
        HT-delayed Block Ack: [DELAYED-BA] (disabled if not set)
        Maximum A-MSDU length: [MAX-AMSDU-7935] for 7935 octets (3839 octets if not
          set)
        DSSS/CCK Mode in 40 MHz: [DSSS_CCK-40] = allowed (not allowed if not set)
        40 MHz intolerant [40-INTOLERANT] (not advertised if not set)
        L-SIG TXOP protection support: [LSIG-TXOP-PROT] (disabled if not set)
        '';
      };

      require_ht = mkOption {
        type = types.bool;
        default = true;
        description = "Require stations to support VHT PHY (reject association if they do not)";
      };

      ieee80211ac = mkOption {
        type = types.bool;
        default = false;
        description = "Whether IEEE 802.11ac (VHT) is enabled";
      };

      vht_capab = mkOption {
        type = with types; listOf str;
        default = ["SHORT-GI-80" "HTC-VHT"];
        description = ''
          VHT capabilities (list of flags)

          vht_max_mpdu_len: [MAX-MPDU-7991] [MAX-MPDU-11454]
          Indicates maximum MPDU length
          0 = 3895 octets (default)
          1 = 7991 octets
          2 = 11454 octets
          3 = reserved

          supported_chan_width: [VHT160] [VHT160-80PLUS80]
          Indicates supported Channel widths
          0 = 160 MHz & 80+80 channel widths are not supported (default)
          1 = 160 MHz channel width is supported
          2 = 160 MHz & 80+80 channel widths are supported
          3 = reserved

          Rx LDPC coding capability: [RXLDPC]
          Indicates support for receiving LDPC coded pkts
          0 = Not supported (default)
          1 = Supported

          Short GI for 80 MHz: [SHORT-GI-80]
          Indicates short GI support for reception of packets transmitted with TXVECTOR
          params format equal to VHT and CBW = 80Mhz
          0 = Not supported (default)
          1 = Supported

          Short GI for 160 MHz: [SHORT-GI-160]
          Indicates short GI support for reception of packets transmitted with TXVECTOR
          params format equal to VHT and CBW = 160Mhz
          0 = Not supported (default)
          1 = Supported

          Tx STBC: [TX-STBC-2BY1]
          Indicates support for the transmission of at least 2x1 STBC
          0 = Not supported (default)
          1 = Supported

          Rx STBC: [RX-STBC-1] [RX-STBC-12] [RX-STBC-123] [RX-STBC-1234]
          Indicates support for the reception of PPDUs using STBC
          0 = Not supported (default)
          1 = support of one spatial stream
          2 = support of one and two spatial streams
          3 = support of one, two and three spatial streams
          4 = support of one, two, three and four spatial streams
          5,6,7 = reserved

          SU Beamformer Capable: [SU-BEAMFORMER]
          Indicates support for operation as a single user beamformer
          0 = Not supported (default)
          1 = Supported

          SU Beamformee Capable: [SU-BEAMFORMEE]
          Indicates support for operation as a single user beamformee
          0 = Not supported (default)
          1 = Supported

          Compressed Steering Number of Beamformer Antennas Supported:
          [BF-ANTENNA-2] [BF-ANTENNA-3] [BF-ANTENNA-4]
            Beamformee's capability indicating the maximum number of beamformer
            antennas the beamformee can support when sending compressed beamforming
            feedback
          If SU beamformer capable, set to maximum value minus 1
          else reserved (default)

          Number of Sounding Dimensions:
          [SOUNDING-DIMENSION-2] [SOUNDING-DIMENSION-3] [SOUNDING-DIMENSION-4]
          Beamformer's capability indicating the maximum value of the NUM_STS parameter
          in the TXVECTOR of a VHT NDP
          If SU beamformer capable, set to maximum value minus 1
          else reserved (default)

          MU Beamformer Capable: [MU-BEAMFORMER]
          Indicates support for operation as an MU beamformer
          0 = Not supported or sent by Non-AP STA (default)
          1 = Supported

          VHT TXOP PS: [VHT-TXOP-PS]
          Indicates whether or not the AP supports VHT TXOP Power Save Mode
           or whether or not the STA is in VHT TXOP Power Save mode
          0 = VHT AP doesn't support VHT TXOP PS mode (OR) VHT STA not in VHT TXOP PS
           mode
          1 = VHT AP supports VHT TXOP PS mode (OR) VHT STA is in VHT TXOP power save
           mode

          +HTC-VHT Capable: [HTC-VHT]
          Indicates whether or not the STA supports receiving a VHT variant HT Control
          field.
          0 = Not supported (default)
          1 = supported

          Maximum A-MPDU Length Exponent: [MAX-A-MPDU-LEN-EXP0]..[MAX-A-MPDU-LEN-EXP7]
          Indicates the maximum length of A-MPDU pre-EOF padding that the STA can recv
          This field is an integer in the range of 0 to 7.
          The length defined by this field is equal to
          2 pow(13 + Maximum A-MPDU Length Exponent) -1 octets

          VHT Link Adaptation Capable: [VHT-LINK-ADAPT2] [VHT-LINK-ADAPT3]
          Indicates whether or not the STA supports link adaptation using VHT variant
          HT Control field
          If +HTC-VHTcapable is 1
           0 = (no feedback) if the STA does not provide VHT MFB (default)
           1 = reserved
           2 = (Unsolicited) if the STA provides only unsolicited VHT MFB
           3 = (Both) if the STA can provide VHT MFB in response to VHT MRQ and if the
               STA provides unsolicited VHT MFB
          Reserved if +HTC-VHTcapable is 0

          Rx Antenna Pattern Consistency: [RX-ANTENNA-PATTERN]
          Indicates the possibility of Rx antenna pattern change
          0 = Rx antenna pattern might change during the lifetime of an association
          1 = Rx antenna pattern does not change during the lifetime of an association

          Tx Antenna Pattern Consistency: [TX-ANTENNA-PATTERN]
          Indicates the possibility of Tx antenna pattern change
          0 = Tx antenna pattern might change during the lifetime of an association
          1 = Tx antenna pattern does not change during the lifetime of an association
        '';
      };

      require_vht = mkOption {
        type = types.bool;
        default = true;
        description = "Require stations to support VHT PHY (reject association if they do not)";
      };

      vht_oper_chwidth= mkOption {
        type = types.int;
        default = 1;
        description = ''
          0 = 20 or 40 MHz operating Channel width
          1 = 80 MHz channel width
          2 = 160 MHz channel width
          3 = 80+80 MHz channel width
          '';
      };

      vht_oper_centr_freq_seg0_idx = mkOption {
        type = types.int;
        default = 42;
        description = ''
          center freq 5 GHz + (5 * index)
          So index 42 gives center freq 5.210 GHz which is channel 42 in 5G band.
          '';
      };

      vht_oper_centr_freq_seg1_idx = mkOption {
        type = types.int;
        default = 159;
        description = ''
          center freq = 5 GHz + (5 * index)
          So index 159 gives center freq 5.795 GHz which is channel 159 in 5G band.
          '';
      };

      use_sta_nsts = mkOption {
        type = types.bool;
        default = false;
        description = ''
        Workaround to use station's nsts capability in (Re)Association Response frame
        This may be needed with some deployed devices as an interoperability
        workaround for beamforming if the AP's capability is greater than the
        station's capability. This is disabled by default and can be enabled by
        setting use_sta_nsts=true.
        '';
      };

      ieee80211ax = mkOption {
        type = types.bool;
        default = false;
        description = "Whether IEEE 802.11ax (HE) is enabled";
      };

      bss = mkOption {
        type = with types; attrsOf (submodule {options = options_bss;});
        default = { };
        example = literalExpression ''
          {
            "wlan0host" = {
              ssid = "HostNetwork";
              wpaPassphrase = "NotSoSecretPassword";
            };
          }
          '';
        description = ''
          Support for multiple BSSIDs.
          '';
      };

      extraConfig = mkOption {
        default = "";
        type = types.lines;
        description = "Extra configuration options to put in hostapd.conf.";
      };

  };


  configFile = interface: let
    icfg = cfg."${interface}";
  in ''
    ctrl_interface=/run/hostapd
    ctrl_interface_group=${icfg.group}

    # logging (debug level)
    logger_syslog=-1
    logger_syslog_level=${toString icfg.logLevel}
    logger_stdout=-1
    logger_stdout_level=${toString icfg.logLevel}

    interface=${interface}
    driver=${icfg.driver}
    hw_mode=${icfg.hwMode}
    channel=${toString icfg.channel}
    country_code=${icfg.countryCode}
    ieee80211d=1
    ${optionalString (icfg.ieee80211h) "ieee80211h=1"}
    wmm_enabled=${boolean icfg.wmm_enabled}
    ${optionalString icfg.ieee80211n ''
      ieee80211n=1
      ht_capab=${mapCapab icfg.ht_capab}
      require_ht=${boolean icfg.require_ht}
    ''}
    ${optionalString icfg.ieee80211ac ''
      ieee80211ac=1
      vht_capab=${mapCapab icfg.vht_capab}
      require_vht=${boolean icfg.require_vht}
      vht_oper_chwidth=${toString icfg.vht_oper_chwidth}
      vht_oper_centr_freq_seg0_idx=${toString icfg.vht_oper_centr_freq_seg0_idx}
      vht_oper_centr_freq_seg1_idx=${toString icfg.vht_oper_centr_freq_seg1_idx}
      use_sta_nsts=${boolean icfg.use_sta_nsts}
    ''}
    ${optionalString icfg.ieee80211ax ''
      ieee80211ax=1
    ''}

    ssid=${icfg.ssid}
    ${configBss icfg}

    ${concatMapStringsSep "\n" (bss: ''
      bss=${bss}
      use_driver_iface_addr=1
      ${configBss icfg.bss."${bss}"}'') (attrNames icfg.bss)}

    ${icfg.extraConfig}
  '';

  mapCapab = list: concatStrings (map (key: "[${key}]") list);
  boolean = bool: if bool then "1" else "0";

  configBss = bsscfg: ''
    ${optionalString bsscfg.wpa ''
      wpa=2
      wpa_pairwise=CCMP TKIP
      wpa_key_mgmt=${if bsscfg.wpa3 then "SAE" else "WPA-PSK"}
      ${optionalString (bsscfg.wpaPassphrase != null) "wpa_passphrase=${bsscfg.wpaPassphrase}"}
      ${optionalString (bsscfg.wpaPskFile != null) "wpa_psk_file=${bsscfg.wpaPskFile}"}
    ''}
  '';

  etcConfigs = listToAttrs (map
    (n: nameValuePair "hostapd/${n}.conf" {text = configFile n;})
    (attrNames (filterAttrs (n: v: v.enable) cfg))
  );

in

{

  #disabledModules = [ "services/networking/hostapd.nix" ];

  ###### interface

  options = {
    networking.hostapd = mkOption {
      type = with types; attrsOf (submodule {options = options_interface;});
      default = { };
      example = literalExpression ''
        { "wlan0" = {
            hw_mode = "a";
            channel = 11;
            ssid = "MyNetwork";
            wpaPassphrase = "SecretPassword";
          };
        }
        '';
      description = ''
        Interface for which to start <command>hostapd</command>.
        '';
    };
  };


  ###### implementation

  config = mkIf (any (val: val.enable) (attrValues cfg)) {
    assertions = [{
      assertion = all (val: ! val.enable or val.countryCode != null) (attrValues cfg);
      message = "Country code has to be specified to prevent violation of the law.";
    }];
    ## TODO mkRenamedOptionModule

    environment.systemPackages = [ pkgs.hostapd ];
    services.udev.packages = [ pkgs.crda ];

    environment.etc = etcConfigs;

    systemd.services.hostapd = let
      interfaces = map utils.escapeSystemdPath (attrNames (filterAttrs (n: v: v.enable) cfg));
      links = interfaces ++ (map utils.escapeSystemdPath (concatMap attrNames (catAttrs "bss" (attrValues (filterAttrs (n: v: v.enable) cfg)))));
      devices = map (ifc: "sys-subsystem-net-devices-${ifc}.device") interfaces;
      services = map (ifc: "network-link-${ifc}.service") links;
    in {
        description = "hostapd wireless AP";
        path = [ pkgs.hostapd ];
        after = devices;
        bindsTo = devices;
        requiredBy = services;
        wantedBy = [ "multi-user.target" ];

        serviceConfig =
          { ExecStart = "${pkgs.hostapd}/bin/hostapd ${toString (map (v: "/etc/${v}") (attrNames etcConfigs))}";
            Restart = "always";
          };
      };
  };
}

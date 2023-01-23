{
  self,
  lib ? self.inputs.nixpkgs.lib,
}:
with builtins;
with lib; let
  freq24 = [1 2 3 4 5 6 7 8 9 10 11 12 13 14];
  freq5 = [36 40 44 48 52 56 60 64 100 104 108 112 116 120 124 128 132 136 140 144 149 153 157 161 165 169 173];

  # Select if secondary channel is above or bellow the primary channel
  ht40x = channel:
    if
      (channel
        >= 5
        && channel <= 13
        || channel == 40
        || channel
        == 48
        || channel == 56
        || channel == 64)
    then "HT40-"
    else "HT40+";

  func = {
    freqs ? freq24,
    channelWidths ? [20 40],
    channelDefault ? 7,
    cap_ldpc ? false, # Capability RX LDPC
    cap_max_amsdu ? 3839, # Capability Max AMSDU length: X bytes
    vhtcap_max_mpdu ? 11454, # VHT Capabilty Max MPDU length: X
  }: {
    countryCode ? "CZ",
    channel ? channelDefault,
    channelWidth ? 40,
  }:
    assert elem channel freqs;
    assert elem channelWidth channelWidths; {
      inherit countryCode channel;
      hwMode =
        if channel > 15
        then "a"
        else "g";
      ieee80211ac = channel > 15;
      ht_capab =
        [
          "SHORT-GI-20"
          "SHORT-GI-40"
          "TX-STBC"
          "RX-STBC1"
          "DSSS_CCK-40"
          "MAX-AMSDU-${toString cap_max_amsdu}"
        ]
        ++ (optional (channelWidth >= 40) (ht40x channel))
        ++ (optional cap_ldpc "LDPC");
      vht_capab = optionals (channel > 15) ([
          "RXLDPC"
          "SHORT-GI-80"
          "TX-STBC-2BY1"
          "RX-STBC-1"
          "MAX-A-MPDU-LEN-EXP7"
          "RX-ANTENNA-PATTERN"
          "TX-ANTENNA-PATTERN"
          "MAX-MPDU-${toString vhtcap_max_mpdu}"
        ]
        ++ (optional (channelWidth >= 0) ""));
      vht_oper_chwidth =
        if channelWidths == 80
        then 1
        else 0;
    };
in {
  qualcomAtherosQCA988x = func {
    freqs = freq24 ++ freq5;
    channelWidths = [20 40 80];
    channelDefault = 36;
    cap_ldpc = true;
    cap_max_amsdu = 7935;
  };
  qualcomAtherosAR9287 = func {};
}

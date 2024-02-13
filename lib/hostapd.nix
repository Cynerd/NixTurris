{
  qualcomAtherosAR9287 = {
    wifi4.capabilities = [
      "SHORT-GI-20"
      "SHORT-GI-40"
      "TX-STBC"
      "RX-STBC1"
      "DSSS_CCK-40"
      "MAX-AMSDU-3839"
      "HT40"
      "HT40-"
    ];
  };

  qualcomAtherosQCA988x = {
    wifi4.capabilities = [
      "SHORT-GI-20"
      "SHORT-GI-40"
      "TX-STBC"
      "RX-STBC1"
      "DSSS_CCK-40"
      "MAX-AMSDU-3839"
      "LDPC"
      "HT40-"
      "HT40+"
    ];
    wifi5.capabilities = [
      "RXLDPC"
      "SHORT-GI-80"
      "TX-STBC-2BY1"
      "RX-STBC-1"
      "MAX-A-MPDU-LEN-EXP7"
      "RX-ANTENNA-PATTERN"
      "TX-ANTENNA-PATTERN"
      "MAX-MPDU-11454"
    ];
  };
}

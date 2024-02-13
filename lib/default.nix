self: final: prev:
{
  hostapd = import ./hostapd.nix;
}
// import ./system.nix self final prev

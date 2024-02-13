{
  lib,
  pkgs,
  ...
}: {
  turris.board = "@REPLACE_WITH_BOARD@"; # Either "mox" or "omnia"

  # Place your system configuration here
  users.users.root.password = lib.mkDefault "nixturris";
  environment.systemPackages = with pkgs; [];
}

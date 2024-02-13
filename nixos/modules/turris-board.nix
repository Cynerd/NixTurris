{
  config,
  lib,
  pkgs,
  ...
}:
with lib; {
  options = {
    turris.board = mkOption {
      type = types.enum ["omnia" "mox" null];
      default = null;
      description = "The unique Turris board identifier.";
    };
  };

  config = {
    environment.systemPackages = [
      # The Git is required to access this repository
      pkgs.git
    ];
  };
}

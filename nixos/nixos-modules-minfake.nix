{ config, lib, pkgs, ... }:

with lib;

{

  options = let

    mkFake = {type, default}: mkOption {
      type = type;
      default = default;
      description = "The module this option was part of was removed as part of Turris trim";
    };
    mkFakeList = type: mkFake {
      type = types.listOf type;
      default = [];
    };

    mkFakeDisable = mkOption {
      type = types.bool;
      default = false;
      description = "The in default disabled option that was removed as part of Turris trim";
    };

  in {

    services.xserver.enable = mkFakeDisable;
    services.xserver.displayManager.hiddenUsers = mkFakeList types.str;
    services.xserver.startGnuPGAgent = mkFakeDisable;

  };

  config = {
  };
}



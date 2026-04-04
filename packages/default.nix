{
  pkgs,
  enableOled ? false,
}: rec {
  source = pkgs.callPackage ./source.nix {
    disableOled = !enableOled;
  };

  argon = pkgs.callPackage ./argon.nix {
    sourceFilesPackage = source;
  };

  argonEon = pkgs.callPackage ./argon-eon.nix {
    sourceFilesPackage = source;
  };
}

{
  description = "Flutter shell";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/master";
  inputs.nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, nixpkgs, nixpkgs-unstable, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system: let
      config = {
        android_sdk.accept_license = true;
        allowUnfree = true;
      };
      pkgs = import nixpkgs { inherit system config; };
      # Flutter is taken from nixpkgs-unstable so we get the latest stable
      # toolchain without bumping the rest of the dev shell.
      unstable = import nixpkgs-unstable { inherit system config; };
      androidSdk = (pkgs.androidenv.composeAndroidPackages {
        platformVersions = ["35"];
        buildToolsVersions = ["36.0.0"];
        includeNDK = true;
        ndkVersions = ["28.2.13676358"];
      }).androidsdk;
    in {
      devShells.default = pkgs.mkShell {
        ANDROID_SDK_ROOT = "${androidSdk}/libexec/android-sdk";
        buildInputs = with pkgs; [
          unstable.flutter
          androidSdk
          jdk17
          chromium
        ];
        shellHook = ''
          export CHROME_EXECUTABLE=$(which chromium)
        '';
      };
    });
}

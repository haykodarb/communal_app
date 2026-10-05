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
        platformVersions = ["31" "34" "35"];
        abiVersions = ["arm64-v8a" "x86_64"];
        buildToolsVersions = ["34.0.0"];
        cmakeVersions = ["3.22.1"];
        includeNDK = true;
        ndkVersions = ["27.0.12077973"];
        includeEmulator = true;
        includeSystemImages = true;
        systemImageTypes = ["google_apis_playstore"];
      }).androidsdk;
    in {
      devShells.default = pkgs.mkShell {
        ANDROID_SDK_ROOT = "${androidSdk}/libexec/android-sdk";
        buildInputs = with pkgs; [
          unstable.flutter
          androidSdk
          jdk17
          chromium
          firebase-tools
          # Emulator dependencies
          libGL
          vulkan-loader
        ];
        shellHook = ''
          export CHROME_EXECUTABLE=$(which chromium)
        '';
      };
    });
}

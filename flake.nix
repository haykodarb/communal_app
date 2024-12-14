{
  description = "A basic flake with a shell";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/24.05";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config = {
            android_sdk.accept_license = true;
            allowUnfree = true;
          };
        };
        androidComposition = pkgs.androidenv.composeAndroidPackages
        {
          platformVersions = [ "31" "32" "34" ];
          abiVersions = [ "armeabi-v7a" "arm64-v8a" "x86_64" ];
          buildToolsVersions = [ "30.0.3" ];
          cmakeVersions = [ "3.18.1" "3.22.1" ]; 
          includeNDK = true;
          ndkVersions = [ "23.1.7779620" "26.1.10909125" ];
          includeSystemImages = true;
          includeEmulator = true;
          useGoogleAPIs = true;
        };
        androidSdk = androidComposition.androidsdk;
      in
      {
        devShells.default =
          with pkgs; mkShell {
            ANDROID_SDK_ROOT = "${androidSdk}/libexec/android-sdk";

            buildInputs = [
              bashInteractive
              flutter
              androidSdk
              google-chrome
              pkg-config
              gtk3
              jdk11
            ];
            shellHook = ''
            export CHROME_EXECUTABLE=$(which chromium); 
            zsh -c "./dev.sh"
            '';
          };
      });
}

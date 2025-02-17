{
  description = "Flutter shell";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/master";
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
          platformVersions = [  "31" "33" "34" ];
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
	      android-tools
	      flutter

	      androidSdk
              google-chrome
              pkg-config
              gtk3
	      
	      # emulator hwdecode
	      vulkan-loader 
	      libGL        
	      # fixes nagging
              pcre2.dev
	      util-linux.dev
	      libselinux
	      libsepol
	      libthai
	      libdatrie
	      xorg.libXdmcp
	      xorg.libXtst
	      lerc.dev
	      libxkbcommon
	      libsysprof-capture
	      libepoxy

	      jdk17
            ];

            shellHook = ''
		export CHROME_EXECUTABLE=$(which chromium); 
		export SHELL='/run/current-system/sw/bin/bash';
		export LIBGL_ALWAYS_SOFTWARE=0
		export LIBGL_ALWAYS_INDIRECT=0
            '';
          };
      });
}

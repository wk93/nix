{
  config,
  pkgs,
  lib,
  ...
}: let
  android-pkgs = pkgs;
  androidenv = android-pkgs.androidenv.override {
    licenseAccepted = true;
  };

  android-comp = androidenv.composeAndroidPackages {
    buildToolsVersions = ["34.0.0"];
    toolsVersion = "26.1.1";
    platformVersions = ["29" "30" "31" "33" "34"];
    extraLicenses = [
      "android-googletv-license"
      "android-sdk-arm-dbt-license"
      "android-sdk-license"
      "android-sdk-preview-license"
      "google-gdk-license"
      "intel-android-extra-license"
      "intel-android-sysimage-license"
      "mips-android-sysimage-license"
    ];
  };

  android-sdk = android-comp.androidsdk;
  android-sdk-root = "${android-sdk}/libexec/android-sdk";
in {
  home.packages = [
    android-sdk
    pkgs.unzip
    pkgs.google-chrome
    pkgs.addlicense
    pkgs.nodePackages.firebase-tools
    pkgs.flutter
    pkgs.jdk17
  ];

  home.sessionVariables = {
    ANDROID_SDK_ROOT = android-sdk-root;
    ANDROID_HOME = android-sdk-root;
    CHROME_EXECUTABLE = "${pkgs.google-chrome}/bin/google-chrome-stable";
    FLUTTER_SDK_ROOT = "${pkgs.flutter}";
    JAVA_HOME = "${pkgs.jdk17}";
  };
}

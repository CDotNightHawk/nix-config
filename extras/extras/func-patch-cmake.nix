pkg:
pkg.overrideAttrs (
  final: prev: {
    cmakeFlags = (if prev ? cmakeFlags then prev.cmakeFlags else [ ]) ++ [
      (lib.cmakeFeature "CMAKE_POLICY_VERSION_MINIMUM" "3.5")
    ];
  }
)

{
  pkgs ? import <nixpkgs> { },
}:

let
  inherit (pkgs) fetchFromGitHub;
  # Get Wikimedia Extension
  getWMExtension = import ../func-get-wm-extension.nix { inherit pkgs; };
in
{
  CodeMirror = getWMExtension {
    name = "CodeMirror";
    rev = "70945366fa9a2d4ef13e26e6c93ec497e04d529d";
    hash = "sha256-krZHw0fRnYtllaEpQBJjY819LRYyucLkyAcH4OvHUuA=";
  };
  Loops = getWMExtension {
    name = "Loops";
    rev = "e62a4bd3e7b91ac6167860969a16181d621805e3";
    hash = "sha256-4NTY7Me3DJAfRqy67rNOsfWH664SQlgDJx1bZLiO3XQ=";
  };
  MagicNoCache = getWMExtension {
    name = "MagicNoCache";
    rev = "feb3079089672c06bb8c1f21fbfc328bddcc841c";
    hash = "sha256-u3o5AHm1eNdTxq9QBJPhkOkXC4kxnIlPC9hIs47ROl4=";
  };
  DynamicSidebar = getWMExtension {
    name = "DynamicSidebar";
    rev = "1284da0cf76d402c631afc15dcdccfa086fe941e";
    hash = "sha256-sBcTWUuvqnfVTsCnL//DMxzVU/TqeAIXsvDPU7r5XCQ=";
  };
  MobileFrontend = getWMExtension {
    name = "MobileFrontend";
    rev = "8463fddf9f923f2aa3d4b332bc016b540fc1e23f";
    hash = "sha256-srBPRj+RV65WUbg633TACJbfrwfvrNG8kxzHIjUVHrs=";
  };
  SecureLinkFixer = getWMExtension {
    name = "SecureLinkFixer";
    rev = "d7ffecb943c6f43c992f29bce3977be6d1298b03";
    hash = "sha256-B3flM4Cpr40eoH2txjdQA+mPsXs4f/oruy40ClJAnnM=";
  };
}

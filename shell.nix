let

  pkgs = (import (builtins.fetchGit {
    url = "git@github.com:etaque/elm-compiler.git";
    rev = "7cef1de9207b241675432ae40d723b6adf1024dd"; # 4.0.0
  })).forPackage {
    hasTests = true;
    hasExamples = true;
  };

in pkgs.mkShell {

  ELM_HOME = (builtins.getEnv "PWD") + "/.elm";

  buildInputs = with pkgs; [
    elm-pkg
    elmPackages.elm
    elmPackages.elm-format
  ];

}

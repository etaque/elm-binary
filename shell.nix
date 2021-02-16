let

  pkgs = (import (builtins.fetchGit {
    url = "git@github.com:dividat/elm-compiler.git";
    rev = "6f755abe65739990a2641fbea8775704eb8d4f35"; # 4.0.0
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

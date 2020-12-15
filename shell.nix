let
  elmPackages = fetchGit {
    url = "git@github.com:dividat/elm-compiler.git";
    rev = "96a50718998028c8ba2e557a0907b2bb54166d5c";
    ref = "refs/tags/3.1.0";
  };
in
  (import elmPackages {
    publicElmPackages =
      (import ./elm-packages/public.nix)
      // (import ./tests/elm-packages/public.nix)
      // (import ./example/elm-packages/public.nix);
    package = {
      name = "dividat/elm-binary";
      version = "1.2.0";
    };
  }).shell

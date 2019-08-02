let
  elm019Env = fetchGit {
     url = "git@github.com:dividat/elm-compiler.git";
     rev = "8ae2148630d1ac7bc6d26c4433ae32124a5311fb";
  };
in
(import elm019Env {
   elmPackages = (import ./tests/elm-srcs.nix) // (import ./example/elm-srcs.nix);
   watchPkg = "dividat/elm-binary/1.1.0";
   privatePackages = {
      "dividat/elm-binary" = {
          src = ./.;
          version = "1.1.0";
      };
   };
}).shell

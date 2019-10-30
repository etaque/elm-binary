let
  elm019Env = fetchGit {
     url = "git@github.com:dividat/elm-compiler.git";
     ref = "master";
  };
in
(import elm019Env {
   watchPkg = "dividat/elm-binary/1.2.0";
   dependenciesFrom = [
      ./tests/elm.json
      ./example/elm.json
   ];
   dependencySources = [
      ./.
   ];
}).shell

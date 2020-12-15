module BinaryTest exposing (..)

import Binary
import Binary.Decode as BD
import Html as H
import Browser


main : Program () () ()
main =
    Browser.sandbox
        { init = ()
        , view = view
        , update = \msg model -> model
        }

view : () -> H.Html ()
view _ =
    let
        toString r =
            case r of
                Err err ->
                    err
                Ok (a, b) ->
                    "(" ++ String.fromInt a ++ "," ++ String.fromInt b ++ ")"
    in
    List.range 0 10
        |> List.map Binary.uint8
        |> Binary.concat
        |> BD.decode
            (BD.succeed (\a b -> ( a, b ))
                |> BD.apply BD.uint8
                |> BD.ignore BD.uint8
                |> BD.apply BD.uint8
            )
        |> (toString >> H.text)

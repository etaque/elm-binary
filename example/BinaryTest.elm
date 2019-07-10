module BinaryTest exposing (Model, Msg(..), SomeStruct, init, main, subscriptions, update, view)

--
--

import Binary
import Binary.Decode as BD
import Html as H
import Return exposing (Return)


main : Program Never Model Msg
main =
    H.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }



-- MODEL


type alias Model =
    ()


init : Return Msg Model
init =
    ()
        |> Return.singleton



-- UPDATE


type Msg
    = NoOp


update : Msg -> Model -> Return Msg Model
update msg model =
    model
        |> Return.singleton



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- VIEW


type alias SomeStruct =
    { x : Int
    , comment : String
    , y : Int
    }


view : Model -> H.Html Msg
view model =
    [ List.range 0 10
        |> List.map Binary.uint8
        |> Binary.concat
        |> BD.decode
            (BD.succeed (\a b -> ( a, b ))
                |> BD.apply BD.uint8
                |> BD.ignore BD.uint8
                |> BD.apply BD.uint8
            )
    ]
        |> toString
        |> H.text

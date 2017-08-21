module BinaryTest exposing (..)

import Return exposing (Return)


--

import Array
import Binary
import Binary.Decode as BD exposing ((|=), (|.))
import Binary.LowLevel


--

import Html as H


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
    Binary.LowLevel.test ()
        |> Binary.LowLevel.fromArrayBuffer
        -- |> Array.map
        --     (\byte ->
        --         Array.empty
        --             |> Array.push byte
        --             |> Binary.LowLevel.toArrayBuffer
        --             |> Binary.LowLevel.getInt8 0
        --     )
        |> BD.decode
            (BD.succeed identity
                |. BD.int8
                |= BD.position
            )
        |> toString
        |> H.text

module HeartRateMonitor exposing (..)

import Html as H
import Html.Events as HE


--

import Task


--

import BinaryDecoder as BD
import BinaryDecoder.Byte as BDB exposing (ArrayBuffer)
import Bluetooth


main : Program Never Model Msg
main =
    H.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }



--


type BodySensorLocation
    = Other
    | Chest
    | Wrist
    | Finger
    | Hand
    | EarLobe
    | Foot
    | Unknown


bodySensorLocationDecoder : BDB.Decoder BodySensorLocation
bodySensorLocationDecoder =
    BDB.uint8
        |> BD.andThen
            (\i ->
                case i of
                    0 ->
                        Other
                            |> BD.succeed

                    1 ->
                        Chest
                            |> BD.succeed

                    2 ->
                        Wrist
                            |> BD.succeed

                    3 ->
                        Finger
                            |> BD.succeed

                    4 ->
                        Hand
                            |> BD.succeed

                    5 ->
                        EarLobe
                            |> BD.succeed

                    6 ->
                        Foot
                            |> BD.succeed

                    _ ->
                        Unknown
                            |> BD.succeed
            )



-- MODEL


type alias Model =
    Result () BodySensorLocation


init : ( Model, Cmd Msg )
init =
    ( Err (), Cmd.none )



-- UPDATE


type Msg
    = Connect
    | ReadBodySensorLocation (Result () ArrayBuffer)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Connect ->
            model
                ! [ Bluetooth.requestDevice ()
                        |> Bluetooth.connect
                        |> Task.andThen (Bluetooth.getPrimaryService "heart_rate")
                        |> Task.andThen (Bluetooth.getCharacteristic "body_sensor_location")
                        |> Task.andThen (Bluetooth.readValue)
                        |> Task.attempt ReadBodySensorLocation
                  ]

        ReadBodySensorLocation result ->
            (result
                |> Result.andThen
                    (BDB.decode bodySensorLocationDecoder
                        >> Result.mapError (always ())
                    )
            )
                ! []



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- VIEW


view : Model -> H.Html Msg
view model =
    H.div []
        [ model |> toString |> H.text
        , H.button [ HE.onClick Connect ] [ H.text "Connect" ]
        ]

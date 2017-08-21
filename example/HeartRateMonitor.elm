module HeartRateMonitor exposing (..)

import Html as H
import Html.Events as HE


--

import Task
import Return exposing (Return)


--

import Array exposing (Array)
import Binary exposing (Byte)
import Binary.Decode as BD exposing ((|.), (|=))
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


bodySensorLocationDecoder : BD.Decoder BodySensorLocation
bodySensorLocationDecoder =
    BD.int8
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



--


type alias HeartRate =
    { heartRate : Int }


heartRateDecoder : BD.Decoder HeartRate
heartRateDecoder =
    BD.succeed HeartRate
        -- The first byte holds some flags
        |. BD.int8
        |= BD.int8



-- MODEL


type alias Model =
    { service : Maybe Bluetooth.Service
    , heartRateCharacteristic : Maybe Bluetooth.Characteristic

    --
    , bodySensorLocation : Maybe BodySensorLocation
    , heartRate : Maybe HeartRate
    }


init : Return Msg Model
init =
    { service = Nothing
    , heartRateCharacteristic = Nothing

    --
    , bodySensorLocation = Nothing
    , heartRate = Nothing
    }
        |> Return.singleton



-- UPDATE


type Msg
    = Connect
    | GotService (Result () Bluetooth.Service)
    | GotHeartRateCharacteristic (Result () Bluetooth.Characteristic)
      --
    | ReadBodySensorLocation (Result () (Array Byte))
      --
    | GotHeartRate (Result BD.Error HeartRate)


update : Msg -> Model -> Return Msg Model
update msg model =
    case msg of
        Connect ->
            model
                |> Return.singleton
                |> Return.command
                    (Bluetooth.requestDevice ()
                        |> Bluetooth.connect
                        |> Task.andThen (Bluetooth.getPrimaryService "heart_rate")
                        |> Task.attempt GotService
                    )

        GotService (Ok service) ->
            { model | service = Just service }
                |> Return.singleton
                |> Return.command
                    (Bluetooth.getCharacteristic "body_sensor_location" service
                        |> Task.andThen Bluetooth.readValue
                        |> Task.attempt ReadBodySensorLocation
                    )
                |> Return.command
                    (Bluetooth.getCharacteristic "heart_rate_measurement" service
                        |> Task.attempt GotHeartRateCharacteristic
                    )

        GotService (Err ()) ->
            model
                |> Return.singleton

        GotHeartRateCharacteristic result ->
            result
                |> Result.toMaybe
                |> (\maybeCharacteristic ->
                        { model | heartRateCharacteristic = maybeCharacteristic }
                   )
                |> Return.singleton

        ReadBodySensorLocation result ->
            result
                |> Result.andThen
                    (BD.decode bodySensorLocationDecoder
                        >> Result.mapError (always ())
                    )
                |> Result.toMaybe
                |> (\sensorLocation -> { model | bodySensorLocation = sensorLocation })
                |> Return.singleton

        GotHeartRate result ->
            result
                |> Result.toMaybe
                |> (\maybeHR ->
                        { model | heartRate = maybeHR }
                   )
                |> Return.singleton



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    case model.heartRateCharacteristic of
        Just characteristic ->
            Bluetooth.notify characteristic (BD.decode heartRateDecoder >> GotHeartRate)

        Nothing ->
            Sub.none



-- VIEW


view : Model -> H.Html Msg
view model =
    H.div []
        [ model |> toString |> H.text
        , H.br [] []
        , H.button [ HE.onClick Connect ] [ H.text "Connect" ]
        ]

module HeartRateMonitor exposing (..)

import Html as H
import Html.Events as HE


--

import Task
import Return exposing (Return)
import Bitwise


--

import Binary exposing (ArrayBuffer)
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
    { flags : Int
    , heartRate : Int
    , sensorContact : Bool
    , energyExpended : Maybe Int
    , rrInterval : Maybe Int
    }


{-| See here for specification: <https://www.bluetooth.com/specifications/gatt/viewer?attributeXmlFile=org.bluetooth.characteristic.heart_rate_measurement.xml&u=org.bluetooth.characteristic.heart_rate_measurement.xml>
-}
heartRateDecoder : BD.Decoder HeartRate
heartRateDecoder =
    let
        isHearRate16bit flags =
            (Bitwise.and flags 1) /= 0

        sensorContact flags =
            (Bitwise.and flags 2) /= 0

        isEnergyExpendedPresent flags =
            (Bitwise.and flags 8) /= 0

        isRRIntervalPresent flags =
            (Bitwise.and flags 16) /= 0
    in
        BD.uint8
            |> BD.andThen
                (\flags ->
                    BD.succeed HeartRate
                        |= BD.succeed flags
                        |= (if isHearRate16bit flags then
                                BD.uint16
                            else
                                BD.uint8
                           )
                        |= BD.succeed (sensorContact flags)
                        |= (if isEnergyExpendedPresent flags then
                                BD.uint16LE
                                    |> BD.map Just
                            else
                                BD.succeed Nothing
                           )
                        |= (if isRRIntervalPresent flags then
                                BD.uint16LE
                                    |> BD.map Just
                            else
                                BD.succeed Nothing
                           )
                )



-- MODEL


type alias Model =
    { service : Maybe Bluetooth.Service
    , heartRateCharacteristic : Maybe Bluetooth.Characteristic

    --
    , bodySensorLocation : Maybe BodySensorLocation
    , heartRate : Result String HeartRate
    }


init : Return Msg Model
init =
    { service = Nothing
    , heartRateCharacteristic = Nothing

    --
    , bodySensorLocation = Nothing
    , heartRate = Err "Nothing to decode yet"
    }
        |> Return.singleton



-- UPDATE


type Msg
    = Connect
    | GotService (Result () Bluetooth.Service)
    | GotHeartRateCharacteristic (Result () Bluetooth.Characteristic)
      --
    | ReadBodySensorLocation (Result () ArrayBuffer)
      --
    | GotHeartRate (Result String HeartRate)


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
                |> (\hr ->
                        { model | heartRate = hr }
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

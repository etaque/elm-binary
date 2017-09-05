effect module Bluetooth
    where { subscription = MySub }
    exposing
        ( RequestOptions(..)
        , Filter(..)
        , Request
        , requestDevice
          --
        , Error(..)
          --
        , Device
        , connect
          --
        , Service
        , getPrimaryService
          --
        , Characteristic
        , getCharacteristic
        , readValue
        , notify
          --
        , onCharacteristicValueChanged
        )

{-| Access the WebBluetooth API (<https://webbluetoothcg.github.io/web-bluetooth/>)


# Requesting and connect with a device

@docs RequestOptions, Filter, Request, requestDevice, Device, connect


# Error handling

@docs Error


# Services

@docs Service, getPrimaryService


# Characteristic

@docs Characteristic, getCharacteristic, readValue, notify


# Low level

@docs onCharacteristicValueChanged

TODO:

  - writeValue (requires a way to encode binary data)
  - use `BluetoothUUID` and require ids to be UUIDs

-}

import Task exposing (Task)
import Process


--

import Json.Encode as JE


--

import Binary exposing (ArrayBuffer)
import Binary.Decode


--

import Native.Bluetooth


{-| Options while requesting a device (<https://webbluetoothcg.github.io/web-bluetooth/#dom-bluetooth-requestdevice>).
-}
type RequestOptions
    = Filters (List Filter)
    | AcceptAllDevices (List String)


encodeRequestOptions : RequestOptions -> JE.Value
encodeRequestOptions options =
    case options of
        Filters filters ->
            JE.object [ ( "filters", filters |> List.map encodeFilter |> JE.list ) ]

        AcceptAllDevices optionalServices ->
            JE.object
                [ ( "acceptAllDevices", JE.bool True )
                , ( "optionalServices", optionalServices |> List.map JE.string |> JE.list )
                ]


{-| Filter for request a device. See <https://webbluetoothcg.github.io/web-bluetooth/#matches-a-filter> for details.
-}
type Filter
    = Name String
    | NamePrefix String
    | Services (List String)


encodeFilter : Filter -> JE.Value
encodeFilter filter =
    case filter of
        Name name ->
            JE.object [ ( "name", JE.string name ) ]

        NamePrefix prefix ->
            JE.object [ ( "namePrefix", JE.string prefix ) ]

        Services services ->
            JE.object [ ( "services", services |> List.map JE.string |> JE.list ) ]


{-| A request to the user to connect with a device
-}
type Request
    = Request


{-| Request a device.

WARNING: This causes a side-effect without encapsulating in a Task. This breaks a lot of nice things about Elm.

Encapsulating this request in a Task did not work as it needs to be triggered directly by user interaction (<https://html.spec.whatwg.org/multipage/interaction.html#triggered-by-user-activation>).

TODO: Check if this could be implemented in a Task with the `isTrusted` attribute.

-}
requestDevice : RequestOptions -> Request
requestDevice requestOptions =
    Native.Bluetooth.requestDevice (requestOptions |> encodeRequestOptions)



--


{-| Error types

TODO: figure out all possible error types and get rid of Other

-}
type Error
    = NoBluetooth
    | DecodeError String
    | Other String



--


{-| A bluetooth device
-}
type Device
    = Device


{-| Connect to a bluetooth device.

Note: this will automatically create a connection to the `BluetoothRemoteGATTServer` (<https://webbluetoothcg.github.io/web-bluetooth/#bluetoothremotegattserver>). This is not automatically done in the pure WebBluetooth API. I don't see any reason why anyone would not want to directly connect with the `BluetoothRemoteGATTServer`.

-}
connect : Request -> Task Error Device
connect =
    Native.Bluetooth.connect



--


{-| A GATT service
-}
type Service
    = Service


{-| Get a primary GATT service.

Identifier can be an UUID or an alias to an UUID (e.g. `heart_rate`).

-}
getPrimaryService : String -> Device -> Task Error Service
getPrimaryService =
    Native.Bluetooth.getPrimaryService



--


{-| A GATT characteristic
-}
type Characteristic
    = Characteristic


{-| Get a characteristic
-}
getCharacteristic : String -> Service -> Task Error Characteristic
getCharacteristic =
    Native.Bluetooth.getCharacteristic


{-| Read a value from a characteristic

NOTE: This does not allow direct access to the raw ArrayBuffer but makes the usual case much easier. Maybe `readValueRaw` should be exposed or there should be a `Binary.Decoder.raw : Decoder ArrayBuffer`.

-}
readValue : Binary.Decode.Decoder a -> Characteristic -> Task Error a
readValue decoder characteristic =
    readValueRaw characteristic
        |> Task.andThen
            (\buffer ->
                case (Binary.Decode.decode decoder buffer) of
                    Ok a ->
                        Task.succeed a

                    Err err ->
                        Task.fail (DecodeError err)
            )


readValueRaw : Characteristic -> Task Error ArrayBuffer
readValueRaw =
    Native.Bluetooth.readValue


{-| Notify on changes in characteristic value.

This sets up a listener for the `charastericvaluechanged` event.

-}
notify : Characteristic -> (ArrayBuffer -> msg) -> Sub msg
notify characteristic tagger =
    subscription (Notify characteristic tagger)


{-| Add an event handler on the `charastericvaluechanged` event. The resulting task will never end, and when you kill the process it is on, it will detatch the relevant JavaScript event listener.

NOTE: This is ment to be used if you are crearing your own Effects Manager. In most cases you want to use `notify`.

-}
onCharacteristicValueChanged : (ArrayBuffer -> Task Never ()) -> Characteristic -> Task Never Never
onCharacteristicValueChanged =
    Native.Bluetooth.onCharacteristicValueChanged



-- Effect Manager


type MySub msg
    = Notify Characteristic (ArrayBuffer -> msg)


subMap : (a -> b) -> MySub a -> MySub b
subMap f (Notify characteristic tagger) =
    Notify characteristic (tagger >> f)


type alias State msg =
    { processes : List ( Characteristic, Process.Id )
    , subs : List (MySub msg)
    }


init : Task Never (State msg)
init =
    { processes = []
    , subs = []
    }
        |> Task.succeed


type Msg msg
    = ValueChanged Characteristic ArrayBuffer


onEffects : Platform.Router msg (Msg msg) -> List (MySub msg) -> State msg -> Task Never (State msg)
onEffects router subs state =
    let
        listeningCharacteristics =
            state.processes
                |> List.map Tuple.first

        subscribedCharacteristics =
            subs
                |> List.map (\(Notify characteristic _) -> characteristic)

        spawnProcesses : Task Never (List ( Characteristic, Process.Id ))
        spawnProcesses =
            subscribedCharacteristics
                |> List.filter (\characteristic -> not <| List.member characteristic listeningCharacteristics)
                |> List.map
                    (\characteristic ->
                        characteristic
                            |> onCharacteristicValueChanged (ValueChanged characteristic >> Platform.sendToSelf router)
                            |> Process.spawn
                            |> Task.map ((,) characteristic)
                    )
                |> Task.sequence

        killProcesses : Task Never (List Process.Id)
        killProcesses =
            state.processes
                |> List.filterMap
                    (\( characteristic, pid ) ->
                        if not <| List.member characteristic subscribedCharacteristics then
                            Just pid
                        else
                            Nothing
                    )
                |> List.map (\pid -> Process.kill pid |> Task.map (always pid))
                |> Task.sequence
    in
        Task.map2
            (\newProcesses killedProcesses ->
                { state
                    | subs = subs
                    , processes =
                        (state.processes
                            ++ newProcesses
                        )
                            |> List.filter (\( _, pid ) -> not <| List.member pid killedProcesses)
                }
            )
            spawnProcesses
            killProcesses


onSelfMsg : Platform.Router msg (Msg msg) -> Msg msg -> State msg -> Task Never (State msg)
onSelfMsg router msg state =
    case msg of
        ValueChanged characteristic buffer ->
            state.subs
                |> List.filterMap
                    (\(Notify subCharacteristic tagger) ->
                        if characteristic == subCharacteristic then
                            Platform.sendToApp router (tagger buffer)
                                |> Just
                        else
                            Nothing
                    )
                |> Task.sequence
                |> Task.map (always state)

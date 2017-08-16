effect module Bluetooth
    where { subscription = MySub }
    exposing
        ( RequestOptions
        , Request
        , requestDevice
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
        )

{-| Access the WebBluetooth API (<https://webbluetoothcg.github.io/web-bluetooth/>)


# Requesting and connect with a device

@dcs RequestOptions, Request, requestDevice, Device, connect


# Services

@docs Service, getPrimaryService


# Characteristic

@docs Characteristic, getCharacteristic, readValue, notify

TODO: writeValue (requires a way to encode binary data)

-}

import Task exposing (Task)
import Process


--

import BinaryDecoder.Byte exposing (ArrayBuffer)


--

import Native.Bluetooth


{-| Options while requesting a device (<https://webbluetoothcg.github.io/web-bluetooth/#dom-bluetooth-requestdevice>).

TODO: implement properly. Currently options are hardcoded in the Native binding.

-}
type alias RequestOptions =
    ()


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
    Native.Bluetooth.requestDevice requestOptions



--


{-| A bluetooth device
-}
type Device
    = Device


{-| Connect to a bluetooth device.

Note: this will automatically create a connection to the `BluetoothRemoteGATTServer` (<https://webbluetoothcg.github.io/web-bluetooth/#bluetoothremotegattserver>). This is not automatically done in the pure WebBluetooth API. I don't see any reason why anyone would not want to directly connect with the `BluetoothRemoteGATTServer`.

-}
connect : Request -> Task () Device
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
getPrimaryService : String -> Device -> Task () Service
getPrimaryService =
    Native.Bluetooth.getPrimaryService



--


{-| A GATT characteristic
-}
type Characteristic
    = Characteristic


{-| Get a characteristic
-}
getCharacteristic : String -> Service -> Task () Characteristic
getCharacteristic =
    Native.Bluetooth.getCharacteristic


{-| Read a value from a characteristic
-}
readValue : Characteristic -> Task () ArrayBuffer
readValue =
    Native.Bluetooth.readValue


{-| Notify on changes in characteristic value.

This sets up a listener for the `charastericvaluechanged` event.

-}
notify : Characteristic -> (ArrayBuffer -> msg) -> Sub msg
notify characteristic tagger =
    subscription (Notify characteristic tagger)


{-| Add an event handler on the `charastericvaluechanged` event. The resulting task will never end, and when you kill the process it is on, it will detatch the relevant JavaScript event listener.
-}
onCharacteristicValueChanged : (ArrayBuffer -> Task Never ()) -> Characteristic -> Task Never Never
onCharacteristicValueChanged =
    Native.Bluetooth.onCharacteristicValueChanged



-- Effect Manager
{- Lot of work to do here!

   Currently only one (the first) subscription is handled. We need a mechanism to identify which subscriptions already have a notify listener set up, which ones not and which notify processes can be killed. This requires some kind of `Dict` (as in Websocket). However we don't have a nice (comparable) identifier to use.

   TODO: figure out a datastructure to track subscriptions and corresponding active processes.
-}


type MySub msg
    = Notify Characteristic (ArrayBuffer -> msg)


subMap : (a -> b) -> MySub a -> MySub b
subMap f (Notify characteristic tagger) =
    Notify characteristic (tagger >> f)


type alias State =
    Maybe Process.Id


init : Task Never State
init =
    Nothing
        |> Task.succeed


type Msg msg
    = CharacteristicValueChanged (ArrayBuffer -> msg) ArrayBuffer


(&>) t1 t2 =
    t1 |> Task.andThen (\_ -> t2)


onEffects : Platform.Router msg (Msg msg) -> List (MySub msg) -> State -> Task Never State
onEffects router subs state =
    case ( state, subs ) of
        ( Just pid, [] ) ->
            Process.kill pid
                &> Task.succeed Nothing

        ( Nothing, [] ) ->
            Task.succeed Nothing

        ( Nothing, (Notify characteristic tagger) :: rest ) ->
            characteristic
                |> onCharacteristicValueChanged
                    (\buffer ->
                        buffer
                            |> CharacteristicValueChanged tagger
                            |> Platform.sendToSelf router
                    )
                |> Process.spawn
                |> Task.andThen (Just >> Task.succeed)

        ( Just pid, _ ) ->
            Task.succeed state


onSelfMsg : Platform.Router msg (Msg msg) -> Msg msg -> State -> Task Never State
onSelfMsg router msg state =
    case msg of
        CharacteristicValueChanged tagger buffer ->
            buffer
                |> tagger
                |> Platform.sendToApp router
                |> Task.andThen (always <| Task.succeed state)

module Bluetooth exposing (..)

import Task exposing (Task)


--

import BinaryDecoder.Byte exposing (ArrayBuffer)


--

import Native.Bluetooth


type alias RequestOptions =
    ()


{-| A request to the user to connect with a device
-}
type Request
    = Request


requestDevice : RequestOptions -> Request
requestDevice requestOptions =
    Native.Bluetooth.requestDevice requestOptions



--


{-| A bluetooth device
-}
type Device
    = Device


connect : Request -> Task () Device
connect =
    Native.Bluetooth.connect



--


{-| A GATT service
-}
type Service
    = Service


type alias ServiceUUID =
    String


getPrimaryService : ServiceUUID -> Device -> Task () Service
getPrimaryService =
    Native.Bluetooth.getPrimaryService



--


type Characteristic
    = Characteristic


getCharacteristic : String -> Service -> Task () Characteristic
getCharacteristic =
    Native.Bluetooth.getCharacteristic


readValue : Characteristic -> Task () ArrayBuffer
readValue =
    Native.Bluetooth.readValue

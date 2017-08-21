module Binary.LowLevel exposing (..)

import Array exposing (Array)


--

import Native.Binary


type Byte
    = Byte



--


type ArrayBuffer
    = ArrayBuffer


toArrayBuffer : Array Byte -> ArrayBuffer
toArrayBuffer =
    Native.Binary.toArrayBuffer


fromArrayBuffer : ArrayBuffer -> Array Byte
fromArrayBuffer =
    Native.Binary.fromArrayBuffer


getInt8 : Int -> ArrayBuffer -> Maybe Int
getInt8 =
    Native.Binary.getInt8


test : () -> ArrayBuffer
test =
    Native.Binary.test

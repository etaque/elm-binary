module Binary exposing (..)

import Native.Binary
import Binary.LowLevel
import Array exposing (Array)


--


type alias Byte =
    Binary.LowLevel.Byte


zeros : Int -> Array Byte
zeros n =
    let
        n_ =
            max 0 n
    in
        Native.Binary.zeros n_
            |> Binary.LowLevel.fromArrayBuffer


int8 : Int -> Array Byte
int8 =
    Native.Binary.int8
        >> Binary.LowLevel.fromArrayBuffer


uint8 : Int -> Array Byte
uint8 =
    Native.Binary.uint8
        >> Binary.LowLevel.fromArrayBuffer



--
-- int16 : Int -> Array Byte
-- int16 =
--     Native.Binary.int16
--         >> fromArrayBuffer
--
--
-- uint16 : Int -> Array Byte
-- uint16 =
--     Native.Binary.uint16
--         >> fromArrayBuffer
--
--
-- int32 : Int -> Array Byte
-- int32 =
--     Native.Binary.int32
--         >> fromArrayBuffer
--
--
-- uint32 : Int -> Array Byte
-- uint32 =
--     Native.Binary.uint32
--         >> fromArrayBuffer
--

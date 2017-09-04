module Binary exposing (..)

{-| Binary data
-}

import Native.Binary


{-| The basic binary type. Corresponds to a JavaScript ArrayBuffer.
-}
type ArrayBuffer
    = ArrayBuffer


{-| Create an ArrayBuffer of n bytes filled with 0.
-}
zeros : Int -> ArrayBuffer
zeros n =
    let
        n_ =
            max 0 n
    in
        Native.Binary.zeros n_


{-| Encode as int8
-}
int8 : Int -> ArrayBuffer
int8 =
    Native.Binary.int8


{-| Encode as uint8
-}
uint8 : Int -> ArrayBuffer
uint8 =
    Native.Binary.uint8



--


int16 : Int -> ArrayBuffer
int16 =
    Native.Binary.int16 False


int16LE : Int -> ArrayBuffer
int16LE =
    Native.Binary.int16 True


uint16 : Int -> ArrayBuffer
uint16 =
    Native.Binary.uint16 False


uint16LE : Int -> ArrayBuffer
uint16LE =
    Native.Binary.uint16 True



--


int32 : Int -> ArrayBuffer
int32 =
    Native.Binary.int32 False


int32LE : Int -> ArrayBuffer
int32LE =
    Native.Binary.int32 True


uint32 : Int -> ArrayBuffer
uint32 =
    Native.Binary.uint32 False


uint32LE : Int -> ArrayBuffer
uint32LE =
    Native.Binary.uint32 True



--


float32 : Float -> ArrayBuffer
float32 =
    Native.Binary.float32 False


float32LE : Float -> ArrayBuffer
float32LE =
    Native.Binary.float32 True


float64 : Float -> ArrayBuffer
float64 =
    Native.Binary.float64 False


float64LE : Float -> ArrayBuffer
float64LE =
    Native.Binary.float64 True



--


{-| Concat a list of ArrayBuffers to an ArrayBuffer.
-}
concat : List ArrayBuffer -> ArrayBuffer
concat =
    Native.Binary.concat


{-| Return lenght of ArrayBuffer in bytes.
-}
length : ArrayBuffer -> Int
length =
    Native.Binary.length


{-| Get content of ArrayBuffer from specified begin byte offset (inclusive) to end (exclusive).
-}
slice : Int -> Int -> ArrayBuffer -> Maybe ArrayBuffer
slice =
    Native.Binary.slice

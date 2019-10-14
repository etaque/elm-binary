module Binary exposing
    ( ArrayBuffer(..), zeros
    , concat, length, slice
    , int8, uint8, int16, int16LE
    , uint16, uint16LE
    , int32, int32LE, uint32, uint32LE
    , float32, float32LE, float64, float64LE
    , char, string
    )

{-| Binary data


# Basics

@docs ArrayBuffer, zeros
@docs concat, length, slice


# Encoding


## Integers

@docs int8, uint8, int16, int16LE
@docs uint16, uint16LE
@docs int32, int32LE, uint32, uint32LE


## Floats

@docs float32, float32LE, float64, float64LE

@@ Characters

@docs char, string

-}

import Char
import Elm.Kernel.Binary
import String


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
    Elm.Kernel.Binary.zeros n_


{-| Encode as int8
-}
int8 : Int -> ArrayBuffer
int8 =
    Elm.Kernel.Binary.int8


{-| Encode as uint8
-}
uint8 : Int -> ArrayBuffer
uint8 =
    Elm.Kernel.Binary.uint8



--


{-| Encode as int16
-}
int16 : Int -> ArrayBuffer
int16 =
    Elm.Kernel.Binary.int16 False


{-| Encode as int16 (little-endian)
-}
int16LE : Int -> ArrayBuffer
int16LE =
    Elm.Kernel.Binary.int16 True


{-| Encode as uint16
-}
uint16 : Int -> ArrayBuffer
uint16 =
    Elm.Kernel.Binary.uint16 False


{-| Encode as uint16 (little-endian)
-}
uint16LE : Int -> ArrayBuffer
uint16LE =
    Elm.Kernel.Binary.uint16 True



--


{-| Encode as int32
-}
int32 : Int -> ArrayBuffer
int32 =
    Elm.Kernel.Binary.int32 False


{-| Encode as int32 (little-endian)
-}
int32LE : Int -> ArrayBuffer
int32LE =
    Elm.Kernel.Binary.int32 True


{-| Encode as uint32
-}
uint32 : Int -> ArrayBuffer
uint32 =
    Elm.Kernel.Binary.uint32 False


{-| Encode as uint32 (little-endian)
-}
uint32LE : Int -> ArrayBuffer
uint32LE =
    Elm.Kernel.Binary.uint32 True



--


{-| Encode as 32bit float
-}
float32 : Float -> ArrayBuffer
float32 =
    Elm.Kernel.Binary.float32 False


{-| Encode as 32bit float (little-endian)
-}
float32LE : Float -> ArrayBuffer
float32LE =
    Elm.Kernel.Binary.float32 True


{-| Encode as 64bit float
-}
float64 : Float -> ArrayBuffer
float64 =
    Elm.Kernel.Binary.float64 False


{-| Encode as 64bit float (little-endian)
-}
float64LE : Float -> ArrayBuffer
float64LE =
    Elm.Kernel.Binary.float64 True



--


{-| Encode a single character
-}
char : Char -> ArrayBuffer
char =
    Char.toCode >> uint8


{-| Encode an ASCII String
-}
string : String -> ArrayBuffer
string =
    String.toList
        >> List.map char
        >> concat



--


{-| Concat a list of ArrayBuffers to an ArrayBuffer.
-}
concat : List ArrayBuffer -> ArrayBuffer
concat =
    Elm.Kernel.Binary.concat


{-| Return lenght of ArrayBuffer in bytes.
-}
length : ArrayBuffer -> Int
length =
    Elm.Kernel.Binary.length


{-| Get content of ArrayBuffer from specified begin byte offset (inclusive) to end (exclusive).
-}
slice : Int -> Int -> ArrayBuffer -> Maybe ArrayBuffer
slice =
    Elm.Kernel.Binary.slice

module Binary exposing (..)

import Native.Binary


type ArrayBuffer
    = ArrayBuffer


zeros : Int -> ArrayBuffer
zeros n =
    let
        n_ =
            max 0 n
    in
        Native.Binary.zeros n_


int8 : Int -> ArrayBuffer
int8 =
    Native.Binary.int8


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


concat : List ArrayBuffer -> ArrayBuffer
concat =
    Native.Binary.concat

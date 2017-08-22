module Binary.Decode
    exposing
        ( Decoder
        , decode
          --
        , succeed
        , fail
        , andThen
        , map
        , map2
        , apply
        , (|=)
        , ignore
        , (|.)
          --
        , sequence
        , repeat
        , many
          --
        , position
        , skip
        , goto
          --
        , int8
        , uint8
        , int16
        , int16LE
        , uint16
        , uint16LE
        , int32
        , int32LE
        , uint32
        , uint32LE
        , float32
        , float32LE
        , float64
        , float64LE
        )

import Binary exposing (ArrayBuffer)


type alias State =
    { position : Int
    , context : List ( Int, String )
    , source : DataView
    }


type alias Error =
    { position : Int
    , context : List ( Int, String )
    , msg : String
    }


{-| A binary decoder.
-}
type Decoder a
    = Decoder (State -> Result Error ( State, a ))


{-| Run the decoder.
-}
decode : Decoder a -> ArrayBuffer -> Result String a
decode (Decoder f) source =
    f (State 0 [] (dataView source))
        |> Result.map Tuple.second
        |> Result.mapError
            (\err ->
                err.msg
                    ++ " at position "
                    ++ (toString err.position)
             -- TODO: add context to error message
            )



-- PRIMITIVES


{-| Decoder that succeeds without doing anything.
-}
succeed : a -> Decoder a
succeed a =
    Decoder (\state -> Ok ( state, a ))


{-| Decoder that always fails.
-}
fail : String -> Decoder a
fail msg =
    Decoder (\state -> Err (Error state.position state.context msg))


{-| Run a decoder and then run another decoder.
-}
andThen : (a -> Decoder b) -> Decoder a -> Decoder b
andThen f (Decoder decoderA) =
    Decoder
        (\state1 ->
            decoderA state1
                |> Result.andThen
                    (\( state2, a ) ->
                        let
                            (Decoder decoderB) =
                                f a
                        in
                            decoderB state2
                    )
        )


{-| Transform result of a decoder.
-}
map : (a -> b) -> Decoder a -> Decoder b
map f =
    andThen (f >> succeed)


{-| Combine the result from two decoders.
-}
map2 : (a -> b -> c) -> Decoder a -> Decoder b -> Decoder c
map2 f decoderA decoderB =
    decoderA
        |> andThen
            (\a ->
                decoderB
                    |> map (f a)
            )


{-| Apply the result of a decoder to a decoder.
-}
apply : Decoder a -> Decoder (a -> b) -> Decoder b
apply =
    map2 (|>)


{-| Run a decoder and keep the value in the pipeline.
-}
(|=) : Decoder (a -> b) -> Decoder a -> Decoder b
(|=) =
    map2 (<|)


{-| Run a decoder and ignore thre result.
-}
ignore : Decoder b -> Decoder a -> Decoder a
ignore =
    map2 (flip always)


{-| Run a decoder and ignore the result.
-}
(|.) : Decoder a -> Decoder b -> Decoder a
(|.) =
    map2 always


infixl 5 |=


infixl 5 |.


{-| Sequence a list of decoders.
-}
sequence : List (Decoder a) -> Decoder (List a)
sequence decoders =
    case decoders of
        [] ->
            succeed []

        headDecoder :: tailDecoders ->
            headDecoder
                |> andThen
                    (\headValue ->
                        sequence tailDecoders
                            |> map (\tailValues -> headValue :: tailValues)
                    )


{-| Repeat a decoder n times and collect decoded values in a list.
-}
repeat : Int -> Decoder a -> Decoder (List a)
repeat n decoder =
    sequence (List.repeat n decoder)


{-| Apply a decoder many times until it fails.
-}
many : Decoder a -> Decoder (List a)
many (Decoder decoder) =
    let
        manyHelp decoder state =
            case decoder state of
                Ok ( newState, a ) ->
                    manyHelp decoder newState
                        |> Result.map (Tuple.mapSecond ((::) a))

                Err _ ->
                    Ok ( state, [] )
    in
        Decoder
            (\state ->
                manyHelp decoder state
            )



-- POSITION


{-| Get current decoder position.
-}
position : Decoder Int
position =
    Decoder (\state -> Ok ( state, state.position ))


{-| Move the decoder position by a relative offset.
-}
skip : Int -> Decoder ()
skip n =
    Decoder
        (\state ->
            Ok ( { state | position = state.position + n }, () )
        )


{-| Go to a specific position and continue decoding there.
-}
goto : Int -> Decoder ()
goto n =
    Decoder
        (\state ->
            Ok ( { state | position = n }, () )
        )



-- INT


{-| Decode int8.
-}
int8 : Decoder Int
int8 =
    Decoder
        (\state ->
            state.source
                |> getInt8 state.position
                |> toResult state 1 "could not get int8"
        )


{-| Decode uint8.
-}
uint8 : Decoder Int
uint8 =
    Decoder
        (\state ->
            state.source
                |> getUint8 state.position
                |> toResult state 1 "could not get uint8"
        )


int16 : Decoder Int
int16 =
    Decoder
        (\state ->
            state.source
                |> getInt16 False state.position
                |> toResult state 2 "could not get int16"
        )


int16LE : Decoder Int
int16LE =
    Decoder
        (\state ->
            state.source
                |> getInt16 True state.position
                |> toResult state 2 "could not get int16LE"
        )


uint16 : Decoder Int
uint16 =
    Decoder
        (\state ->
            state.source
                |> getUint16 False state.position
                |> toResult state 2 "could not get uint16"
        )


uint16LE : Decoder Int
uint16LE =
    Decoder
        (\state ->
            state.source
                |> getUint16 True state.position
                |> toResult state 2 "could not get uint16LE"
        )


int32 : Decoder Int
int32 =
    Decoder
        (\state ->
            state.source
                |> getInt32 False state.position
                |> toResult state 4 "could not get int32"
        )


int32LE : Decoder Int
int32LE =
    Decoder
        (\state ->
            state.source
                |> getInt32 True state.position
                |> toResult state 4 "could not get int32LE"
        )


uint32 : Decoder Int
uint32 =
    Decoder
        (\state ->
            state.source
                |> getUint32 False state.position
                |> toResult state 4 "could not get uint32"
        )


uint32LE : Decoder Int
uint32LE =
    Decoder
        (\state ->
            state.source
                |> getUint32 True state.position
                |> toResult state 4 "could not get uint32LE"
        )


float32 : Decoder Float
float32 =
    Decoder
        (\state ->
            state.source
                |> getFloat32 False state.position
                |> toResult state 4 "could not get float32"
        )


float32LE : Decoder Float
float32LE =
    Decoder
        (\state ->
            state.source
                |> getFloat32 True state.position
                |> toResult state 4 "could not get float32LE"
        )


float64 : Decoder Float
float64 =
    Decoder
        (\state ->
            state.source
                |> getFloat64 False state.position
                |> toResult state 8 "could not get float64"
        )


float64LE : Decoder Float
float64LE =
    Decoder
        (\state ->
            state.source
                |> getFloat64 True state.position
                |> toResult state 8 "could not get float64LE"
        )



-- LOW LEVEL


type DataView
    = DataView


dataView : ArrayBuffer -> DataView
dataView =
    Native.Binary.dataView


getInt8 : Int -> DataView -> Maybe Int
getInt8 =
    Native.Binary.getInt8


getUint8 : Int -> DataView -> Maybe Int
getUint8 =
    Native.Binary.getUint8


getInt16 : Bool -> Int -> DataView -> Maybe Int
getInt16 =
    Native.Binary.getInt16


getUint16 : Bool -> Int -> DataView -> Maybe Int
getUint16 =
    Native.Binary.getUint16


getInt32 : Bool -> Int -> DataView -> Maybe Int
getInt32 =
    Native.Binary.getInt32


getUint32 : Bool -> Int -> DataView -> Maybe Int
getUint32 =
    Native.Binary.getUint32


getFloat32 : Bool -> Int -> DataView -> Maybe Float
getFloat32 =
    Native.Binary.getFloat32


getFloat64 : Bool -> Int -> DataView -> Maybe Float
getFloat64 =
    Native.Binary.getFloat64



-- HELPERS


toResult : State -> Int -> String -> Maybe a -> Result Error ( State, a )
toResult state offset errorMsg maybe =
    case maybe of
        Just a ->
            Ok ( { state | position = state.position + offset }, a )

        Nothing ->
            Err (Error state.position state.context errorMsg)

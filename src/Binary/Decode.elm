module Binary.Decode
    exposing
        ( Decoder
        , decode
        , Error
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
        , position
        , move
        , goto
          --
        , int8
        )

import Array exposing (Array)
import Binary exposing (Byte)
import Binary.LowLevel


-- Basics that could also go into a more generic Array.Decode


type alias State =
    { position : Int
    , context : List ( Int, String )
    , source : Array Byte
    }


type alias Error =
    { position : Int
    , context : List ( Int, String )
    , msg : String
    }


type Decoder a
    = Decoder (State -> Result Error ( State, a ))


decode : Decoder a -> Array Byte -> Result Error a
decode (Decoder f) source =
    f (State 0 [] source)
        |> Result.map Tuple.second


succeed : a -> Decoder a
succeed a =
    Decoder (\state -> Ok ( state, a ))


fail : String -> Decoder a
fail msg =
    Decoder (\state -> Err (Error state.position state.context msg))


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


map : (a -> b) -> Decoder a -> Decoder b
map f =
    andThen (f >> succeed)


map2 : (a -> b -> c) -> Decoder a -> Decoder b -> Decoder c
map2 f decoderA decoderB =
    decoderA
        |> andThen
            (\a ->
                decoderB
                    |> map (f a)
            )



-- map2 : (a -> b -> c) -> Decoder a -> Decoder b -> Decoder c
-- map2 f (Decoder decoderA) (Decoder decoderB) =
--     Decoder
--         (\state1 ->
--             decoderA state1
--                 |> Result.andThen
--                     (\( state2, a ) ->
--                         decoderB state2
--                             |> Result.map (\( state3, b ) -> ( state3, f a b ))
--                     )
--         )
--


apply : Decoder a -> Decoder (a -> b) -> Decoder b
apply =
    -- Note: (|>) : a -> (a -> b) -> b
    map2 (|>)


(|=) : Decoder (a -> b) -> Decoder a -> Decoder b
(|=) =
    flip apply


ignore : Decoder b -> Decoder a -> Decoder a
ignore =
    flip (|.)


(|.) : Decoder a -> Decoder b -> Decoder a
(|.) =
    map2 always


infixl 5 |=


infixl 5 |.


{-| Get current decoder position
-}
position : Decoder Int
position =
    Decoder (\state -> Ok ( state, state.position ))


{-| Move the decoder position by a relative offset.
-}
move : Int -> Decoder ()
move n =
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



-- Byte specific


{-| Decode int8
-}
int8 : Decoder Int
int8 =
    Decoder
        (\state ->
            state.source
                |> Array.slice state.position (state.position + 1)
                |> Binary.LowLevel.toArrayBuffer
                |> Binary.LowLevel.getInt8 0
                |> toResult { state | position = state.position + 1 } "could not get int8"
        )



-- HELPERS


toResult : State -> String -> Maybe a -> Result Error ( State, a )
toResult state errorMsg maybe =
    case maybe of
        Just a ->
            Ok ( state, a )

        Nothing ->
            Err (Error state.position state.context errorMsg)

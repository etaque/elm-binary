module Tests exposing (suite)

import Binary exposing (ArrayBuffer)
import Binary.Decode as BD
import Expect
import Fuzz
import Test exposing (..)


suite : Test
suite =
    describe "Binary"
        [ basicOperations
        , basicTypes
        , algebraic
        , decoder
        ]


basicOperations : Test
basicOperations =
    describe "basic operations"
        [ test "concat" <|
            \_ ->
                [ Binary.zeros 8, Binary.zeros 2, Binary.zeros 6 ]
                    |> Binary.concat
                    |> Binary.length
                    |> Expect.equal 16
        , test "equality" <|
            \_ ->
                (Binary.uint32 0 /= Binary.uint32 1)
                    |> Expect.true "Expecting uint32 0 /= uint32 1"
        , fuzz (Fuzz.intRange 0 64) "lenght (zeros)" <|
            \n ->
                Binary.zeros n
                    |> Binary.length
                    |> Expect.equal n
        , test "lenght (mixed types)" <|
            \_ ->
                [ Binary.float64 3.141, Binary.int32LE 42, Binary.uint8 0 ]
                    |> Binary.concat
                    |> Binary.length
                    |> Expect.equal (8 + 4 + 1)
        , fuzz (Fuzz.map2 Tuple.pair (Fuzz.intRange 0 28) (Fuzz.intRange -32768 32767)) "slice" <|
            \( offset, v ) ->
                [ Binary.zeros offset, Binary.int32 v, Binary.zeros (32 - 4 - offset) ]
                    |> Binary.concat
                    |> Binary.slice offset (offset + 4)
                    |> Maybe.withDefault (Binary.zeros 4)
                    |> BD.decode BD.int32
                    |> Expect.equal (Ok v)
        ]


basicTypes : Test
basicTypes =
    let
        basicTest : String -> Fuzz.Fuzzer a -> (a -> ArrayBuffer) -> BD.Decoder a -> Test
        basicTest name fuzzer encoder decoder_ =
            fuzz fuzzer name <|
                \a ->
                    encoder a
                        -- Repeat multiple times to make sure decoder shifts forward properly after successfull decoding
                        |> List.repeat 3
                        |> Binary.concat
                        |> BD.decode (BD.many decoder_)
                        |> Expect.equal (Ok (a |> List.repeat 3))
    in
    describe "basic types"
        [ fuzz (Fuzz.intRange 0 50) "zeros" <|
            \n ->
                Binary.zeros n
                    |> BD.decode (BD.many BD.int8)
                    |> Expect.equal (Ok (List.repeat n 0))
        , basicTest "int8" (Fuzz.intRange -128 127) Binary.int8 BD.int8
        , test "int8 overflow" <|
            \_ ->
                Binary.int8 128
                    |> BD.decode BD.int8
                    |> Expect.equal (Ok -128)
        , basicTest "uint8" (Fuzz.intRange 0 255) Binary.uint8 BD.uint8
        , basicTest "int16" (Fuzz.intRange -32768 32767) Binary.int16 BD.int16
        , basicTest "int16LE" (Fuzz.intRange -32768 32767) Binary.int16LE BD.int16LE
        , basicTest "uint16" (Fuzz.intRange 0 65535) Binary.uint16 BD.uint16
        , basicTest "uint16LE" (Fuzz.intRange 0 65535) Binary.uint16LE BD.uint16LE
        , basicTest "int32" (Fuzz.intRange -32768 32767) Binary.int32 BD.int32
        , basicTest "int32LE" (Fuzz.intRange -32768 32767) Binary.int32LE BD.int32LE
        , basicTest "uint32" (Fuzz.intRange 0 65535) Binary.uint32 BD.uint32
        , basicTest "uint32LE" (Fuzz.intRange 0 65535) Binary.uint32LE BD.uint32LE

        -- Testing float32 is tricky as Elm uses 64 bit floats internally. We loose precision and can only check that it is close enough.
        , fuzz (Fuzz.floatRange -10 10) "float32" <|
            \a ->
                Binary.float32 a
                    |> List.repeat 3
                    |> Binary.concat
                    |> BD.decode (BD.many BD.float32)
                    |> Result.withDefault []
                    |> List.map ((-) a)
                    |> List.map abs
                    |> List.maximum
                    |> Maybe.withDefault 1000
                    |> Expect.atMost 1.0e-6
        , fuzz (Fuzz.floatRange -10 10) "float32LE" <|
            \a ->
                Binary.float32LE a
                    |> List.repeat 3
                    |> Binary.concat
                    |> BD.decode (BD.many BD.float32LE)
                    |> Result.withDefault []
                    |> List.map ((-) a)
                    |> List.map abs
                    |> List.maximum
                    |> Maybe.withDefault 1000
                    |> Expect.atMost 1.0e-6
        , basicTest "float64" Fuzz.float Binary.float64 BD.float64
        , basicTest "float64LE" Fuzz.float Binary.float64LE BD.float64LE
        , basicTest "char" Fuzz.char Binary.char BD.char
        , fuzz Fuzz.string "string (fixed-lenght)" <|
            \a ->
                Binary.string a
                    |> BD.decode (BD.string (String.length a))
                    |> Expect.equal (Ok a)
        ]


algebraic : Test
algebraic =
    let
        additionFuzzer : Fuzz.Fuzzer (Int -> Int)
        additionFuzzer =
            Fuzz.int
                |> Fuzz.map (\a -> (+) a)

        extract : BD.Decoder a -> Result String a
        extract decoder_ =
            BD.decode decoder_ (Binary.zeros 10)
    in
    describe "Algebraic"
        [ describe "Functor Laws"
            [ fuzz Fuzz.int "identity preserved over map" <|
                \a ->
                    BD.map identity (BD.succeed a)
                        |> extract
                        |> Expect.equal (BD.succeed a |> extract)
            , fuzz (Fuzz.map3 (\a b c -> ( a, b, c )) additionFuzzer additionFuzzer Fuzz.int) "Function composition" <|
                \( f, g, value ) ->
                    BD.map (f >> g) (BD.succeed value)
                        |> extract
                        |> Expect.equal (BD.apply (BD.succeed value) (BD.map2 (>>) (BD.succeed f) (BD.succeed g)) |> extract)
            ]
        ]


decoder : Test
decoder =
    describe "Decode"
        [ test "succeed" <|
            \_ ->
                Binary.int8 0
                    |> BD.decode (BD.succeed 0)
                    |> Expect.equal (Ok 0)
        , test "fail" <|
            \_ ->
                Binary.int8 0
                    |> BD.decode (BD.fail "Just like that.")
                    |> Expect.err
        , test "andThen" <|
            \_ ->
                Binary.int8 0
                    |> BD.decode (BD.succeed 0 |> BD.andThen (\a -> BD.succeed (a + 1)))
                    |> Expect.equal (Ok 1)
        , test "map" <|
            \_ ->
                Binary.int8 0
                    |> BD.decode (BD.succeed 0 |> BD.map ((+) 1))
                    |> Expect.equal (Ok 1)
        , test "map2" <|
            \_ ->
                Binary.int8 0
                    |> BD.decode (BD.map2 Tuple.pair (BD.succeed 0) (BD.succeed 1))
                    |> Expect.equal (Ok ( 0, 1 ))
        , test "apply" <|
            \_ ->
                Binary.int8 0
                    |> BD.decode
                        (BD.succeed Tuple.pair
                            |> BD.apply (BD.succeed 0)
                            |> BD.apply (BD.succeed 1)
                        )
                    |> Expect.equal (Ok ( 0, 1 ))
        , test "ignore does not change result" <|
            \_ ->
                Binary.int8 0
                    |> BD.decode
                        (BD.succeed Tuple.pair
                            |> BD.apply (BD.succeed 0)
                            |> BD.ignore (BD.succeed 2)
                            |> BD.apply (BD.succeed 1)
                            |> BD.ignore (BD.succeed 2)
                            |> BD.ignore (BD.succeed 3)
                            |> BD.ignore (BD.succeed 5)
                            |> BD.ignore (BD.succeed 2)
                        )
                    |> Expect.equal (Ok ( 0, 1 ))
        , test "ignore can cause fail" <|
            \_ ->
                Binary.int8 0
                    |> BD.decode
                        (BD.succeed identity
                            |> BD.apply (BD.succeed "What??")
                            |> BD.ignore (BD.fail "Fail!")
                        )
                    |> Expect.err
        , test "position is inititalized at 0" <|
            \_ ->
                Binary.int8 0
                    |> BD.decode BD.position
                    |> Expect.equal (Ok 0)
        , fuzz Fuzz.int "position can be set with goto" <|
            \n ->
                Binary.int8 0
                    |> BD.decode
                        (BD.succeed identity
                            |> BD.ignore (BD.goto n)
                            |> BD.apply BD.position
                        )
                    |> Expect.equal (Ok n)
        , fuzz Fuzz.int "position can be skipped" <|
            \n ->
                Binary.int8 0
                    |> BD.decode
                        (BD.succeed identity
                            |> BD.ignore (BD.skip n)
                            |> BD.apply BD.position
                        )
                    |> Expect.equal (Ok n)
        , test "can get source ArrayBuffer" <|
            \_ ->
                Binary.zeros 16
                    |> BD.decode BD.source
                    |> Expect.equal (Ok <| Binary.zeros 16)
        , test "can decode n bytes are ArrayBuffer" <|
            \_ ->
                Binary.zeros 16
                    |> BD.decode (BD.arrayBuffer 8)
                    |> Expect.equal (Ok <| Binary.zeros 8)
        ]

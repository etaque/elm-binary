module Binary.Test exposing (suite)

import Test exposing (..)
import Expect
import Fuzz


--

import Binary exposing (ArrayBuffer)
import Binary.Decode as BD exposing ((|=), (|.))


suite : Test
suite =
    describe "Binary"
        [ encoding
        , decoder
        ]


encoding : Test
encoding =
    let
        basicTest : String -> Fuzz.Fuzzer a -> (a -> ArrayBuffer) -> BD.Decoder a -> Test
        basicTest name fuzzer encoder decoder =
            fuzz fuzzer name <|
                \a ->
                    encoder a
                        |> List.repeat 3
                        |> Binary.concat
                        |> BD.decode (BD.many decoder)
                        |> Expect.equal (Ok (a |> List.repeat 3))
    in
        describe "basic types"
            [ fuzz (Fuzz.intRange 0 50) "zeros" <|
                \n ->
                    Binary.zeros n
                        |> BD.decode (BD.many BD.int8)
                        |> Expect.equal (Ok (List.repeat n 0))
            , basicTest "int8-" (Fuzz.intRange -128 127) Binary.int8 BD.int8
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
                    |> BD.decode (BD.map2 (,) (BD.succeed 0) (BD.succeed 1))
                    |> Expect.equal (Ok ( 0, 1 ))
        , test "apply" <|
            \_ ->
                Binary.int8 0
                    |> BD.decode
                        (BD.succeed (,)
                            |> BD.apply (BD.succeed 0)
                            |> BD.apply (BD.succeed 1)
                        )
                    |> Expect.equal (Ok ( 0, 1 ))
        , test "ignore does not change result" <|
            \_ ->
                Binary.int8 0
                    |> BD.decode
                        (BD.succeed (,)
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
        , test "infix apply" <|
            \_ ->
                Binary.int8 0
                    |> BD.decode
                        (BD.succeed (,)
                            |= BD.succeed 0
                            |= BD.succeed 1
                        )
                    |> Expect.equal (Ok ( 0, 1 ))
        , test "infix ignore" <|
            \_ ->
                Binary.int8 0
                    |> BD.decode
                        (BD.succeed (,)
                            |= BD.succeed 0
                            |. BD.succeed 2
                            |= BD.succeed 1
                            |. BD.succeed 2
                            |. BD.succeed 3
                            |. BD.succeed 5
                            |. BD.succeed 2
                        )
                    |> Expect.equal (Ok ( 0, 1 ))
        , test "position is inititalized at 0" <|
            \_ ->
                Binary.int8 0
                    |> BD.decode
                        (BD.succeed identity
                            |= BD.position
                        )
                    |> Expect.equal (Ok 0)
        , fuzz Fuzz.int "position can be set with goto" <|
            \n ->
                Binary.int8 0
                    |> BD.decode
                        (BD.succeed identity
                            |. BD.goto n
                            |= BD.position
                        )
                    |> Expect.equal (Ok n)
        , fuzz Fuzz.int "position can be skipped" <|
            \n ->
                Binary.int8 0
                    |> BD.decode
                        (BD.succeed identity
                            |. BD.skip n
                            |= BD.position
                        )
                    |> Expect.equal (Ok n)
        ]

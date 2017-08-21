module Binary.Test exposing (suite)

import Test exposing (..)
import Expect
import Fuzz


--

import Array
import Binary
import Binary.Decode as BD exposing ((|=), (|.))
import Binary.LowLevel


suite : Test
suite =
    describe "Binary"
        [ encoding
        , decoder
        ]


encoding : Test
encoding =
    describe "Encoding"
        [ fuzz (Fuzz.intRange 0 50) "zeros returns n sized array" <|
            \n ->
                Binary.zeros n
                    |> Array.length
                    |> Expect.equal n
        , fuzz (Fuzz.intRange 0 50) "zeros returns all zeros" <|
            \n ->
                Binary.zeros n
                    |> Array.map
                        (\byte ->
                            Array.empty
                                |> Array.push byte
                                |> Binary.LowLevel.toArrayBuffer
                                |> Binary.LowLevel.getInt8 0
                        )
                    |> Array.toList
                    |> List.all
                        (\maybe ->
                            case maybe of
                                Just 0 ->
                                    True

                                _ ->
                                    False
                        )
                    |> Expect.true "Expected all bytes to be zero"
        , fuzz (Fuzz.intRange -20 0) "ask for negative amount of zeros and get 0" <|
            \n ->
                Binary.zeros n
                    |> Array.length
                    |> Expect.equal 0

        -- int8
        , fuzz (Fuzz.intRange -128 127) "encode a valid int8" <|
            \n ->
                Binary.int8 n
                    |> Binary.LowLevel.toArrayBuffer
                    |> Binary.LowLevel.getInt8 0
                    |> Expect.equal (Just n)
        , test "encoding an out of range int8 causes overflow" <|
            \_ ->
                Binary.int8 128
                    |> Binary.LowLevel.toArrayBuffer
                    |> Binary.LowLevel.getInt8 0
                    |> Expect.equal (Just -128)
        ]


decoder : Test
decoder =
    describe "Decode"
        [ test "succeed" <|
            \_ ->
                Array.empty
                    |> BD.decode (BD.succeed 0)
                    |> Expect.equal (Ok 0)
        , test "fail" <|
            \_ ->
                Array.empty
                    |> BD.decode (BD.fail "Just like that.")
                    |> Expect.err
        , test "andThen" <|
            \_ ->
                Array.empty
                    |> BD.decode (BD.succeed 0 |> BD.andThen (\a -> BD.succeed (a + 1)))
                    |> Expect.equal (Ok 1)
        , test "map" <|
            \_ ->
                Array.empty
                    |> BD.decode (BD.succeed 0 |> BD.map ((+) 1))
                    |> Expect.equal (Ok 1)
        , test "map2" <|
            \_ ->
                Array.empty
                    |> BD.decode (BD.map2 (,) (BD.succeed 0) (BD.succeed 1))
                    |> Expect.equal (Ok ( 0, 1 ))
        , test "apply" <|
            \_ ->
                Array.empty
                    |> BD.decode
                        (BD.succeed (,)
                            |> BD.apply (BD.succeed 0)
                            |> BD.apply (BD.succeed 1)
                        )
                    |> Expect.equal (Ok ( 0, 1 ))
        , test "ignore does not change result" <|
            \_ ->
                Array.empty
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
                Array.empty
                    |> BD.decode
                        (BD.succeed identity
                            |> BD.apply (BD.succeed "What??")
                            |> BD.ignore (BD.fail "Fail!")
                        )
                    |> Expect.err
        , test "infix apply" <|
            \_ ->
                Array.empty
                    |> BD.decode
                        (BD.succeed (,)
                            |= BD.succeed 0
                            |= BD.succeed 1
                        )
                    |> Expect.equal (Ok ( 0, 1 ))
        , test "infix ignore" <|
            \_ ->
                Array.empty
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
                Array.empty
                    |> BD.decode
                        (BD.succeed identity
                            |= BD.position
                        )
                    |> Expect.equal (Ok 0)
        , fuzz Fuzz.int "position can be set with goto" <|
            \n ->
                Array.empty
                    |> BD.decode
                        (BD.succeed identity
                            |. BD.goto n
                            |= BD.position
                        )
                    |> Expect.equal (Ok n)
        , fuzz Fuzz.int "position can be moved" <|
            \n ->
                Array.empty
                    |> BD.decode
                        (BD.succeed identity
                            |. BD.move n
                            |= BD.position
                        )
                    |> Expect.equal (Ok n)
        ]

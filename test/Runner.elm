module Runner exposing (..)

import Test.Runner.Html
import Test


--

import Binary.Test


main : Test.Runner.Html.TestProgram
main =
    [ Binary.Test.suite
    ]
        |> Test.concat
        |> Test.Runner.Html.run

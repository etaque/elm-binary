module Runner exposing (..)

import Test.Runner.Html
import Test


--

import Tests


main : Test.Runner.Html.TestProgram
main =
    [ Tests.suite
    ]
        |> Test.concat
        |> Test.Runner.Html.run

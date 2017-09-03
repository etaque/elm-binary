module Loadable exposing (..)


type Loadable err a
    = Init
    | Loading
    | Loaded a
    | Error err


map : (a -> b) -> Loadable err a -> Loadable err b
map func ra =
    case ra of
        Loaded a ->
            Loaded (func a)

        Error err ->
            Error err

        Init ->
            Init

        Loading ->
            Loading


apply : Loadable err a -> Loadable err (a -> b) -> Loadable err b
apply la lf =
    case ( la, lf ) of
        ( Error err, _ ) ->
            Error err

        ( _, Error err ) ->
            Error err

        ( Init, _ ) ->
            Init

        ( _, Init ) ->
            Init

        ( Loading, _ ) ->
            Loading

        ( _, Loading ) ->
            Loading

        ( Loaded a, Loaded f ) ->
            Loaded (f a)


or : Loadable err a -> Loadable err a -> Loadable err a
or left right =
    case ( left, right ) of
        ( Loaded a, _ ) ->
            Loaded a

        ( _, Loaded a ) ->
            Loaded a

        ( Error err, _ ) ->
            Error err

        ( _, Error err ) ->
            Error err

        ( Loading, _ ) ->
            Loading

        ( _, Loading ) ->
            Loading

        ( Init, Init ) ->
            Init


toMaybe : Loadable err a -> Maybe a
toMaybe ra =
    case ra of
        Loaded a ->
            Just a

        _ ->
            Nothing


isLoading : Loadable err a -> Bool
isLoading ra =
    case ra of
        Loading ->
            True

        _ ->
            False


isLoaded : Loadable err a -> Bool
isLoaded ra =
    case ra of
        Loaded a ->
            True

        _ ->
            False


isError : Loadable err a -> Bool
isError ra =
    case ra of
        Error _ ->
            True

        _ ->
            False

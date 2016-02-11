module Routes where

import Effects exposing (Effects)
import RouteParser exposing (..)
import TransitRouter


type Route
    = Home
    | Login
    | Register
    | NotFound


routeParsers: List (Matcher Route)
routeParsers = 
    [ static Home "/"
    , static Login "/login"
    , static Register "/register"
    ]


decode: String -> Route
decode path =
    RouteParser.match routeParsers path
        |> Maybe.withDefault NotFound


encode: Route -> String
encode route =
    case route of
        Home -> "/"
        Login -> "/login"
        Register -> "/register"
        NotFound -> ""


redirect: Route -> Effects ()
redirect route = 
    encode route
        |> Signal.send TransitRouter.pushPathAddress
        |> Effects.task

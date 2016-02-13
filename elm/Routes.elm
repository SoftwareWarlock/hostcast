module Routes where

import Effects exposing (Effects)
import RouteParser exposing (..)
import TransitRouter


type Route
    = Home
    | Login
    | Register
    | NotFound


appRoutePrefix: String
appRoutePrefix =
    "/app"


getRoute: String -> String
getRoute route =
    appRoutePrefix ++ route


routeParsers: List (Matcher Route)
routeParsers = 
    [ static Home (getRoute "")
    , static Home (getRoute "/")
    , static Login (getRoute "/login")
    , static Register (getRoute "/register")
    ]


decode: String -> Route
decode path =
    RouteParser.match routeParsers path
        |> Maybe.withDefault NotFound


encode: Route -> String
encode route =
    case route of
        Home -> (getRoute "")
        Login -> (getRoute "/login")
        Register -> (getRoute "/register")
        NotFound -> (getRoute "/not-found")


redirect: Route -> Effects ()
redirect route = 
    encode route
        |> Signal.send TransitRouter.pushPathAddress
        |> Effects.task

module Update.Utils where

import Model exposing (appAddress)
import Services.Auth as Auth
import Services.Podcasts exposing (Podcast)

import Effects exposing (Effects)


setUser : Maybe Auth.User -> Effects ()
setUser user =
    Model.SetUser user
        |> Signal.send appAddress
        |> Effects.task

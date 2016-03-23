module Pages.Home.Model where

import Services.Auth as Auth
import Services.Helpers exposing (ServerResult)
import Services.Podcasts exposing (Podcast)

type alias Model =
    { user: Maybe (Auth.User)
    , podcasts: Maybe (List Podcast)
    }

type Action
    = NoOp
    | SetPodcasts (ServerResult (List Podcast))


init : Model
init = 
    { user = Nothing
    , podcasts = Nothing
    }

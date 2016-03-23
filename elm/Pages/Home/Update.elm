module Pages.Home.Update where

import Pages.Home.Model exposing (..)
import Services.Podcasts as Podcasts

import Task exposing (Task)
import Effects exposing (Never, Effects)
import Result exposing (Result(Ok, Err))


podcastsResolveTask : Model -> Task Never Action
podcastsResolveTask model =
    case model.user of
        Just user ->
            Podcasts.getPodcasts user.token
                |> Task.map SetPodcasts
        Nothing ->
            Task.succeed NoOp


update : Action -> Model -> (Model, Effects Action)
update action model =
    case action of
        NoOp ->
            (model, Effects.none)

        SetPodcasts serverResult ->
            case serverResult of
                Ok podcasts ->
                    ( { model | podcasts = Just podcasts }
                    , Effects.none
                    )
                Err _ ->
                    (model, Effects.none)

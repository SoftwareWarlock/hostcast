module Pages.CreatePodcast.Update where
import Pages.CreatePodcast.Model exposing (..)

import Services.Podcasts as Podcasts exposing (Podcast)

import Routes

import Form exposing (Form)
import Response exposing (..)
import Result exposing (Result(Ok, Err))
import Task exposing (Task)
import Effects exposing (Effects, Never)

import Dict


update : Action -> Model -> (Model, Effects Action)
update action model =
    case action of
        FormAction formAction ->
            res { model | form = Form.update formAction model.form } Effects.none

        SubmitPodcast podcast ->
            case model.user of
                Just user ->
                    taskRes { model | serverErrors = Dict.empty }
                        (submitPodcastTask podcast user.token)
                Nothing ->
                    res model Effects.none

        PodcastCreated serverResult ->
            let 
                newModel = 
                    { model
                    | loading = False
                    , serverErrors = Dict.empty
                    }
            in
                case serverResult of
                    Ok podcast ->
                        let
                            redirectEffect = 
                                Effects.map (\_ -> NoOp) <| Routes.redirect Routes.Home
                        in
                            res newModel redirectEffect

                    Err serverErrors ->
                        res { newModel | serverErrors = serverErrors } Effects.none

        NoOp ->
            res model Effects.none


submitPodcastTask : Podcast -> String -> Task Never Action
submitPodcastTask podcast token =
    Podcasts.createPodcast token podcast
        |> Task.map PodcastCreated

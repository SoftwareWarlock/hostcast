module Pages.CreatePodcast.Update where

import Services.Podcasts as Podcasts

import Form exposing (Form)
import Response exposing (..)
import Result exposing (Result(Ok, Err))


update : Action -> Model -> (Model, Effects Action)
update action model =
    case action of
        FormAction formAction ->
            res { model | form = Form.update formAction model.form } Effects.none

        SubmitPodcast podcast ->
            taskRes { model | serverErrors = Dict.empty }
                (submitPodcastEffects podcast)

        PodcastCreated serverResult ->
            case serverResult of
                Ok podcast ->
                    let
                        redirectEffect = 
                            Effects.map (\_ -> NoOp) <| Routes.redirect Routes.Home

                        newModel = 
                            { model
                            | loading = False
                            , serverErrors = Dict.empty
                            }
                    in
                        res newModel redirectEffect

                Err serverErrors ->
                    res { newModel | serverErrors = serverErrors } Effects.none


submitPodcastTask : Podcast -> Task Never Action
submitPodcastTask podcast =
    Podcasts.createPodcast podcast
        |> Task.map 

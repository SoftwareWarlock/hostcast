module Pages.CreatePodcast.Model where

import Services.Podcasts as Podcasts exposing (Podcast)
import Services.Helpers exposing (ServerResult, ServerErrors)

import Form.Validate as Validate exposing (string, (:=), Validation, form2)
import Form exposing (Form)


type alias Model = 
    { form: Form () Podcast
    , serverErrors: ServerErrors
    , loading: Bool
    }

type Action 
    = FormAction Form.Action
    | SubmitPodcast Podcast
    | PodcastCreated (ServerResult Podcast)


init : Model
init =  
    { form = Form.initial [] validate
    , serverErrors = Dict.empty
    , loading = False
    }

validate : Validation () Login
validate = 
    form2 Podcast
        ("title" := string)
        ("description" := string)

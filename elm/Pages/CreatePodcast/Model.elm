module Pages.CreatePodcast.Model where

import Services.Podcasts as Podcasts exposing (Podcast)
import Services.Auth as Auth
import Services.Helpers exposing (ServerResult, ServerErrors)

import Form.Validate as Validate exposing (string, (:=), Validation, form2)
import Form exposing (Form)

import Dict


type alias Model = 
    { form: Form () Podcast
    , serverErrors: ServerErrors
    , loading: Bool
    , user: Maybe Auth.User
    }

type Action 
    = FormAction Form.Action
    | SubmitPodcast Podcast
    | PodcastCreated (ServerResult Podcast)
    | NoOp


init : Model
init =  
    { form = Form.initial [] validate
    , serverErrors = Dict.empty
    , loading = False
    , user = Nothing
    }

validate : Validation () Podcast
validate = 
    form2 Podcast
        ("title" := string)
        ("description" := string)

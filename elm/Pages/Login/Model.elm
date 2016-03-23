module Pages.Login.Model where

import Services.Auth as Auth
import Services.Helpers exposing (ServerResult, ServerErrors)

import Form.Validate as Validate exposing (string, (:=), Validation, form2)
import Form exposing (Form)
import Dict exposing (Dict)


type alias Login = 
    { email: String
    , password: String
    }

type alias Model = 
    { user: Maybe Auth.User
    , form: Form () Login
    , serverErrors: ServerErrors
    , loading: Bool
    }

type Action 
    = FormAction Form.Action
    | SubmitLogin Login
    | LoginComplete (ServerResult String)
    | Logout
    | NoOp

init : Model
init =  
    { user = Nothing
    , form = Form.initial [] validate
    , serverErrors = Dict.empty
    , loading = False
    }

validate : Validation () Login
validate = 
    form2 Login
        ("email" := string)
        ("password" := string)

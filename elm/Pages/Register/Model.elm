module Pages.Register.Model where

import Services.Auth as Auth exposing (RegisterResponse)
import Services.Helpers exposing (ServerResult)

import Form exposing (Form)
import Form.Validate as Validate exposing (..)

import Dict exposing (Dict)


type alias Registration = 
    { email: String
    , password: String
    }


type alias Model = 
    { form: Form () Registration 
    , serverErrors: Dict String (List String)
    , loading: Bool
    }


type Action 
    = FormAction Form.Action
    | SubmitRegister Registration
    | RegisterComplete (ServerResult RegisterResponse)
    | NoOp


init : Model
init = 
    { form = Form.initial [] validate
    , serverErrors = Dict.empty
    , loading = False
    }


validate : Validation () Registration
validate = 
    form2 Registration
        ("email" := string `andThen` nonEmpty)
        ("password" := string `andThen` minLength 8)

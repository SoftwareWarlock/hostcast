module Pages.Register (Model, Action, update, view, init) where

import Services.Auth as Auth exposing (ServerResult, RegisterResponse)

import Effects exposing (Effects, Never, none)
import Task exposing (toMaybe, map, Task)

import Html exposing (..)
import Html.Attributes exposing (style, class)
import Html.Events exposing (onClick)

import Form exposing (Form)
import Form.Validate as Validate exposing (..)
import Form.Input as Input

import Dict exposing (Dict)

import Result exposing (Result(Ok, Err))
import Response exposing (..)


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


update : Action -> Model -> (Model, Effects Action)
update action model =
    case action of
        FormAction formAction ->
            let
                updatedForm = Form.update formAction model.form
            in
                res  { model | form = updatedForm } none

        SubmitRegister registration ->
            taskRes { model | loading = True } (registerTask registration)

        RegisterComplete result ->
            case result of
                Ok _ ->
                    res { model | loading = False } none
                Err errors ->
                    res { model | loading = False, serverErrors = errors } none


view : Signal.Address Action -> Model -> Html
view address model =
        let
            formAddress = Signal.forwardTo address FormAction

            errorFor field =
                case field.liveError of
                    Just error ->
                        div [ class "error" ] [ text (toString error) ]
                    Nothing ->
                        text ""
            email = Form.getFieldAsString "email" model.form
            password = Form.getFieldAsString "password" model.form
            clickEvent = case Form.getOutput model.form of
                Just registration ->
                    onClick address (SubmitRegister registration)
                Nothing ->
                    onClick formAddress Form.submit
        in
            div []
                [ label [] [ text "Email" ]
                , Input.textInput email formAddress []
                , errorFor email

                , label [] [ text "Password" ]
                , Input.passwordInput password formAddress []
                , errorFor password

                , button
                    [ clickEvent ]
                    [ text "Register" ]
                ]


registerTask : Registration -> Task Never Action
registerTask { email, password } =
    Auth.register email password
        |> Task.map RegisterComplete

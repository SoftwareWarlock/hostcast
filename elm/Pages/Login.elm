module Pages.Login (Model, Action, update, view, init) where

import Services.Auth as Auth exposing (ServerResult, RegisterResponse, ServerErrors)

import Effects exposing (Effects, Never)
import Task exposing (Task)

import Html exposing (..)
import Html.Attributes exposing (style, class)
import Html.Events exposing (onClick)

import Form exposing (Form)
import Form.Validate as Validate exposing (string, (:=), Validation, form2)
import Form.Input as Input

import Maybe exposing (map, andThen)
import Dict exposing (Dict)

import Result exposing (Result(Ok, Err))
import Response exposing (..)


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

update : Action -> Model -> (Model, Effects Action)
update action model =
    case action of
        FormAction formAction ->
            res { model | form = Form.update formAction model.form } Effects.none

        SubmitLogin login ->
            taskRes model (loginEffects login.email login.password)

        LoginComplete serverResponse ->
            case serverResponse of
                Ok token ->
                    let
                        newUser = 
                            getFieldAsMaybe "email" model.form
                                |> Maybe.map (\email -> { email = email, token = token })
                    in
                        res { model | user = newUser, loading = False } Effects.none
                Err serverErrors ->
                    res { model | loading = False, serverErrors = serverErrors } Effects.none

        Logout ->
            res { model | user = Nothing } Effects.none


getFieldAsMaybe : String -> Form.Form a b -> Maybe String
getFieldAsMaybe field form =
    Form.getFieldAsString field form
        |> .value


view : Signal.Address Action -> Model -> Html
view address model =
    case model.user of
        Just user -> text user.email

        Nothing ->
            let
                formAddress = Signal.forwardTo address FormAction

                email = Form.getFieldAsString "email" model.form
                password = Form.getFieldAsString "password" model.form
                clickEvent = case Form.getOutput model.form of
                    Just login ->
                        onClick address (SubmitLogin login)
                    Nothing ->
                        onClick formAddress Form.submit
                serverErrorsFor = getServerErrorsFor model.serverErrors
            in
                div []
                    [ label [] [ text "Email" ]
                    , Input.textInput email formAddress []
                    , errorFor email
                    , serverErrorsFor "email"

                    , label [] [ text "Password" ]
                    , Input.passwordInput password formAddress []
                    , errorFor password
                    , serverErrorsFor "password"

                    , serverErrorsFor "non_field_errors"
                    , button
                        [ clickEvent ]
                        [ text "Login" ]
                    ]

errorFor field =
    case field.liveError of
        Just error ->
            errorDiv (toString error)
        Nothing ->
            text ""


errorDiv error = 
    div [ class "error" ] [ text error ]


getServerErrorsFor : ServerErrors -> String -> Html
getServerErrorsFor serverErrors field =
    case Dict.get field serverErrors of
        Just errorList ->
            div [] (List.map errorDiv errorList)
        Nothing ->
            text ""

loginEffects : String -> String -> Task Never Action
loginEffects email password =
    Auth.login email password
        |> Task.map LoginComplete

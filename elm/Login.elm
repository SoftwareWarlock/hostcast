module Login (Model, Action, update, view, init) where

import Auth

import Effects exposing (Effects, Never)
import Task exposing (..)

import Html exposing (..)
import Html.Attributes exposing (style, class)
import Html.Events exposing (onClick)

import Form exposing (Form)
import Form.Validate as Validate exposing (..)
import Form.Input as Input

type State
    = Authenticated
    | Unauthenticated

type alias Login = 
    { username: String
    , password: String
    }

type alias Model = 
    { token: Maybe String
    , state: State
    , form: Form () Login
    }

type Action 
    = FormAction Form.Action
    | SubmitLogin Login
    | LoginComplete (Maybe String)
    | Logout

init: (Model, Effects Action)
init = ( { token = Nothing
         , state = Unauthenticated
         , form = Form.initial [] validate
         }
       , Effects.none
       )

validate: Validation () Login
validate = 
    form2 Login
        ("username" := string)
        ("password" := string)

update: Action -> Model -> (Model, Effects Action)
update action model =
    case action of
        FormAction formAction ->
            ( { model | form = Form.update formAction model.form }
            , case Form.getOutput model.form of
                Just login -> loginEffects login.username login.password
                Nothing -> Effects.none
            )

        SubmitLogin login ->
            ( model
            , loginEffects login.username login.password
            )

        LoginComplete maybeToken ->
            ( { model
              | token = maybeToken
              , state = Authenticated
              }
            , Effects.none
            )

        Logout ->
            ( { model
              | token = Just ""
              , state = Unauthenticated
              }
            , Effects.none
            )

view: Signal.Address Action -> Model -> Html
view address model =
    case model.state of
        Authenticated -> text "Authenticated"

        Unauthenticated ->
            let
                formAddress = Signal.forwardTo address FormAction

                errorFor field =
                    case field.liveError of
                        Just error ->
                            div [ class "error" ] [ text (toString error) ]
                        Nothing ->
                            text ""
                username = Form.getFieldAsString "username" model.form
                password = Form.getFieldAsString "password" model.form
                clickEvent = case Form.getOutput of
                    Just login ->
                        onClick address SubmitLogin login
                    Nothing ->
                        onClick formAddress Form.submit
            in
                div []
                    [ label [] [ text "Username" ]
                    , Input.textInput username formAddress []
                    , errorFor username

                    , label [] [ text "Password" ]
                    , Input.textInput password formAddress []
                    , errorFor password

                    , button
                        [ clickEvent ]
                        [ text "Login" ]
                    ]

loginEffects: String -> String -> Effects Action
loginEffects username password =
    Auth.login username password
        |> Task.toMaybe
        |> Task.map LoginComplete
        |> Effects.task

module Pages.Login (Model, Action, update, view, init) where

import Services.Auth as Auth

import Effects exposing (Effects, Never)
import Task

import Html exposing (..)
import Html.Attributes exposing (style, class)
import Html.Events exposing (onClick)

import Form exposing (Form)
import Form.Validate as Validate exposing (string, (:=), Validation, form2)
import Form.Input as Input

import Maybe exposing (map, andThen)


type alias Login = 
    { email: String
    , password: String
    }

type alias Model = 
    { user: Maybe Auth.User
    , form: Form () Login
    }

type Action 
    = FormAction Form.Action
    | SubmitLogin Login
    | LoginComplete (Maybe String)
    | Logout

init : Model
init =  
    { user = Nothing
    , form = Form.initial [] validate
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
            ( { model | form = Form.update formAction model.form }
            , Effects.none
            )

        SubmitLogin login ->
            ( model
            , loginEffects login.email login.password
            )

        LoginComplete maybeToken ->
            ( { model
              | user = createUser maybeToken (getFieldAsMaybe "email" model.form)
              }
            , Effects.none
            )

        Logout ->
            ( { model | user = Nothing }
            , Effects.none
            )


createUser : Maybe String -> Maybe String -> Maybe Auth.User
createUser maybeToken maybeEmail =
    maybeToken `andThen` \token -> 
        maybeEmail |>
            map (\email -> 
                 { token = token
                 , email = email 
                 })


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

                errorFor field =
                    case field.liveError of
                        Just error ->
                            div [ class "error" ] [ text (toString error) ]
                        Nothing ->
                            text ""
                email = Form.getFieldAsString "email" model.form
                password = Form.getFieldAsString "password" model.form
                clickEvent = case Form.getOutput model.form of
                    Just login ->
                        onClick address (SubmitLogin login)
                    Nothing ->
                        onClick formAddress Form.submit
            in
                div []
                    [ label [] [ text "Email" ]
                    , Input.textInput email formAddress []
                    , errorFor email

                    , label [] [ text "Password" ]
                    , Input.textInput password formAddress []
                    , errorFor password

                    , button
                        [ clickEvent ]
                        [ text "Login" ]
                    ]

loginEffects : String -> String -> Effects Action
loginEffects email password =
    Auth.login email password
        |> Task.toMaybe
        |> Task.map LoginComplete
        |> Effects.task

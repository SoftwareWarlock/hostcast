odule Pages.Register (Model, Action, update, view, init) where

import Services.Auth as Auth

import Effects exposing (Effects, Never)
import Task exposing (toMaybe, map)

import Html exposing (..)
import Html.Attributes exposing (style, class)
import Html.Events exposing (onClick)

import Form exposing (Form)
import Form.Validate as Validate exposing (..)
import Form.Input as Input

type State
    = Registered
    | Unregistered

type alias Registration = 
    { email: String
    , passwordOnce: String
    , passwordTwice: String
    }

type alias Model = 
    { state: State
    , form: Form RegisterError Registration
    }

type Action 
    = FormAction Form.Action
    | SubmitRegister Registration
    | RegisterComplete (Maybe String)

type RegisterError =
    UsernameTaken | PasswordMismatch | ServerError

init: Model
init = 
    { state = Unregistered
    , form = Form.initial [] validate
    }

validate: Validation RegisterError Registration
validate = 
    form3 Registration
        ("email" := string `andThen` nonEmpty)
        ("passwordOnce" := string)
        ("passwordTwice" := string) --`andThen` (matches ("passwordOne" := string)))

{-
matches: Validation RegisterError String -> String -> Validation RegisterError String
matches passwordOneValidation passwordTwo = 
    case passwordOneValidation of
        Validation _ passwordOne -> if passwordOne == passwordTwo
                                       then succeed passwordTwo
                                       else fail (customError PasswordMismatch)
        Validation error _ -> fail error
-}

update: Action -> Model -> (Model, Effects Action)
update action model =
    case action of
        FormAction formAction ->
            ( { model | form = Form.update formAction model.form }
            , Effects.none
            )

        SubmitRegister registration ->
            ( model
            , registerEffects registration.email registration.passwordOnce
            )

        RegisterComplete _ ->
            ( model
            , Effects.none
            )

view: Signal.Address Action -> Model -> Html
view address model =
    case model.state of
        Registered -> text "Registered"

        Unregistered ->
            let
                formAddress = Signal.forwardTo address FormAction

                errorFor field =
                    case field.liveError of
                        Just error ->
                            div [ class "error" ] [ text (toString error) ]
                        Nothing ->
                            text ""
                email = Form.getFieldAsString "email" model.form
                passwordOnce = Form.getFieldAsString "passwordOnce" model.form
                passwordTwice = Form.getFieldAsString "passwordTwice" model.form
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
                    , Input.passwordInput passwordOnce formAddress []
                    , errorFor passwordOnce

                    , label [] [ text "Re-enter password" ]
                    , Input.passwordInput passwordTwice formAddress []
                    , errorFor passwordTwice

                    , button
                        [ clickEvent ]
                        [ text "Register" ]
                    ]

registerEffects: String -> String -> Effects Action
registerEffects email password =
    Auth.register email password
        |> Task.toMaybe
        |> Task.map RegisterComplete
        |> Effects.task

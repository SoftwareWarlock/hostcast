module Pages.Login.View where

import Pages.Login.Model exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)

import Form exposing (Form)
import Form.Input as Input

import Dict exposing (Dict)


view : Signal.Address Action -> Model -> Html
view address model =
    let
        formAddress = Signal.forwardTo address FormAction

        email = Form.getFieldAsString "email" model.form
        password = Form.getFieldAsString "password" model.form
        clickEvent = case Form.getOutput model.form of
            Just login ->
                onClick address (SubmitLogin login)
            Nothing ->
                onClick formAddress Form.submit
        nonFieldErrors = 
            getServerErrorsFor model.serverErrors "non_field_errors"
    in
        div [ class "row" ]
            [ Html.form [ class "col s6 offset-s3" ] 
                [ div [ class "row" ] 
                    [ div [ class "col s12"]
                        ([ label [ ] [ text "Email" ]
                         , Input.textInput email formAddress []
                         ] ++ (allFieldErrors model "email" |> divsFromErrors))

                    , div [ class "col s12" ]
                        ([ label [ ] [ text "Password" ]
                         , Input.passwordInput password formAddress []
                         ] ++ (allFieldErrors model "password" |> divsFromErrors))

                    , case nonFieldErrors of
                        [] -> 
                            text ""
                        _ -> div [ class "col s12" ] (List.map errorDiv nonFieldErrors)
                    , button
                        [ clickEvent 
                        , class "waves-effect waves-light btn right-align"
                        , type' "button"
                        ]
                        [ text "Login" ]
                    ]
                ]
            ]

divsFromErrors errors =
    List.map errorDiv errors

allFieldErrors model fieldName =
    let
        serverErrors = getServerErrorsFor model.serverErrors fieldName
        formField = Form.getFieldAsString fieldName model.form
        formErrors = formErrorFor formField
    in
        formErrors ++ serverErrors


formErrorFor field =
    case field.liveError of
        Just error ->
            [ toString error ]
        Nothing ->
            [ ]

errorDiv error = 
    div [ class "card-panel white-text red darken-2" ] [ text error ]

getServerErrorsFor serverErrors field =
    case Dict.get field serverErrors of
        Just errorList ->
           errorList
        Nothing ->
            [ ]

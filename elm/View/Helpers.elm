module View.Helpers where

import Form exposing (Form)
import Form.Input as Input

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)

import Dict exposing (Dict)


divsFromErrors : List String -> List Html
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

errorDiv : String -> Html
errorDiv error = 
    div [ class "card-panel white-text red darken-2" ] [ text error ]


getServerErrorsFor : Dict String (List String) -> String -> List String
getServerErrorsFor serverErrors field =
    case Dict.get field serverErrors of
        Just errorList ->
           errorList
        Nothing ->
            [ ]


passwordFormField model formAddress = 
    let
        password = Form.getFieldAsString "password" model.form
    in
        div [ class "col s12" ]
            ([ label [ ] [ text "Password" ]
             , Input.passwordInput password formAddress []
             ] ++ (allFieldErrors model "password" |> divsFromErrors))


emailFormField model formAddress =
    let
        email = Form.getFieldAsString "email" model.form
    in
        div [ class "col s12"]
            ([ label [ ] [ text "Email" ]
            , Input.textInput email formAddress []
            ] ++ (allFieldErrors model "email" |> divsFromErrors))


nonFieldErrorsView model =
    let
        nonFieldErrors = 
            getServerErrorsFor model.serverErrors "non_field_errors"
    in
        case nonFieldErrors of
            [] -> 
                text ""
            _ -> 
                div [ class "col s12" ] (List.map errorDiv nonFieldErrors)

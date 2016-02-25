module View.Helpers where

import Routes exposing (..)

import TransitRouter exposing (getTransition)

import Signal exposing (message)

import Json.Decode as Json

import Form exposing (Form)
import Form.Input as Input

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onWithOptions)

import Dict exposing (Dict)
import String
import Char


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


errorLabelFrom : String -> List String -> Html
errorLabelFrom fieldName errors =
    label 
        [ class "invalid" 
        , for fieldName
        , id <| fieldName ++ "-error"
        ] 
        [ text <| String.join ", " errors ]


getServerErrorsFor : Dict String (List String) -> String -> List String
getServerErrorsFor serverErrors field =
    case Dict.get field serverErrors of
        Just errorList ->
           errorList
        Nothing ->
            [ ]


createInputField model formAddress fieldName displayName inputFunction = 
    let
        field = Form.getFieldAsString fieldName model.form
        errorStrings = allFieldErrors model fieldName
        fieldErrorLabel = 
            case errorStrings of
                [] -> text ""
                _ -> errorLabelFrom fieldName errorStrings
        validClass =
            case errorStrings of
                [] -> ""
                _ -> "invalid"
    in
        div [ class "col s12 input-field" ]
            [ inputFunction field formAddress 
                [ class <| "validate " ++ validClass
                , id fieldName
                ]
            , label 
                [ for fieldName ]
                [ text displayName ]
            , fieldErrorLabel
            ]

emailTypeTextInput field formAddress attributes =
    Input.textInput field formAddress <| attributes ++ [ type' "email" ]

passwordFormField model formAddress = 
    createInputField model formAddress "password" "Password" Input.passwordInput

emailFormField model formAddress =
    createInputField model formAddress "email" "Email" emailTypeTextInput


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


navbar : Bool -> Html
navbar showLoginAndRegister =
      nav [ class "teal lighten-1" ] 
        [ div [ class "nav-wrapper container" ] 
            [ a ((clickTo <| Routes.encode Home) ++ [ class "brand-logo" ]) [ text "Hostcast" ]
            , ul [ id "nav-mobile"
                 , class "right hide-on-med-and-down"
                 ]
              [ li [ ] [  a (clickTo <| Routes.encode Home) [ text "Home" ] ]
              , if showLoginAndRegister then
                  li [ ] [ a (clickTo <| Routes.encode Register) [ text "Register" ] ]
                else
                  text ""
              , if showLoginAndRegister then
                  li [ ] [ a (clickTo <| Routes.encode Login) [ text "Login" ] ]
                else
                  text ""
              ]
            ]
        ]


clickTo : String -> List Attribute
clickTo path =
      [ href path
      , onWithOptions
          "click"
          { stopPropagation = True, preventDefault = True }
          Json.value
          (\_ -> message TransitRouter.pushPathAddress path)
      ]

module Pages.CreatePodcast.View where
import Pages.CreatePodcast.Model exposing (..)

import View.Helpers exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)

import Form exposing (Form)
import Form.Input as Input
import Json.Decode as Json

import Signal exposing (message)


view : Signal.Address Action -> Model -> Html
view address model =
    let
        formAddress = Signal.forwardTo address FormAction
        formOutput = Form.getOutput model.form
        clickEvent = 
            case formOutput of
                Just podcast ->
                    onClick address (SubmitPodcast podcast)
                Nothing ->
                    onClick formAddress Form.submit
        inputField name display inputType =
            createInputField model formAddress name display inputType

    in
        div [ class "row" ]
            [ div [ class "col s6 offset-s3" ]
                [ h4 [ ] [ text "Podcast" ]
                , div [ class "row" ] 
                  [ inputField "title" "Title" Input.textInput
                  , inputField "description" "Description" textAreaInput
                  , nonFieldErrorsView model
                      , button
                      [ class "waves-effect waves-light btn right-align" 
                      , clickEvent
                      ]
                      [ text "Save" ]
                  ]
                ]
            ]

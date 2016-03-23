module Pages.Login.View where
import Pages.Login.Model exposing (..)

import View.Helpers exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)

import Form exposing (Form)
import Json.Decode as Json

import Signal exposing (message)


view : Signal.Address Action -> Model -> Html
view address model =
    let
        formAddress = Signal.forwardTo address FormAction

        formOutput = Debug.log "Form output: " <| Form.getOutput model.form
        clickEvent = 
            case formOutput of
                Just login ->
                    onClick address (SubmitLogin login)
                Nothing ->
                    onClick formAddress Form.submit
        submitEvent =
            case formOutput of
                Just login ->
                    onWithOptions
                      "submit"
                      { stopPropagation = True, preventDefault = True }
                      Json.value
                      (\_ -> message address <| SubmitLogin login)
                Nothing ->
                    onWithOptions
                      "submit"
                      { stopPropagation = True, preventDefault = True }
                      Json.value
                      (\_ -> message formAddress Form.submit)
    in
        div [ class "row" ]
            [ div [ class "col s6 offset-s3" ]
                [ h4 [ ] [ text "Login" ]
                , Html.form 
                    [ submitEvent 
                    , novalidate True
                    ] 
                    [ div [ class "row" ] 
                        [ emailFormField model formAddress
                        , passwordFormField model formAddress
                        , nonFieldErrorsView model
                        , button
                            [ class "waves-effect waves-light btn right-align"
                            , type' "submit"
                            ]
                            [ text "Login" ]
                        ]
                    ]
                ]
            ]

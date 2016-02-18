module Pages.Login.View where
import Pages.Login.Model exposing (..)

import View.Helpers exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)

import Form exposing (Form)


view : Signal.Address Action -> Model -> Html
view address model =
    let
        formAddress = Signal.forwardTo address FormAction

        clickEvent = case Form.getOutput model.form of
            Just login ->
                onClick address (SubmitLogin login)
            Nothing ->
                onClick formAddress Form.submit
    in
        div [ class "row" ]
            [ div [ class "col s6 offset-s3" ]
                [ h4 [ ] [ text "Login" ]
                , Html.form [ ] 
                    [ div [ class "row" ] 
                        [ emailFormField model formAddress
                        , passwordFormField model formAddress
                        , nonFieldErrorsView model
                        , button
                            [ clickEvent 
                            , class "waves-effect waves-light btn right-align"
                            , type' "button"
                            ]
                            [ text "Login" ]
                        ]
                    ]
                ]
            ]

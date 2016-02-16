module View where

import Html exposing (..)
import Html.Events exposing (..)
import Html.Attributes exposing (..)
import Signal exposing (..)
import Json.Decode as Json

import TransitRouter exposing (getTransition)

import Model exposing (..)
import Routes exposing (..)
import Pages.Login
import Pages.Register


view : Address Action -> Model -> Html
view address model =
    div
      [ ]
      [ nav [ class "teal lighten-1" ] 
          [ div [ class "nav-wrapper container" ] 
              [ a ((clickTo <| Routes.encode Home) ++ [ class "brand-logo" ]) [ text "Hostcast" ]
              , ul [ id "nav-mobile"
                   , class "right hide-on-med-and-down"
                   ]
                [ li [ ] [  a (clickTo <| Routes.encode Home) [ text "Home" ] ]
                , li [ ] [ a (clickTo <| Routes.encode Register) [ text "Register" ] ]
                , li [ ] [ a (clickTo <| Routes.encode Login) [ text "Login" ] ]
                ]
              ]
          ]
      , div
          [ class "container" ]
          [ case (TransitRouter.getRoute model) of
              Home ->
                  text <| "Welcome to Hostcast"
              Register ->
                  Pages.Register.view (Signal.forwardTo address RegisterPageAction) model.registerPageModel
              Login ->
                  Pages.Login.view (Signal.forwardTo address LoginPageAction) model.loginPageModel
              NotFound ->
                  text <| "Not found"
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

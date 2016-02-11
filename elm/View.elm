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
      [ h1 [ ] [ text "Hostcast - Podcast hosting made simple" ]
      , div [ ]
          [ a (clickTo <| Routes.encode Home) [ text "Home" ]
          , a (clickTo <| Routes.encode Register) [ text "Register" ]
          , a (clickTo <| Routes.encode Login) [ text "Login" ]
          ]
      , div
          [ ]
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

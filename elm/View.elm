module View where

import Html exposing (..)
import Html.Events exposing (..)
import Html.Attributes exposing (..)
import Signal exposing (..)
import Json.Decode as Json

import TransitRouter exposing (getTransition)

import Model exposing (..)
import Routes exposing (..)
import Pages.Login.View as Login
import Pages.Register.View as Register

import View.Helpers exposing (navbar)


view : Address Action -> Model -> Html
view address model =
    div
      [ ]
      [ navbar <| shouldShowLoginAndRegister model
      , div
          [ class "container" ]
          [ case (TransitRouter.getRoute model) of
              Home ->
                  text <| "Welcome to Hostcast"
              Register ->
                  Register.view (Signal.forwardTo address RegisterPageAction) model.registerPageModel
              Login ->
                  Login.view (Signal.forwardTo address LoginPageAction) model.loginPageModel
              NotFound ->
                  text <| "Not found"
          ]
      ]


shouldShowLoginAndRegister: Model -> Bool
shouldShowLoginAndRegister model =
    case model.user of
        Just _ -> False
        Nothing -> True

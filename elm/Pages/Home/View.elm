module Pages.Home.View where
import Pages.Home.Model exposing (..)

import Services.Podcasts exposing (..)
import View.Helpers exposing (clickTo)
import Routes exposing (..)

import Signal exposing (Address)

import Html exposing (..)
import Html.Events exposing (..)
import Html.Attributes exposing (..)


podcastView : Podcast -> Html
podcastView podcast =
    text "Here's a podcast"


podcastListView : List Podcast -> Html
podcastListView podcasts =
    case podcasts of
        [] ->
            span [] 
                [ text "To get started, let's "
                , a (clickTo <| Routes.encode Home) 
                    [ text "create your first podcast"
                    ] 
                ]
        _ ->
            div [ ] <| List.map podcastView podcasts

view : Address Action -> Model -> Html
view address model =
    div
      [ ]
      [ text "Welcome to Hostcast! "
      , case model.user of
          Just user ->
              case model.podcasts of
                  Just podcasts ->
                      podcastListView podcasts
                  Nothing ->
                      text "There was a problem getting your podcasts, please try again."
          Nothing ->
              span [ ]
                [ text "Please "
                , a (clickTo <| Routes.encode Login) [ text "log in" ]
                , text " or "
                , a (clickTo <| Routes.encode Register) [ text "register" ]
                ]
      ]

module Model where

import TransitRouter exposing (WithRoute)
import Routes exposing (Route)
import Pages.Login.Model as Login
import Pages.Register.Model as Register
import Pages.Home.Model as Home
import Pages.CreatePodcast.Model as CreatePodcast

import Services.Auth as Auth
import Services.Podcasts exposing (Podcast)

import Effects exposing (Effects)
import TransitRouter

import Routes exposing (..)


appMailbox : Signal.Mailbox Action
appMailbox =
      Signal.mailbox NoOp

appAddress : Signal.Address Action
appAddress =
      appMailbox.address


type alias Model = WithRoute Route
    { registerPageModel: Register.Model
    , loginPageModel: Login.Model
    , homePageModel: Home.Model
    , createPodcastModel: CreatePodcast.Model
    , user: Maybe Auth.User
    }


type Action
    = NoOp
    | RegisterPageAction Register.Action
    | LoginPageAction Login.Action
    | HomePageAction Home.Action
    | CreatePodcastAction CreatePodcast.Action
    | RouterAction (TransitRouter.Action Route)
    | SetUser (Maybe Auth.User)


initialModel : Model
initialModel =
    { transitRouter = TransitRouter.empty Home
    , loginPageModel = Login.init
    , registerPageModel = Register.init
    , homePageModel = Home.init
    , createPodcastModel = CreatePodcast.init
    , user = Nothing
    }

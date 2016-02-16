module Model where

import TransitRouter exposing (WithRoute)
import Routes exposing (Route)
import Pages.Login.Model as Login
import Pages.Register

import Services.Auth as Auth

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
    { registerPageModel: Pages.Register.Model
    , loginPageModel: Login.Model
    , user: Maybe Auth.User
    }


type Action
    = NoOp
    | RegisterPageAction Pages.Register.Action
    | LoginPageAction Login.Action
    | RouterAction (TransitRouter.Action Route)
    | SetUser (Maybe Auth.User)


initialModel : Model
initialModel =
    { transitRouter = TransitRouter.empty Home
    , loginPageModel = Login.init
    , registerPageModel = Pages.Register.init
    , user = Nothing
    }

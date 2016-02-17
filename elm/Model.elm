module Model where

import TransitRouter exposing (WithRoute)
import Routes exposing (Route)
import Pages.Login.Model as Login
import Pages.Register.Model as Register

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
    { registerPageModel: Register.Model
    , loginPageModel: Login.Model
    , user: Maybe Auth.User
    }


type Action
    = NoOp
    | RegisterPageAction Register.Action
    | LoginPageAction Login.Action
    | RouterAction (TransitRouter.Action Route)
    | SetUser (Maybe Auth.User)


initialModel : Model
initialModel =
    { transitRouter = TransitRouter.empty Home
    , loginPageModel = Login.init
    , registerPageModel = Register.init
    , user = Nothing
    }

module Model where

import TransitRouter exposing (WithRoute)
import Routes exposing (Route)
import Pages.Login
import Pages.Register


type alias Model = WithRoute Route
    { registerPageModel: Pages.Register.Model
    , loginPageModel: Pages.Login.Model
    }


type Action
    = NoOp
    | RegisterPageAction Pages.Register.Action
    | LoginPageAction Pages.Login.Action
    | RouterAction (TransitRouter.Action Route)

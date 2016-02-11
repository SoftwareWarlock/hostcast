module Update where

import Effects exposing (Effects, none)
import TransitRouter

import Model exposing (..)
import Routes exposing (..)
import Pages.Login
import Pages.Register


initialModel: Model
initialModel =
    { transitRouter = TransitRouter.empty Home
    , loginPageModel = Pages.Login.init
    , registerPageModel = Pages.Register.init
    }


actions: Signal Action
actions =
    Signal.map RouterAction TransitRouter.actions


routerConfig: TransitRouter.Config Route Action Model
routerConfig =
    { mountRoute = mountRoute
    , getDurations = \_ _ _ -> (50, 200)
    , actionWrapper = RouterAction
    , routeDecoder = Routes.decode
    }


init: String -> (Model, Effects Action)
init path =
    TransitRouter.init routerConfig path initialModel


update: Action -> Model -> (Model, Effects Action)
update action model =
    case action of
        NoOp ->
            (model, Effects.none)

        RegisterPageAction registerAction ->
            let (newModel, effects) = Pages.Register.update registerAction model.registerPageModel
            in ( { model | registerPageModel = newModel }
               , Effects.map RegisterPageAction effects )

        LoginPageAction loginAction ->
            let (newModel, effects) = Pages.Login.update loginAction model.loginPageModel
            in ( { model | loginPageModel = newModel }
               , Effects.map LoginPageAction effects )

        RouterAction routeAction ->
            TransitRouter.update routerConfig routeAction model


mountRoute: Route -> Route -> Model -> (Model, Effects Action)
mountRoute previousRoute route model =
    case route of
        Home ->
            (model, Effects.none)

        Login ->
            (model, Effects.none)

        Register ->
            (model, Effects.none)

        NotFound ->
            (model, Effects.none)

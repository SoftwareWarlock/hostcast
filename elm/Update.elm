module Update where

import Effects exposing (Effects, none)
import TransitRouter

import Model exposing (..)
import Routes exposing (..)
import Pages.Login.Update as Login
import Pages.Register.Update as Register
import Pages.Home.Update as Home
import Pages.CreatePodcast.Update as CreatePodcast
import Pages.CreatePodcast.Model as CreatePodcastModel

import Services.Podcasts as Podcasts
import Task
import Response exposing (..)


actions : Signal Action
actions =
    Signal.map RouterAction TransitRouter.actions


routerConfig : TransitRouter.Config Route Action Model
routerConfig =
    { mountRoute = mountRoute
    , getDurations = \_ _ _ -> (50, 200)
    , actionWrapper = RouterAction
    , routeDecoder = Routes.decode
    }


init : String -> (Model, Effects Action)
init path =
    TransitRouter.init routerConfig path initialModel


update : Action -> Model -> (Model, Effects Action)
update action model =
    case action of
        NoOp ->
            (model, Effects.none)

        RegisterPageAction registerAction ->
            let (newModel, effects) = Register.update registerAction model.registerPageModel
            in ( { model | registerPageModel = newModel }
               , Effects.map RegisterPageAction effects )

        LoginPageAction loginAction ->
            let (newModel, effects) = Login.update loginAction model.loginPageModel
            in ( { model | loginPageModel = newModel }
               , Effects.map LoginPageAction effects )

        HomePageAction homePageAction ->
            let (newModel, effects) = Home.update homePageAction model.homePageModel
            in ( { model | homePageModel = newModel }
               , Effects.map HomePageAction effects )

        CreatePodcastAction createPodcastAction ->
            let 
                (newModel, effects) = 
                    CreatePodcast.update createPodcastAction model.createPodcastModel
            in 
                ( { model | createPodcastModel = newModel }
                , Effects.map CreatePodcastAction effects )

        RouterAction routeAction ->
            TransitRouter.update routerConfig routeAction model

        SetUser user ->
            let
                homeModel = model.homePageModel
                newHomeModel = { homeModel | user = user }
                newModel =
                    { model
                    | user = user
                    , homePageModel = newHomeModel
                    }
            in
                (newModel, Effects.none)


mountRoute : Route -> Route -> Model -> (Model, Effects Action)
mountRoute previousRoute route model =
    case route of
        Home ->
            Home.podcastsResolveTask model.homePageModel
                |> Task.map (\a -> HomePageAction a)
                |> taskRes model

        Login ->
            (model, Effects.none)

        Register ->
            (model, Effects.none)

        NotFound ->
            (model, Effects.none)

        CreatePodcast ->
            let
                initialModel = CreatePodcastModel.init
                newCreatePodcastModel = { initialModel | user = model.user }
                newModel = { model | createPodcastModel = newCreatePodcastModel }
            in
                (newModel, Effects.none)

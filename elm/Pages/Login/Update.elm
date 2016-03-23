module Pages.Login.Update where

import Pages.Login.Model exposing (..)

import Services.Auth as Auth exposing (RegisterResponse) 
import Services.Helpers exposing (ServerResult, ServerErrors)
import Update.Utils as Utils

import Routes

import Effects exposing (Effects, Never)
import Task exposing (Task)

import Form exposing (Form)

import Maybe exposing (map, andThen)
import Dict exposing (Dict)

import Result exposing (Result(Ok, Err))
import Response exposing (..)


update : Action -> Model -> (Model, Effects Action)
update action model =
    case action of
        FormAction formAction ->
            res { model | form = Form.update formAction model.form } Effects.none

        SubmitLogin login ->
            taskRes { model | serverErrors = Dict.empty }
                (loginEffects login.email login.password)

        LoginComplete serverResponse ->
            let
                newModel = { model | loading = False }
                makeNoOp = (\_ -> NoOp)
                redirectEffect = 
                    Effects.map
                        makeNoOp
                        (Routes.redirect Routes.Home)
                setUserEffect user = 
                    Effects.map
                        makeNoOp
                        (Utils.setUser user)
                batchEffects user =
                    Effects.batch [redirectEffect, setUserEffect user]
            in
                case serverResponse of
                    Ok token ->
                        let
                            newUser = 
                                getFieldAsMaybe "email" model.form
                                    |> Maybe.map (\email -> { email = email, token = token })
                        in
                            res {newModel | user = newUser } (batchEffects newUser)
                    Err serverErrors ->
                        res { newModel | serverErrors = serverErrors } Effects.none

        Logout ->
            res { model | user = Nothing } Effects.none

        NoOp ->
            res model Effects.none


getFieldAsMaybe : String -> Form.Form a b -> Maybe String
getFieldAsMaybe field form =
    Form.getFieldAsString field form
        |> .value


loginEffects : String -> String -> Task Never Action
loginEffects email password =
    Auth.login email password
        |> Task.map LoginComplete

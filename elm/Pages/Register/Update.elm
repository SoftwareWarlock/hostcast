module Pages.Register.Update where
import Pages.Register.Model exposing (..)

import Services.Auth as Auth exposing (ServerResult, RegisterResponse)
import Routes

import Task exposing (toMaybe, map, Task)
import Effects exposing (Effects, Never, none)

import Result exposing (Result(Ok, Err))
import Response exposing (..)

import Form exposing (Form)

update : Action -> Model -> (Model, Effects Action)
update action model =
    case action of
        FormAction formAction ->
            let
                updatedForm = Form.update formAction model.form
            in
                res  { model | form = updatedForm } none

        SubmitRegister registration ->
            taskRes { model | loading = True } (registerTask registration)

        RegisterComplete result ->
            let
                newModel = { model | loading = True }
                makeNoOp = (\_ -> NoOp)
                redirectEffect = 
                    Effects.map
                        makeNoOp
                        (Routes.redirect Routes.Login)
            in
                case result of
                    Ok _ ->
                        res newModel redirectEffect
                    Err errors ->
                        res { model | serverErrors = errors } none

        NoOp ->
            res model none


registerTask : Registration -> Task Never Action
registerTask { email, password } =
    Auth.register email password
        |> Task.map RegisterComplete

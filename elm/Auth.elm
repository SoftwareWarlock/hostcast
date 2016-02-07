module Auth (Model, Action, State, update, view, init) where

import Effects exposing (Effects, Never)
import Html exposing (..)
import Html.Attributes exposing (style)
import Html.Events exposing (onClick)
import Http exposing (..)
import Json.Decode as JsonDecode
import Json.Encode as JsonEncode
import Task exposing (..)

type State
    = Authenticated
    | Unauthenticated

type alias Model = 
    { token: String
    , state: State
    }

type Action 
    = SubmitLogin (String, String)
    | LoginComplete (Maybe String)
    | Logout

init: (Model, Effects Action)
init = ( { token = ""
         , state = Unauthenticated
         }
       , Effects.none
       )

update: Action -> Model -> (Model, Effects Action)
update action model =
    case action of
        SubmitLogin (username, password) ->
            (model, login username password)

        LoginComplete maybeToken ->
            ( { token = (Maybe.withDefault "no token" maybeToken)
              , state = Authenticated
              }
            , Effects.none
            )

        Logout ->
            ( { token = ""
              , state = Unauthenticated
              }
            , Effects.none
            )

view: Signal.Address Action -> Model -> Html
view address model =
    div [] 
        [ button [ onClick address (SubmitLogin ("test", "test")) ] [ text "Login" ]
        ]

login: String -> String -> Effects Action
login username password =
    sendAuthRequest (authRequest (loginBody username password))
        |> Task.toMaybe
        |> Task.map LoginComplete
        |> Effects.task

sendAuthRequest: Request -> Task Error String
sendAuthRequest request = fromJson decodeToken (send defaultSettings request)

authRequest: Body -> Request
authRequest body = 
    { verb = "POST"
    , headers = [ ("Content-Type", "application/json") ]
    , url = "/auth/login/"
    , body = body
    }

loginBody: String -> String -> Body
loginBody username password =
    string (jsonUserObject username password)

jsonUserObject: String -> String -> String
jsonUserObject username password = 
    JsonEncode.encode 4 ( 
        JsonEncode.object
            [ ("username", JsonEncode.string username)
            , ("password", JsonEncode.string password)
            ]
        )

decodeToken : JsonDecode.Decoder String
decodeToken =
      JsonDecode.at ["data", "token"] JsonDecode.string

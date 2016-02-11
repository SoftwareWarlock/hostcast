module Services.Auth (login, register) where

import Effects exposing (Effects, Never)
import Task exposing (..)

import Http exposing (..)
import Json.Decode as JsonDecode
import Json.Encode as JsonEncode

login: String -> String -> Task Error String
login username password =
    loginBody username password
        |> loginRequest 
        |> sendAuthRequest

register: String -> String -> Task Error String
register username password =
    registerBody username password
        |> registerRequest
        |> sendAuthRequest 

sendAuthRequest: Request -> Task Error String
sendAuthRequest request = fromJson decodeToken (send defaultSettings request)

loginRequest: Body -> Request
loginRequest body = 
    { verb = "POST"
    , headers = [ ("Content-Type", "application/json") ]
    , url = "/auth/login/"
    , body = body
    }

loginBody: String -> String -> Body
loginBody username password =
    string (jsonUserObject username password)

registerRequest: Body -> Request
registerRequest body = 
    { verb = "POST"
    , headers = [ ("Content-Type", "application/json") ]
    , url = "/auth/register/"
    , body = body
    }

registerBody: String -> String -> Body
registerBody username password =
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
      JsonDecode.at ["auth_token"] JsonDecode.string

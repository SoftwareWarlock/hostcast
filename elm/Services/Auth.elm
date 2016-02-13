module Services.Auth (login, register, User) where

import Effects exposing (Effects, Never)
import Task exposing (..)

import Http exposing (..)
import Json.Decode as JsonDecode
import Json.Encode as JsonEncode

type alias User =
    { email: String
    , token: String
    }

login : String -> String -> Task Error String
login email password =
    loginBody email password
        |> loginRequest 
        |> sendAuthRequest

register : String -> String -> Task Error String
register email password =
    registerBody email password
        |> registerRequest
        |> sendAuthRequest 

sendAuthRequest : Request -> Task Error String
sendAuthRequest request = fromJson decodeToken (send defaultSettings request)

loginRequest : Body -> Request
loginRequest body = 
    { verb = "POST"
    , headers = [ ("Content-Type", "application/json") ]
    , url = "/auth/login/"
    , body = body
    }

loginBody : String -> String -> Body
loginBody email password =
    string (jsonUserObject email password)

registerRequest : Body -> Request
registerRequest body = 
    { verb = "POST"
    , headers = [ ("Content-Type", "application/json") ]
    , url = "/auth/register/"
    , body = body
    }

registerBody: String -> String -> Body
registerBody email password =
    string (jsonUserObject email password)

jsonUserObject : String -> String -> String
jsonUserObject email password = 
    JsonEncode.encode 4 ( 
        JsonEncode.object
            [ ("email", JsonEncode.string email)
            , ("password", JsonEncode.string password)
            ]
        )

decodeToken : JsonDecode.Decoder String
decodeToken =
      JsonDecode.at ["auth_token"] JsonDecode.string

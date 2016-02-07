module Auth (login) where

import Effects exposing (Effects, Never)
import Task exposing (..)

import Http exposing (..)
import Json.Decode as JsonDecode
import Json.Encode as JsonEncode

login: String -> String -> Task Error String
login username password =
    sendAuthRequest (loginRequest (loginBody username password))

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

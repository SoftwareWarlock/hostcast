module Services.Auth where

import Services.Helpers exposing (..)

import Json.Decode as JsonDecode exposing ((:=))
import Json.Encode as JsonEncode

import Effects exposing (Effects, Never)
import Task exposing (..)


type alias User =
    { email: String
    , token: String
    }

type alias RegisterResponse =
    { id: Int
    , email: String
    }


login : String -> String -> Task Never (ServerResult String)
login email password =
    postJson decodeToken "/auth/login/" (jsonUserObject email password)


register : String -> String -> Task Never (ServerResult RegisterResponse)
register email password =
    postJson decodeRegisterResponse "/auth/register/" (jsonUserObject email password)


jsonUserObject : String -> String -> JsonEncode.Value
jsonUserObject email password = 
    JsonEncode.object
        [ ("email", JsonEncode.string email)
        , ("password", JsonEncode.string password)
        ]


decodeToken : JsonDecode.Decoder String
decodeToken =
      JsonDecode.at ["auth_token"] JsonDecode.string


decodeRegisterResponse : JsonDecode.Decoder RegisterResponse
decodeRegisterResponse = 
    JsonDecode.object2 RegisterResponse
        ("id" := JsonDecode.int)
        ("email" := JsonDecode.string)

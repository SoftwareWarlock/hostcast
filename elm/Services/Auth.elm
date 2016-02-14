module Services.Auth where

import Effects exposing (Effects, Never)
import Task exposing (..)

import Http exposing (..)
import Json.Decode as JsonDecode exposing ((:=))
import Json.Encode as JsonEncode

import Dict exposing (Dict)


type alias User =
    { email: String
    , token: String
    }

type alias RegisterResponse =
    { id: String
    , email: String
    }

type alias ServerResult a = Result ServerErrors a

type alias ServerErrors = Dict String (List String)


login : String -> String -> Task Never (ServerResult String)
login email password =
    postJson decodeToken "/auth/login/" (jsonUserObject email password)


register : String -> String -> Task Never (ServerResult RegisterResponse)
register email password =
    postJson decodeRegisterResponse "/auth/register/" (jsonUserObject email password)


postJson : JsonDecode.Decoder a -> String -> JsonEncode.Value -> Task Never (ServerResult a)
postJson decoder url jsonBody = 
    Http.send Http.defaultSettings (jsonRequest url jsonBody)
        |> Task.toResult
        |> Task.map (handleResult decoder)


jsonRequest : String -> JsonEncode.Value -> Request
jsonRequest url jsonBody= 
    { verb = "POST"
    , headers = [ ("Content-Type", "application/json") ]
    , url = url
    , body = Http.string (JsonEncode.encode 0 jsonBody)
    }


handleResult : JsonDecode.Decoder a -> Result RawError Response -> ServerResult a
handleResult decoder result =
    case result of
        Ok response ->
            handleResponse decoder response
        Err _ ->
            Err defaultServerError


handleResponse : JsonDecode.Decoder a -> Response -> ServerResult a
handleResponse decoder response =
    if response.status >= 200 && response.status < 300 then
        case response.value of
            Text body ->
                JsonDecode.decodeString decoder body
                    |> Result.formatError (\_ -> defaultServerError)
            _ ->
                Err defaultServerError
    else
        case (response.status, response.value) of
            (400, Text body) ->
                case JsonDecode.decodeString errorsDecoder body of
                    Ok errors ->
                        Err errors
                    Err _ ->
                        Err defaultServerError
            _ ->
                Err defaultServerError


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
        ("id" := JsonDecode.string)
        ("email" := JsonDecode.string)


errorsDecoder : JsonDecode.Decoder ServerErrors
errorsDecoder =
    JsonDecode.dict (JsonDecode.list JsonDecode.string)


defaultServerError : ServerErrors
defaultServerError =
    Dict.singleton "non_field_errors" ["An unexpected error occured."]

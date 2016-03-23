module Services.Helpers where

import Effects exposing (Effects, Never)
import Task exposing (..)

import Http exposing (..)
import Json.Decode as JsonDecode exposing ((:=))
import Json.Encode as JsonEncode

import Dict exposing (Dict)


type alias ServerResult a = Result ServerErrors a

type alias ServerErrors = Dict String (List String)


postJson : JsonDecode.Decoder a -> String -> JsonEncode.Value -> Task Never (ServerResult a)
postJson decoder url jsonBody = 
    Http.send Http.defaultSettings (jsonRequest url jsonBody)
        |> Task.toResult
        |> Task.map (handleResult decoder)


postAuthenticatedJson : String -> JsonDecode.Decoder a -> String -> JsonEncode.Value -> Task Never (ServerResult a)
postAuthenticatedJson token decoder url jsonBody =
    Http.send Http.defaultSettings (authenticatedPostRequest token url jsonBody)
        |> Task.toResult
        |> Task.map (handleResult decoder)


getJson : String -> JsonDecode.Decoder a -> String -> Task Never (ServerResult a)
getJson token decoder url =
    Http.send Http.defaultSettings (authenticatedGetRequest token url)
        |> Task.toResult
        |> Task.map (handleResult decoder)


authenticatedGetRequest : String -> String -> Request
authenticatedGetRequest token url =
    { verb = "GET"
    , headers = 
        [ ("Content-Type", "application/json") 
        , ("Authorization", "Token " ++ token)
        ]
    , url = url
    , body = Http.empty
    }

authenticatedPostRequest : String -> String -> JsonEncode.Value -> Request
authenticatedPostRequest token url body =
    { verb = "POST"
    , headers = 
        [ ("Content-Type", "application/json") 
        , ("Authorization", "Token " ++ token)
        ]
    , url = url
    , body = Http.string (JsonEncode.encode 0 body)
    }



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


errorsDecoder : JsonDecode.Decoder ServerErrors
errorsDecoder =
    JsonDecode.dict (JsonDecode.list JsonDecode.string)


defaultServerError : ServerErrors
defaultServerError =
    Dict.singleton "non_field_errors" ["An unexpected error occured."]

module Services.Podcasts where

import Services.Helpers exposing (..)

import Json.Decode as JsonDecode exposing ((:=))
import Json.Encode as JsonEncode

import Effects exposing (Effects, Never)
import Task exposing (..)


type alias Podcast =
    { title: String
    , description: String
    }


getPodcasts : String -> Task Never (ServerResult (List Podcast))
getPodcasts token =
    getJson token decodePodcasts "/api/podcasts/" 


decodePodcasts : JsonDecode.Decoder (List Podcast)
decodePodcasts = 
    JsonDecode.list <| decodePodcast


decodePodcast : JsonDecode.Decoder Podcast
decodePodcast =
    JsonDecode.object2 Podcast
        ("title" := JsonDecode.string)
        ("description" := JsonDecode.string)

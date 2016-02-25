import Html exposing (text)
import StartApp
import Task
import Effects exposing (Never)

import Model exposing (appMailbox)
import Update exposing (init, update, actions)
import View exposing (view)


port initialPath: String


app = 
    StartApp.start
    { init = init initialPath
    , update = update
    , view = view
    , inputs = 
        [ actions 
        , appMailbox.signal
        ]
    }

main = app.html

port tasks: Signal (Task.Task Never ())
port tasks =
    app.tasks

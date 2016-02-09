import Html exposing (text)
import Register exposing (update, view, init)
import StartApp
import Task
import Effects exposing (Never)

app = 
    StartApp.start
    { init = init
    , update = update
    , view = view
    , inputs = []
    }

main = app.html

port tasks: Signal (Task.Task Never ())
port tasks =
    app.tasks

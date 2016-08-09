port module Online.Model exposing (initialModel, subscriptions)

import Dict exposing (Dict)
import Phoenix.Socket
import Online.Types exposing (..)
import Components.DiscussionEditor as DiscussionEditor
import Online.Routing as Routing
import Online.Backend as Backend


-- MODEL


initialModel : Route -> Model
initialModel route =
    { socket = Backend.initSocket
    , connected = False
    , presences = Dict.empty
    , discussions = []
    , discussionId = Nothing
    , messages = []
    , config = AppConfig 0 "n/a"
    , route = route
    , discussionEditorModel = DiscussionEditor.initialModel
    }



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Phoenix.Socket.listen model.socket PhoenixMsg
        , initApplication InitApplication
        ]


port initApplication : (AppConfig -> msg) -> Sub msg

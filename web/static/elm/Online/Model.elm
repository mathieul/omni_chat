port module Online.Model exposing (Model, initialModel, subscriptions, hallChannel)

import Dict exposing (Dict)
import Phoenix.Socket
import Online.Types exposing (..)
import Components.DiscussionEditor as DiscussionEditor


-- MODEL


type alias Model =
    { socket : Phoenix.Socket.Socket Msg
    , connected : Bool
    , presences : PresenceState
    , discussions : List Discussion
    , config : AppConfig
    , discussionEditorModel : DiscussionEditor.Model
    }


socketServer : String
socketServer =
    "ws://localhost:4000/socket/websocket"


hallChannel : String
hallChannel =
    "discussion:hall"


initSocket : Phoenix.Socket.Socket Msg
initSocket =
    Phoenix.Socket.init socketServer
        |> Phoenix.Socket.on "all_discussions" hallChannel ReceiveAllDiscussions
        |> Phoenix.Socket.on "presence_state" hallChannel HandlePresenceState
        |> Phoenix.Socket.on "presence_diff" hallChannel HandlePresenceDiff
        |> Phoenix.Socket.withDebug


initialModel : Model
initialModel =
    { socket = initSocket
    , connected = False
    , presences = Dict.empty
    , discussions = []
    , config = AppConfig 0 "n/a"
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

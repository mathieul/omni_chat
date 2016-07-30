port module Online.Model exposing (Model, initialModel, subscriptions)

import Dict exposing (Dict)
import Phoenix.Socket
import Online.Types exposing (..)


-- MODEL


type alias Model =
    { socket : Phoenix.Socket.Socket Msg
    , status : String
    , presences : PresenceState
    , discussions : List Discussion
    , config : AppConfig
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



-- |> Phoenix.Socket.withDebug


initialModel : Model
initialModel =
    { socket = initSocket
    , status = "disconnected"
    , presences = Dict.empty
    , discussions = []
    , config = AppConfig 0 "n/a"
    }



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Phoenix.Socket.listen model.socket PhoenixMsg
        , initApplication InitApplication
        ]


port initApplication : (AppConfig -> msg) -> Sub msg

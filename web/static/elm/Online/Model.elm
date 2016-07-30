port module Online.Model exposing (Model, initialModel, subscriptions)

import Dict exposing (Dict)
import Phoenix.Socket
import Online.Types exposing (..)


-- MODEL


type alias Model =
    { socket : Phoenix.Socket.Socket Msg
    , status : String
    , latestMessage : String
    , presences : PresenceState
    , config : AppConfig
    }


socketServer : String
socketServer =
    "ws://localhost:4000/socket/websocket"


initSocket : Phoenix.Socket.Socket Msg
initSocket =
    Phoenix.Socket.init socketServer
        |> Phoenix.Socket.on "init" "discussion:hall" ReceiveChatMessage
        |> Phoenix.Socket.on "presence_state" "discussion:hall" HandlePresenceState
        |> Phoenix.Socket.on "presence_diff" "discussion:hall" HandlePresenceDiff



-- |> Phoenix.Socket.withDebug


initialModel : Model
initialModel =
    { socket = initSocket
    , status = "disconnected"
    , latestMessage = ""
    , presences = Dict.empty
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

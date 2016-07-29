port module Online.App exposing (initialModel, subscriptions)

import Dict exposing (Dict)
import Phoenix.Socket
import Online.Model exposing (..)


-- MODEL


socketServer : String
socketServer =
    "ws://localhost:4000/socket/websocket"


initSocket : Phoenix.Socket.Socket Msg
initSocket =
    Phoenix.Socket.init socketServer
        |> Phoenix.Socket.withDebug
        |> Phoenix.Socket.on "welcome" "subject:lobby" ReceiveChatMessage
        |> Phoenix.Socket.on "presence_state" "subject:lobby" HandlePresenceState
        |> Phoenix.Socket.on "presence_diff" "subject:lobby" HandlePresenceDiff


initialModel : Model
initialModel =
    { socket = initSocket
    , status = "disconnected"
    , latestMessage = ""
    , presences = Dict.empty
    , config = ApplicationConfig 0 "n/a" "n/a"
    }



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Phoenix.Socket.listen model.socket PhoenixMsg
        , initApplication InitApplication
        ]


port initApplication : (ApplicationConfig -> msg) -> Sub msg

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
    , config : ApplicationConfig
    }


socketServer : String
socketServer =
    "ws://localhost:4000/socket/websocket"


initSocket : Phoenix.Socket.Socket Msg
initSocket =
    Phoenix.Socket.init socketServer
        |> Phoenix.Socket.withDebug
        |> Phoenix.Socket.on "init" "discussion:hall" ReceiveChatMessage
        |> Phoenix.Socket.on "presence_state" "discussion:hall" HandlePresenceState
        |> Phoenix.Socket.on "presence_diff" "discussion:hall" HandlePresenceDiff


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

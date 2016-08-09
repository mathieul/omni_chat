module Online.Backend
    exposing
        ( hallChannel
        , discussionChannel
        , initSocket
        , leaveDiscussionChannel
        , doHandlePhoenixMsg
        )

import Phoenix.Socket
import Online.Types exposing (Msg(..), DiscussionId, Model)


socketServer : String
socketServer =
    "ws://localhost:4000/socket/websocket"


hallChannel : String
hallChannel =
    "discussion:hall"


discussionChannel : DiscussionId -> String
discussionChannel discussionId =
    "discussion:" ++ (toString discussionId)


initSocket : Phoenix.Socket.Socket Msg
initSocket =
    Phoenix.Socket.init socketServer
        |> Phoenix.Socket.on "presence_state" hallChannel HandlePresenceState
        |> Phoenix.Socket.on "presence_diff" hallChannel HandlePresenceDiff
        |> Phoenix.Socket.on "all_discussions" hallChannel ReceiveAllDiscussions
        |> Phoenix.Socket.withDebug


leaveDiscussionChannel :
    DiscussionId
    -> Phoenix.Socket.Socket Msg
    -> ( Phoenix.Socket.Socket Msg, Cmd (Phoenix.Socket.Msg Msg) )
leaveDiscussionChannel discussionId socket =
    let
        channelName =
            discussionChannel discussionId

        unsubscribedSocket =
            Phoenix.Socket.off "messages" channelName socket
    in
        Phoenix.Socket.leave channelName unsubscribedSocket


doHandlePhoenixMsg : Phoenix.Socket.Msg Msg -> Model -> ( Model, Cmd Msg )
doHandlePhoenixMsg phxMsg model =
    let
        ( phxSocket, phxCmd ) =
            Phoenix.Socket.update phxMsg model.socket
    in
        ( { model | socket = phxSocket }
        , Cmd.map PhoenixMsg phxCmd
        )

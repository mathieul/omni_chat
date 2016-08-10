module Online.Backend
    exposing
        ( hallChannel
        , discussionChannel
        , initSocket
        , leaveDiscussionChannel
        , doHandlePhoenixMsg
        , requestDiscussionCreation
        , doJoinDiscussionChannel
        , doJoinDiscussionHallChannel
        )

import Json.Encode as JE
import Phoenix.Socket exposing (Socket)
import Phoenix.Channel
import Phoenix.Push
import Online.Types exposing (Model, Msg(..), DiscussionId, AppConfig)


socketServer : String
socketServer =
    "ws://localhost:4000/socket/websocket"


hallChannel : String
hallChannel =
    "discussion:hall"


discussionChannel : DiscussionId -> String
discussionChannel discussionId =
    "discussion:" ++ (toString discussionId)


initSocket : Socket Msg
initSocket =
    Phoenix.Socket.init socketServer
        |> Phoenix.Socket.on "presence_state" hallChannel HandlePresenceState
        |> Phoenix.Socket.on "presence_diff" hallChannel HandlePresenceDiff
        |> Phoenix.Socket.on "all_discussions" hallChannel ReceiveAllDiscussions
        |> Phoenix.Socket.withDebug


leaveDiscussionChannel :
    DiscussionId
    -> Socket Msg
    -> ( Socket Msg, Cmd (Phoenix.Socket.Msg Msg) )
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


requestDiscussionCreation : String -> Socket Msg -> ( Socket Msg, Cmd (Phoenix.Socket.Msg Msg) )
requestDiscussionCreation subject socket =
    let
        payload =
            JE.object
                [ ( "subject", JE.string subject ) ]

        phxPush =
            Phoenix.Push.init "create_discussion" hallChannel
                |> Phoenix.Push.withPayload payload
    in
        Phoenix.Socket.push phxPush socket


doJoinDiscussionChannel : DiscussionId -> AppConfig -> Socket Msg -> ( Socket Msg, Cmd (Phoenix.Socket.Msg Msg) )
doJoinDiscussionChannel discussionId config socket =
    let
        channelName =
            discussionChannel discussionId

        subscribedSocket =
            Phoenix.Socket.on "messages" channelName ReceiveMessageList socket

        channel =
            Phoenix.Channel.init channelName
                |> Phoenix.Channel.withPayload (userParams config)
    in
        Phoenix.Socket.join channel subscribedSocket


doJoinDiscussionHallChannel : AppConfig -> Socket Msg -> ( Socket Msg, Cmd (Phoenix.Socket.Msg Msg) )
doJoinDiscussionHallChannel config socket =
    let
        channel =
            Phoenix.Channel.init hallChannel
                |> Phoenix.Channel.withPayload (userParams config)
                |> Phoenix.Channel.onJoin (always DidJoinChannel)
                |> Phoenix.Channel.onClose (always DidLeaveChannel)
    in
        Phoenix.Socket.join channel socket


userParams : AppConfig -> JE.Value
userParams config =
    JE.object
        [ ( "chatter_id", JE.int config.chatter_id )
        , ( "nickname", JE.string config.nickname )
        ]

module Online.Backend
    exposing
        ( hallChannel
        , discussionChannel
        , initSocket
        , leaveDiscussionChannel
        , handlePhoenixMsg
        , createDiscussion
        , joinDiscussionChannel
        , joinDiscussionHallChannel
        , sendMessage
        )

import Json.Encode as JE
import Phoenix.Socket exposing (Socket)
import Phoenix.Channel
import Phoenix.Push
import Online.Types exposing (Model, Msg(..), DiscussionId, AppConfig)


hallChannel : String
hallChannel =
    "discussion:hall"


discussionChannel : DiscussionId -> String
discussionChannel discussionId =
    "discussion:" ++ (toString discussionId)


initSocket : String -> Socket Msg
initSocket socketServer =
    Phoenix.Socket.init socketServer
        |> Phoenix.Socket.on "presence_state" hallChannel HandlePresenceState
        |> Phoenix.Socket.on "presence_diff" hallChannel HandlePresenceDiff
        |> Phoenix.Socket.on "all_discussions" hallChannel ReceiveAllDiscussions


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


handlePhoenixMsg : Phoenix.Socket.Msg Msg -> Model -> ( Model, Cmd Msg )
handlePhoenixMsg phxMsg model =
    let
        ( phxSocket, phxCmd ) =
            Phoenix.Socket.update phxMsg model.socket
    in
        ( { model | socket = phxSocket }
        , Cmd.map PhoenixMsg phxCmd
        )


createDiscussion : String -> Socket Msg -> ( Socket Msg, Cmd (Phoenix.Socket.Msg Msg) )
createDiscussion subject socket =
    let
        payload =
            JE.object
                [ ( "subject", JE.string subject ) ]

        phxPush =
            Phoenix.Push.init "create_discussion" hallChannel
                |> Phoenix.Push.withPayload payload
    in
        Phoenix.Socket.push phxPush socket


joinDiscussionChannel : DiscussionId -> AppConfig -> Socket Msg -> ( Socket Msg, Cmd (Phoenix.Socket.Msg Msg) )
joinDiscussionChannel discussionId config socket =
    let
        channelName =
            discussionChannel discussionId

        subscribedSocket =
            socket
                |> Phoenix.Socket.on "messages" channelName ReceiveMessageList
                |> Phoenix.Socket.on "message" channelName ReceiveMessage

        channel =
            Phoenix.Channel.init channelName
                |> Phoenix.Channel.withPayload (userParams config)
    in
        Phoenix.Socket.join channel subscribedSocket


joinDiscussionHallChannel : AppConfig -> Socket Msg -> ( Socket Msg, Cmd (Phoenix.Socket.Msg Msg) )
joinDiscussionHallChannel config socket =
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
        [ ( "chatter_id", JE.int config.chatterId )
        , ( "nickname", JE.string config.nickname )
        ]


sendMessage : String -> DiscussionId -> Socket Msg -> ( Socket Msg, Cmd (Phoenix.Socket.Msg Msg) )
sendMessage content discussionId socket =
    let
        channelName =
            discussionChannel discussionId

        payload =
            JE.object
                [ ( "content", JE.string content ) ]

        phxPush =
            Phoenix.Push.init "send_message" channelName
                |> Phoenix.Push.withPayload payload
    in
        Phoenix.Socket.push phxPush socket

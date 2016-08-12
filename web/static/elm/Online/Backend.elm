module Online.Backend
    exposing
        ( hallChannel
        , discussionChannel
        , emptySocket
        , initSocket
        , leaveDiscussionChannel
        , doHandlePhoenixMsg
        , doCreateDiscussion
        , doJoinDiscussionChannel
        , doJoinDiscussionHallChannel
        , doSendMessage
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


emptySocket : Socket Msg
emptySocket =
    Phoenix.Socket.init ""


initSocket : String -> Socket Msg
initSocket socketServer =
    Phoenix.Socket.init socketServer
        -- |> Phoenix.Socket.withDebug
        |>
            Phoenix.Socket.on "presence_state" hallChannel HandlePresenceState
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


doHandlePhoenixMsg : Phoenix.Socket.Msg Msg -> Model -> ( Model, Cmd Msg )
doHandlePhoenixMsg phxMsg model =
    let
        ( phxSocket, phxCmd ) =
            Phoenix.Socket.update phxMsg model.socket
    in
        ( { model | socket = phxSocket }
        , Cmd.map PhoenixMsg phxCmd
        )


doCreateDiscussion : String -> Socket Msg -> ( Socket Msg, Cmd (Phoenix.Socket.Msg Msg) )
doCreateDiscussion subject socket =
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
            socket
                |> Phoenix.Socket.on "messages" channelName ReceiveMessageList
                |> Phoenix.Socket.on "message" channelName ReceiveMessage

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


doSendMessage : String -> DiscussionId -> Socket Msg -> ( Socket Msg, Cmd (Phoenix.Socket.Msg Msg) )
doSendMessage content discussionId socket =
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

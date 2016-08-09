module Online.Update exposing (update)

import Json.Encode as JE
import Navigation
import Phoenix.Socket
import Phoenix.Channel
import Phoenix.Push
import OutMessage
import Online.Types exposing (..)
import Online.Backend as Backend
import Online.Presence as Presence
import Online.Discussion as Discussion
import Online.DiscussionMessage as DiscussionMessage
import Components.DiscussionEditor as DiscussionEditor


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        InitApplication content ->
            doInitApplication content model

        PhoenixMsg phxMsg ->
            Backend.doHandlePhoenixMsg phxMsg model

        DiscussionEditorMsg deMsg ->
            DiscussionEditor.update deMsg model.discussionEditorModel
                |> OutMessage.mapComponent
                    (\discussionEditorModel ->
                        { model | discussionEditorModel = discussionEditorModel }
                    )
                |> OutMessage.mapCmd DiscussionEditorMsg
                |> OutMessage.evaluateMaybe interpretOutMsg Cmd.none

        DidJoinChannel ->
            { model | connected = True } ! []

        DidLeaveChannel ->
            { model | connected = False } ! []

        ReceiveAllDiscussions raw ->
            Discussion.receiveAll raw model

        ReceiveMessages raw ->
            DiscussionMessage.receiveCollection raw model

        HandlePresenceState raw ->
            (Presence.processPresenceState raw model) ! []

        HandlePresenceDiff raw ->
            (Presence.processPresenceDiff raw model) ! []

        ShowDiscussionList ->
            doShowDiscussionList model

        ShowDiscussion discussionId ->
            doShowDiscussion discussionId model


interpretOutMsg : DiscussionEditor.OutMsg -> Model -> ( Model, Cmd Msg )
interpretOutMsg outmsg model =
    case outmsg of
        DiscussionEditor.DiscussionCreationRequested subject ->
            let
                newDiscussion =
                    { id = 0
                    , subject = subject
                    , participants = []
                    , last_activity = "loading..."
                    }

                ( newModel, commands ) =
                    doRequestDiscussionCreation newDiscussion model
            in
                ( { newModel
                    | discussions = newDiscussion :: model.discussions
                  }
                , commands
                )


doRequestDiscussionCreation : Discussion -> Model -> ( Model, Cmd Msg )
doRequestDiscussionCreation discussion model =
    let
        payload =
            JE.object
                [ ( "subject", JE.string discussion.subject ) ]

        phxPush =
            Phoenix.Push.init "create_discussion" Backend.hallChannel
                |> Phoenix.Push.withPayload payload

        ( socket, phxCmd ) =
            Phoenix.Socket.push phxPush model.socket
    in
        ( { model | socket = socket }
        , Cmd.map PhoenixMsg phxCmd
        )


doShowDiscussionList : Model -> ( Model, Cmd Msg )
doShowDiscussionList model =
    let
        modifyUrlCmd =
            Navigation.modifyUrl "#discussions"
    in
        case model.discussionId of
            Just discussionId ->
                let
                    ( phxSocket, phxCmd ) =
                        Backend.leaveDiscussionChannel discussionId model.socket
                in
                    ( { model
                        | socket = phxSocket
                        , discussionId = Nothing
                      }
                    , Cmd.batch
                        [ modifyUrlCmd
                        , Cmd.map PhoenixMsg phxCmd
                        ]
                    )

            Nothing ->
                model ! [ modifyUrlCmd ]


doShowDiscussion : DiscussionId -> Model -> ( Model, Cmd Msg )
doShowDiscussion discussionId model =
    let
        channelName =
            Backend.discussionChannel discussionId

        subscribedSocket =
            Phoenix.Socket.on "messages" channelName ReceiveMessages model.socket

        channel =
            Phoenix.Channel.init channelName
                |> Phoenix.Channel.withPayload (userParams model.config)

        ( phxSocket, phxCmd ) =
            Phoenix.Socket.join channel subscribedSocket
    in
        ( { model
            | socket = phxSocket
            , discussionId = Just discussionId
          }
        , Cmd.batch
            [ Navigation.modifyUrl <| "#discussions/" ++ (toString discussionId)
            , Cmd.map PhoenixMsg phxCmd
            ]
        )


doInitApplication : AppConfig -> Model -> ( Model, Cmd Msg )
doInitApplication content model =
    let
        newConfig =
            AppConfig content.chatter_id content.nickname

        channel =
            Phoenix.Channel.init Backend.hallChannel
                |> Phoenix.Channel.withPayload (userParams newConfig)
                |> Phoenix.Channel.onJoin (always DidJoinChannel)
                |> Phoenix.Channel.onClose (always DidLeaveChannel)

        ( phxSocket, phxCmd ) =
            Phoenix.Socket.join channel model.socket
    in
        ( { model
            | socket = phxSocket
            , config = newConfig
          }
        , Cmd.map PhoenixMsg phxCmd
        )


userParams : AppConfig -> JE.Value
userParams config =
    JE.object
        [ ( "chatter_id", JE.int config.chatter_id )
        , ( "nickname", JE.string config.nickname )
        ]

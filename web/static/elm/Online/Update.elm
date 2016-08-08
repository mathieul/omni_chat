module Online.Update exposing (update)

import Json.Encode as JE
import Navigation
import Phoenix.Socket
import Phoenix.Channel
import Phoenix.Push
import OutMessage
import Online.Types exposing (..)
import Online.Model exposing (Model)
import Online.Presence as Presence
import Online.Discussion as Discussion
import Components.DiscussionEditor as DiscussionEditor


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        InitApplication content ->
            doInitApplication content model

        PhoenixMsg phxMsg ->
            doHandlePhoenixMsg phxMsg model

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

        HandlePresenceState raw ->
            (Presence.processPresenceState raw model) ! []

        HandlePresenceDiff raw ->
            (Presence.processPresenceDiff raw model) ! []

        ShowDiscussions ->
            ( model, Navigation.modifyUrl "#discussions" )

        ShowDiscussion discussionId ->
            ( model
            , Navigation.modifyUrl <| "#discussions/" ++ (toString discussionId)
            )


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
            Phoenix.Push.init "create_discussion" Online.Model.hallChannel
                |> Phoenix.Push.withPayload payload

        ( socket, phxCmd ) =
            Phoenix.Socket.push phxPush model.socket

        _ =
            Debug.log "doRequestDiscussionCreation" discussion
    in
        ( { model | socket = socket }
        , Cmd.map PhoenixMsg phxCmd
        )


doInitApplication : AppConfig -> Model -> ( Model, Cmd Msg )
doInitApplication content model =
    let
        newConfig =
            AppConfig content.chatter_id content.nickname

        channel =
            Phoenix.Channel.init Online.Model.hallChannel
                |> Phoenix.Channel.withPayload (userParams newConfig)
                |> Phoenix.Channel.onJoin (always DidJoinChannel)
                |> Phoenix.Channel.onClose (always DidLeaveChannel)

        ( phxSocket, phxCmd ) =
            Phoenix.Socket.join channel model.socket

        wrappedCommands =
            Cmd.map PhoenixMsg phxCmd
    in
        ( { model
            | socket = phxSocket
            , config = newConfig
          }
        , wrappedCommands
        )


doHandlePhoenixMsg : Phoenix.Socket.Msg Msg -> Model -> ( Model, Cmd Msg )
doHandlePhoenixMsg phxMsg model =
    let
        ( phxSocket, phxCmd ) =
            Phoenix.Socket.update phxMsg model.socket
    in
        ( { model | socket = phxSocket }
        , Cmd.map PhoenixMsg phxCmd
        )


userParams : AppConfig -> JE.Value
userParams config =
    JE.object
        [ ( "chatter_id", JE.int config.chatter_id )
        , ( "nickname", JE.string config.nickname )
        ]

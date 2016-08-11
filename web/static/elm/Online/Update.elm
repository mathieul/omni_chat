module Online.Update exposing (update)

import Json.Encode as JE
import Navigation
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
        InitApplication config ->
            doInitApplication config model

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

        ReceiveMessageList raw ->
            DiscussionMessage.receiveCollection raw model

        ReceiveMessage raw ->
            DiscussionMessage.receiveOne raw model

        UpdateCurrentMessage content ->
            { model | currentMessage = content } ! []

        SendMessage ->
            let
                discussionId =
                    Maybe.withDefault 0 model.discussionId

                ( phxSocket, phxCmd ) =
                    Backend.doSendMessage model.currentMessage discussionId model.socket
            in
                { model
                    | socket = phxSocket
                    , currentMessage = ""
                }
                    ! [ Cmd.map PhoenixMsg phxCmd ]

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
        ( pxhSocket, phxCmd ) =
            Backend.doCreateDiscussion discussion.subject model.socket
    in
        ( { model | socket = pxhSocket }
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
        ( phxSocket, phxCmd ) =
            Backend.doJoinDiscussionChannel discussionId model.config model.socket
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
doInitApplication config model =
    let
        ( phxSocket, phxCmd ) =
            Backend.doJoinDiscussionHallChannel config model.socket

        maybeRedirect =
            case config.discussion_id of
                Just discussionId ->
                    Navigation.modifyUrl <| "#discussions/" ++ (toString discussionId)

                Nothing ->
                    Cmd.none

        maybeDiscussionId =
            if config.discussion_id == Nothing then
                case model.route of
                    DiscussionRoute discussionId ->
                        Just discussionId

                    _ ->
                        Nothing
            else
                config.discussion_id

        ( phxSocket', phxCmd' ) =
            case maybeDiscussionId of
                Just discussionId ->
                    Backend.doJoinDiscussionChannel discussionId config phxSocket

                Nothing ->
                    ( phxSocket, Cmd.none )
    in
        ( { model
            | socket = phxSocket'
            , config = config
            , discussionId = maybeDiscussionId
          }
        , Cmd.batch
            [ Cmd.map PhoenixMsg phxCmd
            , Cmd.map PhoenixMsg phxCmd'
            , maybeRedirect
            ]
        )

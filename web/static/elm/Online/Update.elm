module Online.Update exposing (update)

import String
import String.Extra
import Navigation
import Task
import Dom exposing (focus)
import Dom.Scroll exposing (toBottom)
import Online.Types exposing (..)
import Online.Backend as Backend
import Online.Presence as Presence
import Online.JsonApiDecoders as JsonApiDecoders


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            model ! []

        InitApplication ->
            doInitApplication model

        PhoenixMsg phxMsg ->
            Backend.doHandlePhoenixMsg phxMsg model

        DidJoinChannel ->
            { model | connected = True } ! []

        DidLeaveChannel ->
            { model | connected = False } ! []

        ReceiveAllDiscussions raw ->
            ( JsonApiDecoders.decodeDiscussionCollection raw model
            , Cmd.none
            )

        ReceiveMessageList raw ->
            ( JsonApiDecoders.decodeDiscussionMessageCollection raw model
            , Task.perform (always NoOp) (always NoOp) (toBottom "main")
            )

        ReceiveMessage raw ->
            ( JsonApiDecoders.decodeDiscussionMessage raw model
            , Task.perform (always NoOp) (always NoOp) (toBottom "main")
            )

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

        StartEditingDiscussion ->
            ( { model | editingDiscussion = True }
            , Task.perform (always NoOp) (always NoOp) (Dom.focus "discussion-subject")
            )

        StopEditingDiscussion ->
            { model | editingDiscussion = False } ! []

        UpdateDiscussionSubject subject ->
            { model | discussionSubject = subject } ! []

        CreateDiscussion subject ->
            let
                cleanSubject =
                    subject
                        |> String.trim
                        |> String.toLower
                        |> String.Extra.humanize

                newDiscussion =
                    { id = 0
                    , subject = subject
                    , participants = []
                    , last_activity = "loading..."
                    }

                ( newModel, commands ) =
                    doRequestDiscussionCreation newDiscussion model
            in
                if String.isEmpty cleanSubject then
                    model ! []
                else
                    ( { newModel
                        | discussions = newDiscussion :: model.discussions
                        , discussionSubject = ""
                        , editingDiscussion = False
                      }
                    , commands
                    )


doInitApplication : Model -> ( Model, Cmd Msg )
doInitApplication model =
    let
        ( phxSocket, phxCmd ) =
            Backend.doJoinDiscussionHallChannel model.config model.socket

        maybeRedirect =
            case model.config.discussionId of
                Just discussionId ->
                    Navigation.modifyUrl <| "#discussions/" ++ (toString discussionId)

                Nothing ->
                    Cmd.none

        maybeDiscussionId =
            if model.config.discussionId == Nothing then
                case model.route of
                    DiscussionRoute discussionId ->
                        Just discussionId

                    _ ->
                        Nothing
            else
                model.config.discussionId

        ( phxSocket', phxCmd' ) =
            case maybeDiscussionId of
                Just discussionId ->
                    Backend.doJoinDiscussionChannel discussionId model.config phxSocket

                Nothing ->
                    ( phxSocket, Cmd.none )
    in
        ( { model
            | socket = phxSocket'
            , discussionId = maybeDiscussionId
          }
        , Cmd.batch
            [ Cmd.map PhoenixMsg phxCmd
            , Cmd.map PhoenixMsg phxCmd'
            , maybeRedirect
            ]
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

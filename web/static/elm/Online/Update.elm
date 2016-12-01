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

        UrlChange location ->
            model ! []

        InitApplication ->
            ( model, Cmd.none )
                |> joinDiscussionHallChannel
                |> joinDiscussionChannelIfApplicable

        PhoenixMsg phxMsg ->
            Backend.handlePhoenixMsg phxMsg model

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
            , scrollToBottomOfBody
            )

        ReceiveMessage raw ->
            ( JsonApiDecoders.decodeDiscussionMessage raw model
            , scrollToBottomOfBody
            )

        UpdateCurrentMessage content ->
            { model | currentMessage = content } ! []

        SendMessage ->
            sendMessage model

        HandlePresenceState raw ->
            Presence.processPresenceState raw model ! []

        HandlePresenceDiff raw ->
            Presence.processPresenceDiff raw model ! []

        ShowDiscussionList ->
            showDiscussionList model

        ShowDiscussion discussionId ->
            showDiscussion discussionId model

        StartEditingDiscussion ->
            ( { model | editingDiscussion = True }
            , focusOnElement "discussion-subject"
            )

        StopEditingDiscussion ->
            { model | editingDiscussion = False } ! []

        UpdateDiscussionSubject subject ->
            { model | discussionSubject = subject } ! []

        CreateDiscussion subject ->
            createDiscussion subject model


joinDiscussionHallChannel : ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
joinDiscussionHallChannel ( model, cmds ) =
    let
        ( phxSocket, phxCmd ) =
            Backend.joinDiscussionHallChannel model.config model.socket
    in
        ( { model | socket = phxSocket }
        , Cmd.batch [ cmds, Cmd.map PhoenixMsg phxCmd ]
        )


joinDiscussionChannelIfApplicable : ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
joinDiscussionChannelIfApplicable ( model, cmds ) =
    let
        maybeDiscussionId =
            if model.config.discussionId == Nothing then
                case model.route of
                    DiscussionRoute discussionId ->
                        Just discussionId

                    _ ->
                        Nothing
            else
                model.config.discussionId

        ( phxSocket, phxCmd ) =
            case maybeDiscussionId of
                Just discussionId ->
                    Backend.joinDiscussionChannel discussionId model.config model.socket

                Nothing ->
                    ( model.socket, Cmd.none )

        maybeRedirect =
            case model.config.discussionId of
                Just discussionId ->
                    Navigation.modifyUrl <| "#discussions/" ++ (toString discussionId)

                Nothing ->
                    Cmd.none
    in
        ( { model | socket = phxSocket }
        , Cmd.batch
            [ cmds
            , Cmd.map PhoenixMsg phxCmd
            , maybeRedirect
            ]
        )


sendMessage : Model -> ( Model, Cmd Msg )
sendMessage model =
    let
        discussionId =
            Maybe.withDefault 0 model.discussionId

        ( phxSocket, phxCmd ) =
            Backend.sendMessage model.currentMessage discussionId model.socket
    in
        ( { model
            | socket = phxSocket
            , currentMessage = ""
          }
        , Cmd.map PhoenixMsg phxCmd
        )


showDiscussionList : Model -> ( Model, Cmd Msg )
showDiscussionList model =
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


showDiscussion : DiscussionId -> Model -> ( Model, Cmd Msg )
showDiscussion discussionId model =
    let
        ( phxSocket, phxCmd ) =
            Backend.joinDiscussionChannel discussionId model.config model.socket
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


createDiscussion : String -> Model -> ( Model, Cmd Msg )
createDiscussion subject model =
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

        ( phxSocket, phxCmd ) =
            Backend.createDiscussion cleanSubject model.socket
    in
        if String.isEmpty cleanSubject then
            model ! []
        else
            ( { model
                | socket = phxSocket
                , discussions = newDiscussion :: model.discussions
                , discussionSubject = ""
                , editingDiscussion = False
              }
            , Cmd.map PhoenixMsg phxCmd
            )


scrollToBottomOfBody : Cmd Msg
scrollToBottomOfBody =
    Task.attempt (\_ -> NoOp) (toBottom "main")


focusOnElement : String -> Cmd Msg
focusOnElement id =
    Task.attempt (\_ -> NoOp) (Dom.focus id)

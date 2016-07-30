module Online.Update exposing (update)

import Json.Encode as JE
import Phoenix.Socket
import Phoenix.Channel
import Online.Types exposing (..)
import Online.Model exposing (Model)
import Online.Presence as Presence
import Online.Discussion as Discussion


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case Debug.log "update:" msg of
        InitApplication content ->
            doInitApplication content model

        PhoenixMsg phxMsg ->
            doHandlePhoenixMsg phxMsg model

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


doInitApplication : AppConfig -> Model -> ( Model, Cmd Msg )
doInitApplication content model =
    let
        newConfig =
            AppConfig content.chatter_id content.nickname

        channel =
            Phoenix.Channel.init "discussion:hall"
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

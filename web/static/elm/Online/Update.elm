module Online.Update exposing (update)

import Json.Decode as JD exposing ((:=))
import Json.Encode as JE
import Phoenix.Socket
import Phoenix.Channel
import Online.Types exposing (..)
import Online.Model exposing (Model)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case Debug.log "update:" msg of
        InitApplication content ->
            doInitApplication content model

        DidJoinChannel ->
            ( { model | status = "connected" }, Cmd.none )

        DidLeaveChannel ->
            ( { model | status = "disconnected" }, Cmd.none )

        PhoenixMsg phxMsg ->
            doHandlePhoenixMsg phxMsg model

        ReceiveChatMessage raw ->
            doProcessMessageReceived raw model

        HandlePresenceState raw ->
            doProcessPresenceState raw model

        HandlePresenceDiff raw ->
            doProcessPresenceDiff raw model


doInitApplication : ApplicationConfig -> Model -> ( Model, Cmd Msg )
doInitApplication content model =
    let
        newConfig =
            ApplicationConfig content.chatter_id content.nickname content.phone_number

        channel =
            Phoenix.Channel.init "discussion:hall"
                |> Phoenix.Channel.withPayload (userParams newConfig)
                |> Phoenix.Channel.onJoin (always <| DidJoinChannel)
                |> Phoenix.Channel.onClose (always <| DidLeaveChannel)

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


doProcessMessageReceived : JE.Value -> Model -> ( Model, Cmd Msg )
doProcessMessageReceived raw model =
    case JD.decodeValue chatMessageDecoder raw of
        Ok content ->
            ( { model | latestMessage = content.body }
            , Cmd.none
            )

        Err error ->
            ( model, Cmd.none )


doProcessPresenceState : JE.Value -> Model -> ( Model, Cmd Msg )
doProcessPresenceState raw model =
    case JD.decodeValue presenceStateDecoder raw of
        Ok presenceState ->
            let
                _ =
                    Debug.log "PRESENCE STATE:" presenceState
            in
                model ! []

        Err error ->
            let
                _ =
                    Debug.log "ERROR(STATE):" error
            in
                model ! []


doProcessPresenceDiff : JE.Value -> Model -> ( Model, Cmd Msg )
doProcessPresenceDiff raw model =
    case JD.decodeValue presenceDiffDecoder raw of
        Ok presenceDiff ->
            let
                _ =
                    Debug.log "PRESENCE_DIFF" presenceDiff
            in
                model ! []

        Err error ->
            let
                _ =
                    Debug.log "Error(DIFF)" error
            in
                model ! []


userParams : ApplicationConfig -> JE.Value
userParams config =
    JE.object
        [ ( "chatter_id", JE.int config.chatter_id )
        , ( "nickname", JE.string config.nickname )
        , ( "phone_number", JE.string config.phone_number )
        ]


type alias ChatMessage =
    { user : String
    , body : String
    }


chatMessageDecoder : JD.Decoder ChatMessage
chatMessageDecoder =
    JD.object2 ChatMessage
        ("user" := JD.string)
        ("body" := JD.string)


presenceDiffDecoder : JD.Decoder PresenceDiff
presenceDiffDecoder =
    JD.object2 PresenceDiff
        ("leaves" := presenceStateDecoder)
        ("joins" := presenceStateDecoder)


presenceStateDecoder : JD.Decoder PresenceState
presenceStateDecoder =
    JD.dict presenceStateMetaWrapperDecoder


presenceStateMetaWrapperDecoder : JD.Decoder PresenceStateMetaWrapper
presenceStateMetaWrapperDecoder =
    JD.object1 PresenceStateMetaWrapper
        ("metas" := JD.list presenceStateMetaDecoder)


presenceStateMetaDecoder : JD.Decoder PresenceStateMetaValue
presenceStateMetaDecoder =
    JD.object4 PresenceStateMetaValue
        ("phx_ref" := JD.string)
        ("online_at" := JD.string)
        ("nickname" := JD.string)
        ("phone_number" := JD.string)

port module Online.App exposing (initialModel, update, subscriptions, view)

import Html exposing (Html, div, text, h2, p, dl, dt, dd)
import Html.Attributes exposing (class)
import Json.Encode as JE
import Json.Decode as JD exposing ((:=))
import Dict exposing (Dict)
import Phoenix.Socket
import Phoenix.Channel


-- MODEL


type alias Model =
    { socket : Phoenix.Socket.Socket Msg
    , status : String
    , latestMessage : String
    , presences : PresenceState
    , config : ApplicationConfig
    }


type alias PresenceState =
    Dict String PresenceStateMetaWrapper


type alias PresenceStateMetaWrapper =
    { metas : List PresenceStateMetaValue }


type alias PresenceStateMetaValue =
    { phx_ref : String
    , online_at : String
    , device : String
    }


type alias PresenceDiff =
    { leaves : PresenceState
    , joins : PresenceState
    }


socketServer : String
socketServer =
    "ws://localhost:4000/socket/websocket"


initSocket : Phoenix.Socket.Socket Msg
initSocket =
    Phoenix.Socket.init socketServer
        |> Phoenix.Socket.withDebug
        |> Phoenix.Socket.on "welcome" "subject:lobby" ReceiveChatMessage
        |> Phoenix.Socket.on "presence_state" "subject:lobby" HandlePresenceState
        |> Phoenix.Socket.on "presence_diff" "subject:lobby" HandlePresenceDiff


initialModel : Model
initialModel =
    { socket = initSocket
    , status = "disconnected"
    , latestMessage = ""
    , presences = Dict.empty
    , config = ApplicationConfig 0 "n/a" "n/a"
    }


type alias ApplicationConfig =
    { chatter_id : Int
    , nickname : String
    , phone_number : String
    }



-- UPDATE


type Msg
    = InitApplication ApplicationConfig
    | PhoenixMsg (Phoenix.Socket.Msg Msg)
    | DidJoinChannel
    | DidLeaveChannel
    | ReceiveChatMessage JE.Value
    | HandlePresenceState JE.Value
    | HandlePresenceDiff JE.Value


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        InitApplication content ->
            let
                newConfig =
                    ApplicationConfig content.chatter_id content.nickname content.phone_number

                channel =
                    Phoenix.Channel.init "subject:lobby"
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

        DidJoinChannel ->
            ( { model | status = "connected" }, Cmd.none )

        DidLeaveChannel ->
            ( { model | status = "disconnected" }, Cmd.none )

        PhoenixMsg msg ->
            let
                ( phxSocket, phxCmd ) =
                    Phoenix.Socket.update msg model.socket
            in
                ( { model | socket = phxSocket }
                , Cmd.map PhoenixMsg phxCmd
                )

        ReceiveChatMessage raw ->
            case JD.decodeValue chatMessageDecoder raw of
                Ok content ->
                    ( { model | latestMessage = content.body }
                    , Cmd.none
                    )

                Err error ->
                    ( model, Cmd.none )

        HandlePresenceState raw ->
            case JD.decodeValue presenceStateDecoder raw of
                Ok presenceState ->
                    let
                        _ =
                            Debug.log "PresenceState" presenceState
                    in
                        model ! []

                Err error ->
                    let
                        _ =
                            Debug.log "Error" error
                    in
                        model ! []

        HandlePresenceDiff raw ->
            case JD.decodeValue presenceDiffDecoder raw of
                Ok presenceDiff ->
                    let
                        _ =
                            Debug.log "PresenceDiff" presenceDiff
                    in
                        model ! []

                Err error ->
                    let
                        _ =
                            Debug.log "Error" error
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
    JD.object3 PresenceStateMetaValue
        ("phx_ref" := JD.string)
        ("online_at" := JD.string)
        ("device" := JD.string)



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Phoenix.Socket.listen model.socket PhoenixMsg
        , initApplication InitApplication
        ]


port initApplication : (ApplicationConfig -> msg) -> Sub msg



-- VIEW


view : Model -> Html Msg
view model =
    div []
        [ h2 []
            [ text "Online.elm" ]
        , dl []
            [ dt [] [ text "status" ]
            , dd [] [ text model.status ]
            ]
        , dl []
            [ dt [] [ text "latestMessage" ]
            , dd [] [ text model.latestMessage ]
            ]
        , dl []
            [ dt [] [ text "nickname" ]
            , dd [] [ text model.config.nickname ]
            ]
        , dl []
            [ dt [] [ text "phone_number" ]
            , dd [] [ text model.config.phone_number ]
            ]
        , p []
            [ text "TODO: Implement in Elm now \x1F913!" ]
        ]

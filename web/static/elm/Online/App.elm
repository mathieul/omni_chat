module Online.App exposing (initialModel, update, subscriptions, view)

import Html exposing (Html, div, text, h2, p, button)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)
import Json.Encode as JE
import Json.Decode as JD exposing ((:=))
import Phoenix.Socket
import Phoenix.Channel


-- import Phoenix.Push


type alias Model =
    { socket : Phoenix.Socket.Socket Msg
    , status : String
    , latestMessage : String
    }


socketServer : String
socketServer =
    "ws://localhost:4000/socket/websocket"


initSocket : Phoenix.Socket.Socket Msg
initSocket =
    Phoenix.Socket.init socketServer
        |> Phoenix.Socket.withDebug
        |> Phoenix.Socket.on "welcome" "subject:lobby" ReceiveChatMessage


initialModel : Model
initialModel =
    { socket = initSocket
    , status = "disconnected"
    , latestMessage = ""
    }


type Msg
    = NoOp
    | PhoenixMsg (Phoenix.Socket.Msg Msg)
    | JoinChannel
    | DidJoinChannel
    | DidLeaveChannel
    | ReceiveChatMessage JE.Value


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        PhoenixMsg msg ->
            let
                ( phxSocket, phxCmd ) =
                    Phoenix.Socket.update msg model.socket
            in
                ( { model | socket = phxSocket }
                , Cmd.map PhoenixMsg phxCmd
                )

        JoinChannel ->
            let
                channel =
                    Phoenix.Channel.init "subject:lobby"
                        |> Phoenix.Channel.withPayload userParams
                        |> Phoenix.Channel.onJoin (always <| DidJoinChannel)
                        |> Phoenix.Channel.onClose (always <| DidLeaveChannel)

                ( phxSocket, phxCmd ) =
                    Phoenix.Socket.join channel model.socket
            in
                ( { model | socket = phxSocket }
                , Cmd.map PhoenixMsg phxCmd
                )

        DidJoinChannel ->
            ( { model | status = "connected" }, Cmd.none )

        DidLeaveChannel ->
            ( { model | status = "disconnected" }, Cmd.none )

        ReceiveChatMessage raw ->
            case JD.decodeValue chatMessageDecoder raw of
                Ok content ->
                    ( { model | latestMessage = content.body }
                    , Cmd.none
                    )

                Err error ->
                    ( model, Cmd.none )


userParams : JE.Value
userParams =
    JE.object
        [ ( "user_id", JE.string "42" ) ]


type alias ChatMessage =
    { user : String
    , body : String
    }


chatMessageDecoder : JD.Decoder ChatMessage
chatMessageDecoder =
    JD.object2 ChatMessage
        ("user" := JD.string)
        ("body" := JD.string)


subscriptions : Model -> Sub Msg
subscriptions model =
    Phoenix.Socket.listen model.socket PhoenixMsg


view : Model -> Html Msg
view model =
    div []
        [ h2 []
            [ text "Online.elm" ]
        , p [ class "lead" ]
            [ text <| "status = " ++ model.status ]
        , p [ class "lead" ]
            [ text <| "latestMessage = " ++ model.latestMessage ]
        , p []
            [ text "TODO: implement in Elm now \x1F913!" ]
        , button
            [ class "btn btn-primary", onClick JoinChannel ]
            [ text "Join Channel" ]
        ]

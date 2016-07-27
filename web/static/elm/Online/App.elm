port module Online.App exposing (initialModel, update, subscriptions, view)

import Html exposing (Html, div, text, h2, p)
import Html.Attributes exposing (class)
import Json.Encode as JE
import Json.Decode as JD exposing ((:=))
import Phoenix.Socket
import Phoenix.Channel


-- MODEL


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



-- UPDATE


type Msg
    = InitApplication String
    | PhoenixMsg (Phoenix.Socket.Msg Msg)
    | DidJoinChannel
    | DidLeaveChannel
    | ReceiveChatMessage JE.Value


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        InitApplication content ->
            let
                _ =
                    Debug.log "InitApplication message:" content

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



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Phoenix.Socket.listen model.socket PhoenixMsg
        , initApplication InitApplication
        ]


port initApplication : (String -> msg) -> Sub msg



-- VIEW


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
        ]

port module Online exposing (main)

import String
import Dict exposing (Dict)
import Navigation
import Phoenix.Socket exposing (listen)
import Online.Types exposing (Model, Msg(..), Route, AppConfig)
import Online.Update exposing (update)
import Online.Views.Main exposing (view)
import Online.Routing as Routing
import Online.Backend as Backend
import Components.DiscussionEditor as DiscussionEditor


main : Program ConfigFromJs
main =
    Navigation.programWithFlags Routing.parser
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        , urlUpdate = urlUpdate
        }


init : ConfigFromJs -> Result String Route -> ( Model, Cmd Msg )
init rawConfig result =
    let
        currentRoute =
            Routing.routeFromResult result
    in
        ( initialModel rawConfig currentRoute, Cmd.none )


urlUpdate : Result String Route -> Model -> ( Model, Cmd Msg )
urlUpdate result model =
    let
        currentRoute =
            Routing.routeFromResult result
    in
        ( { model | route = currentRoute }, Cmd.none )



-- MODEL


type alias ConfigFromJs =
    { chatter_id : String
    , nickname : String
    , max_messages : String
    , maybe_discussion_id : String
    , socket_server : String
    }


initialAppConfig : ConfigFromJs -> AppConfig
initialAppConfig rawConfig =
    { chatterId = Result.withDefault 0 (String.toInt rawConfig.chatter_id)
    , nickname = rawConfig.nickname
    , maxMessages = Result.withDefault 1 (String.toInt rawConfig.max_messages)
    , discussionId = Result.toMaybe (String.toInt rawConfig.maybe_discussion_id)
    , socketServer = rawConfig.socket_server
    }


initialModel : ConfigFromJs -> Route -> Model
initialModel rawConfig route =
    { socket = Backend.initSocket rawConfig.socket_server
    , connected = False
    , presences = Dict.empty
    , discussions = []
    , discussionId = Nothing
    , messages = []
    , config = initialAppConfig rawConfig
    , route = route
    , discussionEditorModel = DiscussionEditor.initialModel
    , currentMessage = ""
    }



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ listen model.socket PhoenixMsg
        , initApplication (always InitApplication)
        ]


port initApplication : (() -> msg) -> Sub msg

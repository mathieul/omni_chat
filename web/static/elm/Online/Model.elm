module Online.Model exposing (ConfigFromJs, init)

import String
import Dict exposing (Dict)
import Online.Types exposing (Model, Msg, Route, AppConfig)
import Online.Routing as Routing
import Online.Backend as Backend


type alias ConfigFromJs =
    { chatter_id : String
    , nickname : String
    , max_messages : String
    , maybe_discussion_id : String
    , socket_server : String
    }


init : ConfigFromJs -> Result String Route -> ( Model, Cmd Msg )
init rawConfig result =
    let
        currentRoute =
            Routing.routeFromResult result
    in
        ( initialModel rawConfig currentRoute, Cmd.none )


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
    , currentMessage = ""
    , editingDiscussion = False
    , discussionSubject = ""
    }

port module Online exposing (main)

import Dict exposing (Dict)
import Navigation
import Phoenix.Socket exposing (listen)
import Online.Types exposing (Model, Msg(..), Route, AppConfig)
import Online.Update exposing (update)
import Online.View exposing (view)
import Online.Routing as Routing
import Online.Backend as Backend
import Components.DiscussionEditor as DiscussionEditor


main : Program Never
main =
    Navigation.program Routing.parser
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        , urlUpdate = urlUpdate
        }


init : Result String Route -> ( Model, Cmd Msg )
init result =
    let
        currentRoute =
            Routing.routeFromResult result
    in
        ( initialModel currentRoute, Cmd.none )


urlUpdate : Result String Route -> Model -> ( Model, Cmd Msg )
urlUpdate result model =
    let
        currentRoute =
            Routing.routeFromResult result
    in
        ( { model | route = currentRoute }, Cmd.none )



-- MODEL


initialModel : Route -> Model
initialModel route =
    { socket = Backend.initSocket
    , connected = False
    , presences = Dict.empty
    , discussions = []
    , discussionId = Nothing
    , messages = []
    , config = AppConfig 0 "n/a" 1 Nothing
    , route = route
    , discussionEditorModel = DiscussionEditor.initialModel
    , currentMessage = ""
    }



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ listen model.socket PhoenixMsg
        , initApplication InitApplication
        ]


port initApplication : (AppConfig -> msg) -> Sub msg

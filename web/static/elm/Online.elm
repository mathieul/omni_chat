port module Online exposing (main)

import Navigation
import Online.Types exposing (Model, Msg, Route, AppConfig)
import Online.Model exposing (ConfigFromJs, init)
import Online.Update exposing (update)
import Online.Subscriptions exposing (subscriptions)
import Online.Views.Main exposing (view)
import Online.Routing as Routing


main : Program ConfigFromJs
main =
    Navigation.programWithFlags Routing.parser
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        , urlUpdate = urlUpdate
        }


urlUpdate : Result String Route -> Model -> ( Model, Cmd Msg )
urlUpdate result model =
    let
        currentRoute =
            Routing.routeFromResult result
    in
        ( { model | route = currentRoute }, Cmd.none )

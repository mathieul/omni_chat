module Online exposing (..)

import Navigation
import Online.Types exposing (Msg)
import Online.Model exposing (Model, initialModel, subscriptions)
import Online.Update exposing (update)
import Online.View exposing (view)
import Online.Routing as Routing exposing (Route)


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
        { model | route = currentRoute, scrolled = False } ! []

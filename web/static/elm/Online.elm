module Online exposing (..)

import Html.App as App
import Online.Model exposing (initialModel, subscriptions)
import Online.Update exposing (update)
import Online.View exposing (view)


main : Program Never
main =
    App.program
        { init = ( initialModel, Cmd.none )
        , update = update
        , subscriptions = subscriptions
        , view = view
        }

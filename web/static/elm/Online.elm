module Online exposing (..)

import Html.App as Html
import Online.App exposing (initialModel, subscriptions)
import Online.Update exposing (update)
import Online.View exposing (view)


main : Program Never
main =
    Html.program
        { init = ( initialModel, Cmd.none )
        , update = update
        , subscriptions = subscriptions
        , view = view
        }

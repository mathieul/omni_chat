module Online exposing (..)

import Html.App as Html
import Online.App exposing (..)


main : Program Never
main =
    Html.program
        { init = ( initialModel, Cmd.none )
        , update = update
        , subscriptions = subscriptions
        , view = view
        }

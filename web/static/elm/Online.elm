port module Online exposing (main)

import Navigation
import Online.Types exposing (Model, Msg(UrlChange), Route, AppConfig)
import Online.Model exposing (ConfigFromJs, init)
import Online.Update exposing (update)
import Online.Subscriptions exposing (subscriptions)
import Online.Views.Main exposing (view)


main : Program ConfigFromJs Model Msg
main =
    Navigation.programWithFlags UrlChange
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }

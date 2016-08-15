port module Online.Subscriptions exposing (subscriptions)

import Phoenix.Socket exposing (listen)
import Online.Types exposing (Model, Msg(PhoenixMsg, InitApplication))


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ listen model.socket PhoenixMsg
        , initApplication (always InitApplication)
        ]


port initApplication : (() -> msg) -> Sub msg

module Online.View exposing (view)

import Html exposing (Html, div, text, h2, p, dl, dt, dd)
import Html.Attributes exposing (class)
import Dict
import String
import Online.Types exposing (..)
import Online.Model exposing (Model)


view : Model -> Html Msg
view model =
    div [ class "container" ]
        [ h2 []
            [ text "Online.elm" ]
        , div []
            (List.map keyValuePair
                [ ( "status", model.status )
                , ( "nickname", model.config.nickname )
                , ( "present", presentNicknames model.presences )
                , ( "discussions", toString model.discussions )
                ]
            )
        ]


keyValuePair : ( String, String ) -> Html Msg
keyValuePair ( key, value ) =
    dl []
        [ dt [] [ text key ]
        , dd [] [ text value ]
        ]


presentNicknames : PresenceState -> String
presentNicknames presences =
    presences
        |> Dict.values
        |> List.map
            (\wrapper ->
                case List.head wrapper.metas of
                    Just value ->
                        value.nickname

                    Nothing ->
                        "missing"
            )
        |> String.join ", "

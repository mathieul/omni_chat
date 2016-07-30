module Online.View exposing (view)

import Html exposing (Html, div, text, h2, p, dl, dt, dd)
import Html.Attributes exposing (class)
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
                , ( "latestMessage", model.latestMessage )
                , ( "nickname", model.config.nickname )
                , ( "phone_number", model.config.phone_number )
                ]
            )
        ]


keyValuePair : ( String, String ) -> Html Msg
keyValuePair ( key, value ) =
    dl []
        [ dt [] [ text key ]
        , dd [] [ text value ]
        ]

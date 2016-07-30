module Online.View exposing (view)

import Html exposing (Html, div, text, h3, p, dl, dt, dd, a, ul, li)
import Html.Attributes exposing (class, href)
import Dict
import String
import Online.Types exposing (..)
import Online.Model exposing (Model)


view : Model -> Html Msg
view model =
    div [ class "container" ]
        [ div
            [ class "card-columns" ]
            (List.map discussionCardView model.discussions)
        ]


discussionCardView : Discussion -> Html Msg
discussionCardView discussion =
    div [ class "card" ]
        [ div [ class "card-block" ]
            [ h3
                [ class "card-title text-xs-center" ]
                [ text discussion.subject ]
            , div [ class "row m-t-2" ]
                [ div [ class "col-xs-6" ]
                    [ ul
                        [ class "list-group" ]
                        (List.map participantLine discussion.participants)
                    ]
                , div [ class "col-xs-6" ]
                    [ a
                        [ href "", class "btn btn-success btn-block" ]
                        [ text "Join" ]
                    ]
                ]
            ]
        , div [ class "card-footer text-muted" ]
            [ text discussion.last_activity_at ]
        ]


participantLine : Participant -> Html Msg
participantLine participant =
    li [ class "list-group-item" ] [ text participant.nickname ]



-- Debug


viewDebug : Model -> Html Msg
viewDebug model =
    div [ class "container" ]
        [ h3 []
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

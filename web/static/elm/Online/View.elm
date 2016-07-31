module Online.View exposing (view)

import Html.App as App
import Html exposing (Html, div, header, text, i, h4, p, dl, dt, dd, a, ul, li)
import Html.Attributes exposing (class, classList, href)
import Dict
import String
import Online.Types exposing (..)
import Online.Model exposing (Model)
import Components.DiscussionEditor as DiscussionEditor


view : Model -> Html Msg
view model =
    let
        discussionEditorView =
            DiscussionEditor.view model.discussionEditorModel
                |> App.map DiscussionEditorMsg

        discussionsView =
            List.map discussionCardView model.discussions
    in
        div []
            [ topBar model
            , div [ class "container with-fixed-top-navbar" ]
                [ div
                    [ class "card-columns" ]
                    (discussionEditorView :: discussionsView)
                ]
            ]


topBar : Model -> Html Msg
topBar model =
    header
        [ class "navbar navbar-fixed-top navbar-dark bg-primary" ]
        [ div
            [ class "nav navbar-nav" ]
            [ div [ class "navbar-brand" ] [ text model.config.nickname ] ]
        , div
            [ class "nav navbar-nav pull-right" ]
            [ i
                [ classList
                    [ ( "fa", True )
                    , ( "fa-spinner fa-pulse fa-fw", not model.connected )
                    , ( "fa fa-2x fa-wifi", model.connected )
                    ]
                ]
                []
            ]
        ]


discussionCardView : Discussion -> Html Msg
discussionCardView discussion =
    div [ class "card" ]
        [ div [ class "card-block" ]
            [ h4
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
        [ h4 []
            [ text "Online.elm" ]
        , div []
            (List.map keyValuePair
                [ ( "connected", toString model.connected )
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

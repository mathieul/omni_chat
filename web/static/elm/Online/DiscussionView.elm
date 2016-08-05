module Online.DiscussionView exposing (view)

import Html.App as App
import Html exposing (Html, div, header, text, i, h4, p, dl, dt, dd, ul, li, button)
import Html.Attributes exposing (class, classList, type')
import Html.Events exposing (onClick)
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
    let
        noParticipants =
            List.length discussion.participants == 0
    in
        div
            [ classList
                [ ( "card", True )
                , ( "card-warning", noParticipants )
                ]
            ]
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
                        [ button
                            [ type' "button"
                            , class "btn btn-success btn-block"
                            , onClick (ShowDiscussion discussion.id)
                            ]
                            [ text "Join" ]
                        ]
                    ]
                ]
            , div [ class "card-footer text-muted" ]
                [ text discussion.last_activity ]
            ]


participantLine : Participant -> Html Msg
participantLine participant =
    li [ class "list-group-item" ] [ text participant.nickname ]

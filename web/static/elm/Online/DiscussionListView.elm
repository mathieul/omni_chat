module Online.DiscussionListView exposing (view)

import Html.App as App
import Html exposing (Html, div, header, text, h4, p, dl, dt, dd, ul, li, button, i)
import Html.Attributes exposing (class, classList, type')
import Html.Events exposing (onClick)
import Online.Types exposing (..)
import Online.Model exposing (Model)
import Online.TopBarView as TopBarView
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
        div [ class "container with-fixed-top-navbar" ]
            [ TopBarView.view model { title = model.config.nickname, back = Nothing }
            , div
                [ class "card-columns" ]
                (discussionEditorView :: discussionsView)
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

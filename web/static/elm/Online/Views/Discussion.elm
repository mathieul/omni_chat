module Online.Views.Discussion exposing (view)

import Date exposing (Date)
import Date.Format as DF
import Html exposing (Html, div, text, form, input, button, strong, br)
import Html.Attributes exposing (class, type', style, id, value, autofocus, title)
import Html.Events exposing (onSubmit, onInput)
import Online.Types exposing (..)
import Online.Views.TopBar as TopBarView


view : Discussion -> Model -> Html Msg
view discussion model =
    div [ class "container with-fixed-top-navbar" ]
        [ TopBarView.view model
            { title = discussion.subject
            , back = Just ShowDiscussionList
            }
        , messageListView model
        , editor model
        ]


messageListView : Model -> Html Msg
messageListView model =
    div [ id "discussion-messages" ]
        (List.map (messageView model.config.chatterId) model.messages)


messageView : ChatterId -> DiscussionMessage -> Html Msg
messageView chatterId message =
    let
        messageDate =
            DF.format "%m/%d/%Y %I:%M%P" message.insertedAt
    in
        if message.chatter.id == chatterId then
            myMessage message.content messageDate
        else
            theirMessage message.chatter.nickname message.content messageDate


myMessage : String -> String -> Html Msg
myMessage content messageDate =
    div [ class "row" ]
        [ div [ class "col-xs-10 col-xs-offset-2" ]
            [ div
                [ class "message mine pull-xs-right"
                , title messageDate
                ]
                [ text content
                  -- , br [] []
                  -- , div [ class "tag tag-pill tag-success" ] [ text messageDate ]
                ]
            ]
        ]


theirMessage : String -> String -> String -> Html Msg
theirMessage nickname content messageDate =
    div [ class "row" ]
        [ div [ class "col-xs-10" ]
            [ div
                [ class "message theirs pull-xs-left"
                , title messageDate
                ]
                [ strong [ style [ ( "margin-right", ".5rem" ) ] ] [ text nickname ]
                , text content
                  -- , br [] []
                  -- , div [ class "tag tag-pill tag-default" ] [ text messageDate ]
                ]
            ]
        ]


editor : Model -> Html Msg
editor model =
    div [ class "navbar navbar-fixed-bottom navbar-light bg-faded" ]
        [ form [ onSubmit (SendMessage) ]
            [ div [ class "row" ]
                [ div [ class "col-xs-8", style [ ( "padding-right", "0" ) ] ]
                    [ input
                        [ type' "text"
                        , class "form-control"
                        , value model.currentMessage
                        , autofocus True
                        , onInput UpdateCurrentMessage
                        ]
                        []
                    ]
                , div [ class "col-xs-4" ]
                    [ button [ class "btn btn-primary btn-block" ]
                        [ text "Send" ]
                    ]
                ]
            ]
        ]

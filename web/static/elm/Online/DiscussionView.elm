module Online.DiscussionView exposing (view)

import Html exposing (Html, div, text, form, input, button, strong)
import Html.Attributes exposing (class, type', style, id, value, autofocus)
import Html.Events exposing (onSubmit)
import Online.Types exposing (..)
import Online.TopBarView as TopBarView


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
        (List.map (messageView model.config.chatter_id) model.messages)


messageView : ChatterId -> DiscussionMessage -> Html Msg
messageView chatterId message =
    if message.chatter.id == chatterId then
        myMessage message.content
    else
        theirMessage message.chatter.nickname message.content


myMessage : String -> Html Msg
myMessage content =
    div [ class "row" ]
        [ div [ class "col-xs-10 col-xs-offset-2" ]
            [ div [ class "message mine pull-xs-right" ]
                [ text content ]
            ]
        ]


theirMessage : String -> String -> Html Msg
theirMessage nickname content =
    div [ class "row" ]
        [ div [ class "col-xs-10" ]
            [ div [ class "message theirs pull-xs-left" ]
                [ strong [ style [ ( "margin-right", ".5rem" ) ] ] [ text nickname ]
                , text content
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

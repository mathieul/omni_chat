module Online.DiscussionView exposing (view)

import Html exposing (Html, div, text, form, input, button, strong)
import Html.Attributes exposing (class, type', style, id)
import Html.Events exposing (onSubmit)
import Online.Types exposing (..)
import Online.Model exposing (Model)
import Online.TopBarView as TopBarView


view : Discussion -> Model -> Html Msg
view discussion model =
    div [ class "container with-fixed-top-navbar" ]
        [ TopBarView.view model
            { title = discussion.subject
            , back = Just ShowDiscussions
            }
        , messages model
        , editor model
        ]


messages : Model -> Html Msg
messages model =
    div [ id "discussion-messages" ]
        [ myMessage "Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor"
        , theirMessage "fifi" "Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."
        , theirMessage "fifi" "sunt in culpa qui officia deserunt mollit anim id est laborum."
        , theirMessage "zhannulia" "cupidatat non proident"
        , myMessage "Esse cillum dolore eu fugiat nulla pariatur."
        , myMessage "Ok..."
        , theirMessage "riri" "I don't want to!"
        , myMessage "I figured"
        ]


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
        [ form [ onSubmit ShowDiscussions ]
            [ div [ class "row" ]
                [ div [ class "col-xs-8", style [ ( "padding-right", "0" ) ] ]
                    [ input
                        [ type' "text"
                        , class "form-control"
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

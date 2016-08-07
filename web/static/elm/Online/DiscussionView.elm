module Online.DiscussionView exposing (view)

import Html exposing (Html, div, text, button)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)
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
        , div [] [ text <| "DISCUSSION ROUTE ID=" ++ (toString discussion.id) ]
        , button
            [ class "btn btn-alternate"
            , onClick ShowDiscussions
            ]
            [ text "Back to all discussions" ]
        ]

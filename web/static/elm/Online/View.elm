module Online.View exposing (view)

import Html exposing (Html, div, text, button)
import Html.Attributes exposing (type', class)
import Html.Events exposing (onClick)
import Online.DiscussionView as DiscussionView
import Online.Types exposing (Msg(..))
import Online.Model exposing (Model)
import Online.Routing as Routing exposing (Route(..))


view : Model -> Html Msg
view model =
    case model.route of
        DiscussionsRoute ->
            DiscussionView.view model

        DiscussionRoute discussionId ->
            div [ class "container" ]
                [ div [] [ text <| "DISCUSSION ROUTE ID=" ++ (toString discussionId) ]
                , button
                    [ class "btn btn-alternate"
                    , onClick ShowDiscussions
                    ]
                    [ text "Back to all discussions" ]
                ]

        NotFoundRoute ->
            div [] [ text "NOT FOUND ROUTE" ]

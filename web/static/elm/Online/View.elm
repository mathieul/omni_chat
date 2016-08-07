module Online.View exposing (view)

import List.Extra
import Html exposing (Html, div, text, button, header, i)
import Online.DiscussionListView as DiscussionListView
import Online.DiscussionView as DiscussionView
import Online.Types exposing (Msg(..))
import Online.Model exposing (Model)
import Online.Routing as Routing exposing (Route(..))


view : Model -> Html Msg
view model =
    case model.route of
        DiscussionsRoute ->
            DiscussionListView.view model

        DiscussionRoute discussionId ->
            let
                discussionFromId =
                    List.Extra.find (\item -> item.id == discussionId) model.discussions
            in
                case discussionFromId of
                    Just discussion ->
                        DiscussionView.view discussion model

                    Nothing ->
                        notFoundView

        NotFoundRoute ->
            notFoundView


notFoundView : Html msg
notFoundView =
    div [] [ text "NOT FOUND ROUTE" ]

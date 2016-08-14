module Online.View exposing (view)

import List.Extra
import Html exposing (Html, div, text, button, header, i)
import Html.Attributes exposing (class)
import Online.DiscussionListView as DiscussionListView
import Online.DiscussionView as DiscussionView
import Online.Types exposing (Model, Msg(..), Route(..))
import Online.TopBarView as TopBarView


view : Model -> Html Msg
view model =
    case model.route of
        DiscussionListRoute ->
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
                        loadingView model

        NotFoundRoute ->
            notFoundView


loadingView : Model -> Html Msg
loadingView model =
    div [ class "container with-fixed-top-navbar" ]
        [ TopBarView.view model { title = "Loading...", back = Nothing } ]


notFoundView : Html msg
notFoundView =
    div [] [ text "NOT FOUND ROUTE" ]

module Components.DiscussionEditor
    exposing
        ( Model
        , Msg
        , initialModel
        , update
        , view
        )

import Html exposing (Html, text, div, a, i, h4)
import Html.Attributes exposing (class, href)


type alias Model =
    {}


initialModel : Model
initialModel =
    {}


type Msg
    = NoOp


update : Msg -> Model -> Model
update msg model =
    case msg of
        NoOp ->
            model


view : Model -> Html Msg
view model =
    div [] [ cardView ]


cardView : Html Msg
cardView =
    div [ class "card" ]
        [ div [ class "card-block text-xs-center" ]
            [ h4
                [ class "card-title text-muted" ]
                [ text "New Discussion" ]
            , a
                [ href "", class "btn btn-lg btn-warning m-y-1" ]
                [ i [ class "fa fa-plus" ] [] ]
            ]
        , div [ class "card-footer text-muted" ]
            [ text "start new discussion" ]
        ]

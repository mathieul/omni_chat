module Components.DiscussionEditor
    exposing
        ( Model
        , Msg
        , initialModel
        , update
        , view
        )

import Html exposing (Html, div, text)


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
    div [] [ text "Discussion Editor" ]

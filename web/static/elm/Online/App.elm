module Online.App exposing (initialModel, update, subscriptions, view)

import Html exposing (Html, div, text, h2, p)
import Html.Attributes exposing (class)


type alias Model =
    {}


type Msg
    = NoOp


initialModel : Model
initialModel =
    {}


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


view : Model -> Html Msg
view model =
    div []
        [ h2 []
            [ text "Online.elm" ]
        , p [ class "lead" ]
            [ text "TODO: implement in Elm now \x1F913" ]
        ]

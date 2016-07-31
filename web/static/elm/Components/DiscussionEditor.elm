module Components.DiscussionEditor
    exposing
        ( Model
        , Msg
        , initialModel
        , update
        , view
        )

import Html exposing (Html, text, div, a, i, h4, button)
import Html.Attributes exposing (class, href, type')
import Html.Events exposing (onClick)


type alias Model =
    { editing : Bool
    }


initialModel : Model
initialModel =
    { editing = False
    }


type Msg
    = NoOp
    | StartEditing
    | StopEditing


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            model ! []

        StartEditing ->
            { model | editing = True } ! []

        StopEditing ->
            { model | editing = False } ! []


view : Model -> Html Msg
view model =
    div []
        [ if model.editing then
            formView model
          else
            choiceView
        ]


choiceView : Html Msg
choiceView =
    div [ class "card" ]
        [ div [ class "card-block text-xs-center" ]
            [ h4
                [ class "card-title text-muted" ]
                [ text "New Discussion" ]
            , button
                [ type' "button"
                , class "btn btn-lg btn-warning m-y-1"
                , onClick StartEditing
                ]
                [ i [ class "fa fa-plus" ] [] ]
            ]
        , div [ class "card-footer text-muted" ]
            [ text "start new discussion" ]
        ]


formView : Model -> Html Msg
formView model =
    div [ class "card" ]
        [ div [ class "card-block text-xs-center" ]
            [ h4
                [ class "card-title text-muted" ]
                [ text "TODO" ]
            , button
                [ type' "button"
                , class "btn btn-lg btn-secondary "
                , onClick StopEditing
                ]
                [ text "Cancel" ]
            ]
        , div [ class "card-footer text-muted" ]
            [ text "start new discussion" ]
        ]

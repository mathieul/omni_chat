module Components.DiscussionEditor
    exposing
        ( Model
        , Msg
        , initialModel
        , update
        , view
        )

import Html exposing (Html, text, div, a, i, h4, button, form, input)
import Html.Attributes exposing (class, href, type', placeholder, autofocus)
import Html.Events exposing (onClick, onInput)


type alias Model =
    { editing : Bool
    , subject : String
    }


initialModel : Model
initialModel =
    { editing = False
    , subject = ""
    }


type Msg
    = NoOp
    | StartEditing
    | StopEditing
    | UpdateSubject String
    | CreateDiscussion String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            model ! []

        StartEditing ->
            { model | editing = True } ! []

        StopEditing ->
            { model | editing = False } ! []

        UpdateSubject subject ->
            { model | subject = subject } ! []

        CreateDiscussion subject ->
            -- TODO: pass action to parent
            ( { model | subject = "", editing = False }, Cmd.none )


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
                , class "btn btn-lg btn-primary m-y-1"
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
            [ form []
                [ div [ class "form-group" ]
                    [ input
                        [ type' "text"
                        , class "form-control card-title"
                        , placeholder "Enter subject..."
                        , autofocus True
                        , onInput UpdateSubject
                        ]
                        []
                    ]
                ]
            , div [ class "row" ]
                [ div [ class "col-xs-6" ]
                    [ button
                        [ type' "button"
                        , class "btn btn-lg btn-primary btn-block col-xs-5"
                        , onClick <| CreateDiscussion model.subject
                        ]
                        [ text "Create" ]
                    ]
                , div [ class "col-xs-6" ]
                    [ button
                        [ type' "button"
                        , class "btn btn-lg btn-secondary btn-block col-xs-5 offset-xs-1"
                        , onClick StopEditing
                        ]
                        [ text "Cancel" ]
                    ]
                ]
            ]
        , div [ class "card-footer text-muted" ]
            [ text "start new discussion" ]
        ]

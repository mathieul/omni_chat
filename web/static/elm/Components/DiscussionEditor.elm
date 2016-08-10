module Components.DiscussionEditor
    exposing
        ( Model
        , Msg
        , OutMsg(..)
        , initialModel
        , update
        , view
        )

import Html exposing (Html, text, div, a, i, h4, button, form, input)
import Html.Attributes exposing (class, href, type', placeholder, autofocus, required, style)
import Html.Events exposing (onClick, onInput, onSubmit)
import String
import String.Extra


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
    = StartEditing
    | StopEditing
    | UpdateSubject String
    | CreateDiscussion String


type OutMsg
    = DiscussionCreationRequested String


update : Msg -> Model -> ( Model, Cmd Msg, Maybe OutMsg )
update msg model =
    case msg of
        StartEditing ->
            ( { model | editing = True }, Cmd.none, Nothing )

        StopEditing ->
            ( { model | editing = False }, Cmd.none, Nothing )

        UpdateSubject subject ->
            ( { model | subject = subject }, Cmd.none, Nothing )

        CreateDiscussion subject ->
            let
                cleanSubject =
                    subject
                        |> String.trim
                        |> String.toLower
                        |> String.Extra.humanize
            in
                if String.isEmpty cleanSubject then
                    ( model, Cmd.none, Nothing )
                else
                    ( { model
                        | subject = ""
                        , editing = False
                      }
                    , Cmd.none
                    , Just (DiscussionCreationRequested subject)
                    )


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
    div [ class "card card-inverse card-warning" ]
        [ div [ class "card-block text-xs-center" ]
            [ div [ class "row" ]
                [ div [ class "col-xs-8" ]
                    [ h4
                        [ class "card-title"
                        , style [ ( "margin-top", "1.5rem" ) ]
                        ]
                        [ text "New Discussion" ]
                    ]
                , div [ class "col-xs-4" ]
                    [ button
                        [ type' "button"
                        , class "btn btn-lg btn-primary m-y-1"
                        , onClick StartEditing
                        ]
                        [ i [ class "fa fa-plus" ] [] ]
                    ]
                ]
            ]
        ]


formView : Model -> Html Msg
formView model =
    div [ class "card" ]
        [ div [ class "card-block text-xs-center" ]
            [ form [ onSubmit <| CreateDiscussion model.subject ]
                [ div [ class "form-group" ]
                    [ input
                        [ type' "text"
                        , class "form-control card-title"
                        , placeholder "Enter subject..."
                        , required True
                        , autofocus True
                        , onInput UpdateSubject
                        ]
                        []
                    ]
                , div [ class "row" ]
                    [ div [ class "col-xs-6" ]
                        [ button
                            [ type' "submit"
                            , class "btn btn-lg btn-primary btn-block col-xs-5"
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
            ]
        , div [ class "card-footer text-muted" ]
            [ text "start new discussion" ]
        ]

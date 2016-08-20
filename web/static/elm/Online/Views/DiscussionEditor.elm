module Online.Views.DiscussionEditor exposing (view)

import Html exposing (Html, text, div, a, i, h4, button, form, input)
import Html.Attributes exposing (class, id, href, type', placeholder, autofocus, required, style)
import Html.Events exposing (onClick, onInput, onSubmit)
import Online.Types exposing (Model, Msg(..))


view : Model -> Html Msg
view model =
    div []
        [ if model.editingDiscussion then
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
                        , onClick StartEditingDiscussion
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
            [ form [ onSubmit <| CreateDiscussion model.discussionSubject ]
                [ div [ class "form-group" ]
                    [ input
                        [ type' "text"
                        , id "discussion-subject"
                        , class "form-control card-title"
                        , placeholder "Enter subject..."
                        , required True
                        , onInput UpdateDiscussionSubject
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
                            , onClick StopEditingDiscussion
                            ]
                            [ text "Cancel" ]
                        ]
                    ]
                ]
            ]
        , div [ class "card-footer text-muted" ]
            [ text "start new discussion" ]
        ]

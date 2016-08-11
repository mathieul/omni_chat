module Online.TopBarView exposing (view)

import String.Extra
import Json.Decode as Json
import Html exposing (Html, div, header, text, i, a, nav)
import Html.Attributes exposing (class, classList, href)
import Html.Events exposing (onWithOptions, defaultOptions)
import Unicode
import Online.Types exposing (Model, Msg)


type alias Config =
    { title : String
    , back : Maybe Msg
    }


view : Model -> Config -> Html Msg
view model config =
    header
        [ class "navbar navbar-fixed-top navbar-dark bg-primary" ]
        [ backView config.back
        , titleView config.title
        , iconView model.connected
        ]


backView : Maybe Msg -> Html Msg
backView back =
    let
        link =
            case back of
                Just msg ->
                    a
                        [ href ""
                        , class "nav-item nav-link active"
                        , onClickPreventDefault msg
                        ]
                        [ text "< Leave" ]

                Nothing ->
                    a
                        [ href "/sign-out"
                        , class "nav-item nav-link active"
                        ]
                        [ text "Exit" ]
    in
        nav [ class "navbar-nav pull-xs-left" ]
            [ link ]


onClickPreventDefault : msg -> Html.Attribute msg
onClickPreventDefault msg =
    onWithOptions "click" { defaultOptions | preventDefault = True } (Json.succeed msg)


titleView : String -> Html Msg
titleView title =
    nav
        [ class "navbar-nav text-xs-center pull-xs-left title-view"
        ]
        [ title |> String.Extra.ellipsis 20 |> text ]


iconView : Bool -> Html Msg
iconView connected =
    nav [ class "navbar-nav pull-xs-right" ]
        [ i
            [ classList
                [ ( "fa", True )
                , ( "fa-spinner fa-pulse fa-fw", not connected )
                , ( "fa fa-wifi", connected )
                ]
            ]
            []
        ]

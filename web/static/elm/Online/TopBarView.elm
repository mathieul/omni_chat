module Online.TopBarView exposing (view)

import String.Extra
import Json.Decode as Json
import Html exposing (Html, div, header, text, i, a, nav)
import Html.Attributes exposing (class, classList, href)
import Html.Events exposing (onWithOptions, defaultOptions)
import Online.Types exposing (Msg)
import Online.Model exposing (Model)


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
    case back of
        Just msg ->
            nav [ class "navbar-nav pull-xs-left" ]
                [ a
                    [ href ""
                    , class "nav-item nav-link active"
                    , onClickPreventDefault msg
                    ]
                    [ text "< Back" ]
                ]

        Nothing ->
            nav [ class "col-xs-4" ]
                []


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
